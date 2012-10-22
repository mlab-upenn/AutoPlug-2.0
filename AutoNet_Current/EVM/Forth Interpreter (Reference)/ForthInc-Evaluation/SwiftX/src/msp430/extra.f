{ =====================================================================
Miscellaneous extensions

Copyright (C) 2001  FORTH, Inc.

This file supplies some common non-ANS extensions.
===================================================================== }

TARGET

{ ---------------------------------------------------------------------
Application support

C+! adds to the contents of the byte at addr.
@EXECUTE is short for @ EXECUTE but does nothing if addr contains 0.
NOT is a synonym for 0=.
2+ and 2- are short for 2 + and 2 -.
M/ provides mixed double/single divide.
--------------------------------------------------------------------- }

CODE C+! ( char addr -- )
   @S+ R8 MOV   R8 0 (T) ADD.B
   TPOP   RET   END-CODE

CODE 2C@ ( addr -- char1 char2 )
   2 # S SUB   1 (T) R8 MOV.B   R8 0 (S) MOV
   @T T MOV.B   RET   END-CODE

CODE @EXECUTE ( i*x addr -- j*x)
   @T R8 MOV   TPOP   R8 TST
   0= NOT IF   R8 BR   THEN   RET   END-CODE

: NOT ( x -- flag)   0= ;

COMPILER

: 2+ ( -- )   [+ASSEMBLER]  2 # T ADD  [PREVIOUS] ;
: 2- ( -- )   [+ASSEMBLER]  2 # T SUB  [PREVIOUS] ;

TARGET

: 2+ ( n2 -- n2 )   2+ ;
: 2- ( n2 -- n2 )   2- ;

