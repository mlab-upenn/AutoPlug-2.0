{ =====================================================================
Generic ACCEPT and STRAIGHT functions

Copyright (c) 1972-1997, FORTH, Inc.

This file supplies generic high-level ACCEPT and STRAIGHT functions for
target terminal tasks.

Dependencies:  Requires vectored KEY and EMIT.

Exports:  (ACCEPT)  (STRAIGHT)
===================================================================== }

TARGET

{ ---------------------------------------------------------------------
Generic string input

(ACCEPT) provides a generic high-level vectored behavior to plug into
'ACCEPT for a terminal task.

(STRAIGHT) is a generic high-level vectored STRAIGHT behavior.  This
is especially well suited for serial ports whose KEY returns the next
available character from an input queue.
--------------------------------------------------------------------- }

8 EQU <BS>
13 EQU <CR>
127 EQU <DEL>

: (ACCEPT) ( c-addr u1 -- u2 )   OVER + OVER 2>R
   BEGIN  KEY  CASE  <CR> OF  2R> NIP -  EXIT  ENDOF
      <BS> OF  1- DUP 2R@ WITHIN IF  1+  ELSE  <BS> EMIT
         BL EMIT  <BS> EMIT  THEN  ENDOF
      <DEL> OF  1- DUP 2R@ WITHIN IF  1+  ELSE  <BS> EMIT
         BL EMIT  <BS> EMIT  THEN  ENDOF
      OVER 2R@ WITHIN IF  <BS> EMIT  DUP EMIT  OVER 1- C!
   ELSE  DUP EMIT  OVER C! 1+  THEN  DUP  ENDCASE  AGAIN ;

: (STRAIGHT) ( c-addr u -- )
   OVER + SWAP DO  KEY I C!  LOOP ;


