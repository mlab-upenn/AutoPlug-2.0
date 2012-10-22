{ =====================================================================
Catch & throw exception handling

Copyright (C) 2001  FORTH, Inc.

This file implements the ANS exception handling with CATCH and THROW.

Requires:  User variable CATCHER

Exports: CATCH  THROW
===================================================================== }

TARGET

{ ---------------------------------------------------------------------
Exception frame operators

CATCH links a new exception frame on the return stack into the list
pointed to by user variable CATCHER, calls the execution token on the
stack.  If the called xt returns here, the exception frame is unlinked
and discarded, and 0 is returned on the data stack.  Each exception
frame has 2 cells: data stack pointer and previous contents of CATCHER.

THROW takes a throw code n from the data stack.  If n is 0 or there is
no exception frame (user variable CATCHER contains 0), THROW simply
returns to its caller.  If n is non-zero, the exception is thrown via
the exception frame set up by the most recent call to CATCH: the return
stack is set to the address held in CATCHER which is then updated from
the address on top of the return stack.  The parameter stack pointer is
also popped from the exception frame, the throw code n is placed on the
data stack, and control is returned immediately after the call to CATCH.

/STACKS clears stacks and the exception stack frame pointer.
--------------------------------------------------------------------- }

CODE CATCH ( i*x xt -- j*x 0 | i*x n )
   S PUSH   CATCHER (U) PUSH   R CATCHER (U) MOV
   T R8 MOV   TPOP   R8 CALL   CATCHER (U) POP
   2 # R ADD   TPUSH   T CLR   RET   END-CODE

CODE THROW ( k*x n -- k*x | i*x n )
   T TST   0= NOT IF   CATCHER (U) TST   0= NOT IF
      CATCHER (U) R MOV   CATCHER (U) POP   S POP
   RET   THEN THEN   TPOP   RET   END-CODE

CODE /STACKS ( i*x -- ) ( R: j*x -- )
   R8 POP   U R MOV   S0 (U) S MOV   T CLR
   CATCHER (U) CLR   R8 BR   END-CODE

