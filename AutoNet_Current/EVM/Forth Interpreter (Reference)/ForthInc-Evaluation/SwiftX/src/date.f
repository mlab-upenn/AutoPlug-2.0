{ =====================================================================
System date

Copyright (c) 1972-2000, FORTH, Inc.

Requires: @NOW  !NOW  .DATE M/D/Y

Exports: @DATE  DATE  NOW
===================================================================== }

TARGET

{ ---------------------------------------------------------------------
Date access and display

@DATE returns the current system date.

DATE gets the current system date and displays it.

NOW takes the date as a double number which was entered as mm/dd/yyyy,
converts it to a system time and sets the system time and date.
--------------------------------------------------------------------- }

: @DATE ( -- u)   @NOW NIP NIP ;

: DATE ( -- )   @DATE .DATE ;

: NOW ( ud -- )   M/D/Y  @NOW DROP  ROT !NOW ;

