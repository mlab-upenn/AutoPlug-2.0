{ =====================================================================
Low-power mode

Copyright (C) 2001-2002  FORTH, Inc.

This file implements the low-power mode control as integrated into
the SwiftX multitasker.

===================================================================== }

TARGET

{ ---------------------------------------------------------------------
Multitasker power mode control

'LP holds the low-power mode specifier.  The initial default is LPMODE,
but this may be changed to AM if a JTAG XTL session is active.
Can be set to LPM0 - LPM4 as needed by the application.

The ?XTL flag is set if a JTAG XTL session is active.  In this case,
the LPM has been set to AM on entry to the XTL DEBUG-LOOP and !LPM
is prevented from changing the low-power mode.

<LPM> is patched into the multitasker in the OPERATOR initialization table.

!LPM sets 'LP to one of AM or LPM0 through LPM4.

The only way to get out of low-power mode and resume the task processing
is for an interrupt routine to clear the LPM bits in the stack frame.
Include this instruction (assumes the stacked SR is the top item on
the interrupt stack frame) when it is time to resume task processing:

   &LPM # 0 (SP) BIC    \ Clear LPM bits in stacked SR

--------------------------------------------------------------------- }

CREATE 'LP   LPMODE ,

VARIABLE ?XTL

LABEL <LPM>
   U TST  0= IF   'LP & SR BIS   THEN
   U CLR   'R0 # BR   END-CODE

: !LPM ( u -- )
   ?XTL @ IF  DROP  ELSE  'LP !  THEN ;

