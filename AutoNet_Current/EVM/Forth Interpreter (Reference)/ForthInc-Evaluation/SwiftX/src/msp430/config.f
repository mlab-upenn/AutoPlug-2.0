{ =====================================================================
Common MSP430 target configuration

Copyright 2001  FORTH, Inc.

These parameters describe generic kernel configuration
===================================================================== }

TARGET

32 EQU |S|      \ Size of data stack in bytes
64 EQU |R|      \ Size of return stack
64 EQU |U|      \ Size of user area

80 EQU |TIB|    \ Size of Terminal Input Buffer
84 EQU |PAD|    \ Size of PAD
34 EQU |NUM|    \ Size numeric output string buffer
