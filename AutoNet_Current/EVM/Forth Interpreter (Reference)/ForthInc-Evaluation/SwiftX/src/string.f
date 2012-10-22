{ ====================================================================
String operators

Copyright (c) 1972-2000, FORTH, Inc.

This file contains common string operators from the ANS Forth
Core, Core Extensions, and Strings word sets as well as the
SwiftForth S\" operators for compiling strings with special characters.

Requires: CMOVE  CMOVE>  FILL  COMPARE  (S")  (C")

Exports: ANS string operators and compiling words
==================================================================== }

TARGET

{ --------------------------------------------------------------------
Core supplemental

These high-level versions are compiled only if the underlying core code
does not supply them.
-------------------------------------------------------------------- }

[UNDEFINED] -TRAILING [IF]

: -TRAILING ( c-addr len1 -- c-addr len2)
   BEGIN  DUP  WHILE
      1-  2DUP + C@ BL - IF  1+ EXIT THEN
   REPEAT ;

[THEN]

[UNDEFINED] COMPARE [IF]

: COMPARE ( c-addr1 u1 c-addr2 u2 -- n)
   ROT 2>R  1- SWAP 1-  2R@ MIN  0 ?DO  SWAP 1+  SWAP 1+
   OVER C@  OVER C@  <> IF  LEAVE  THEN LOOP  C@ SWAP C@ -
   DUP 0=  2R> SWAP - AND OR  -1 MAX  1 MIN ;

[THEN]

{ --------------------------------------------------------------------
High-level string operators

SKIP skips leading occurrences of char in the string, if any.  If
none, string is returned unchanged.

SCAN skips leading characters until it finds char.  If char is not
found, string is returned unchanged.
-------------------------------------------------------------------- }

: MOVE ( c-addr1 c-addr2 u)
   >R  2DUP SWAP DUP R@ + WITHIN IF
   R> CMOVE>  EXIT THEN  R> CMOVE ;

: ERASE ( c-addr u -- )   0 FILL ;
: BLANK ( c-addr u -- )   BL FILL ;

: /STRING ( c-addr1 u1 u -- c-addr2 u2)
   >R  SWAP R@ +  SWAP R> - ;

: SEARCH ( c-addr1 u1 c-addr2 u2 -- c-addr3 u3 flag )
   2>R 2DUP  BEGIN  DUP R@ U< NOT WHILE
      OVER R@ 2R@ COMPARE WHILE  1 /STRING  REPEAT
   2SWAP 2DROP  2R> 2DROP  -1  EXIT  THEN
   2DROP  2R> 2DROP 0 ;

[UNDEFINED] SKIP [IF]

: SKIP ( c-addr1 u1 char -- c-addr2 u2 )
   >R  DUP IF
      BEGIN  OVER C@ R@ =  OVER 0> AND WHILE  1 /STRING  REPEAT
   THEN  R> DROP ;

[THEN]

[UNDEFINED] SCAN [IF]

: SCAN ( c-addr1 u1 char -- c-addr2 u2 )
   >R  DUP IF
      BEGIN  OVER C@ R@ <>  OVER 0> AND WHILE  1 /STRING  REPEAT
   THEN  R> DROP ;

[THEN]

{ --------------------------------------------------------------------
String literals

," is a non-standard word for compiling strings in target memory.
Uses C, so can be directed to IDATA or CDATA as needed.  String
terminates with " character.
-------------------------------------------------------------------- }

COMPILER

: S"  ( C: <string"> -- ) ( -- c-addr u )
   POSTPONE (S")  ",C ;

: C" ( C:" <string"> -- ) ( -- c-addr)
   POSTPONE (C")  ",C ;

: SLITERAL ( C: c-addr u -- ) ( -- c-addr u)
   SWAP  POSTPONE LITERAL  POSTPONE LITERAL ;

INTERPRETER

: ," ( -- )   [CHAR] " WORD COUNT  DUP C,
   0 ?DO  COUNT C,  LOOP DROP ;

{ --------------------------------------------------------------------
Special strings

These words support the parsing and compiling of strings that contain
embedded control characters.

\\              backslash
\"              double quote
\0              00 (null)
\A              07 (bell)
\B              08 (backspace)
\F              12 (vertical tab, or formfeed)
\N              13 10 (crlf)
\R              13 (return)
\T              09 (tab)
\XHH            insert hex code HH

PARSE-\" uses the HOST's S\" to parse the "-terminated string and
\-escaped characters for us.  We turn off the compiler to get the
interpretive behavior of HOST's S\", then return that string for
either moving to the target, or compiling into the image.

\",C compiles the "-terminated string (with possible escape
sequences) into target code space.

C\",  and S\" work exactly like C", and S" respectively, except they
handle the escape sequences above.
-------------------------------------------------------------------- }

HOST

: PARSE-\" ( <text"> -- c-addr u )
   STATE @ >R  0 STATE !  POSTPONE S\"  R> STATE ! ;

: \",C ( <text"> -- )   PARSE-\"
   DUP C,C(T)  0 ?DO  COUNT C,C(T)  LOOP DROP  ALIGN-CODE  !DEST ;

INTERPRETER

: C\" ( <text"> -- c-addr )   POSTPONE S\"
   DUP HERE C!
   1+ 1 ?DO  COUNT HERE I + C!  LOOP DROP  HERE ;

: S\" ( <text"> -- c-addr len )   POSTPONE S\"  DUP >R
   0 ?DO  COUNT HERE I + C!  LOOP DROP  HERE R> ;

COMPILER

: S\" ( C: <text"> -- ) ( -- c-addr len )   POSTPONE (S")  \",C ;
: C\" ( C: <text"> -- ) ( -- c-addr )   POSTPONE (C")  \",C ;

TARGET
