\ Trace utility for WinForth 1.0
\ Adapted from TRACE implemented by Forth Systeme GmbH
\ Copyright 1993 LMI and Forth Systeme

FORTH DEFINITIONS DECIMAL

( --- char | 0 ; returns character if any is waiting )
: TRKEY     ?TERMINAL IF KEY ELSE 0 THEN ;

( cfa --- ; print out dictionary name if it has header )
: TRNAME    DUP >NAME DUP -1 =
            IF    DROP ." ?? =" U.
            ELSE  .NAME DROP BL EMIT THEN ;

( --- ; called on Esc key to abort tracing )
: TRABORT   trActive OFF  trMax OFF  trGo OFF
            CR CR ABORT ;

\ --- ; called after stack and current wordname audit to
\ check whether trace should be continued, paused, or aborted
: TRCHECK   vSTATUS PERFORM
            trGo @ IF  TRKEY  ELSE  KEY  THEN CASE
            027     OF  TRABORT                  ENDOF    \ Esc
            BL      OF  trGo @  0=  trGo !   ENDOF  \ Space
            ASCII U OF  trMax @ 1- 1 MAX trMax ! ENDOF      \ <
            ASCII N OF  trMax @ 1+ trMax !       ENDOF      \ >
            ASCII P OF  CR                              \ Pause
                        BEGIN  CR ." Command: "  QUERY  #TIB @
                        WHILE  INTERPRET  vSTATUS PERFORM
                        REPEAT CR  ENDOF
            ENDCASE ;

( --- ; display stack status horizontally )
: TRSTACK   ?STACK  DEPTH
            SPACE  32  OUT @  OVER MOD -  SPACES
            8 MIN  0
            ?DO   I PICK 6 BASE @ 10 =
                  IF  U.R  ELSE  .R   THEN
            LOOP  OUT @ 80 <>
            IF    CR
            THEN  trLev C@ 3 - 3 * SPACES ;

\ --- ; display current stack status, then name of definition
\ that is about to execute
: TRSTEP     TRSTACK  R> R@ SWAP >R @  TRNAME  TRCHECK ;

\ adr1 := address of jump or call relativ displacement
\ adr2 := address jumping to
\ absadr := adr2

\ reladr := adr2 - ( adr1 + 2 )
\ absadr := reladr + adr1 + 2

: absadr  ( reladr adr1 --- absadr )  + 2+ ;
: reladr  ( adr2 adr1 --- reladr adr1 )  SWAP OVER 2+ - SWAP ;

HEX

\ this is a literal copy of the in-line NEXT
CREATE LODSW AD C, FF C, E0 C,  \ lodsw AX jmp

DECIMAL

\ search for inline NEXT
\ starting_offset --- match_offset | -1
: TRSCH     >R  CS0 R@  CP @ R@ -       \ code segment: ptr len
            DS0  LODSW 3                   \ template: ptr len
            STRNDXL                  \ search for next instance
            R>  OVER  -1 =                         \ none left?
            IF   DROP                    \ exhausted, return -1
            ELSE +                      \ return offset of NEXT
            THEN ;

\ dest source --- ; assemble  "JMP dest"  at location "source"
: TRJMP     >R  [ HEX ] 0E9 [ DECIMAL ] HERE C!
            R@  3 + -  HERE 1+ !
            DS0 HERE  CS0 R>  3  CMOVEL ;

\ start_addr --- ; find all instances of NEXT and replace them
: TRREPL    BEGIN TRSCH \ look for next inline NEXT
          \ DUP U. ?TERMINAL DROP   \ debugging only
                   DUP -1 =                    \ found any more?
                   IF    DROP EXIT                        \ done
                   THEN  nextt OVER TRJMP    \ patch NEXT to JMP
                   3 +                  \ advance past this NEXT
            AGAIN  ;

\ --- ; initialize TRACE utility, patch up all necessary runtime
\ routines, put address of audit word in trace vector
: TRINIT
    \ replace all instances of NEXT starting with the central copy
    next TRREPL
    \ patch entry points of critical runtime routines
    unnestt ['] EXIT   TRJMP            \ codedef EXIT
    unnestt ['] unnest TRJMP            \ codedef unnest
    null?t  ['] NULL?  TRJMP            \ codedef NULL?
    nestt       nest   TRJMP            \ runtime nest
    doest       does   TRJMP            \ runtime does
    \ install trace audit routine
    ['] TRSTEP vTRACE ! ;

\ --- ; used in the form: TRACE <name>
: TRACE     TRINIT  ' 4 + CS0 SWAP 2DUP @L
            OVER absadr  DUP nest <> SWAP trEnb <> AND
            ABORT" must be colon-definition"
            trEnb SWAP reladr ROT SWAP !L ;

\ --- ; used in the form: UNTRACE <name>
\ If <name> was not previously being traced, takes no action
: UNTRACE   ' 4 + CS0 SWAP 2DUP @L  OVER absadr trEnb =
            IF  nest SWAP reladr ROT SWAP !L
            THEN ;

\ discard headers for tracer's building blocks and variables
EXCISE TRKEY TRINIT
EXCISE trLev trLev
EXCISE trMax trMax
EXCISE trGo trGo
EXCISE trActive trActive
EXCISE trEnb trEnb

CR CR
CR .( Trace utility loaded. To designate a word for tracing, enter: )
CR .(     TRACE <wordname>  )
CR .( For example,  after the command TRACE FOOBAR, a trace audit will)
CR .( be displayed whenever FOOBAR is executed. During a trace audit, the)
CR .( following keys are active:
CR .(     Spacebar  = run/stop trace )
CR .(     Enter     = single-step)
CR .(     Esc       = terminate trace)
CR .(     N         = nest trace)
CR .(     U         = unnest trace)
CR .(     P         = pause and accept commands)
CR .( See the on-line documentation for more information.)
CR CR
