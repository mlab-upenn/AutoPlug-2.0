{ =====================================================================
Memory dump

Copyright (c) 1972-2000, FORTH, Inc.

This file provides DUMP tool for 32-bit cell-addressed targets.
Also supplies DUMPC for targets with separate code space.

Exports: DUMP  DUMPC
===================================================================== }

TARGET

{ ---------------------------------------------------------------------
Basic debug tools

DUMP displays u bytes of memory starting at c-addr.
--------------------------------------------------------------------- }

: DUMP ( c-addr u -- )   0 ?DO  I 3 AND 0= IF  CR
   DUP 6 .HEX SPACE  THEN  DUP @ 8 .HEX  CELL+  LOOP DROP ;

[DEFINED] @C [IF]

: DUMPC ( c-addr u -- )   0 ?DO  I 3 AND 0= IF  CR
   DUP 6 .HEX SPACE  THEN  DUP @C 8 .HEX  CELL+  LOOP DROP ;

[THEN]

