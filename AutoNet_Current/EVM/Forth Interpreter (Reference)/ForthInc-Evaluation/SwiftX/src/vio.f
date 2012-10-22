{ =====================================================================
Vectored terminal I/O

Copyright (c) 1972-2000, FORTH, Inc.

This file implements vectored terminal input and output functions in the
ANS Forth Core, Core Extension, and Facility word sets.

Exports: KEY, KEY?, ACCEPT, STRAIGHT, TYPE, EMIT, CR, PAGE, AT-XY

Requires: Terminal I/O vectors and @EXECUTE
===================================================================== }

TARGET

{ ---------------------------------------------------------------------
Vectored input

KEY and KEY? return single key and key input available status through
their corresponding vectors which are usually USER variables.

ACCEPT calls the 'ACCEPT vector only if the requested length was non-
zero.  Returns the actual input length.

STRAIGHT calls the 'STRAIGHT vector to perform unedited input of
exactly n characters.
--------------------------------------------------------------------- }

: KEY ( -- char)   'KEY @EXECUTE ;
: KEY? ( -- flag)   'KEY? @EXECUTE ;
: ACCEPT ( c-addr +n1 -- +n2)   DUP IF  'ACCEPT @EXECUTE  EXIT  THEN NIP ;
: STRAIGHT ( c-addr +n -- )   DUP IF  'STRAIGHT @EXECUTE  EXIT  THEN 2DROP ;

{ ---------------------------------------------------------------------
Vectored output

TYPE calls the 'TYPE vector to output a string if its length is non-zero.
EMIT call the 'EMIT vector to output a character.
AT-XY passes the x and y display coordinates to the vectored handler.
--------------------------------------------------------------------- }

: TYPE ( c-addr n -- )   DUP IF  DUP X# +!  'TYPE @EXECUTE  EXIT  THEN 2DROP ;
: EMIT ( char -- )   1 X# +!  'EMIT @EXECUTE ;
: CR ( -- )   1 Y# +!  'CR @EXECUTE  0 X# ! ;
: PAGE ( -- )   'PAGE @EXECUTE  0 X# !  0 Y# ! ;
: AT-XY ( x y -- )   2DUP 'ATXY @EXECUTE  Y# ! X# ! ;
: GET-XY ( -- x y )   'GETXY @EXECUTE ;

{ ---------------------------------------------------------------------
Default cursor position

(GETXY) can be used as the generic GET-XY to return the X# and Y# user
variables as maintained above.
--------------------------------------------------------------------- }

: (GETXY) ( -- x y )   X# @  Y# @ ;

