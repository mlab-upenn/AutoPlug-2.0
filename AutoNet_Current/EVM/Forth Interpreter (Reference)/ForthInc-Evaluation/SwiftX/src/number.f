{ =====================================================================
Input number conversion

Copyright (c) 1972-2000, FORTH, Inc.

This file supplies functions to convert text strings to numeric values.

Exports:  >NUMBER  NUMBER?  NUMBER  DPL  NH
===================================================================== }

TARGET

{ ---------------------------------------------------------------------
Convert strings to numbers

DPL and NH hold results about the number conversion after a string
is processed by NUMBER? or NUMBER .  These are global variables, so
their contents must be examined before doing a PAUSE.

DPL holds the digits to the right of the last punctiation character in
the string.  Any negative value indicates that there was no punctuation.

NH holds the high half of a double number.

>NUMBER supplies the basic ANS text to number conversion primitive.

NUMBER? takes a string address and length and attempts to convert it
to a number.  Returns 0 to indicate that the conversion failed, a single
number and 1, or a double number (if it contains puctuation characters)
and 2.  Also leaves DPL and NH set as described above.

NUMBER takes a string address and length and converts it to a number
using NUMBER? .  Throws an exception if the conversion fails.
--------------------------------------------------------------------- }

TARGET

VARIABLE DPL   VARIABLE NH

: >NUMBER ( ud1 c-addr1 u1 -- ud2 c-addr2 u2)
   DUP IF  BEGIN  1 DPL +!  OVER C@
      [CHAR] 0 - DUP 10 16 WITHIN OR
      DUP 16 > 7 AND -  DUP 0 BASE @ WITHIN WHILE
      SWAP >R  2SWAP  BASE @ *  SWAP BASE @ UM* D+ ROT 1+
   R> 1-  DUP 0= UNTIL  EXIT  THEN DROP  THEN ;

: +NUM ( c-addr1 u1 -- c-addr2 u2 )
   SWAP 1+  SWAP 1- ;

: NUMBER? ( c-addr u -- d 2 | n 1 | 0)
   -1024 DPL !  OVER C@ [CHAR] - =  DUP NH ! IF  +NUM  THEN
   DUP 1 < IF  2DROP 0  EXIT  THEN  0 0 2SWAP
   BEGIN  >NUMBER  DUP WHILE
      OVER C@  DUP [CHAR] + [CHAR] 0 WITHIN
      SWAP [CHAR] : = OR WHILE  +NUM  0 DPL !  REPEAT
   2DROP 2DROP 0  EXIT  THEN
   2DROP  NH @ IF DNEGATE THEN  2
   DPL @ 0< IF  SWAP NH ! 1-  THEN ;

: NUMBER ( c-addr u -- d | n )
   NUMBER? 0= IF  -24 THROW  THEN ;

