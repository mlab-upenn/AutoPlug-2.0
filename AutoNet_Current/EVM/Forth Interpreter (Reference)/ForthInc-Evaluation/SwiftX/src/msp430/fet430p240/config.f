{ =====================================================================
FET430P240 TARGET ENVIRONMENT CONFIGURATION

Copyright 2001  FORTH, Inc.

The target environment is configured here for the MSP-FET430P240
with the MSP430F2619.

===================================================================== }

INTERPRETER

{ ---------------------------------------------------------------------
Memory map

The code and data memory sections are defined here.

The parameter and return stack addresses are also placed in TS0 and
TR0 for use by the cross-target link (XTL).

Note that we use the "mirrored" SRAM in address space below $1100 to
prevent the downloader from doing a flash erase on it.
--------------------------------------------------------------------- }

HEX

0200 02FF IDATA SECTION IRAM            \ Initialized data ("mirror" of 1100-11FF)
1200 20FF UDATA SECTION URAM            \ Uninitialized data
2100 FFFF CDATA SECTION PROG            \ Main program in flash memory

|PAD| |NUM| + RESERVE EQU 'H0           \ Target dictionary
|S| RESERVE  |S| + EQU 'S0              \ Target data stack
|R| |U| + RESERVE  |R| + EQU 'R0        \ Target return stack + task user area

'S0 TS0 !  'R0 TR0 !                    \ Set cross-target link pointers
LPM3 EQU LPMODE                         \ Establish low-power mode
DECIMAL  TARGET  IDATA                  \ Defaults

0 EQU TARGET-INTERP                     \ Target-resident interpreter (0=no, 1=yes)
TARGET-INTERP [IF]  +HEADS  [THEN]      \ Target heads for resident interpreter
