\ MSP430 OPTIMIZER RULES

OPTIMIZER? [IF]

OPTIMIZER

{ ---------------------------------------------------------------------
Comparisons and conditionals
--------------------------------------------------------------------- }

: EQ_IF ( -- addr )   @S+ T CMP   TPOP   0 RULEX IF ;
: EQ_WHILE ( addr1 -- addr2 addr1 )   EQ_IF SWAP ;
: EQ_UNTIL ( addr -- )   @S+ T CMP   TPOP   0 RULEX UNTIL ;

: CMP_IF ( -- addr )   @S+ T CMP   TPOP   0 RULEX IF ;
: CMP_WHILE ( addr1 -- addr2 addr1 )   CMP_IF SWAP ;
: CMP_UNTIL ( addr -- )   @S+ T CMP   TPOP   0 RULEX UNTIL ;

: RCMP_IF ( -- addr )   @S+ R8 MOV   T R8 CMP   TPOP   0 RULEX IF ;
: RCMP_WHILE ( addr1 -- addr2 addr1 )   RCMP_IF SWAP ;
: RCMP_UNTIL ( addr -- )   @S+ R8 MOV   T R8 CMP   TPOP   0 RULEX UNTIL ;

: LIT_EQ_IF ( -- addr )   @LITERAL # T CMP   TPOP   1 RULEX IF ;
: LIT_EQ_WHILE ( addr1 -- addr2 addr1 )   LIT_EQ_IF SWAP ;
: LIT_EQ_UNTIL ( addr -- )   @LITERAL # T CMP   TPOP   1 RULEX UNTIL ;

: LIT_CMP_IF ( -- addr )   @LITERAL # R8 MOV   T R8 CMP   TPOP   1 RULEX IF ;
: LIT_CMP_WHILE ( addr1 -- addr2 addr1 )   LIT_CMP_IF SWAP ;
: LIT_CMP_UNTIL ( addr -- )   @LITERAL # R8 MOV   T R8 CMP   TPOP   1 RULEX UNTIL ;

: LIT_RCMP_IF ( -- addr )   @LITERAL # T CMP   TPOP   1 RULEX IF ;
: LIT_RCMP_WHILE ( addr1 -- addr2 addr1 )   LIT_RCMP_IF SWAP ;
: LIT_RCMP_UNTIL ( addr -- )   @LITERAL # T CMP   TPOP   1 RULEX UNTIL ;

: DUP_LIT_EQ_IF ( -- addr )   @LITERAL # T CMP   2 RULEX IF ;
: DUP_LIT_EQ_WHILE ( addr1 -- addr2 addr1 )   DUP_LIT_EQ_IF SWAP ;
: DUP_LIT_EQ_UNTIL ( addr -- )   @LITERAL # T CMP  2 RULEX UNTIL ;

: DUP_LIT_CMP_IF ( -- addr )   @LITERAL # R8 MOV   T R8 CMP   2 RULEX IF ;
: DUP_LIT_CMP_WHILE ( addr1 -- addr2 addr1 )   DUP_LIT_CMP_IF SWAP ;
: DUP_LIT_CMP_UNTIL ( addr -- )   @LITERAL # R8 MOV   T R8 CMP   2 RULEX UNTIL ;

: DUP_LIT_RCMP_IF ( -- addr )   @LITERAL # T CMP   2 RULEX IF ;
: DUP_LIT_RCMP_WHILE ( addr1 -- addr2 addr1 )   DUP_LIT_RCMP_IF SWAP ;
: DUP_LIT_RCMP_UNTIL ( addr -- )   @LITERAL # T CMP   2 RULEX UNTIL ;

: 2DUP_EQ_IF ( -- addr )   @S T CMP   1 RULEX IF ;
: 2DUP_EQ_WHILE ( addr1 -- addr2 addr1 )   2DUP_EQ_IF SWAP ;
: 2DUP_EQ_UNTIL ( addr -- )   @S T CMP   1 RULEX UNTIL ;

: R@_EQ_IF ( -- addr )   @R T CMP   TPOP   1 RULEX IF ;
: R@_EQ_WHILE ( addr1 -- addr2 addr1 )   R@_EQ_IF SWAP ;
: R@_EQ_UNTIL ( addr -- )   @R T CMP   TPOP   1 RULEX UNTIL ;

: R>_EQ_IF ( -- addr )   @R+ T CMP   TPOP   1 RULEX IF ;
: R>_EQ_WHILE ( addr1 -- addr2 addr1 )   R>_EQ_IF SWAP ;
: R>_EQ_UNTIL ( addr -- )   @R+ T CMP   TPOP   1 RULEX UNTIL ;

: LIT_OF ( -- addr -1)   @LITERAL # T CMP   0= IF   TPOP  -1 ;

{ ---------------------------------------------------------------------
Tests and conditionals
--------------------------------------------------------------------- }

: DUP_IF ( -- addr )   T TST   0= NOT IF ;
: DUP_WHILE ( addr1 -- addr2 addr1)   DUP_IF SWAP ;
: DUP_UNTIL ( addr -- )   T TST   0= NOT UNTIL ;

: OVER_IF ( -- addr )   0 (S) TST   0= NOT IF ;
: OVER_WHILE ( addr1 -- addr2 addr1)   OVER_IF SWAP ;
: OVER_UNTIL ( addr -- )   0 (S) TST   0= NOT UNTIL ;

