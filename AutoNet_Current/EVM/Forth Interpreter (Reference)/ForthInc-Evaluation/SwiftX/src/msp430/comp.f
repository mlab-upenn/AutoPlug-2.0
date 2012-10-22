{ =====================================================================
Resident compiler support

Copyright 2009  FORTH, Inc.

This is the CPU-specific compiler support for MSP430 targets.

Exports: Compiler support, control structures
===================================================================== }

TARGET-SHELL

{ ---------------------------------------------------------------------
Compiler internals

ALIGN forces even alignment, required for MSP430 code fields.
COMPILE, assembles a & JSR opcode to the destination addr.
--------------------------------------------------------------------- }

: ALIGN ( -- )   HERE 1 AND ALLOT ;

TARGET

| : COMPILE, ( addr -- )   $12B0 , , ;

{ --------------------------------------------------------------------
Resident compiler run-time code

These words supply the run-time code for the target's resident
compiler.

Words that transfer control are followed by  <dest> # BR  opcode.
-------------------------------------------------------------------- }

| CODE {CREATE} ( -- addr)
   TPUSH   T POP   RET   END-CODE

| CODE {IF} ( flag -- )
   T TST   TPOP   0= NOT IF   4 # 0 (R) ADD   THEN
   RET   END-CODE

| CODE {DO} ( n1|u1 n2|u2 -- ) ( R: -- addr x1 x2 )
   @R R8 MOV                            \ Get return address
   @S+ R9 MOV   $8000 # R9 XOR          \ Wrap limit n1 around number circle
   R9 PUSH   R9 T SUB   T PUSH          \ Push wrapped n1, index-limit
   TPOP   4 # R8 ADD                    \ Pop new T, skip BR after return
   R8 BR   END-CODE                     \ Branch to new ret addr

| CODE {?DO} ( n1|u1 n2|u2 -- ) ( R: -- addr x1 x2 )
   @R R8 MOV                            \ Get return address
   @S+ R9 MOV   R9 T CMP                \ Compare limits
   0= IF   TPOP   RET   THEN            \ If same, return to BR
   $8000 # R9 XOR   R9 PUSH             \ Push wrapped n1
   R9 T SUB   T PUSH   TPOP             \ Push index-limit, pop new T
   4 # R8 ADD   R8 BR   END-CODE        \ Branch past inline addr

| CODE {LOOP} ( -- )
   R8 POP   0 (R) INC                   \ Pop return addr, increment index-limit
   V # SR BIT   0= NOT IF               \ On overflow, pop loop parameters
   6 # R ADD   4 # R8 ADD   THEN        \ Return past BR
   R8 BR   END-CODE                     \ Otherwise branch back to start of loop

| CODE {+LOOP} ( n -- )
   R8 POP   T 0 (R) ADD   TPOP          \ Pop return addr, add n to index-limit
   V # SR BIT   0= NOT IF               \ On overflow, pop loop parameters
      6 # R ADD   4 # R8 ADD   THEN     \ Return past inline branch addr
   R8 BR   END-CODE                     \ Otherwise branch back to start of loop

| CODE {OF} ( x1 x2 -- x1 | )
   R8 POP   @S T CMP   TPOP
   0= IF   TPOP   4 # R8 ADD   THEN
   R8 BR   END-CODE

{ ---------------------------------------------------------------------
Resident compiler structures

AHEAD, and BACK, assemble forward and backward BR opcodes.
AHEAD, leaves the address at which the destination address will be
patched on the stack.  BACK, takes the destination addr.
!AHEAD  sets forward jump at addr1 to addr2.

J provides the resident compiler's version of J.  To keep the compiler
simple, loops push an additional cell on the stack at run time.
--------------------------------------------------------------------- }

| : AHEAD, ( -- a-addr )   $4030 ,  HERE 0 , ;
| : !AHEAD ( addr1 addr2 -- )   SWAP ! ;
| : BACK, ( a-addr -- )   $4030 , , ;

TARGET-SHELL

: EXIT ( -- )   $4130 , ;  IMMEDIATE
: LITERAL ( n -- )   ['] (LITERAL) COMPILE, , ;  IMMEDIATE

CODE >R ( x -- ) ( R: -- x)
   R8 POP   T PUSH   TPOP   R8 BR   END-CODE

CODE R> ( x -- ) ( R: x -- )
   R8 POP   TPUSH   T POP   R8 BR   END-CODE

CODE R@ ( -- x )
   TPUSH   2 (R) T MOV   RET   END-CODE

CODE LEAVE ( -- ) ( R: addr x1 x2 -- )
   6 # R ADD   RET   END-CODE

CODE UNLOOP ( R: addr n1 n3 -- )
   R8 POP   4 # R ADD   R8 BR   END-CODE

CODE J ( -- x)
   TPUSH   8 (R) T MOV   10 (R) T ADD
   RET   END-CODE

TARGET
