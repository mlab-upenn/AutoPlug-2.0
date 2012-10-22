{ =====================================================================
VT100 terminal personality

Copyright (c) 1972-2000, FORTH, Inc.

This files defines a VT100 terminal personality for use by
terminal tasks.

===================================================================== }

TARGET

{ ---------------------------------------------------------------------
VT100 terminal vectored behaviors

(VT100-CR) and (VT100-PAGE) perform generic VT100 terminal output for the
'CR and 'PAGE vectors.

VT100 sets the terminal output vectors to their VT100 behaviors.
--------------------------------------------------------------------- }

: (VT100-CR) ( -- )   13 EMIT  10 EMIT ;

: CSI ( -- )   27 EMIT  ." [" ;

: (VT100-PAGE) ( -- )   CSI ." H"  CSI  ." 2J" ;

: (VT100-ATXY) ( x y -- )   BASE @ >R DECIMAL  CSI
   ?DUP IF  1+ 0 U.R  THEN  ." ;"
   ?DUP IF  1+ 0 U.R  THEN  ." H"  R> BASE ! ;

: (GETPOS) ( -- n )
   0  BEGIN  KEY  DUP 48 58 WITHIN WHILE  48 - SWAP 10 * +
   REPEAT DROP  ?DUP IF  1-  THEN ;

: (VT100-GETXY) ( -- x y )
   0 0  CSI ." 6n"  BEGIN  KEY 27 =  UNTIL
   KEY [CHAR] [ = IF  2DROP  (GETPOS) (GETPOS) SWAP  THEN ;

: VT100   ['] (VT100-CR) 'CR !  ['] (VT100-PAGE) 'PAGE !
   ['] (VT100-ATXY) 'ATXY !  ['] (VT100-GETXY) 'GETXY ! ;

