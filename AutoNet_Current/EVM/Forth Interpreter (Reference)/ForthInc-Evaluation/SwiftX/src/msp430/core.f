{ =====================================================================
Core wordset

Copyright 2001  FORTH, Inc.

This file implements most of the ANS Forth Core and Core Extensions
word sets for the MSP430 processor core.

This Forth kernel is a subroutine threaded implementation with
in-line code substitution for simple primitives.

Target register model:

Registers R0 - R7 are reserved for functions dedicated to the CPU and
for the Forth Virtual Machine.  Registers R8 - R15 are available for
use by primitives, interrupts, and CODE definitions.

TI                              Forth alias
PC -- Program counter
SP -- Return stack pointer      R
SR -- Status register
R3 -- Constant generator

R4 -- Data stack pointer        S
R5 -- Top of stack              T
R6 -- User task pointer         U

R7 -- Reserved for future use

Aliases are defined in ASSEMBLER for dedicated registers.
TPUSH and TPOP push and pop the T register to and from the data stack.
==================================================================== }

TARGET

{ ---------------------------------------------------------------------
Run-time code for compiler structures

(LITERAL) is the run-time code for LITERAL.  The call to (LITERAL) is
followed by the in-line literal value.

(CREATE) is the run-time code for CREATE.  The call to (CREATE) is
followed by the address of the word's parameter field.

(IF) is the in-line code compiled by IF.  It pops the top data stack
item into D, setting the Z condition code if flag was 0.

(DO) provides the run-time code for DO and ?DO.  It pushes the loop limit
and the limit subtracted from the initial index onto the return stack.
If they are equal, returns with $8000 in D.

(LOOP) and (+LOOP) provide the run-time code for LOOP and +LOOP.  They
return the overflow V bit set when the loop terminates.  The compiler
follows the call to (LOOP) or (+LOOP) with a conditional branch to
the beginning of the loop and code to drop the loop parameters when
the conditional branch is not taken (i.e. the loop has terminated).
--------------------------------------------------------------------- }

CODE (LITERAL) ( -- x )
   R8 POP   TPUSH   @R8+ T MOV          \ Get in-line literal
   R8 BR   END-CODE                     \ Branch to address after literal

CODE (CREATE) ( -- addr )
   R8 POP   TPUSH   @R8+ T MOV          \ Get in-line PFA pointer
   RET   END-CODE                       \ Return to caller of CREATE word

HOST

DECODE: (LITERAL) .LIT
DECODE: (CREATE) .PFA

TARGET

CODE (DO) ( n1|u1 n2|u2 -- ) ( R: -- x1 x2 )
   R8 POP                               \ Pop return address
   @S+ R9 MOV   $8000 # R9 XOR          \ Wrap limit n1 around number circle
   R9 PUSH   R9 T SUB   T PUSH          \ Push wrapped n1, index-limit
   TPOP   R8 BR   END-CODE              \ Pop new T, brach to return addr

CODE (?DO) ( n1|u1 n2|u2 -- ) ( R: -- x1 x2 )
   R8 POP                               \ Pop return address
   @S+ R9 MOV   R9 T CMP                \ Compare limits
   0= IF   TPOP   @R8 BR   THEN         \ If same, jump to inline addr
   $8000 # R9 XOR   R9 PUSH             \ Push wrapped n1
   R9 T SUB   T PUSH   TPOP             \ Push index-limit, pop new T
   2 # R8 ADD   R8 BR   END-CODE        \ Branch past inline addr

CODE (LOOP) ( -- )
   R8 POP   0 (R) INC                   \ Pop return addr, increment index-limit
   V # SR BIT   0= NOT IF               \ On overflow, pop loop parameters
      4 # R ADD   2 # R8 ADD            \ Return past inline branch addr
   R8 BR   THEN   @R8 BR   END-CODE     \ Otherwise branch back to start of loop

