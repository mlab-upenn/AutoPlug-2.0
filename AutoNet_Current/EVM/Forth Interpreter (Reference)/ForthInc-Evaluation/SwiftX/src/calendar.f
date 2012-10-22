{ =====================================================================
Calendar

Copyright (c) 1972-2000, FORTH, Inc.

The date is encoded as the number of days since 31 DEC 1899 which was a
Sunday.  The day of the week can be calculated from this with 7 MOD.

The useful range of dates that can be converted by this algorithm is from
1 MAR 1900 thru 28 FEB 2100.  Both of these are not leap years and are not
handled by this algorithm which is good only for leap years which are
divisible by 4 with no remainder.

Exports: D/M/Y  M/D/Y  (DATE)  .DATE
===================================================================== }

TARGET

{ ---------------------------------------------------------------------
Modified Julian Date

D/Y is the number of days for a four-year period which includes a leap day.

DAYS is the lookup table of total days in the year at the start of
each month.  @MTH  returns the value from days for the given month.

D/M/Y converts day, month, year into MJD.
M/D/Y takes a double number mm/dd/yyyy and converts it to MJD.
Y-DD and DM split the serial number back into its components.
--------------------------------------------------------------------- }

365 4 * 1+ CONSTANT D/Y

CREATE DAYS   -1 ,  0 ,  31 ,  59 ,  90 ,  120 ,  151 ,
   181 ,  212 ,  243 ,  273 ,  304 ,  334 ,  367 ,

: @MTH ( u1 -- u2)   CELLS DAYS + @ ;

: D/M/Y ( d m y -- u)   >R  @MTH
   58 OVER < IF  R@ 3 AND 0= - THEN + 1-
   R> 1900 -  D/Y UM*  4 UM/MOD SWAP 0<> - + ;

: M/D/Y ( ud -- u)   10000 UM/MOD  100 /MOD  ROT D/M/Y ;

: Y-DD ( u1 - y u2 u3)   4 UM* D/Y  UM/MOD 1900 +  SWAP 4 /MOD 1+
   DUP ROT 0= IF  DUP 60 > +  SWAP DUP 59 > +  THEN ;

: DM ( u1 u2 - d m)   1 BEGIN  1+  2DUP @MTH > NOT UNTIL  1-
   SWAP DROP SWAP  OVER @MTH - SWAP ;

{ ---------------------------------------------------------------------
Date display and setting

(DATE) formats system date u1 as a string with the format mm/dd/yyyy.
.DATE displays system date u as mm/dd/yyyy.
--------------------------------------------------------------------- }

: (DATE) ( u1 -- c-addr u2)   BASE @ >R  DECIMAL  Y-DD
   ROT 0 <#  # # # #  2DROP  [CHAR] / HOLD  DM SWAP
   0 # #  2DROP   [CHAR] / HOLD  0 # #  #>  R> BASE ! ;

: .DATE ( u -- )   (DATE) TYPE SPACE ;

