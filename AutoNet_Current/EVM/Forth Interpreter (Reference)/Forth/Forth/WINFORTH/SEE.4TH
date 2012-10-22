\ Decompiler for WinForth 1.0                    
\ Copyright (c) 1983-1993 Laboratory Microsystems Inc.

\ The release of this decompiler by LMI does not imply that we
\ will not change the underlying implementation of WINFORTH at
\ any time. It is provided "as is" without any guarantee of
\ completeness or compatibility with future versions of WINFORTH.
\ Modified from the original PC/FORTH version by Tom Almy

CR .( Wait ... loading Decompiler ) CR

FORTH DEFINITIONS DECIMAL

VOCABULARY TVOCAB

BSTART OVERLAY

VARIABLE    $QUIT       ( flag to quit decompiling )
VARIABLE    $IP         ( pseudo FORTH instruction pointer )
VARIABLE    $INDEF      ( in colon definition )
VARIABLE    $BRANCH     ( farthest branch target )
: CSC@  CS0 SWAP C@L ;
: CS@   CS0 SWAP @L ;

( n --- ; print # in hex and decimal )
: N.    DUP DECIMAL . SPACE HEX 0 ."  (" D. ." h) "  DECIMAL ;

( --- ; tab or carriage return depending on current column )
: CR?   OUT @ ?DUP
        IF 39 > IF   CR
                ELSE 20 OUT @ OVER MOD - SPACES
                THEN
        THEN ;

( cfa --- ; print out dictionary name if it has header )
: .NAME?  DUP >NAME DUP -1 =
          IF    DROP ." ?? =" N. EXIT
          THEN  NIP
          HS0 OVER 2DUP C@L 2+ + C@L 2 AND ( immediate )
          $INDEF @
          IF    DUP
                IF ." [COMPILE] " THEN
          THEN  SWAP .NAME  $INDEF @
          IF    DROP
          ELSE  IF ." IMMEDIATE" THEN
          THEN ;

( ---- address ; get address  of literal argument )
: GETLIT        $IP @ 2+ DUP $IP ! ;

( string string --- ; display string literal )
: .LITQ         COUNT TYPE
                ASCII " EMIT
                SPACE  COUNT TYPE
                ASCII " EMIT  ;

( --- addr ; return address of string literal )
: LITQ          $IP @ 2+ DUP >R COUNT + ALIGN  $IP !
                R> ;
( --- ; display target of branch or loop runtime routine )
: .BRANCH       GETLIT DUP @  + HEX DUP U. DECIMAL
                DUP $BRANCH @ U> IF $BRANCH ! ELSE DROP THEN ;

: .VAR          ." Variable, address = "
                $IP @ EXECUTE DUP N.  CR
                10 SPACES ." current value = "
                @ N.    ;

: .EQU          ." EQUate, current value = "
                $IP @ EXECUTE N. ;

: .2EQU         ." 2EQUate, current value = "
                $IP @ EXECUTE D. ;

: .CONST        ." Constant, value = "
                $IP @ EXECUTE N.    ;

: .USERV        ." User " .VAR  ;

: .2CONST       ." 2Constant, value = "
                $IP @ EXECUTE D.  ;

: .VOCAB        ." Vocabulary #" $IP @ >BODY @ . ;

: .PRIM         ." <Primitive>" ;

\ these become addresses of runtime routines
0   EQU p.EQU   
0. 2EQU p.2EQU   
0   EQU p.LEAVE
0   EQU p.DO  
0   EQU p.?DO  
0   EQU p.LOOP 
0   EQU p.+LOOP
0   EQU p.lit 
0   EQU p.dlit 
0   EQU p.dotq 
0   EQU p.abtq

: X  DO [ HERE 4 - @ EQU p.DO ]
        LEAVE [ HERE 2- @ EQU p.LEAVE ]
     LOOP [ HERE 4 - @ EQU p.LOOP ]
     ?DO [ HERE 4 - @ EQU p.?DO ]
     +LOOP [ HERE 4 - @ EQU p.+LOOP ]
     0 EQU p.EQU [ HERE 4 - @ EQU p.EQU ]
     0. 2EQU p.2EQU [ HERE 4 - @ S>D  2EQU p.2EQU ]
     1000 [ HERE 4 - @ EQU p.lit ]
     1000. [ HERE 6 - @ EQU p.dlit ]
     ." X" [ HERE 2- @ EQU p.dotq ]
 ABORT" X" [ HERE 2- @ EQU p.abtq ] ;

: SEE2    $INDEF ON  CR    $BRANCH OFF  $IP @ 1+ CS@ $IP !
  BEGIN  $IP @                           ( simulated Forth IP )
   DUP HEX U. SPACE DECIMAL           ( print hex IP location )
     @ CASE ( decode word type it )
     ( runtime words for control structures )
     ['] 0branch  OF  ." Jz "    .BRANCH  ENDOF
     ['] branch   OF  ." Jmp "   .BRANCH  ENDOF
     p.DO         OF  ." Do"     2 $IP +! ENDOF
     p.?DO        OF  ." ?Do"    2 $IP +! ENDOF
     ['] of       OF  ." Of"     2 $IP +! ENDOF
     p.LOOP       OF   ." Loop " .BRANCH  ENDOF
     p.+LOOP      OF  ." +Loop " .BRANCH  ENDOF
     p.LEAVE      OF  ." LEAVE"  ENDOF
     ( miscellaneous literal data types etc. )
     ['] COMPILE  OF  GETLIT  @ ." COMPILE: " .NAME? ENDOF
     p.dlit       OF  $IP @ 2+ DUP 2+ $IP ! 2@ D. ENDOF
     p.lit        OF  GETLIT @ N.                ENDOF
     p.EQU        OF  GETLIT @ ." EQU " BODY> .NAME? ENDOF
     p.2EQU DROP  OF  GETLIT @ ." 2EQU " BODY> .NAME? ENDOF
     ['] litq     OF  LITQ  $IP @ @ CASE  \ get type of string
          p.dotq OF " ." ENDOF  p.abtq OF " ABORT" ENDOF
          " " -2 $IP +! SWAP ENDCASE .LITQ ENDOF
     ['] (;CODE)  OF  ." ;CODE"   $QUIT ON       ENDOF
     ['] EXIT     OF  $BRANCH @ $IP @ U> IF ." EXIT " ELSE
                     ." ;"  $QUIT ON THEN        ENDOF
     ['] unnest   OF  ." ;" $QUIT ON ENDOF

     ( default case )
     DUP  .NAME?           ( print name if it has a header )
     ENDCASE CR?           ( tab or carriage return as needed )
     2 $IP +!                       ( advance Forth pseudo IP )
     $QUIT @ ESC?  OR                ( time to stop yet ? )
  UNTIL  ;

: 'RTIME  ' DUP 4 + CS@ + [COMPILE] LITERAL ; IMMEDIATE

10 EQU TEMP1   10. 2CONSTANT TEMP2

: LOAD-AND-JUMPS
       $IP @ 4 + CS@ $IP @ + CASE ( one of many... )
          'RTIME TVOCAB OF .VOCAB ENDOF
          'RTIME TEMP1 OF .EQU  ENDOF
          'RTIME SOURCE OF .2EQU ENDOF
          'RTIME CONTEXT OF .VAR  ENDOF
          'RTIME TEMP2 OF .2CONST ENDOF
          'RTIME S0 OF .USERV ENDOF
          'RTIME SEE2 OF SEE2 ENDOF
        ." USER DEFINED TYPE:"  DUP N.  ENDCASE   ;

HEX

( cfa --- ; or  --- followed by name )
: SEE    BASE @ >R    $INDEF OFF
  DEPTH 1 <> IF ' THEN        ( if cfa not on stack look it up )
  DUP .NAME? 2 SPACES  $QUIT OFF   $IP !
  $IP @  DUP  HEX U.  SPACE  DECIMAL   ( print hex IP location )
  CSC@   CASE                               ( decode word type )
  053 OF   $IP @ 1+ CSC@ 0BB =
           IF   .CONST 
           ELSE .PRIM 
           THEN ENDOF
  0BF OF   LOAD-AND-JUMPS   ENDOF
  ( default case) .PRIM
  ENDCASE CR R> BASE ! ;

DECIMAL  

EXCISE $QUIT LOAD-AND-JUMPS \ clean up helper words

CR CR
CR .( To use, either supply SEE with a word name or a cfa. For example: )
CR .( SEE LIST <Enter>  or  HEX 9FCA SEE <Enter> )
CR .( Latter form can be used to decompile headerless words.)
CR CR

