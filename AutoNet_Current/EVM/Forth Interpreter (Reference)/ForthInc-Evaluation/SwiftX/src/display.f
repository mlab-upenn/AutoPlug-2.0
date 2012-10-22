{ =====================================================================
LCD display interface

Copyright (c) 1972-2000, FORTH, Inc.

This file supplies the SwiftX LCD terminal output routines for the
LCD displays which can be connected to the Axiom development boards.

Requires: !LCD-CMD !LCD-DAT @LCD-CMD @LCD-DAT
===================================================================== }

TARGET

{ ---------------------------------------------------------------------
LCD command set

These are the commands for the LCD controller.
LCD-WAIT waits until the busy bit is clear.
!LCD-WAIT outputs a command and waits until not busy.
/LCD initializes the LCD.
--------------------------------------------------------------------- }

$38 EQU FUNC-SET        \ Function set: 8-bit, 2 lines, 5x7
$08 EQU DISP-OFF        \ Display off
$06 EQU MODE-SET        \ Entry mode
$0C EQU -CURSOR         \ Display on, cursor off
$0E EQU +CURSOR         \ Display on, cursor on
$01 EQU DISP-CLR        \ Clear display

: LCD-WAIT ( -- )   BEGIN  PAUSE  @LCD-CMD
   $80 AND  0= UNTIL ;

: !LCD-WAIT ( char  -- )   !LCD-CMD LCD-WAIT ;

: /LCD ( -- )
   4 0 DO  FUNC-SET !LCD-CMD  2 MS  LOOP
   DISP-OFF !LCD-WAIT  DISP-CLR !LCD-WAIT
   MODE-SET !LCD-WAIT  -CURSOR !LCD-WAIT ;

{ ---------------------------------------------------------------------
LCD terminal driver

These functions supply the terminal output routines for the LCD.
LCD-TERMINAL sets the outuput vectors.

#ROWS and #COLS define the layout of the LCD.  This driver assumes
that for display with more than 2 lines, the DDRAM maps physical line 2
as part of logical line 0.  LINE# holds the last LINE# positioned by
(D-ATXY) and is cleared by (D-PAGE).

Notes:
Data written to the display are not buffered.
Scrolling is not supported.
The CR function places the cursor at the start of the next line.
--------------------------------------------------------------------- }

4 EQU #ROWS   20 EQU #COLS   CVARIABLE LINE#

: (D-EMIT) ( char -- )   !LCD-DAT LCD-WAIT ;

: (D-TYPE) ( c-addr len -- )
   0 ?DO COUNT  (D-EMIT)  LOOP DROP ;

: (D-PAGE) ( -- )   DISP-CLR !LCD-WAIT  0 LINE# C! ;

: (D-ATXY) ( x y -- )   SWAP #COLS MIN  SWAP #ROWS MIN  DUP LINE# C!
   2 /MOD #COLS *  SWAP $40 *  + + $80 + !LCD-WAIT ;

: (D-CR) ( -- )   0 LINE# C@ 1+  #ROWS MOD (D-ATXY) ;

: LCD-TERMINAL ( -- )
   ['] (D-EMIT) 'EMIT !  ['] (D-TYPE) 'TYPE !
   ['] (D-CR) 'CR !  ['] (D-PAGE) 'PAGE !
   ['] (D-ATXY) 'ATXY ! ;

