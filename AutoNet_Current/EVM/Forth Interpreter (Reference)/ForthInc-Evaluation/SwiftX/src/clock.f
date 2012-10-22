{ =====================================================================
Clock

Copyright (c) 1972-2000, FORTH, Inc.

This clock represents the system time as a double number of seconds since
midnight which is compatible with both 16- and 32-bit systems.

Requires: @NOW  !NOW

Exports: (TIME)  .TIME  @TIME  TIME  HOURS
===================================================================== }

TARGET

{ ---------------------------------------------------------------------
Time display and entry

(TIME) formats the system time (ud) as a string with the format hh:mm:ss.
.TIME displays the system time (ud) as hh:mm:ss.
TIME gets the current system time and displays it.

HOURS takes the time as a double number which was entered as hh:mm:ss,
converts it to a system time and sets the clock with existing date.
--------------------------------------------------------------------- }

: :00 ( ud1 -- ud2)   DECIMAL  #  6 BASE !  # [CHAR] : HOLD ;

: (TIME) ( ud -- c-addr u)   BASE @ >R  <#  :00 :00
   DECIMAL # #  #>  R> BASE ! ;

: .TIME ( ud -- )   (TIME) TYPE SPACE ;

: @TIME ( -- ud )   @NOW DROP ;

: TIME ( -- )   @TIME .TIME ;

: HOURS ( ud -- )   100 UM/MOD 100 /MOD  60 * +  60 UM*  ROT M+
   @NOW NIP NIP !NOW ;

