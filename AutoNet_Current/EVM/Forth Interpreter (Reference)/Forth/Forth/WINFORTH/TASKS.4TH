\ Display task control blocks and state of background tasks
\ Copyright 1986-1993 Laboratory Microsystems Inc.

FORTH DEFINITIONS DECIMAL

EXISTS? OPERATOR NOT .IF TASKER .THEN \ load multitasker if necessary

( n --- )
: TAB           OUT @ - 0 MAX SPACES ;

( n --- ; display a number in hexadecimal )
: H4.           BASE @ >R   HEX
                0 <# # # # # #>  TYPE ASCII H EMIT
                R> BASE ! ;

( n --- ; display current state of TCB )
: .TCBSTATE
           CASE
            -1  OF  ." Asleep"  ENDOF
            0   OF  ." Awake "  ENDOF
            ( <>0, <>-1)  ." Delay"
           ENDCASE ;

( tcb --- ; display one task control block )
: .TCB      CR  DUP H4. 6 TAB  DUP BODY> >NAME .NAME 22 TAB
            DUP 2+ @ .TCBSTATE
            30 TAB
            DUP  6 + @  OVER 10 + @ - H4. \ return stack size
            40 TAB  DUP  10 + @  H4.        \ data stack size
            50 TAB  DUP  14 + @  H4.         \ stack selector
            4 + @ ?DUP
            IF   CR 6 TAB ." owned by " >NAME .NAME THEN ;

( --- )
: .TASKS        CR CR
                30 TAB  ." Ret Stk" 40 TAB ." Data Stk"
                50 TAB  ." Stack"
                CR  ." Task Control Block" 22 TAB ." State"
                30 TAB   ." Size"  40 TAB ." Size"
                50 TAB   ." Selector"  CR
                OPERATOR DUP                     \ head_tcb tcb
                BEGIN   DUP .TCB             \ display this tcb
                        @ 2DUP =          \ go to next in chain
                UNTIL
                2DROP CR ;


CR CR .( Enter .TASKS to show tasks and TCBs.) CR CR

