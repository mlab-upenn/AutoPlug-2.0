{ =====================================================================
Memory dump

Copyright (c) 1972-2000, FORTH, Inc.

This file provides DUMP tool for 16-bit cell-addressed targets.
Also supplies DUMPC for targets with separate code space.

Exports: DUMP  DUMPC
===================================================================== }

TARGET

{ ---------------------------------------------------------------------
Basic debug tools

DUMP displays u bytes of memory starting at c-addr.
--------------------------------------------------------------------- }

: DUMP ( c-addr u -- )   0 ?DO  I 7 AND 0= IF  CR
   DUP 4 .HEX SPACE  THEN  DUP @ 4 .HEX  CELL+  LOOP DROP ;

[DEFINED] @C [IF]

: DUMPC ( c-addr u -- )   0 ?DO  I 7 AND 0= IF  CR
   DUP 4 .HEX SPACE  THEN  DUP @C 4 .HEX  CELL+  LOOP DROP ;

[THEN]

