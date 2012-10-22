{ =====================================================================
Double numbers

Copyright (c) 1972-2000, FORTH, Inc.

This file implements the common functions in the ANS Forth Double-number
and Double-number Extension word sets.

Requires: CPU-specific Double-number support

Exports: Common Double-number functions
===================================================================== }

{ ---------------------------------------------------------------------
Double literals and operators

2LITERAL takes a double number (or two single ones) and compiles them
into the target definition.

Most of the generic high-level double operators are defined here.
--------------------------------------------------------------------- }

COMPILER

: 2LITERAL ( d -- )   SWAP  POSTPONE LITERAL  POSTPONE LITERAL ;

TARGET

: D0= ( d -- flag)   OR 0= ;
: D0< ( d -- flag)   NIP 0< ;
: D= ( d1 d2 -- flag)   D- D0= ;
: DABS ( d1 -- d2)   DUP 0< IF  DNEGATE  THEN ;
: D>S ( d -- n)   DROP ;
: M+ ( d1 n -- d2)   S>D D+ ;

: DMIN ( d1 d2 -- d3)   2OVER 2OVER D< NOT IF  2SWAP  THEN 2DROP ;
: DMAX ( d1 d2 -- d3)   2OVER 2OVER D< IF  2SWAP  THEN 2DROP ;

