{ =====================================================================
MSP430 RAM interrupt vectors

Copyright (C) 2002  FORTH, Inc.

This file supplies an interface to the MSP430 interrupt vectors.
===================================================================== }

TARGET

{ ---------------------------------------------------------------------
Exception vector interface

<RTI> is the default dummy interrupt handler.

(INTERRUPTS) holds the compile-time image of the INTERRUPTS table.

INTERRUPTS is the run-time interrupt dispatch jump table.  All interrupt
vectors except RESET go through this table which allows vectors to be
set dynamically at run time.  This feature provides development support
while testing new interrupt handlers as well as allowing application code
to easily implement interrupt state machines.

INTERRUPT takes the handler address and vector name (defined in REG_xxx.F)
and puts the address in (INTERRUPTS) at compile time or INTERRUPTS at run
time.  Compile- and run-time versions are supplied.

/VECTORS sets the interrupt vectors to point into the INTERRUPTS
dispatch jump table at compile time.

/INTERRUPTS copies the (INTERRUPTS) code into the INTERRUPTS dispatch
jump table and enables interrupts.
--------------------------------------------------------------------- }

LABEL <RTI>   RETI   END-CODE

LABEL (INTERRUPTS)
   <RTI> # PC MOV   <RTI> # PC MOV   <RTI> # PC MOV   <RTI> # PC MOV
   <RTI> # PC MOV   <RTI> # PC MOV   <RTI> # PC MOV   <RTI> # PC MOV
   <RTI> # PC MOV   <RTI> # PC MOV   <RTI> # PC MOV   <RTI> # PC MOV
   <RTI> # PC MOV   <RTI> # PC MOV   <RTI> # PC MOV   END-CODE

15 2* CELLS BUFFER: INTERRUPTS

INTERPRETER

: /VECTORS ( -- )
   INTERRUPTS  $FFFE $FFE0 DO  DUP I !C  4 +  2 +LOOP DROP ;

TARGET  /VECTORS

INTERPRETER

: INTERRUPT ( addr v -- )   $FFE0 - 2* (INTERRUPTS) 2+ + !C ;

ASSEMBLER

: INTERRUPT ( addr v -- )   >R #  R> $FFE0 - 2* INTERRUPTS 2+ + & MOV ;

TARGET

: INTERRUPT ( addr v -- )   $FFE0 - 2* INTERRUPTS 2+ + ! ;

CODE /INTERRUPTS ( -- )
   (INTERRUPTS) # R8 MOV   INTERRUPTS # R9 MOV   15 2* # R10 MOV
   BEGIN   @R8+ 0 (R9) MOV   R9 INCD   R10 DEC   0= UNTIL
   EINT   RET   END-CODE