CODE (+LOOP) ( n -- )
   R8 POP   T 0 (R) ADD   TPOP          \ Pop return addr, add n to index-limit
   V # SR BIT   0= NOT IF               \ On overflow, pop loop parameters
      4 # R ADD   2 # R8 ADD            \ Return past inline branch addr
   R8 BR   THEN   @R8 BR   END-CODE     \ Otherwise branch back to start of loop

HOST

DECODE: (?DO) .LOOP
DECODE: (LOOP) .LOOP
DECODE: (+LOOP) .LOOP

TARGET
{ ---------------------------------------------------------------------
Stack operators

Simple stack operators are implemented as in-line code macros in the
COMPILER word list.
--------------------------------------------------------------------- }

COMPILER

: DROP   [+ASSEMBLER]   TPOP  [PREVIOUS] ;
: NIP   [+ASSEMBLER]   S INCD  [PREVIOUS] ;
: 2DROP   [+ASSEMBLER]   S INCD   TPOP  [PREVIOUS] ;

TARGET

: DROP ( x -- )   DROP ;
: NIP ( x1 x2 -- x2 )   NIP ;
: 2DROP ( d -- )   2DROP ;

CODE DUP ( x -- x x )   TPUSH    RET   END-CODE
CODE OVER ( x1 x2 -- x1 x2 x1 )   TPUSH   2 (S) T MOV   RET   END-CODE

CODE ?DUP ( x -- 0 x x )
   T TST   0= NOT IF   TPUSH   THEN
   RET   END-CODE

CODE SWAP ( x1 x2 -- x2 x1 )
   T R8 MOV   @S T MOV   R8 0 (S) MOV
   RET   END-CODE

: TUCK ( x1 x2 -- x2 x1 x2 )   SWAP OVER ;

CODE ROT ( x1 x2 x3 -- x2 x3 x1 )
   @S R8 MOV   2 (S) R9 MOV
   R8 2 (S) MOV   T 0 (S) MOV
   R9 T MOV   RET   END-CODE

CODE -ROT ( x1 x2 x3 -- x3 x1 x2 )
   @S R8 MOV   2 (S) R9 MOV
   T 2 (S) MOV   R9 0 (S) MOV
   R8 T MOV   RET   END-CODE

CODE PICK ( xu ... x1 x0 u -- xu ... x1 x0 xu )
   T RLA   S T ADD   @T T MOV
   RET   END-CODE

CODE ROLL ( xu xu-1 ... x0 u -- xu-1 ... x0 xu)
   T S ADD   T S ADD   T R8 MOV
   @S+ T MOV   BEGIN   R8 DEC
      0< NOT WHILE   -4 (S) -2 (S) MOV
   S DECD   REPEAT   RET   END-CODE

CODE 2DUP ( d -- d d )
   @S R8 MOV   4 # S SUB   T 2 (S) MOV
   R8 0 (S) MOV   RET   END-CODE

CODE 2OVER ( d1 d2 -- d1 d2 d1 )
   4 # S SUB   T 2 (S) MOV   6 (S) T MOV
   8 (S) R8 MOV   R8 0 (S) MOV
   RET   END-CODE

CODE 2SWAP ( d1 d2 -- d2 d1 )
   @S R8 MOV   2 (S) R9 MOV   4 (S) R10 MOV
   R10 0 (S) MOV   T 2 (S) MOV   R8 4 (S) MOV
   R9 T MOV   RET   END-CODE

CODE DEPTH ( -- n )
   S0 (U) R8 MOV   S R8 SUB   R8 RRA
   TPUSH   R8 T MOV   RET   END-CODE

{ ---------------------------------------------------------------------
Return stack operators

The CPU subroutine stack is used in this implementation as the return
stack.  Loop indexes are calculated.
--------------------------------------------------------------------- }

COMPILER

: >R ( -- )   [+ASSEMBLER]  T PUSH  TPOP  [PREVIOUS] ;
: R> ( -- )   [+ASSEMBLER]  TPUSH  T POP  [PREVIOUS] ;
: R@ ( -- )   [+ASSEMBLER]  TPUSH  @R T MOV  [PREVIOUS] ;
: UNLOOP ( -- )   [+ASSEMBLER]  4 # R ADD  [PREVIOUS]  !DEST ;

