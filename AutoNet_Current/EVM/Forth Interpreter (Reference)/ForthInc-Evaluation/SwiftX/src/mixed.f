{ =====================================================================
Mixed precision math

Copyright (c) 1972-2000, FORTH, Inc.

This file provides generic high-level mixed-precision (double and single
integer) math operators for implementations that do not supply them
in code.

Requires: UM*  UM/MOD

Exports: M*  UM*/  M*/
===================================================================== }

[UNDEFINED] M* [IF]

: M* ( n1 n2 -- d)   2DUP XOR >R  ABS  SWAP ABS UM*
   R> 0< IF  DNEGATE  THEN ;

[THEN]

: UT* ( ud u - ut)   DUP >R  SWAP >R  UM*  R> R> UM* >R
   0 SWAP  0 D+  R> + ;

: UT/ ( ut u - ud)   DUP >R UM/MOD  R> SWAP >R
   UM/MOD  SWAP DROP R> ;

: UM*/ ( ud1 u1 u2 -- ud2)   >R UT*  R> UT/ ;

: M*/ ( d1 n1 +n2 -- d2)   DUP 2OVER XOR >R DROP  >R >R
   DABS  R> ABS UT*  R> UT/  R> 0< IF  DNEGATE  THEN ;

