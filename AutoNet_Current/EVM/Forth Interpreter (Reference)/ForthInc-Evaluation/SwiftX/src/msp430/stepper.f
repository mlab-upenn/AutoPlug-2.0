{ =====================================================================
Single step support

Copyright (C) 2001  FORTH, Inc.

This file provides the target and interpreter support for single
stepping.  The compiler places calls to the debug breakpoint handler
between words in target Forth definitions between [DEBUG and DEBUG].

===================================================================== }

TARGET

{ ---------------------------------------------------------------------
Single-step trap handlers

<DEBUG> is the breakpoint handler when debugging is enabled.
It pushes the return stack address, the address of the next location
to be executed, and the STEPPING flag onto the data stack, then
calls BREAKPOINT to return control to the host.  When the host issues
the target RESUME command, it returns out of the breakpoint.

+DEBUG and -DEBUG enable and disable debugging.

DEBUG executes the target word that follows it in single-step
debug mode.
--------------------------------------------------------------------- }

$5A5A EQU STEPPING

VARIABLE ?DEBUG

LABEL <DEBUG>
   ?DEBUG TST                   \ Check flag
   0= IF   RET   THEN           \ Bail if not set
   6 # S SUB   T 4 (S) MOV      \ Allocate data stack frame
   R 2 (S) MOV                  \ Push return stack address
   @R 0 (S) MOV                 \ Address of next word to execute
   STEPPING # T MOV             \ Single-step indicator
   ' BREAKPOINT # BR            \ Return control to host
   END-CODE                     \ Continue in <-DEBUG>

<DEBUG> =BREAK

: +DEBUG ( -- )   -1 ?DEBUG ! ;
: -DEBUG ( -- )   0 ?DEBUG ! ;

INTERPRETER

: DEBUG ( -- )   /STEPPER
   ' [+TARGET] +DEBUG EXECUTE [PREVIOUS]
   BEGIN  DUP STEPPING = WHILE
      DROP $FFFF AND .STEPPER
   [+TARGET] RESUME [PREVIOUS]  REPEAT
   [+TARGET] -DEBUG  [PREVIOUS]  \STEPPER ;

TARGET

