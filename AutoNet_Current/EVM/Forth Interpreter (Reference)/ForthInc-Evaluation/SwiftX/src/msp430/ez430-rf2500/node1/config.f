{ =====================================================================
eZ430-RF2500 TARGET ENVIRONMENT CONFIGURATION

Copyright 2008  FORTH, Inc.

The target environment is configured here for the eZ430-RF2500
as shipped with the MSP430F2274.

===================================================================== }

INTERPRETER   HEX

{ ---------------------------------------------------------------------
Memory map

The code and data memory sections are defined here.

The parameter and return stack addresses are also placed in TS0 and TR0
for use by the cross-target link (XTL).
--------------------------------------------------------------------- }

HEX

0200 02FF IDATA SECTION IRAM            \ Initialized data
0300 05FF UDATA SECTION URAM            \ Uninitialized data
8000 FFFF CDATA SECTION PROG            \ Main program in flash memory

|PAD| |NUM| + RESERVE EQU 'H0           \ Target dictionary
|S| RESERVE  |S| + EQU 'S0              \ Target data stack
|R| |U| + RESERVE  |R| + EQU 'R0        \ Target return stack + task user area

'S0 TS0 !  'R0 TR0 !                    \ Set cross-target link pointers
LPM3 EQU LPMODE                         \ Establish low-power mode
DECIMAL  TARGET  IDATA                  \ Defaults

12000 EQU ACLK                          \ Nominal ACLK (from VLOCLK)