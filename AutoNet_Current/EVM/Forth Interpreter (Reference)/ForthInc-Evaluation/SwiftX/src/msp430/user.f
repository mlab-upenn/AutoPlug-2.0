{ =====================================================================
System user variables

Copyright (C) 2001  FORTH, Inc.

System user variables are defined here.
===================================================================== }

TARGET

0  2 +USER STATUS               \ # PC MOV or T CALL instruction
   2 +USER FOLLOWER             \ Address of next task's STATUS
CELL +USER SSAVE                \ Saved S of suspended task
CELL +USER RSAVE                \ Save R (SP) of suspended task
CELL +USER S0                   \ Initial S of empty data stack
CELL +USER CATCHER              \ Pointer to CATCH return stack frame
CELL +USER BASE                 \ Number conversion radix
CELL +USER H                    \ Pointer to "dictionary" RAM
CELL +USER H0                   \ Pointer to empty dictionary
CELL +USER LAST                 \ Pointer to last head in dictionary
CELL +USER 'EMIT                \ Vectored terminal I/O addresses
CELL +USER 'TYPE
CELL +USER 'CR
CELL +USER 'PAGE
CELL +USER 'ATXY
CELL +USER 'GETXY
CELL +USER 'KEY
CELL +USER 'KEY?
CELL +USER 'ACCEPT
CELL +USER 'STRAIGHT
CELL +USER DEVICE               \ Optional driver-dependent device info
CELL +USER X#
CELL +USER Y#
CELL +USER #TIB
CELL +USER >IN
CELL +USER STATE

EQU #USER

