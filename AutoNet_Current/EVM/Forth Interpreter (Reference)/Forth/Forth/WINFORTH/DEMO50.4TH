\ DEMO50.4TH -- Simple demonstration of the WinForth internal multitasker.
\ Creates a background task which beeps once per second.
\ Copyright (c) 1992 LMI

TASKER   \ load multitasker if not already loaded

4096 128 TCB  BEEP-TCB   \ define task control block

\ --- ;  This is the background task.  Its job is to beep, 
\ then go to sleep for one second.
: BEEPER
   BEGIN  -1 MessageBeep
          1000 MSEC   \ delay execution of this task by 1 sec
   AGAIN ;

\ --- ; This command starts the background task.
: START-BEEPER   BEEP-TCB START BEEPER  BEEP-TCB WAKE ;

\ --- ; This command stops the background task.
: STOP-BEEPER    BEEP-TCB STOP ;

CR
CR .( Type the command: START-BEEPER <Enter> )
CR .( to launch the background task that beeps once per second.)
CR .( Type the command: STOP-BEEPER  <Enter> )
CR .( to kill the background task.)
CR


