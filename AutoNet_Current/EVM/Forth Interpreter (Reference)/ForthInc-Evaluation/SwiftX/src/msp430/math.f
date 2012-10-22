{ =====================================================================
Multiply and divide operators

Copyright (C) 2001  FORTH, Inc.

This file supplies math operators for the MSP430 processor core.
Multiplication operators make use of the hardware multiplier if
there is one.

===================================================================== }

TARGET

{ ---------------------------------------------------------------------
Multiplication

If the processor has a hardware multiplier (i.e. the MPY I/O register
is defined), it is used for multiplication operators.  Otherwise, the
software UM* loop is the basis for all multiply operations.
--------------------------------------------------------------------- }

[DEFINED] MPY [IF]

CODE UM* ( u1 u2 -- ud )
   @S MPY & MOV   T OP2 & MOV
   RESLO & 0 (S) MOV   RESHI & T MOV
   RET   END-CODE

CODE M* ( n1 n2 -- d )
   @S MPYS & MOV   T OP2 & MOV
   RESLO & 0 (S) MOV   RESHI & T MOV
   RET   END-CODE

CODE * ( n1 n2 -- n3 )
   @S+ MPYS & MOV   T OP2 & MOV
   RESLO & T MOV   RET   END-CODE

[ELSE]

CODE UM* ( u1 u2 -- ud )
   @S R8 MOV    R9 R9 XOR               \ R9=result high half, R8=low half
   R8 RRC   SR R10 MOV                  \ Initial shift, R10=saved SR
   16 # R11 MOV   BEGIN   R10 SR MOV    \ R11=loop count
      CS IF   T R9 ADD   THEN           \ Accumulate high half
      R9 RRC   R8 RRC   SR R10 MOV      \ Shift result, save SR across DEC
   R11 DEC   0= UNTIL                   \ Loop
   R9 T MOV   R8 0 (S) MOV              \ Save results
   RET   END-CODE

: * ( n1 n2 -- n3 )   UM* DROP ;

[THEN]

{ ---------------------------------------------------------------------
Division

Division by 0 throws exception code -10.

UM/MOD is the core division primitive.  All divide operators are based
on UM/MOD.
--------------------------------------------------------------------- }

CODE UM/MOD ( ud u1 -- u2 u3 )
   T TST   0= IF   -10 # T MOV   ' THROW JMP   THEN
   @S+ R8 MOV   @S R9 MOV
   R10 CLR   17 # R11 MOV
   BEGIN ( *)   T R8 CMP
      CS IF   T R8 SUB   THEN
      BEGIN ( **)   R10 RLC   R11 DEC
         0= NOT WHILE   R9 RLA   R8 RLC
      ROT ( *) CS UNTIL
   T R8 SUB   SETC   ( ** ) REPEAT
   R8 0 (S) MOV   R10 T MOV
   RET   END-CODE

: */MOD ( n1 n2 n3 -- n4 n5)
   DUP 2OVER XOR DUP >R XOR >R >R  ABS SWAP ABS UM*
   R> ABS UM/MOD  R> 0< IF  NEGATE  THEN
   R> 0< IF  SWAP NEGATE SWAP  THEN ;

: */ ( n1 n2 n3 -- n4)   */MOD NIP ;

: /MOD ( n1 n2 -- n3 n4)   OVER >R  2DUP XOR >R >R
   ABS 0  R> ABS UM/MOD  R> 0< IF  NEGATE  THEN
   R> 0< IF  SWAP NEGATE SWAP  THEN ;

: / ( n1 n2 -- n3)   /MOD NIP ;

: MOD ( n1 n2 -- n3)   /MOD DROP ;

\\
{ ---------------------------------------------------------------------
Extended precision

This operator may be included if your application requires scaling
by larger integers.
--------------------------------------------------------------------- }

CODE UT/MOD ( ut ud1 -- ud2 ud3 )
   @S+ R8 MOV   @S+ R9 MOV   @S+ R10 MOV   @S+ R11 MOV  \ R8=ud1L; R9=utH; R10=utM; R11=utL
   R13 CLR   17 # R14 MOV                               \ R12:R13=accumulator, R14=loop cnt
   BEGIN ( *)   R8 R10 SUB   T R9 SUBC                  \ 1st loop entry point ( *)
      CS NOT IF   R8 R10 ADD   T R9 ADDC   CLRC   THEN
      BEGIN ( **)   R13 RLC   R12 RLC   R14 DEC         \ 2nd loop entry point ( **)
         0= NOT WHILE   R11 RLA   R10 RLC   R9 RLC
      ROT ( *) CS UNTIL
   R8 R10 SUB   T R9 SUBC   SETC   ( ** ) REPEAT
   6 # S SUB   R12 T MOV   R13 0 (S) MOV                \ Return quotient
   R9 2 (S) MOV   R10 4 (S) MOV                         \ Return remainder
   RET   END-CODE

