{ =====================================================================
Common timing functions

Copyright (c) 1972-2000, FORTH, Inc.

The common millisecond timing functions are supplied here.

Requires: COUNTER PAUSE

Exports: EXPIRED MS TIMER
===================================================================== }

TARGET

{ ---------------------------------------------------------------------
Millisecond timing

EXPIRED returns true if counter n is expired.
MS delays for n milliseconds (max is 32767).
TIMER displays the total elapsed time since counter n.
--------------------------------------------------------------------- }

: EXPIRED ( n -- flag)   PAUSE  COUNTER - 0< ;

: MS ( n -- )   COUNTER +  BEGIN  DUP EXPIRED UNTIL  DROP ;

: TIMER ( n -- )   COUNTER SWAP - . ;