: R@_IF ( -- addr )   0 (R) TST   0= NOT IF ;
: R@_WHILE ( addr1 -- addr2 addr1)   R@_IF SWAP ;
: R@_UNTIL ( addr -- )   0 (R) TST   0= NOT UNTIL ;

: R>_IF ( -- addr )   @R+ R8 MOV   R8 TST   0= NOT IF ;
: R>_WHILE ( addr1 -- addr2 addr1)   R>_IF SWAP ;
: R>_UNTIL ( addr -- )   @R+ R8 MOV   R8 TST   0= NOT UNTIL ;

: @_IF ( -- addr )   0 (T) TST   TPOP   0= NOT IF ;
: @_WHILE ( addr1 -- addr2 addr1)   @_IF SWAP ;
: @_UNTIL ( addr -- )   0 (T) TST   TPOP   0= NOT UNTIL ;

: C@_IF ( -- addr )   0 (T) TST.B   TPOP   0= NOT IF ;
: C@_WHILE ( addr1 -- addr2 addr1)   C@_IF SWAP ;
: C@_UNTIL ( addr -- )   0 (T) TST.B   TPOP   0= NOT UNTIL ;

: LIT_@_IF ( -- addr )   @LITERAL & TST   0= NOT IF ;
: LIT_@_WHILE ( addr1 -- addr2 addr1)   LIT_@_IF SWAP ;
: LIT_@_UNTIL ( addr -- )   @LITERAL & TST   0= NOT UNTIL ;

: LIT_C@_IF ( -- addr )   @LITERAL & TST.B   0= NOT IF ;
: LIT_C@_WHILE ( addr1 -- addr2 addr1)   LIT_C@_IF SWAP ;
: LIT_C@_UNTIL ( addr -- )   @LITERAL & TST.B   0= NOT UNTIL ;

: TEST_IF ( -- addr )   T TST   TPOP   0 RULEX IF ;
: TEST_WHILE ( addr1 -- addr2 addr1)   TEST_IF SWAP ;
: TEST_UNTIL ( addr -- )   T TST   TPOP   0 RULEX UNTIL ;

: DUP_TEST_IF ( -- addr )   T TST   1 RULEX IF ;
: DUP_TEST_WHILE ( addr1 -- addr2 addr1)   DUP_TEST_IF SWAP ;
: DUP_TEST_UNTIL ( addr -- )   T TST   1 RULEX UNTIL ;

: OVER_TEST_IF ( -- addr )   0 (S) TST   1 RULEX IF ;
: OVER_TEST_WHILE ( addr1 -- addr2 addr1)   OVER_TEST_IF SWAP ;
: OVER_TEST_UNTIL ( addr -- )   0 (S) TST   1 RULEX UNTIL ;

: @_TEST_IF ( -- addr )   0 (T) TST   TPOP   1 RULEX IF ;
: @_TEST_WHILE ( addr1 -- addr2 addr1)   @_TEST_IF SWAP ;
: @_TEST_UNTIL ( addr -- )   0 (T) TST   TPOP   1 RULEX UNTIL ;

: C@_TEST_IF ( -- addr )   0 (T) TST.B   TPOP   1 RULEX IF ;
: C@_TEST_WHILE ( addr1 -- addr2 addr1)   C@_TEST_IF SWAP ;
: C@_TEST_UNTIL ( addr -- )   0 (T) TST.B   TPOP   1 RULEX UNTIL ;

: LIT_@_TEST_IF ( -- addr )   @LITERAL & TST   1 RULEX IF ;
: LIT_@_TEST_WHILE ( addr1 -- addr2 addr1)   LIT_@_TEST_IF SWAP ;
: LIT_@_TEST_UNTIL ( addr -- )   @LITERAL & TST   1 RULEX UNTIL ;

: LIT_C@_TEST_IF ( -- addr )   @LITERAL & TST.B   1 RULEX IF ;
: LIT_C@_TEST_WHILE ( addr1 -- addr2 addr1)   LIT_C@_TEST_IF SWAP ;
: LIT_C@_TEST_UNTIL ( addr -- )   @LITERAL & TST.B   1 RULEX UNTIL ;

{ ---------------------------------------------------------------------
Literal operations

Note that when LITERAL is about to be executed (i.e. it's the second
term of the OPTIMIZE pair), the literal value is still on the stack.
-------------------------------------------------------------------- }

: DROP_LIT ( n -- )   !LITERAL  # T MOV ;
: 2DROP_LIT ( n -- )   2 # S ADD   DROP_LIT ;

: DROP_LIT_2* ( -- )   @LITERAL 2 *  DROP_LIT ;
: DROP_LIT_2/ ( -- )   @LITERAL 2 /  DROP_LIT ;

: DROP_LIT_2+ ( -- )   @LITERAL 2 +  DROP_LIT ;
: DROP_LIT_2- ( -- )   @LITERAL 2 -  DROP_LIT ;

: DROP_LIT_1+ ( -- )   @LITERAL 1 +  DROP_LIT ;
: DROP_LIT_1- ( -- )   @LITERAL 1 -  DROP_LIT ;

: LIT_2* ( -- )   @LITERAL 2 * RELIT ;
: LIT_2/ ( -- )   @LITERAL 2 / RELIT ;

: LIT_2+ ( -- )   @LITERAL 2 + RELIT ;
: LIT_2- ( -- )   @LITERAL 2 - RELIT ;

: LIT_1+ ( -- )   @LITERAL 1 + RELIT ;
: LIT_1- ( -- )   @LITERAL 1 - RELIT ;

