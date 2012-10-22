{ =====================================================================
Common core output

Copyright (c) 1972-2000, FORTH, Inc.

Common ANS Core output words are implemented here.

Requires: EMIT  TYPE  (("))  ",C

Exports: Output words
===================================================================== }

TARGET

{ ---------------------------------------------------------------------
Common output functions

SPACE and SPACES use EMIT to output spaces.

(.") is the internal working of ." which requires ((")) from the
underlying kernel.  ((")) returns the data space address of the in-line
string from the word that called the word that called it.
--------------------------------------------------------------------- }

: SPACE ( -- )   BL EMIT ;
: SPACES ( num -- )   0 MAX  0 ?DO  BL EMIT  LOOP ;

TARGET-SHELL

: HERE ( -- c-addr )   H @ ;

TARGET

: PAD ( -- c-addr )   HERE |NUM| + ;

: (.") ( -- )   ((")) COUNT TYPE ;

COMPILER

: ." ( -- )   POSTPONE (.")  ",C ;

HOST

DECODE: (.") .STRING

TARGET

{ ---------------------------------------------------------------------
Number output

Common number output functions are implemented here.

HLD is the pointer used during number formatting.  It is a global
variable so do not PAUSE while formatting a number for output!

DIGIT converts binary value u to an ASCII digit.
--------------------------------------------------------------------- }

VARIABLE HLD

: <# ( -- )   PAD HLD ! ;

: HOLD ( char -- )   HLD @  1- DUP HLD !  C! ;

: DIGIT ( u -- char)   DUP 9 > IF  7 +  THEN  [CHAR] 0 + ;

: # ( ud1 -- ud2)   DUP IF  0 BASE @ UM/MOD  ROT ROT
      BASE @ UM/MOD  SWAP DIGIT HOLD  SWAP  ELSE
   BASE @ UM/MOD  SWAP DIGIT HOLD  0  THEN ;

: #S ( ud1 -- ud2)   BEGIN  #  2DUP OR 0= UNTIL ;

: SIGN ( n -- )   0< IF  [CHAR] - HOLD  THEN ;

: #> ( ud -- c-addr u )   2DROP  HLD @ PAD OVER - ;

: (.) ( n -- c-addr u )   DUP ABS 0  <#  #S  ROT SIGN  #> ;
: (U.) ( u -- c-addr u )   0 <#  #S  #> ;

: . ( n -- )   (.) TYPE SPACE ;
: .R ( n n -- )   SWAP (.)  ROT OVER - SPACES TYPE ;

: U. ( u -- )  (U.) TYPE SPACE ;
: U.R ( n n -- )   SWAP (U.)  ROT OVER - SPACES TYPE ;

