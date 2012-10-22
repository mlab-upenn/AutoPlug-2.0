{ =====================================================================
Conical piles demo

Copyright (c) 1972-2000, FORTH, Inc.

This program is a SwiftX version of the sample program in "Starting
Forth" (2nd ed., p. 302).  Refer to the book for the formulas used and
further description.

Dependencies:

Exports:
===================================================================== }

TARGET

{ ---------------------------------------------------------------------
Conical pile calculator

DENSITY and THETA hold the values from the table below.
MATTER points to the counted string which describes the material.
ACCM is the accumulator used by material calculations.

.SUBSTANCE displays material description.
.ERROR issues the invalid value message.
FOOT accumulates number of feet (max 50), multiplied by 10.
INCH accumulates inches (max 11).
PILE uses /TAN to calculate weight for height n, and displays result.
--------------------------------------------------------------------- }

VARIABLE DENSITY
VARIABLE THETA
VARIABLE MATTER
VARIABLE ACCM

: .SUBSTANCE ( -- )   MATTER @  COUNT TYPE CR ;

: .ERROR ( x -- )   DROP  ." Error "  CR ;

: FOOT ( n -- )   DUP 51 < IF  10 *  ." Feet" CR
   ELSE  .ERROR  THEN ;

: INCH ( n1 n2 -- )   DUP 12 < IF  100 12 */  5 + 10 /  +
   ." Inches" CR  ELSE  .ERROR  THEN ;

: /TAN ( n1 -- n2 )   1000 THETA @  */ ;

: PILE ( n -- )   DUP DUP 10 */  1000 */  355 339 */  /TAN /TAN
   DENSITY @  200 */  ." = "  .  ." Tons of " .SUBSTANCE ;

{ ---------------------------------------------------------------------
Conical pile parameters

MATERIAL defines a named material given its density (n1) and theta (n2)
values.  It is followed by a text string enclosed in double quotes which
is compiled into the word's parameter field following the density and
theta values.

TABLE holds the list of execution tokens for the material words.

SELECT executes material n in table.  Sets THETA, DENSITY and MATTER.

#INPUT inputs a numeric value and a single letter.
.DIREECTIONS displays user prompt and materials list.
CALCULATE is the main program entry point.  Exits when Esc is pressed.
--------------------------------------------------------------------- }

INTERPRETER

: MATERIAL ( n1 n2 -- )   CREATE , ,    \ Define material selection word
      [CHAR] " WORD DROP                \ Skip to start of description
      [CHAR] " WORD  COUNT DUP C,       \ Compile count byte
      0 DO  COUNT C,  LOOP DROP  ALIGN  \ Compile description string
   DOES> ( -- )  DUP 2@                 \ Run-time behavior
      THETA !  DENSITY !                \ Set numeric parameters
      CELL+ CELL+ MATTER ! ;            \ Save pointer to description string

TARGET

\ Density   Theta
      131     700   MATERIAL CEMENT             "Cement"
       93     649   MATERIAL LOOSE-GRAVEL       "Loose gravel"
      100     700   MATERIAL PACKED-GRAVEL      "Packed gravel"
       90     754   MATERIAL DRY-SAND           "Dry sand"
      118     900   MATERIAL WET-SAND           "Wet sand"
      120     727   MATERIAL CLAY               "Clay"

CREATE TABLE   ' CEMENT ,  ' LOOSE-GRAVEL ,  ' PACKED-GRAVEL ,
   ' DRY-SAND ,  ' WET-SAND ,  ' CLAY ,

: SELECT ( n -- )   DUP 6 < IF  CELLS TABLE + @EXECUTE  .SUBSTANCE
   ELSE  .ERROR  THEN ;

: #INPUT ( -- n char )   0  BEGIN  KEY DUP 48 58 WITHIN WHILE
   DUP EMIT  48 - SWAP 10 * +  REPEAT  SPACE ;

: .DIRECTIONS ( -- )   CR ." Enter material, feet, inches: nM nF nI ="
   CR  6 0 DO  I 4 U.R  ." M = "  I SELECT  LOOP ;

: CALCULATE ( -- )
   0 ACCM !  PAGE  .DIRECTIONS  CEMENT
   BEGIN  #INPUT  CASE
      [CHAR] M OF  SELECT  ENDOF
      [CHAR] F OF  FOOT ACCM !  ENDOF
      [CHAR] I OF  ACCM @  SWAP INCH  ACCM !  ENDOF
      NIP  [CHAR] = OF  ACCM @ PILE  0 ACCM !  ENDOF
      $1B ( Esc) OF  EXIT  ENDOF
   ENDCASE  AGAIN ;

