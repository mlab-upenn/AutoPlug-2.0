{ =====================================================================
FORTH, INC. target test benchmarks

Copyright (c) 1972-2000, FORTH, Inc.

These simple benchmarks are used for comparisons for FORTH, Inc. kernel
implementations.  Execute BENCH to run all of them.  Timing is only as
accurate as the granularity of the target's millisecond counter.

The value #LOOPS is 10000 for 16-bit targets and 100000 for 32-bit
targets.

Requires: COUNTER and TIMER

Exports: BENCH
===================================================================== }

TARGET   DECIMAL

10000 CELL 4 = [IF]  10 * [THEN] 1+ EQU #LOOPS

: .DO   ." DO "  COUNTER  #LOOPS 1 DO  I DROP  LOOP  TIMER ;
: .*   ." * "  COUNTER  #LOOPS 1 DO  I I * DROP  LOOP  TIMER ;
: ./   ." / "  COUNTER  #LOOPS 1 DO  1000 I / DROP  LOOP  TIMER ;
: .+   ." + "  COUNTER  #LOOPS 1 DO  1000 I + DROP  LOOP  TIMER ;
: .M*   ." M* " COUNTER  #LOOPS 1 DO  I I M* 2DROP  LOOP  TIMER ;
: ./MOD   ." /MOD "  COUNTER  #LOOPS 1 DO  1000 I /MOD  2DROP  LOOP TIMER ;
: .UM/MOD   ." UM/MOD "  COUNTER  #LOOPS 1 DO  1000 0 I UM/MOD 2DROP  LOOP  TIMER ;
: .D+   ." D+ "  COUNTER  #LOOPS 1 DO  1000 0 I 0 D+ 2DROP LOOP  TIMER ;
: .*/   ." */ "  COUNTER  #LOOPS 1 DO  I I I */ DROP  LOOP TIMER ;
: .PAUSE   ." PAUSE "  COUNTER  #LOOPS 1 DO  PAUSE  LOOP  TIMER ;

: BENCH   .DO .* ./ .+ .M* ./MOD .UM/MOD .D+ .*/ .PAUSE ;

