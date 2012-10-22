{ =====================================================================
Debug tools

Copyright (c) 1972-2000, FORTH, Inc.

This file implements a basic of Forth debug tools.

Exports: ? .S .HEX
===================================================================== }

TARGET

{ ---------------------------------------------------------------------
Basic debug tools

? displays the contents of a cell in memory.
.S displays the target stack.
.HEX displays unsigned value u1 in a field at least u2 characters wide.
>BODY takes xt and returns PFA pointer.  Not available in all targets.
--------------------------------------------------------------------- }

: ? ( a-addr -- )   @ . ;

: .S ( x*i -- x*i )   CR  DEPTH ?DUP IF
      DUP 0< ABORT" Stack empty"
      0 SWAP 1- DO  I PICK .  -1 +LOOP
   THEN  ." <-Top " ;

: .HEX ( u1 u2 -- )   BASE @ >R  HEX  0 <#  SWAP 1-
   0 ?DO  #  LOOP  #S  #> TYPE SPACE  R> BASE ! ;

[DEFINED] |CFA| [IF]

: >BODY ( xt -- addr )   |CFA| +
   [DEFINED] @C [IF] @C [ELSE] @ [THEN] ;

[THEN] 