: LIT_INVERT ( -- )   @LITERAL INVERT RELIT ;
: LIT_NEGATE ( -- )   @LITERAL NEGATE RELIT ;
: LIT_ABS ( -- )   @LITERAL ABS RELIT ;

: LIT_0= ( -- )   @LITERAL  [+HOST] 0=  [PREVIOUS] RELIT ;
: LIT_0<> ( -- )   @LITERAL  [+HOST] 0<>  [PREVIOUS] RELIT ;
: LIT_0< ( -- )   @LITERAL  [+HOST] 0<  [PREVIOUS] RELIT ;
: LIT_0> ( -- )   @LITERAL  [+HOST] 0>  [PREVIOUS] RELIT ;

: LIT_PICK ( -- )   TPUSH   @LITERAL 2* (S) T MOV ;
: LIT_>R ( -- )   @LITERAL # PUSH ;

: LIT_/STRING ( -- )   @LITERAL IF(H)
      @LITERAL # 0 (S) ADD   @LITERAL # T SUB
   THEN(H) ;

{ ---------------------------------------------------------------------
Arithmetic and logical operations
--------------------------------------------------------------------- }

: LIT_+ ( -- )   @LITERAL ?DUP IF(H)  # T ADD  THEN(H) ;
: LIT_- ( -- )   @LITERAL ?DUP IF(H)  # T SUB  THEN(H) ;

: LIT_AND ( -- )   @LITERAL  [+HOST] $FFFF AND [PREVIOUS]
   DUP $FFFF <> IF(H)  DUP # T AND  THEN(H) DROP ;

: LIT_OR ( -- )   @LITERAL ?DUP IF(H)  # T BIS  THEN(H) ;
: LIT_XOR ( -- )   @LITERAL ?DUP IF(H)  # T XOR  THEN(H) ;

