{ =====================================================================
SERIAL XTL SHARED FUNCTIONS

Copyright (C) 2002  FORTH, Inc.

This group of functions is shared by many SwiftX targets with a
serial XTL debug interface.

***********************************************************************

Special terminal output control characters:
12 - PAGE
13 - CR
===================================================================== }

TARGET

{ ---------------------------------------------------------------------
Common terminal I/O

The (X.. words provide vectored terminal output functions for the
serial debug interface.

Requires target-specific (X-EMIT) function.
--------------------------------------------------------------------- }

[UNDEFINED] (X-TYPE) [IF] 
: (X-TYPE) ( c-addr u -- )   0 ?DO  DUP C@ (X-EMIT)  1+  LOOP DROP ;
[THEN]

[UNDEFINED] (X-CR) [IF] 
: (X-CR)   13 (X-EMIT)  10 (X-EMIT) ;
[THEN]

[UNDEFINED] (X-PAGE) [IF] 
: (X-PAGE)   12 (X-EMIT) ;
[THEN]

[UNDEFINED] (X-ATXY) [IF] 
: (X-ATXY) ( num1 num2 -- )   <XY> (X-EMIT) (X-EMIT) (X-EMIT) ;
[THEN]

[UNDEFINED] (X-STRAIGHT) [IF] 
: (X-STRAIGHT) ( c-addr u -- )
   OVER + SWAP ?DO  (X-KEY) I C!  LOOP ;
[THEN]

{ ---------------------------------------------------------------------
Extended debug support

.' ("dot-tick") takes a target address and sends it to the host for
decoding and display.

X-LOG and X-CLOSE use XTL function 247 to send binary log data to
the host to be written to the TARGET.LOG file.  Blocks of data are
written in records of up to 255 bytes each.  The message format is:
  <247> <length> <data>

Length is 1 byte (1-255) followed by that many data bytes.

A special form is used by X-CLOSE which sends a length byte of 0
and no data.  This tells the host to close the file.  Further calls
to X-LOG will over-write the existing TARGET.LOG file.
--------------------------------------------------------------------- }

[UNDEFINED] .' [IF]

: .' ( a -- )     250 (X-EMIT)
   3 0 DO  DUP 8 RSHIFT  LOOP
   4 0 DO  (X-EMIT)  LOOP ;

[THEN]

[UNDEFINED] X-LOG [IF]

: X-LOG ( addr u -- )
   BEGIN  DUP 0> WHILE
      2DUP 2>R  255 MIN  247 (X-EMIT) DUP (X-EMIT)
      0 DO  DUP C@ (X-EMIT) 1+  LOOP DROP
   2R> SWAP 255 + SWAP 255 -  REPEAT 2DROP ;

: X-CLOSE ( -- )   247 (X-EMIT) 0 (X-EMIT) ;

[THEN]

{ ---------------------------------------------------------------------
XTL initialization

XTL-TERMINAL sets the terminal I/O vectors for the serial XTL
terminal client.

DEBUG-LOOP is the generic serial XTL entry point.  It sets the
terminal I/O vectors, initializes the XTL port, sens the <NAK>
code, and enters the infinite XTL loop.
--------------------------------------------------------------------- }

: XTL-TERMINAL ( -- )
   ['] (X-EMIT) 'EMIT !  ['] (X-TYPE) 'TYPE !
   ['] (X-CR) 'CR !  ['] (X-PAGE) 'PAGE !
   ['] (X-ATXY) 'ATXY !  ['] (GETXY) 'GETXY !
   ['] (X-KEY) 'KEY !  ['] (X-KEY?) 'KEY? !
   ['] (X-ACCEPT) 'ACCEPT !  ['] (X-STRAIGHT) 'STRAIGHT ! ;

: DEBUG-LOOP ( -- )
   XTL-TERMINAL  /XTL  <NAK> (X-EMIT)  XTL ;
