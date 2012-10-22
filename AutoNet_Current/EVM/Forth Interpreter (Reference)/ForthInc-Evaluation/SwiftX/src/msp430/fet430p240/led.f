{ =====================================================================
LED driver

Copyright (C) 2002  FORTH, Inc.

This file supplies the LED initialization and control words for the
FET430P240 board.  The LED is connect to Port 1 Bit 0.
===================================================================== }

TARGET

{ ---------------------------------------------------------------------
LED output control

+LED turns the LED on.
-LED turns the LED off.
/LED initializes the LED pin as an output, initial condition off.
--------------------------------------------------------------------- }

CODE +LED ( -- )   1 # P1OUT & BIS.B   RET   END-CODE
CODE -LED ( -- )   1 # P1OUT & BIC.B   RET   END-CODE
CODE /LED ( -- )   1 # P1DIR & BIS.B   1 # P1OUT & BIC.B   RET   END-CODE

