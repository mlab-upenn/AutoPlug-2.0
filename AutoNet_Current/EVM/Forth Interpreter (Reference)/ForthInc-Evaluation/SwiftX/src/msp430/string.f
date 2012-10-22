{ =====================================================================
Strings

Copyright 2001  FORTH, Inc.

This file contains CPU-specific string operators from the ANS Forth
Core, Core Extensions, and Strings word sets.
===================================================================== }

TARGET

{ ---------------------------------------------------------------------
String operators

These code words implement the string operators.
--------------------------------------------------------------------- }

CODE CMOVE ( c-addr1 c-addr2 u -- )
   @S+ R8 MOV   @S+ R9 MOV   T TST   0= NOT IF
      BEGIN   @R9+ 0 (R8) MOV.B   R8 INC
   T DEC   0= UNTIL   THEN   TPOP   RET   END-CODE

CODE CMOVE> ( c-addr1 c-addr2 u -- )
   @S+ R8 MOV   @S+ R9 MOV   T TST   0= NOT IF
      T R8 ADD   T R9 ADD   BEGIN
         R8 DEC   R9 DEC   @R9 0 (R8) MOV.B
   T DEC   0= UNTIL   THEN   TPOP   RET   END-CODE

CODE FILL ( c-addr u char -- )
   @S+ R8 MOV   @S+ R9 MOV   R8 TST   0= NOT IF
      BEGIN   T 0 (R9) MOV.B   R9 INC
   R8 DEC   0= UNTIL   THEN   TPOP   RET   END-CODE

CODE COUNT ( c-addr1 -- c-addr2 len )
   @T+ R8 MOV.B   TPUSH   R8 T MOV
   RET   END-CODE

CODE -TRAILING ( c-addr len1 -- c-addr len2)
   T TST   0= NOT IF   @S R8 MOV   T R8 ADD
      BEGIN   BL # -1 (R8) CMP.B   0= WHILE
   R8 DEC   T DEC   0= UNTIL   THEN THEN
   RET   END-CODE

CODE COMPARE ( c-addr1 len1 c-addr2 len2 -- n)
   @S+ R8 MOV   @S+ R9 MOV   @S+ R10 MOV
   R9 R11 MOV   R9 T CMP   CS IF   T R11 MOV   THEN
   R11 TST   0= NOT IF   BEGIN   @R8+ 0 (R10) CMP.B
      0= WHILE   R10 INC   R11 DEC   0= UNTIL   SWAP THEN
      T R9 CMP   THEN   0= IF   T CLR   ELSE
         CS IF   1 # T MOV   ELSE   -1 # T MOV
   THEN THEN   RET   END-CODE

{ ---------------------------------------------------------------------
Compiled strings

((")) returns address of in-line counted string.  This word is called
from a word which is called before an in-line string.  It advances the
return address past the string.

(C") and (S") provide the run-time code for C" and S".

Decompiler behavior for compiled strings is handled by .STRING.
--------------------------------------------------------------------- }

CODE ((")) ( -- c-addr )
   TPUSH   2 (SP) T MOV   R8 CLR   @T R8 MOV.B
   R8 INCD   -2 # R8 AND   R8 2 (SP) ADD
   RET   END-CODE

CODE (C")   ' ((")) # CALL   RET   END-CODE

: (S")   ((")) COUNT ;

HOST

DECODE: (S") .STRING
DECODE: (C") .STRING

TARGET

