{ =====================================================================
Dumb terminal personality

Copyright (c) 2001  FORTH, Inc.

This files defines a "dumb" terminal personality for use by serial
terminal tasks.

Exports: DUMB
===================================================================== }

TARGET

{ ---------------------------------------------------------------------
Dumb terminal vectored behaviors

(DUMB-CR) and (DUMB-PAGE) perform generic dumb terminal output for the
'CR and 'PAGE vectors.

DUMB sets the 'CR and 'PAGE vectors to (DUMB-CR) and (DUMB-PAGE).  It
also sets 'ATXY to 2DROP so no action is performed for cursor positioning.
--------------------------------------------------------------------- }

TARGET

: (DUMB-CR)   13 EMIT  10 EMIT ;

: (DUMB-PAGE)   12 EMIT ;

: (DUMB-ATXY) ( x y -- )   2DROP  PAUSE ;

: (DUMB-GETXY) ( -- x y )   0 0  PAUSE ;

: DUMB   ['] (DUMB-CR) 'CR !  ['] (DUMB-PAGE) 'PAGE !
   ['] 2DROP 'ATXY !  ['] (DUMB-GETXY) 'GETXY ! ;

