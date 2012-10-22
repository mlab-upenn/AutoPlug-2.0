{ =====================================================================
Common exception handling

Copyright (c) 1972-2000, FORTH, Inc.

The generic ABORT behavior is defined here to use CATCH/THROW
exception handling.

Requires: CATCH THROW and TYPE

Exports: ABORT"
===================================================================== }

TARGET

{ ---------------------------------------------------------------------
Generic ABORT

ABORT implements its generic ANS behvior.
ABORT" compiles an in-line string and the run-time (ABORT") code.
--------------------------------------------------------------------- }

: ABORT ( -- )   -1 THROW ;

: (ABORT") ( flag -- )
   (("))  SWAP IF  CR COUNT TYPE  CR ABORT  THEN DROP ;

HOST

DECODE: (ABORT") .STRING

COMPILER

: ABORT"   POSTPONE (ABORT")  ",C ;

TARGET

