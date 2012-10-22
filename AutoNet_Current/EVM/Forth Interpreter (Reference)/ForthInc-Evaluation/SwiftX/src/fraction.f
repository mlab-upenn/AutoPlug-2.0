{ =====================================================================
Fractional angles and transcendentals

Copyright (c) 1972-2000, FORTH, Inc.

This file supplies fractional angle operators and trig functions.

Exports: Fractional angles, transcendental functions
===================================================================== }

TARGET

{ ---------------------------------------------------------------------
Fractional arithmetic operators

The 14-bit fixed point fraction arithmetic routines provide angular
resolution of approximately +/- 2 minutes of arc.  Fixed point
fractions are convenient representations of angles as fractions of
a whole revolution of a circle.

+1 returns the value 1 as a 14-bit fraction.
+1/4 returns the fraction for 1/4.  Used for angle conversions.

*. multiplies two numbers:
   integer * fraction --> integer
   fraction * integer --> integer
   fraction * fraction --> fraction

/. divides two numbers:
   fraction / fraction --> fraction
   integer / integer --> fraction
   integer / fraction --> fraction

Note that fractions can be added and subtracted using + and -.
--------------------------------------------------------------------- }

16384 EQU +1   +1 4 / EQU +1/4

: *. ( x1 x2 -- x3 )   +1 */ ;
: /. ( x1 x2 -- x3 )   +1 SWAP */ ;

{ ---------------------------------------------------------------------
Fractional output

(.F) formats a fraction with four decimal places.
.F types it.
--------------------------------------------------------------------- }

: (.F) ( f -- c-addr u )   10000 *.  DUP ABS
   0 <#  # # # #  [CHAR] . HOLD  #S  ROT SIGN  #> ;

: .F ( f -- )  (.F) TYPE SPACE ;

{ ---------------------------------------------------------------------
Trig functions

TRIANGLE converts a fractional angle (-652 degrees to +652 degrees)
into a fraction between -1/2 and +1/2 inclusive.  TRIANGLE is used so
that the boundary conditions of the polynomial approximation for COS
are met.

90-  offsets a 14-bit fractional angle by 90 degrees.  This allows the
sine routine to be written in terms of the cosine routine.

DEG converts number of degrees to a fractional angle.

SQRT. returns square root of a fraction.

COS is a polynomial approximation of cosine, using constants from the
book "Computer Approximations" by John F. Hart (Wiley, New York, 1968).
The polynomial is factored to minimize multiplications.  Fractional
arithmetic is used. (Hart 3300:  1.5709  -.64589  .07943  .00433)

The remaining functions are written in terms of  COS .  The functions
which are ratios of other trig functions leave two values on the stack
to form a ratio.  For example, TAN = SIN /COS; therefore, TAN leaves
two numbers on the stack.

ADJACENT uses the trigonometric identity
   (sine * sine) + (cosine * cosine) = 1
to convert a sine to a cosine and vice-versa.

ATAN  determines the correct octant, than normalizes the input
ratio so that the angle can be approximated with a polynomial
for that octant.  The values are taken from Hart (above).
(Hart 4960:  .15920  -.05270  .02680  .41421)

ASIN uses ADJACENT to produce the two fractions normally produced by TAN,
using the single fraction from SIN .

ACOS uses ADJACENT similarly to process the fraction from COS .
--------------------------------------------------------------------- }

: TRIANGLE ( f1 -- f2 )   2* 2*
   $FFFF AND  $8000 XOR  $8000 -
   ABS  +1 SWAP - ;

: 90- ( f1 -- f2 )   +1/4 - ;
: DEG ( n -- f )   +1/4 90 */ ;
: SQRT. ( f1 -- f2 )   +1 M* SQRT ;

: COS ( a -- f )   TRIANGLE  DUP DUP *.  DUP -71 *.  1301 +
   OVER *.  -10582 +  *.  9352 +  OVER *. + ;

: SIN ( a -- f )   90- COS ;
: TAN ( a -- f f )   DUP SIN  SWAP COS ;
: COT ( a -- f f )   TAN SWAP ;
: CSC ( a -- f f )   COS +1 SWAP ;

: ADJACENT ( f -- f )   DUP NEGATE M*  $10000000. D+  SQRT ;

HEX

CREATE 'ATAN   
    1400 ,  -1C00 ,  -2C00 ,   2400 ,
   -0C00 ,   0400 ,   3400 ,  -3C00 ,

DECIMAL

: ATAN ( n1 n2 -- a )   DUP 0< >R  ABS  SWAP DUP 0< R> D2* >R DROP ABS
   2DUP > R> D2* >R  IF SWAP THEN  /.  DUP -6786 +  SWAP 6786 *.
   +1 + /.  DUP DUP *.  DUP 438 *.  -864 + *.  2607 + *.
   R> 4 + CELLS  'ATAN + @ + ABS ;

: ASIN ( f -- a)   DUP ADJACENT ATAN ;
: ACOS ( f -- a)   DUP ADJACENT  SWAP ATAN ;

