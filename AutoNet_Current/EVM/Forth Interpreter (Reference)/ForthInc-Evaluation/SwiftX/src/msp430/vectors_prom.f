{ =====================================================================
MSP430 PROM interrupt vectors

Copyright (C) 2001  FORTH, Inc.

This file supplies an interface to the MSP430 interrupt vectors for
parts with limited RAM.  It does not support revectoring the interrupts
through a RAM dispatch table and therefore does not provide run-time
modification of interrupt vectors.

Use this version if you don't have enough RAM to support the interrupt
vector dispatch table or of you don't need run-time vector modification.
===================================================================== }

TARGET

{ ---------------------------------------------------------------------
Exception vector interface

<RTI> is the default dummy interrupt handler.

INTERRUPT takes the handler address and vector name (defined in REG_xxx.F)
and puts the address in the interrupt vectors.

/VECTORS sets the initial interrupt vectors to all point to <RTI>.

/INTERRUPTS enables interrupts.
--------------------------------------------------------------------- }

LABEL <RTI>   RETI   END-CODE

INTERPRETER

: /VECTORS ( -- )
   $FFFE $FFE0 DO  <RTI> I !C  2 +LOOP ;

: INTERRUPT ( addr v -- )   !C ;

TARGET  /VECTORS

CODE /INTERRUPTS ( -- )
   EINT   RET   END-CODE

