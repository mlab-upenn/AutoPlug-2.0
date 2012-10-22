{ =====================================================================
High-level benchmarks

Copyright (c) 1972-2000, FORTH, Inc.

This file supplies some high-level benchmarks.

===================================================================== }

TARGET

{ ---------------------------------------------------------------------
Eratosthenes sieve benchmark program

This is the original BYTE benchmark.
--------------------------------------------------------------------- }

8190 CONSTANT SIZE
SIZE BUFFER: FLAGS

: SIEVE ( -- n )
   FLAGS SIZE -1 FILL
   0 SIZE 0 DO
      FLAGS I + C@ IF
         I 2* 3 + DUP I +  BEGIN
            DUP SIZE < WHILE
               DUP FLAGS + 0 SWAP C! OVER +
         REPEAT  2DROP  1+
   THEN  LOOP ;

: .SIEVE ( -- )
   CR  ." Sieve "  COUNTER >R  SIEVE
   R> TIMER  ." MS "  . ." Primes"  ;

{ ---------------------------------------------------------------------
Fibonacci Benchmark

FIB produces a fibonacci sequence from the given number using recursion.
--------------------------------------------------------------------- }

: FIB ( n -- n' )
   DUP 1 > IF
      DUP 1- RECURSE  SWAP 2-  RECURSE  +
   THEN ;

: .FIB ( -- )
   CR ." Fibonacci recursion "  24 DUP .  COUNTER >R
   FIB  R> TIMER ." MS "  U. ;

{ --------------------------------------------------------------------
QuickSort from Hoare & Wil Baden
-------------------------------------------------------------------- }

7 CELLS CONSTANT THRESHOLD   CELL NEGATE CONSTANT -CELL

: Precedes ( n1 n2 -- f )   U< ;

: Exchange ( a1 a2 -- )   2DUP  @ SWAP @ ROT !  SWAP ! ;

: Both-Ends ( f l pivot -- f l )
    >R  BEGIN
       OVER @ R@ Precedes WHILE
          CELL 0 D+
    REPEAT  BEGIN
       R@ OVER @ Precedes WHILE
          CELL -
    REPEAT  R> DROP ;

: Order3 ( f l -- f l pivot )
   2DUP OVER - 2/ -CELL AND + >R
   DUP @ R@ @ Precedes IF
      DUP R@ Exchange
   THEN  OVER @ R@ @ SWAP Precedes IF
      OVER R@ Exchange  DUP @ R@ @ Precedes IF
         DUP R@ Exchange
   THEN  THEN  R> ;

: Partition ( f l -- f l' f' l )
   Order3 @ >R  2DUP  CELL -CELL D+  BEGIN
      R@ Both-Ends 2DUP 1+ U< IF
         2DUP Exchange CELL -CELL D+
      THEN  2DUP SWAP U<
   UNTIL  R> DROP SWAP ROT ;

: Sink ( f key where -- f )
   ROT >R  BEGIN
      CELL - 2DUP @ Precedes WHILE
         DUP @ OVER CELL + !  DUP R@ = IF
            ! R>  EXIT
         THEN  ( key where -- )
   REPEAT  CELL + ! R> ;

: Insertion ( f l -- )
   2DUP U< IF
      CELL + OVER CELL + DO
         I @ I Sink
      CELL +LOOP  DROP
   ELSE  ( f l -- ) 2DROP
   THEN ;

: Hoarify ( f l -- ... )
   BEGIN
      2DUP THRESHOLD 0 D+ U< WHILE
         Partition  2DUP - >R  2OVER - R> > IF
            2SWAP
   THEN  REPEAT  Insertion ;

: QUICK ( f l -- )
   DEPTH >R  BEGIN
      Hoarify DEPTH R@ <
   UNTIL  R> DROP ;

: SORT ( a n -- )
   DUP 0= ABORT" Nothing to sort "
   1- CELLS  OVER +  QUICK ;

1000 CELLS BUFFER: POINTERS

: /POINTERS ( -- )
   POINTERS  1 1000 DO  I OVER ! CELL+  -1 +LOOP DROP ;

: .SORT ( -- )
   CR ." Quick sort "   /POINTERS  COUNTER >R
   POINTERS 1000 SORT  R> TIMER ;

CR .( Sieve size )  ' .SIEVE ' SIEVE - .
CR .( Fib size   )  ' .FIB ' FIB - .
CR .( Sort size  )  ' /POINTERS ' Precedes - .

