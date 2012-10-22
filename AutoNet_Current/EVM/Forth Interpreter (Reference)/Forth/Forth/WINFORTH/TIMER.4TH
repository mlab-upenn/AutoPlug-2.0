\ Timer module
\ Copyright 1986-1993 Laboratory Microsystems Inc.

\ !TIMER and .TIMER can be used for precise timing of bench- 
\ marks etc.  All calculations are done at the display end
\ for minimal impact on the events being timed. 

FORTH DEFINITIONS DECIMAL

2VARIABLE DSECS \ double precision hundredths of sections

( @time --- d_hundredths_of_seconds )
: DHMS>DSECS    SWAP >R DUP >R  255 AND 0        ( hundredths )
                R> >< 255 AND 100 M* D+           ( + seconds )
                R@ >< 255 AND 60 *               ( hours * 60 )
                R> 255 AND +                      ( + minutes )
                6000 M*                 ( dsec=minutes * 6000 )
                D+ ;               ( return total deciseconds )

\ --- ; start timer 
: !TIMER        @TIME  DSECS 2!  ;

\ --- d ;  return elapsed time since last execution of !TIMER 
\          as double integer, hundredths of seconds 
: @TIMER        @TIME  DHMS>DSECS
                DSECS   2@     DHMS>DSECS  D-  ;

\ --- ; display elapsed time in hundredths of seconds 
\       since last execution of !TIMER 
: .TIMER        @TIMER  <#  # # ASCII . HOLD #S #> TYPE SPACE ;

CR .( Timer utility loaded.) CR 