TARGET

CODE 2R@ ( -- x1 x2 )
   4 # S SUB   T 2 (S) MOV
   4 (R) 0 (S) MOV   2 (R) T MOV
   RET   END-CODE

CODE 2>R ( x1 x2 -- ) ( R: -- x1 x2)
   R8 POP   @S+ R9 MOV   R9 PUSH   T PUSH
   TPOP   R8 BR   END-CODE

CODE 2R> ( -- x1 x2 ) ( R: x1 x2 -- )
   R8 POP   4 # S SUB   T 2 (S) MOV
   T POP   0 (S) POP   R8 BR   END-CODE

COMPILER

: 2R> ( -- )   POSTPONE 2R>  !DEST ;

TARGET

CODE I ( -- x)
   TPUSH   2 (R) T MOV   4 (R) T ADD
   RET   END-CODE

CODE J ( -- x)
   TPUSH   6 (R) T MOV   8 (R) T ADD
   RET   END-CODE

{ ---------------------------------------------------------------------
Logical operators
--------------------------------------------------------------------- }

COMPILER

: AND ( -- )   [+ASSEMBLER]  @S+ T AND  [PREVIOUS] ;
: OR ( -- )   [+ASSEMBLER]  @S+ T BIS  [PREVIOUS] ;
: XOR ( -- )   [+ASSEMBLER]  @S+ T XOR  [PREVIOUS] ;
: INVERT ( -- )   [+ASSEMBLER]  T INV  [PREVIOUS] ;

TARGET

: AND ( x1 x2 -- x3)   AND ;
: OR ( x1 x2 -- x3)   OR ;
: XOR ( x1 x2 -- x3)   XOR ;
: INVERT ( n1 -- n2)   INVERT ;

{ ---------------------------------------------------------------------
Arithmetic operators
--------------------------------------------------------------------- }

COMPILER

: + ( -- )   [+ASSEMBLER]  @S+ T ADD  [PREVIOUS] ;
: 1+ ( -- )   [+ASSEMBLER]  1 # T ADD  [PREVIOUS] ;
: 1- ( -- )   [+ASSEMBLER]  1 # T SUB  [PREVIOUS] ;
: 2* ( -- )   [+ASSEMBLER]  T RLA  [PREVIOUS] ;
: 2/ ( -- )   [+ASSEMBLER]  T RRA  [PREVIOUS] ;

: CHARS ( -- ) ;
: CELLS ( -- )   [+ASSEMBLER]  T RLA  [PREVIOUS] ;

: CHAR+ ( -- )   [+ASSEMBLER]  1 # T ADD  [PREVIOUS] ;
: CELL+ ( -- )   [+ASSEMBLER]  2 # T ADD  [PREVIOUS] ;

TARGET

: + ( n1 n2 -- n3 )   + ;
: 1+ ( n1 -- n2 )   1+ ;
: 1- ( n1 -- n2 )   1- ;
: 2* ( n1 -- n2 )   2* ;
: 2/ ( n1 -- n2 )   2/ ;

: CHARS ( n1 -- n2 )  ;
: CELLS ( n1 -- n2 )   CELLS ;

: CHAR+ ( addr1 -- addr2 )   CHAR+ ;
: CELL+ ( addr1 -- addr2 )   CELL+ ;

CODE - ( n1 n2 -- n3 )
   @S+ R8 MOV   T R8 SUB   R8 T MOV
   RET   END-CODE

CODE NEGATE ( n1 -- n2 )
   R8 CLR   T R8 SUB   R8 T MOV
   RET   END-CODE

CODE ABS ( n1 -- n2 )
   T TST   ' NEGATE 0< NOT UNTIL
   RET   END-CODE

CODE ALIGNED ( x1 -- x2)
   T INC   -2 # T AND   RET   END-CODE