: LIT_++ ( -- )   @LITERALS + /LITERALS  ['] LIT_+ !RECORD ;
: LIT_-- ( -- )   @LITERALS + /LITERALS  ['] LIT_- !RECORD ;
: LIT_+- ( -- )   @LITERALS - /LITERALS  ['] LIT_+ !RECORD ;
: LIT_-+ ( -- )   @LITERALS - /LITERALS  ['] LIT_- !RECORD ;

: LIT_LIT_+ ( -- )   @LITERALS + -LITERAL RELIT ;
: LIT_LIT_- ( -- )   @LITERALS - -LITERAL RELIT ;
: LIT_LIT_AND ( -- )   @LITERALS [+HOST] AND [PREVIOUS] -LITERAL RELIT ;
: LIT_LIT_OR ( -- )   @LITERALS OR -LITERAL RELIT ;
: LIT_LIT_XOR ( -- )   @LITERALS [+HOST] XOR [PREVIOUS] -LITERAL RELIT ;

: LIT_+n ( n -- )   LITS +!  ['] LIT_+ !RECORD ;
: LIT_-n ( n -- )   LITS +!  ['] LIT_- !RECORD ;

: LIT_+_1+ ( -- )   1 LIT_+n ;
: LIT_+_2+ ( -- )   2 LIT_+n ;

: LIT_+_1- ( -- )   -1 LIT_+n ;
: LIT_+_2- ( -- )   -2 LIT_+n ;

: LIT_-_1+ ( -- )   -1 LIT_-n ;
: LIT_-_2+ ( -- )   -2 LIT_-n ;

: LIT_-_1- ( -- )   1 LIT_-n ;
: LIT_-_2- ( -- )   2 LIT_-n ;

: LIT_@_ALU ( -- )   @LITERAL & T 0 RULEX ;

: OVER_ALU ( -- )   @S T 0 RULEX ;
: SWAP_ALU ( -- )   @S+ T 0 RULEX ;

: R@_ALU ( -- )   @R T 0 RULEX ;
: R>_ALU ( -- )   @R+ T 0 RULEX ;

: I_ALU ( -- )   @R R8 MOV   2 (R) R8 ADD   R8 T 0 RULEX ;
: J_ALU ( -- )   4 (R) R8 MOV   6 (R) R8 ADD   R8 T 0 RULEX ;

{ ---------------------------------------------------------------------
Arithmetic and logical conditionals
--------------------------------------------------------------------- }

: ALU_IF ( -- addr )   @S+ T 0 RULEX   TPOP   0= NOT IF ;
: ALU_WHILE ( addr1 -- addr2 addr1)   ALU_IF  SWAP ;
: ALU_UNTIL ( addr -- )   @S+ T 0 RULEX   TPOP   0= NOT UNTIL ;

: SWAP_ALU_IF ( -- addr )   @S+ T 1 RULEX   TPOP   0= NOT IF ;
: SWAP_ALU_WHILE ( addr1 -- addr2 addr1)   SWAP_ALU_IF  SWAP ;
: SWAP_ALU_UNTIL ( addr -- )   @S+ T 1 RULEX   TPOP   0= NOT UNTIL ;

: OVER_ALU_IF ( -- addr )   @S T 1 RULEX   TPOP   0= NOT IF ;
: OVER_ALU_WHILE ( addr1 -- addr2 addr1)   OVER_ALU_IF  SWAP ;
: OVER_ALU_UNTIL ( addr -- )   @S T 1 RULEX   TPOP   0= NOT UNTIL ;

: R@_ALU_IF ( -- addr )   @R T 1 RULEX   TPOP   0= NOT IF ;
: R@_ALU_WHILE ( addr1 -- addr2 addr1)   R@_ALU_IF  SWAP ;
: R@_ALU_UNTIL ( addr -- )   @R T 1 RULEX   TPOP   0= NOT UNTIL ;

: R>_ALU_IF ( -- addr )   @R+ T 1 RULEX   TPOP   0= NOT IF ;
: R>_ALU_WHILE ( addr1 -- addr2 addr1)   R>_ALU_IF  SWAP ;
: R>_ALU_UNTIL ( addr -- )   @R+ T 1 RULEX   TPOP   0= NOT UNTIL ;

{ ---------------------------------------------------------------------
Memory access
--------------------------------------------------------------------- }

: LIT_@ ( -- )   TPUSH   @LITERAL & T MOV ;
: LIT_C@ ( -- )   TPUSH   @LITERAL & T MOV.B ;

: 2+_@ ( -- )   2 (T) T MOV ;
: LIT_+_@ ( -- )   @LITERAL (T) T MOV ;
: LIT_-_@ ( -- )   @LITERAL NEGATE (T) T MOV ;

: LIT_! ( -- )   T @LITERAL & MOV   TPOP ;
: LIT_C! ( -- )   T @LITERAL & MOV.B   TPOP ;

: LIT_+! ( -- )   T @LITERAL & ADD   TPOP ;
: LIT_C+! ( -- )   T @LITERAL & ADD.B   TPOP ;

: SWAP_! ( -- )   @S+ R8 MOV   T 0 (R8) MOV   TPOP ;
: SWAP_C! ( -- )   @S+ R8 MOV   T 0 (R8) MOV.B   TPOP ;

: LIT_SWAP_! ( -- )   @LITERAL # 0 (T) MOV   TPOP ;
: LIT_SWAP_C! ( -- )   @LITERAL # 0 (T) MOV.B   TPOP ;

: OVER_! ( -- )   T R8 MOV   TPOP   R8 0 (T) MOV ;
: OVER_C! ( -- )   T R8 MOV   TPOP   R8 0 (T) MOV.B ;

: LIT_OVER_! ( -- )   @LITERAL # 0 (T) MOV ;
: LIT_OVER_C! ( -- )   @LITERAL # 0 (T) MOV.B ;

: DUP_LIT_! ( -- )   T @LITERAL & MOV ;
: DUP_LIT_C! ( -- )   T @LITERAL & MOV.B ;

: DUP_LIT_+! ( -- )   T @LITERAL & ADD ;
: DUP_LIT_C+! ( -- )   T @LITERAL & ADD.B ;

: LIT_LIT_! ( -- )   @LITERALS >R # R> & MOV ;
: LIT_LIT_C! ( -- )   @LITERALS >R # R> & MOV.B ;

: LIT_LIT_+! ( -- )   @LITERALS >R # R> & ADD ;
: LIT_LIT_C+! ( -- )   @LITERALS >R # R> & ADD.B ;

: LIT_@_LIT_! ( -- )   @LITERALS >R & R> & MOV ;
: LIT_C@_LIT_C! ( -- )   @LITERALS >R & R> & MOV.B ;

: LIT_!_LIT_@ ( -- )   @LITERALS >R >R
   T R> & MOV   R> & T MOV ;

: USER_! ( -- )   T @LITERAL (R6) MOV    TPOP ;
: LIT_USER_! ( -- )   @LITERALS >R  # R> (R6) MOV ;

: USER_@EXECUTE ( -- )   @LITERAL (R6) R8 MOV   R8 TST
   0= NOT IF   R8 CALL   THEN ;

{ ---------------------------------------------------------------------
Mixed stack operations
--------------------------------------------------------------------- }

: DUP_>R ( -- )   T PUSH ;
: OVER_>R ( -- )   @S PUSH ;
: SWAP_>R ( -- )   @S PUSH   2 # S ADD ;
: @_>R ( -- )   @T PUSH   TPOP ;
: DUP_@_>R ( -- )   @T PUSH ;
: OVER_@_>R ( -- )   @S R8 MOV   @R8 PUSH ;
: R>_DROP ( -- )   2 # R ADD ;

{ ---------------------------------------------------------------------
Optimizer condition codes
--------------------------------------------------------------------- }

ASSEMBLER

0= NOT CONSTANT 0<>
CS NOT CONSTANT CSNOT

{ ---------------------------------------------------------------------
Optimizer rules
--------------------------------------------------------------------- }

TARGET

OPTIMIZE = IF                   WITH EQ_IF              ASSEMBLE 0=
OPTIMIZE <> IF                  WITH EQ_IF              ASSEMBLE 0<>
OPTIMIZE - IF                   WITH EQ_IF              ASSEMBLE 0<>
OPTIMIZE XOR IF                 WITH EQ_IF              ASSEMBLE 0<>

OPTIMIZE = WHILE                WITH EQ_WHILE           ASSEMBLE 0=
OPTIMIZE <> WHILE               WITH EQ_WHILE           ASSEMBLE 0<>
OPTIMIZE - WHILE                WITH EQ_WHILE           ASSEMBLE 0<>
OPTIMIZE XOR WHILE              WITH EQ_WHILE           ASSEMBLE 0<>

OPTIMIZE = UNTIL                WITH EQ_UNTIL           ASSEMBLE 0=
OPTIMIZE <> UNTIL               WITH EQ_UNTIL           ASSEMBLE 0<>
OPTIMIZE - UNTIL                WITH EQ_UNTIL           ASSEMBLE 0<>
OPTIMIZE XOR UNTIL              WITH EQ_UNTIL           ASSEMBLE 0<>

OPTIMIZE < IF                   WITH RCMP_IF            ASSEMBLE S<
OPTIMIZE > IF                   WITH CMP_IF             ASSEMBLE S<
OPTIMIZE U< IF                  WITH RCMP_IF            ASSEMBLE CSNOT
OPTIMIZE U> IF                  WITH CMP_IF             ASSEMBLE CSNOT

OPTIMIZE < WHILE                WITH RCMP_WHILE         ASSEMBLE S<
OPTIMIZE > WHILE                WITH CMP_WHILE          ASSEMBLE S<
OPTIMIZE U< WHILE               WITH RCMP_WHILE         ASSEMBLE CSNOT
OPTIMIZE U> WHILE               WITH CMP_WHILE          ASSEMBLE CSNOT

OPTIMIZE < UNTIL                WITH RCMP_UNTIL         ASSEMBLE S<
OPTIMIZE > UNTIL                WITH CMP_UNTIL          ASSEMBLE S<
OPTIMIZE U< UNTIL               WITH RCMP_UNTIL         ASSEMBLE CSNOT
OPTIMIZE U> UNTIL               WITH CMP_UNTIL          ASSEMBLE CSNOT

OPTIMIZE LITERAL EQ_IF          WITH LIT_EQ_IF
OPTIMIZE LITERAL EQ_WHILE       WITH LIT_EQ_WHILE
OPTIMIZE LITERAL EQ_UNTIL       WITH LIT_EQ_UNTIL

OPTIMIZE LITERAL CMP_IF         WITH LIT_CMP_IF
OPTIMIZE LITERAL CMP_WHILE      WITH LIT_CMP_WHILE
OPTIMIZE LITERAL CMP_UNTIL      WITH LIT_CMP_UNTIL

OPTIMIZE LITERAL RCMP_IF        WITH LIT_RCMP_IF
OPTIMIZE LITERAL RCMP_WHILE     WITH LIT_RCMP_WHILE
OPTIMIZE LITERAL RCMP_UNTIL     WITH LIT_RCMP_UNTIL

OPTIMIZE DUP LIT_EQ_IF          WITH DUP_LIT_EQ_IF
OPTIMIZE DUP LIT_EQ_WHILE       WITH DUP_LIT_EQ_WHILE
OPTIMIZE DUP LIT_EQ_UNTIL       WITH DUP_LIT_EQ_UNTIL

OPTIMIZE DUP LIT_CMP_IF         WITH DUP_LIT_CMP_IF
OPTIMIZE DUP LIT_CMP_WHILE      WITH DUP_LIT_CMP_WHILE
OPTIMIZE DUP LIT_CMP_UNTIL      WITH DUP_LIT_CMP_UNTIL

OPTIMIZE DUP LIT_RCMP_IF        WITH DUP_LIT_RCMP_IF
OPTIMIZE DUP LIT_RCMP_WHILE     WITH DUP_LIT_RCMP_WHILE
OPTIMIZE DUP LIT_RCMP_UNTIL     WITH DUP_LIT_RCMP_UNTIL

OPTIMIZE 2DUP EQ_IF             WITH 2DUP_EQ_IF
OPTIMIZE 2DUP EQ_WHILE          WITH 2DUP_EQ_WHILE
OPTIMIZE 2DUP EQ_UNTIL          WITH 2DUP_EQ_UNTIL

OPTIMIZE R@ EQ_IF               WITH R@_EQ_IF
OPTIMIZE R@ EQ_WHILE            WITH R@_EQ_WHILE
OPTIMIZE R@ EQ_UNTIL            WITH R@_EQ_UNTIL

OPTIMIZE R> EQ_IF               WITH R>_EQ_IF
OPTIMIZE R> EQ_WHILE            WITH R>_EQ_WHILE
OPTIMIZE R> EQ_UNTIL            WITH R>_EQ_UNTIL

OPTIMIZE LITERAL OF             WITH LIT_OF

OPTIMIZE DUP IF                 WITH DUP_IF
OPTIMIZE DUP WHILE              WITH DUP_WHILE
OPTIMIZE DUP UNTIL              WITH DUP_UNTIL

OPTIMIZE OVER IF                WITH OVER_IF
OPTIMIZE OVER WHILE             WITH OVER_WHILE
OPTIMIZE OVER UNTIL             WITH OVER_UNTIL

OPTIMIZE R@ IF                  WITH R@_IF
OPTIMIZE R@ WHILE               WITH R@_WHILE
OPTIMIZE R@ UNTIL               WITH R@_UNTIL

OPTIMIZE R> IF                  WITH R>_IF
OPTIMIZE R> WHILE               WITH R>_WHILE
OPTIMIZE R> UNTIL               WITH R>_UNTIL

OPTIMIZE @ IF                   WITH @_IF
OPTIMIZE @ WHILE                WITH @_WHILE
OPTIMIZE @ UNTIL                WITH @_UNTIL

OPTIMIZE C@ IF                  WITH C@_IF
OPTIMIZE C@ WHILE               WITH C@_WHILE
OPTIMIZE C@ UNTIL               WITH C@_UNTIL

OPTIMIZE LIT_@ IF               WITH LIT_@_IF
OPTIMIZE LIT_@ WHILE            WITH LIT_@_WHILE
OPTIMIZE LIT_@ UNTIL            WITH LIT_@_UNTIL

OPTIMIZE LIT_C@ IF              WITH LIT_C@_IF
OPTIMIZE LIT_C@ WHILE           WITH LIT_C@_WHILE
OPTIMIZE LIT_C@ UNTIL           WITH LIT_C@_UNTIL

OPTIMIZE 0= IF                  WITH TEST_IF            ASSEMBLE 0=
OPTIMIZE NOT IF                 WITH TEST_IF            ASSEMBLE 0=
OPTIMIZE 0<> IF                 WITH TEST_IF            ASSEMBLE 0<>

OPTIMIZE 0= WHILE               WITH TEST_WHILE         ASSEMBLE 0=
OPTIMIZE NOT WHILE              WITH TEST_WHILE         ASSEMBLE 0=
OPTIMIZE 0<> WHILE              WITH TEST_WHILE         ASSEMBLE 0<>

OPTIMIZE 0= UNTIL               WITH TEST_UNTIL         ASSEMBLE 0=
OPTIMIZE NOT UNTIL              WITH TEST_UNTIL         ASSEMBLE 0=
OPTIMIZE 0<> UNTIL              WITH TEST_UNTIL         ASSEMBLE 0<>

OPTIMIZE DUP TEST_IF            WITH DUP_TEST_IF
OPTIMIZE DUP TEST_WHILE         WITH DUP_TEST_WHILE
OPTIMIZE DUP TEST_UNTIL         WITH DUP_TEST_UNTIL

OPTIMIZE OVER TEST_IF           WITH OVER_TEST_IF
OPTIMIZE OVER TEST_WHILE        WITH OVER_TEST_WHILE
OPTIMIZE OVER TEST_UNTIL        WITH OVER_TEST_UNTIL

OPTIMIZE @ TEST_IF              WITH @_TEST_IF
OPTIMIZE @ TEST_WHILE           WITH @_TEST_WHILE
OPTIMIZE @ TEST_UNTIL           WITH @_TEST_UNTIL

OPTIMIZE C@ TEST_IF             WITH C@_TEST_IF
OPTIMIZE C@ TEST_WHILE          WITH C@_TEST_WHILE
OPTIMIZE C@ TEST_UNTIL          WITH C@_TEST_UNTIL

OPTIMIZE LIT_@ TEST_IF          WITH LIT_@_TEST_IF
OPTIMIZE LIT_@ TEST_WHILE       WITH LIT_@_TEST_WHILE
OPTIMIZE LIT_@ TEST_UNTIL       WITH LIT_@_TEST_UNTIL

OPTIMIZE LIT_C@ TEST_IF         WITH LIT_C@_TEST_IF
OPTIMIZE LIT_C@ TEST_WHILE      WITH LIT_C@_TEST_WHILE
OPTIMIZE LIT_C@ TEST_UNTIL      WITH LIT_C@_TEST_UNTIL

OPTIMIZE DROP LITERAL           WITH DROP_LIT
OPTIMIZE 2DROP LITERAL          WITH 2DROP_LIT

OPTIMIZE DROP_LIT 2*            WITH DROP_LIT_2*
OPTIMIZE DROP_LIT CELLS         WITH DROP_LIT_2*
OPTIMIZE DROP_LIT 2/            WITH DROP_LIT_2/
OPTIMIZE DROP_LIT 2+            WITH DROP_LIT_2+
OPTIMIZE DROP_LIT CELL+         WITH DROP_LIT_2+
OPTIMIZE DROP_LIT 2-            WITH DROP_LIT_2-
OPTIMIZE DROP_LIT 1+            WITH DROP_LIT_1+
OPTIMIZE DROP_LIT 1-            WITH DROP_LIT_1-

OPTIMIZE LITERAL 2*             WITH LIT_2*
OPTIMIZE LITERAL CELLS          WITH LIT_2*
OPTIMIZE LITERAL 2/             WITH LIT_2/
OPTIMIZE LITERAL 2+             WITH LIT_2+
OPTIMIZE LITERAL CELL+          WITH LIT_2+
OPTIMIZE LITERAL 2-             WITH LIT_2-
OPTIMIZE LITERAL 1+             WITH LIT_1+
OPTIMIZE LITERAL CHAR+          WITH LIT_1+
OPTIMIZE LITERAL 1-             WITH LIT_1-

OPTIMIZE LITERAL INVERT         WITH LIT_INVERT
OPTIMIZE LITERAL NEGATE         WITH LIT_NEGATE
OPTIMIZE LITERAL ABS            WITH LIT_ABS

OPTIMIZE LITERAL 0=             WITH LIT_0=
OPTIMIZE LITERAL 0<>            WITH LIT_0<>
OPTIMIZE LITERAL 0<             WITH LIT_0<
OPTIMIZE LITERAL 0>             WITH LIT_0>

OPTIMIZE LITERAL PICK           WITH LIT_PICK
OPTIMIZE LITERAL >R             WITH LIT_>R
OPTIMIZE LITERAL /STRING        WITH LIT_/STRING

OPTIMIZE LITERAL +              WITH LIT_+
OPTIMIZE LITERAL -              WITH LIT_-
OPTIMIZE LITERAL AND            WITH LIT_AND
OPTIMIZE LITERAL OR             WITH LIT_OR
OPTIMIZE LITERAL XOR            WITH LIT_XOR

OPTIMIZE LIT_+ LIT_+            WITH LIT_++
OPTIMIZE LIT_- LIT_-            WITH LIT_--
OPTIMIZE LIT_+ LIT_-            WITH LIT_+-
OPTIMIZE LIT_- LIT_+            WITH LIT_-+

OPTIMIZE LITERAL LIT_+          WITH LIT_LIT_+
OPTIMIZE LITERAL LIT_-          WITH LIT_LIT_-
OPTIMIZE LITERAL LIT_AND        WITH LIT_LIT_AND
OPTIMIZE LITERAL LIT_OR         WITH LIT_LIT_OR
OPTIMIZE LITERAL LIT_XOR        WITH LIT_LIT_XOR

OPTIMIZE LIT_+ 1+               WITH LIT_+_1+
OPTIMIZE LIT_+ 2+               WITH LIT_+_2+
OPTIMIZE LIT_+ 1-               WITH LIT_+_1-
OPTIMIZE LIT_+ 2-               WITH LIT_+_2-
OPTIMIZE LIT_+ CELL+            WITH LIT_+_2+
OPTIMIZE LIT_+ CELL-            WITH LIT_+_2-

OPTIMIZE 1+ LIT_+               WITH LIT_+_1+
OPTIMIZE 2+ LIT_+               WITH LIT_+_2+
OPTIMIZE 1- LIT_+               WITH LIT_+_1-
OPTIMIZE 2- LIT_+               WITH LIT_+_2-
OPTIMIZE CELL+ LIT_+            WITH LIT_+_2+
OPTIMIZE CELL- LIT_+            WITH LIT_+_2-

OPTIMIZE LIT_- 1+               WITH LIT_-_1+
OPTIMIZE LIT_- 2+               WITH LIT_-_2+
OPTIMIZE LIT_- 1-               WITH LIT_-_1-
OPTIMIZE LIT_- 2-               WITH LIT_-_2-
OPTIMIZE LIT_- CELL+            WITH LIT_-_2+
OPTIMIZE LIT_- CELL-            WITH LIT_-_2-

OPTIMIZE 1+ LIT_-               WITH LIT_-_1+
OPTIMIZE 2+ LIT_-               WITH LIT_-_2+
OPTIMIZE 1- LIT_-               WITH LIT_-_1-
OPTIMIZE 2- LIT_-               WITH LIT_-_2-
OPTIMIZE CELL+ LIT_-            WITH LIT_-_2+
OPTIMIZE CELL- LIT_-            WITH LIT_-_2-

OPTIMIZE LIT_@ +                WITH LIT_@_ALU          ASSEMBLE ADD
OPTIMIZE LIT_@ -                WITH LIT_@_ALU          ASSEMBLE SUB
OPTIMIZE LIT_@ AND              WITH LIT_@_ALU          ASSEMBLE AND
OPTIMIZE LIT_@ OR               WITH LIT_@_ALU          ASSEMBLE BIS
OPTIMIZE LIT_@ XOR              WITH LIT_@_ALU          ASSEMBLE XOR

OPTIMIZE OVER +                 WITH OVER_ALU           ASSEMBLE ADD
OPTIMIZE OVER -                 WITH OVER_ALU           ASSEMBLE SUB
OPTIMIZE OVER AND               WITH OVER_ALU           ASSEMBLE AND
OPTIMIZE OVER OR                WITH OVER_ALU           ASSEMBLE BIS
OPTIMIZE OVER XOR               WITH OVER_ALU           ASSEMBLE XOR

OPTIMIZE SWAP +                 WITH SWAP_ALU           ASSEMBLE ADD
OPTIMIZE SWAP -                 WITH SWAP_ALU           ASSEMBLE SUB
OPTIMIZE SWAP AND               WITH SWAP_ALU           ASSEMBLE AND
OPTIMIZE SWAP OR                WITH SWAP_ALU           ASSEMBLE BIS
OPTIMIZE SWAP XOR               WITH SWAP_ALU           ASSEMBLE XOR

OPTIMIZE R@ +                   WITH R@_ALU             ASSEMBLE ADD
OPTIMIZE R@ -                   WITH R@_ALU             ASSEMBLE SUB
OPTIMIZE R@ AND                 WITH R@_ALU             ASSEMBLE AND
OPTIMIZE R@ OR                  WITH R@_ALU             ASSEMBLE BIS
OPTIMIZE R@ XOR                 WITH R@_ALU             ASSEMBLE XOR

OPTIMIZE R> +                   WITH R>_ALU             ASSEMBLE ADD
OPTIMIZE R> -                   WITH R>_ALU             ASSEMBLE SUB
OPTIMIZE R> AND                 WITH R>_ALU             ASSEMBLE AND
OPTIMIZE R> OR                  WITH R>_ALU             ASSEMBLE BIS
OPTIMIZE R> XOR                 WITH R>_ALU             ASSEMBLE XOR

OPTIMIZE I +                    WITH I_ALU              ASSEMBLE ADD
OPTIMIZE I -                    WITH I_ALU              ASSEMBLE SUB
OPTIMIZE I AND                  WITH I_ALU              ASSEMBLE AND
OPTIMIZE I OR                   WITH I_ALU              ASSEMBLE BIS
OPTIMIZE I XOR                  WITH I_ALU              ASSEMBLE XOR

OPTIMIZE J +                    WITH J_ALU              ASSEMBLE ADD
OPTIMIZE J -                    WITH J_ALU              ASSEMBLE SUB
OPTIMIZE J AND                  WITH J_ALU              ASSEMBLE AND
OPTIMIZE J OR                   WITH J_ALU              ASSEMBLE BIS
OPTIMIZE J XOR                  WITH J_ALU              ASSEMBLE XOR

OPTIMIZE + IF                   WITH ALU_IF             ASSEMBLE ADD
OPTIMIZE AND IF                 WITH ALU_IF             ASSEMBLE AND
OPTIMIZE XOR IF                 WITH ALU_IF             ASSEMBLE XOR

OPTIMIZE + WHILE                WITH ALU_WHILE          ASSEMBLE ADD
OPTIMIZE AND WHILE              WITH ALU_WHILE          ASSEMBLE AND
OPTIMIZE XOR WHILE              WITH ALU_WHILE          ASSEMBLE XOR

OPTIMIZE + UNTIL                WITH ALU_UNTIL          ASSEMBLE ADD
OPTIMIZE AND UNTIL              WITH ALU_UNTIL          ASSEMBLE AND
OPTIMIZE XOR UNTIL              WITH ALU_UNTIL          ASSEMBLE XOR

OPTIMIZE SWAP_ALU IF            WITH SWAP_ALU_IF
OPTIMIZE SWAP_ALU WHILE         WITH SWAP_ALU_WHILE
OPTIMIZE SWAP_ALU UNTIL         WITH SWAP_ALU_UNTIL

OPTIMIZE OVER_ALU IF            WITH OVER_ALU_IF
OPTIMIZE OVER_ALU WHILE         WITH OVER_ALU_WHILE
OPTIMIZE OVER_ALU UNTIL         WITH OVER_ALU_UNTIL

OPTIMIZE R@_ALU IF              WITH R@_ALU_IF
OPTIMIZE R@_ALU WHILE           WITH R@_ALU_WHILE
OPTIMIZE R@_ALU UNTIL           WITH R@_ALU_UNTIL

OPTIMIZE R>_ALU IF              WITH R>_ALU_IF
OPTIMIZE R>_ALU WHILE           WITH R>_ALU_WHILE
OPTIMIZE R>_ALU UNTIL           WITH R>_ALU_UNTIL

OPTIMIZE LITERAL @              WITH LIT_@
OPTIMIZE LITERAL C@             WITH LIT_C@

OPTIMIZE CELL+ @                WITH 2+_@
OPTIMIZE 2+ @                   WITH 2+_@
OPTIMIZE LIT_+ @                WITH LIT_+_@
OPTIMIZE LIT_- @                WITH LIT_-_@

OPTIMIZE LITERAL !              WITH LIT_!
OPTIMIZE LITERAL C!             WITH LIT_C!

OPTIMIZE LITERAL +!             WITH LIT_+!
OPTIMIZE LITERAL C+!            WITH LIT_C+!

OPTIMIZE DUP LIT_!              WITH DUP_LIT_!
OPTIMIZE DUP LIT_C!             WITH DUP_LIT_C!

OPTIMIZE DUP LIT_+!             WITH DUP_LIT_+!
OPTIMIZE DUP LIT_C+!            WITH DUP_LIT_C+!

OPTIMIZE SWAP !                 WITH SWAP_!
OPTIMIZE SWAP C!                WITH SWAP_C!

OPTIMIZE LITERAL SWAP_!         WITH LIT_SWAP_!
OPTIMIZE LITERAL SWAP_C!        WITH LIT_SWAP_C!

OPTIMIZE OVER !                 WITH OVER_!
OPTIMIZE OVER C!                WITH OVER_C!

OPTIMIZE LITERAL OVER_!         WITH LIT_OVER_!
OPTIMIZE LITERAL OVER_C!        WITH LIT_OVER_C!

OPTIMIZE LITERAL LIT_!          WITH LIT_LIT_!
OPTIMIZE LITERAL LIT_C!         WITH LIT_LIT_C!

OPTIMIZE LITERAL LIT_+!         WITH LIT_LIT_+!
OPTIMIZE LITERAL LIT_C+!        WITH LIT_LIT_C+!

OPTIMIZE LIT_@ LIT_!            WITH LIT_@_LIT_!
OPTIMIZE LIT_C@ LIT_C!          WITH LIT_C@_LIT_C!

OPTIMIZE LIT_! LIT_@            WITH LIT_!_LIT_@

OPTIMIZE (USER) !               WITH USER_!
OPTIMIZE LITERAL USER_!         WITH LIT_USER_!
OPTIMIZE (USER) @EXECUTE        WITH USER_@EXECUTE

OPTIMIZE DUP >R                 WITH DUP_>R
OPTIMIZE OVER >R                WITH OVER_>R
OPTIMIZE SWAP >R                WITH SWAP_>R
OPTIMIZE @ >R                   WITH @_>R
OPTIMIZE DUP @_>R               WITH DUP_@_>R
OPTIMIZE OVER @_>R              WITH OVER_@_>R
OPTIMIZE R> DROP                WITH R>_DROP

{ ---------------------------------------------------------------------
Simple rules
--------------------------------------------------------------------- }

OPTIMIZE DROP DROP              WITH 2DROP
OPTIMIZE SWAP DROP              WITH NIP
OPTIMIZE OVER OVER              WITH 2DUP
OPTIMIZE DUP +                  WITH 2*
OPTIMIZE ROT ROT                WITH -ROT
OPTIMIZE -ROT ROT               WITH NO_CODE
OPTIMIZE ROT -ROT               WITH NO_CODE
OPTIMIZE DUP DROP               WITH NO_CODE
OPTIMIZE OVER DROP              WITH NO_CODE
OPTIMIZE >R R>                  WITH NO_CODE
OPTIMIZE R> >R                  WITH NO_CODE
OPTIMIZE R@ DROP                WITH NO_CODE

[THEN]

