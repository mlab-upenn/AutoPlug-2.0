{ =====================================================================
Simple methods

Copyright (c) 1972-2000, FORTH, Inc.

This file uses the cross-compiler's simple methods support to define
VALUE and DEFER.

Requires: METHODS>, TO, @EXECUTE, ABORT

Exports: VALUE, DEFER, IS
===================================================================== }

INTERPRETER

{ ---------------------------------------------------------------------
Methods

VALUE is a core defining word which provides an example of assigning methods.
DEFER is a core defining word which allows deferred execution.
IS  sets the run-time action of words defined by  DEFER .
   INTERPRETER version assigns the action while loading and debugging.
   Usage example:
      DEFER PROC
      ...
      ' PROC1 IS PROC
   COMPILER version is used inside  TARGET definitions to assign the behavior
   at run-time.  Usage example:
      : FOO ( -- )  ['] PROC1 IS PROC ; 
--------------------------------------------------------------------- }

: VALUE ( x -- )   CREATE ,  METHODS> @ ! ;

: DEFER ( -- )   CREATE  ['] ABORT ,
   DOES> ( i*x -- j*x)   @EXECUTE ;

: IS ( xt -- )   ' >BODY ! ;

COMPILER

: IS ( -- )   [+INTERPRETER]  ' >BODY  [PREVIOUS]
   POSTPONE LITERAL  POSTPONE ! ; 

TARGET

