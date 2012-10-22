{ =====================================================================
Common MSP430 initialization

Copyright 2001  FORTH, Inc.

Initialization and system start-up common to MSP430 kernels.
Important: ****LOAD THIS FILE SECOND TO LAST****

Exports: SAVE-IDATA, SAVE-CHECKSUM, SYNC-CORE, /IDATA
===================================================================== }

TARGET

{ ---------------------------------------------------------------------
Initialized data space

IN-DATA holds a copy of initialized data table in code space for /IDATA
to move into data space in START.  CHECKSUM holds the code space
checksum set by SAVE-CHECKSUM.
--------------------------------------------------------------------- }

IDATA  LIMITS DROP EQU IN-DATA
   HERE IN-DATA - EQU DATA-SIZE

CDATA  HERE EQU IN-CODE  DATA-SIZE ALLOT
   ALIGN  HERE 0 ,  EQU CHECKSUM

IDATA

INTERPRETER

: SAVE-IDATA ( -- )   DATA-SIZE 0 ?DO  IN-DATA I + C@
   IN-CODE I + C!C  LOOP ;

: SAVE-CHECKSUM ( -- )   0  CDATA LIMITS SWAP DO  I C@C +  LOOP
   CHECKSUM !C  IDATA ;

: -CHECKSUM ( -- flag )   CONNECT  CHECKSUM @C
   DISCONNECT  CHECKSUM @C <> ;

: SYNC-CORE ( -- )   -CHECKSUM ABORT" KERNEL MISMATCH"
   CONNECT TARGET ;

TARGET

: /IDATA ( -- )   IN-CODE IN-DATA DATA-SIZE CMOVE ;

{ ---------------------------------------------------------------------
Initial task table

OPERATOR has the initial values for the user area of the task which
has control when the system powers up.  The first cell has the address
of the user area, the remainder has the values to copy into it.  This table
resides in code space.

|OPERATOR| is the size of the initial data for the task's user area.
--------------------------------------------------------------------- }

TARGET  CDATA

CREATE OPERATOR
   'R0 ,                        \ Pointer to user area
   SLEEP , <LPM> ,              \ STATUS, FOLLOWER is Low-Power Mode handler
   0 , 0 , 'S0 ,                \ SSAVE, RSAVE, S0
   0 ,  10 ,                    \ CATCHER, BASE
   'H0 DUP , ,                  \ H, H0
   @LAST ,                      \ LAST

HERE OPERATOR CELL+ - EQU |OPERATOR|   IDATA

