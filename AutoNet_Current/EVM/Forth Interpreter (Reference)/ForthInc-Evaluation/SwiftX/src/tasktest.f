{ =====================================================================
Test background task

Copyright (c) 1972-2000, FORTH, Inc.

This file provides an example of a background task.

Requires: Multitasker
===================================================================== }

TARGET

{ ---------------------------------------------------------------------
Task testing

TESTER is the test task.
NP counts the number of pauses.

/TESTER links the task into the multitasker loop and activates
it to increment NP for each PAUSE.

MEASURE displays how many times the task increments NP in 1 second.
--------------------------------------------------------------------- }

|U| |S| |R| BACKGROUND TESTER

VARIABLE NP

: /TESTER ( -- )   0 NP !
   TESTER BUILD  TESTER ACTIVATE
   BEGIN  PAUSE  1 NP +!  AGAIN ;

: MEASURE ( -- )   NP @  1000 MS  NP @ SWAP - . ;

