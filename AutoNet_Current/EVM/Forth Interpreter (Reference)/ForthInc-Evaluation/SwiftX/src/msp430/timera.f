{ =====================================================================
TIMER A 32.768 kHz INTERRUPT

Copyright (C) 2001  FORTH, Inc.

Timer A is clocked by ACLK (aux clock) which is driven by a
32.768 kHz watch crystal for timing and clock functions.

===================================================================== }

TARGET

{ ---------------------------------------------------------------------
Millisecond interval timer

SECS contains the 32-bit number of seconds since midnight.  This may
accumulate a number of days up to 136 years.

MSECS is the millisecond accumulator.  The interrupt rate is 1024 Hz
which is not an even 1 MS interval, so we accumulate a fractional
component in MSECS CELL+ and the integral number of milliseconds
in MSECS.

<MSEC> is the millisecond interrupt.  The fractional and integer
components are accumulated in MSECS.

COUNTER returns the current free-running millisecond counter.
--------------------------------------------------------------------- }

2VARIABLE MSECS   3 CELLS BUFFER: SECS

1024 EQU T/S                            \ Interrupt rate - "ticks per second"
32768 T/S / EQU T(MS)                   \ Inverval in TAR units between ticks

$10000 1000 T/S */  $10000 /MOD
   EQU K0(MS)  EQU K1(MS)

$10000 T/S /MOD
   EQU K1(S)   EQU K0(S)

LABEL <MSEC>
   K1(MS) # MSECS CELL+ ADD             \ Add ms fractional component
   K0(MS) # MSECS ADDC                  \ Accumulate ms integer component
   K1(S) # SECS CELL+ CELL+ ADD         \ Add sec fractional component
   K0(S) # SECS CELL+ ADDC   SECS ADC   \ Accumulate sec integer component
   RETI   END-CODE

<MSEC> TIMERA0_VECTOR INTERRUPT

: COUNTER ( -- n )   MSECS @ ;

{ ---------------------------------------------------------------------
Clock/calendar timekeeping

@SECS and !SECS fetch and store the double quantity in SECS with
interrupts prevented in case of rollover.

TODAY holds the date in MJD format.  See the generic SwiftX calendar
support for details about MJD format.

S/DAY is the number of seconds per day.

@NOW returns the number of seconds since midnight as a double number
and the MJD date as a single.

!NOW sets the date and time with the same parameters returned by @NOW.
--------------------------------------------------------------------- }

CODE @SECS ( -- d )
   4 # S SUB   T 2 (S) MOV   DINT
   SECS CELL+ 0 (S) MOV   SECS T MOV
   EINT   RET   END-CODE

CODE !SECS ( d -- )
   DINT   T SECS MOV   @S+ SECS 2+ MOV
   EINT   TPOP   RET   END-CODE

VARIABLE TODAY   86,400 2CONSTANT S/DAY

: @NOW ( -- ud u)   @SECS
   BEGIN  2DUP S/DAY DU< NOT WHILE
      S/DAY D-  2DUP !SECS  1 TODAY +!
   REPEAT  TODAY @ ;

: !NOW ( ud u -- )   TODAY !  !SECS ;

{ ---------------------------------------------------------------------
Initialization

/TIMERA initializes Timer A to provide millisecond interval timing
and one-second time-of-day clock functions.  CCR0 is used for the
millisecond interval.
--------------------------------------------------------------------- }

: /TIMERA ( -- )
   0 TACTL !  0 TAR !                   \ Disable TA, clear counter
   T(MS) CCR0 !  CCIE CCTL0 !           \ Set CCR0 for initial MS interval measurement
   $110 TACTL ! ;                       \ Start TA, input from ACLK, count up mode