CODE LSHIFT ( x1 u -- x2 )
   T R8 MOV   TPOP   R8 TST   0= NOT IF
      BEGIN   T RLA   R8 DEC   0= UNTIL
   THEN   RET   END-CODE

CODE RSHIFT ( x1 u -- x2 )
   T R8 MOV   TPOP   R8 TST   0= NOT IF
      BEGIN   CLRC   T RRC   R8 DEC   0= UNTIL
   THEN   RET   END-CODE

{ ---------------------------------------------------------------------
Comparison operators
--------------------------------------------------------------------- }

CODE = ( n1 n2 -- flag )
   @S+ T CMP   0= IF   -1 # T MOV   RET   THEN
   0 # T MOV   RET   END-CODE

CODE 0= ( n -- flag )
   T TST   0= IF   -1 # T MOV   RET   THEN
   0 # T MOV   RET   END-CODE

CODE > ( n1 n2 -- flag )
   @S+ T CMP   S< IF   -1 # T MOV   RET   THEN
   0 # T MOV   RET   END-CODE

CODE 0< ( n -- flag )
   T TST   S< IF   -1 # T MOV   RET   THEN
   0 # T MOV   RET   END-CODE

CODE < ( n1 n2 -- flag )
   @S+ R8 MOV   T R8 CMP   S< IF   -1 # T MOV   RET   THEN
   0 # T MOV   RET   END-CODE

CODE 0> ( n -- flag )
   T #0 CMP   S< IF   -1 # T MOV   RET   THEN
   0 # T MOV   RET   END-CODE

CODE <> ( x1 x2 -- flag)
   @S+ T SUB   0= NOT IF   -1 # T MOV   THEN
   RET   END-CODE

CODE 0<> ( x -- flag)
   T TST   0= NOT IF   -1 # T MOV   THEN
   RET   END-CODE

CODE MIN ( n1 n2 -- n3 )
   @S+ R8 MOV   T R8 CMP   S< IF   R8 T MOV   THEN
   RET   END-CODE

CODE MAX ( n n -- n)
   @S+ R8 MOV   R8 T CMP   S< IF   R8 T MOV   THEN
   RET   END-CODE

CODE U< ( u1 u2 -- flag )
   @S+ R8 MOV   T R8 CMP   T T SUBC
   RET   END-CODE

CODE U> ( u1 u2 -- flag )
   @S+ T CMP   T T SUBC   RET   END-CODE

: WITHIN ( n l h -- t)   OVER - >R  - R> U< ;

{ ---------------------------------------------------------------------
Memory access operators
--------------------------------------------------------------------- }

COMPILER

: @ ( -- )   [+ASSEMBLER]  @T T MOV  [PREVIOUS] ;
: C@ ( -- )   [+ASSEMBLER]  @T T MOV.B  [PREVIOUS] ;

TARGET

: @ ( addr -- x)   @ ;
: C@ ( addr -- x)   C@ ;

CODE C! ( char addr -- )
   @S+ R8 MOV   R8 0 (T) MOV.B
   TPOP   RET   END-CODE

CODE ! ( x addr -- )
   @S+ 0 (T) MOV   TPOP   RET   END-CODE

CODE +! ( x addr -- )
   @S+ 0 (T) ADD   TPOP   RET   END-CODE

CODE 2@ ( addr -- d )
   2 # S SUB   2 (T) R8 MOV   R8 0 (S) MOV
   @T T MOV   RET   END-CODE

CODE 2! ( d addr -- )
   @S+ 0 (T) MOV   @S+ 2 (T) MOV
   TPOP   RET   END-CODE

{ ---------------------------------------------------------------------
Vectored exection
--------------------------------------------------------------------- }

COMPILER

: EXECUTE ( -- )
   [+ASSEMBLER]   T R8 MOV   TPOP   R8 CALL  [PREVIOUS] ;

TARGET

CODE EXECUTE ( xt -- )
   T R8 MOV   TPOP   R8 BR   END-CODE

