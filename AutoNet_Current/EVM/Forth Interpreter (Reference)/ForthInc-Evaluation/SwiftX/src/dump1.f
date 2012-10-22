{ =====================================================================
Memory dump

Copyright (C) 2001  FORTH, Inc.

This file provides DUMP tool for byte-addressed targets.
Also supplies DUMPC for targets with separate code space.

Exports: DUMP  DUMPC
===================================================================== }

TARGET

{ --------------------------------------------------------------------
ASCII formatted dump

DUMP  displays memory formatted in lines of up to 16 bytes.  Both HEX
and ASCII representations are shown.  The exact amount of bytes
requested are displayed.

If the target system has a C@C (indicating separate code space),
we also provide DUMPC.
-------------------------------------------------------------------- }

DEFER @DUMP ( addr -- char )   ' C@ IS @DUMP

: DUMPHEX ( addr n -- )
   16 0 DO
      DUP 0> IF  OVER @DUMP 2 .HEX  ELSE  3 SPACES  THEN
   1 /STRING  LOOP 2DROP ;

: DUMPTEXT ( addr n -- )
   16 0 DO
      DUP 0> IF  OVER @DUMP  DUP 127 32 WITHIN IF  DROP [CHAR] .  THEN EMIT
      ELSE  SPACE  THEN
   1 /STRING  LOOP 2DROP ;

: DUMP ( addr n -- )
   BEGIN  DUP 0> WHILE  CR OVER 4 .HEX SPACE
      2DUP 16 MIN  2DUP DUMPHEX  SPACE  DUMPTEXT
   16 /STRING  REPEAT  2DROP ;

[DEFINED] C@C [IF]

: DUMPC ( addr n -- )   ['] C@C IS @DUMP  DUMP ;
-? : DUMP ( addr n -- )   ['] C@ IS @DUMP  DUMP ;

[THEN]

