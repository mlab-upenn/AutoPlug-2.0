{ =====================================================================
Time and date

Copyright (c) 1972-2000, FORTH, Inc.

This file supplies the ANS TIME&DATE function to return the current system
time and date with a single call.  Also implements !TIME&DATE which allows
the time and date to be set.

Requires: @NOW  !NOW

Exports: TIME&DATE  !TIME&DATE
===================================================================== }

TARGET

{ ---------------------------------------------------------------------
ANS time and date

TIME&DATE returns current date and time as seconds, minutes, hours,
day, month, and year.

!TIME&DATE takes that same list of parameters and sets the system
time and date.
--------------------------------------------------------------------- }

: TIME&DATE ( -- +n1 +n2 +n3 +n4 +n5 +n6)       \ sec, min, hr, day, mth, yr
   @NOW >R  60 UM/MOD  60 /MOD  R> Y-DD DM ROT ;

: !TIME&DATE ( u1 u2 u3 u4 u5 u6)               \ sec, min, hr, day, mth, yr
   D/M/Y >R  60 * + 60 UM*  ROT M+  R> !NOW ;

