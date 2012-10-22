{ =====================================================================
TIMER A INTERRUPT - NO XT2

Copyright (C) 2008  FORTH, Inc.

Timer A is clocked by ACLK (aux clock) which is *not* driven by a
32.768 kHz watch crystal for timing and clock functions.  The target
project's Config.f must supply the nominal frequency of ACLK.  This
version does not supply time/date keeping, just an approximate
millisecond counter.
===================================================================== }

TARGET

{ ---------------------------------------------------------------------
Millisecond interval timer

MSECS is the millisecond accumulator.

<MSEC> is the millisecond interrupt.

COUNTER returns the current free-running millisecond counter.
--------------------------------------------------------------------- }

VARIABLE MSECS

ACLK 1000 / EQU K(MS)

LABEL <MSEC>
   1 # MSECS ADD   RETI   END-CODE

<MSEC> TIMERA0_VECTOR INTERRUPT

: COUNTER ( -- n )   MSECS @ ;

{ ---------------------------------------------------------------------
Initialization

/TIMERA initializes Timer A to provide millisecond interval timing
and one-second time-of-day clock functions.  CCR0 is used for the
millisecond interval.
--------------------------------------------------------------------- }

: /TIMERA ( -- )
   4 TACTL !                            \ Reset TA, clear counter
   K(MS) CCR0 !  CCIE CCTL0 !           \ Set CCR0 for initial MS interval measurement
   $110 TACTL ! ;                       \ Start TA, input from ACLK, count up mode
