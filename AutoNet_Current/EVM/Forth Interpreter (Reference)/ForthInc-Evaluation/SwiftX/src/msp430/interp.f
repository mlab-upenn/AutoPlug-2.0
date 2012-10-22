{ =====================================================================
Interpreter support

Copyright 2009  FORTH, Inc.

Low-level support for the text interpreter option on the MSP430
is provided here.

Requires: >IN

Exports: (FIND), /RSTACK
===================================================================== }

TARGET

{ ---------------------------------------------------------------------
Low-level interpreter

(FIND) runs through a single dictionary thread looking for a match
with counted string at c-addr.  Bit 7 of the length is set if the
word is immediate.

/RSTACK clears the return stack.
--------------------------------------------------------------------- }

| CODE (FIND) ( c-addr addr -- c-addr 0 | xt 1 | xt -1 )
   BEGIN   @T T MOV   T TST   0= NOT WHILE   T R8 MOV
      2 # R8 ADD   @S R9 MOV   @R8+ R10 MOV.B   R10 R11 MOV
      $7F # R11 AND   @R9+ R11 CMP.B   0= IF
         BEGIN   @R8+ R12 MOV.B  @R9+ R12 CMP.B
            0= WHILE   R11 DEC   0= UNTIL
            R8 INC   -2 # R8 AND   R8 0 (S) MOV   -1 # T MOV
            R10 TST.B   0< IF   1 # T MOV   THEN    RET
   THEN THEN REPEAT   RET   END-CODE

| CODE /RSTACK ( -- ) ( R: i*x -- )
   R8 POP   U R MOV  CATCHER (U) CLR   R8 BR   END-CODE
