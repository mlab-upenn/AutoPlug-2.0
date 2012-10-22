\ DEMO40.4TH -- Test callback allocation and service
\ Copyright (C) 1992 LMI
\
\ The routine DEMO allocates a callback for the routine
\ TIMERPROC, then starts a 10-second timer specifying the
\ callback address obtained from CBALLOC.  Each time the
\ timer interval elapses, the timer handler TIMERPROC
\ is entered from Windows.  TIMERPROC saves copies of its 
\ parameters, sounds a beep, increments a counter, and
\ exits back to Windows.
\
\ In order to successfully set up a timer callbacK with CBALLOC,
\ you have to know two things:
\ 1) The cfa of the Forth definition that will run as the 
\    callback routine.  
\ 2) The number of stack cells that Windows is going to supply 
\    as parameters when it enters the callback routine.  This
\    number is vital because the "umbrella" callback logic in
\    WinForth, which gets control before YOUR callback handler,
\    has to know how many cells to copy from Windows' stack onto
\    the Forth data stack, and it has to know how many cells to
\    discard from the Windows stack before it returns to Windows
\    after YOUR routine exits. 
\
\ In this particular case we get the CFA of TIMERPROC with the
\ ['] command.  We get the number of stack cells by looking
\ in the Windows API Function reference manual and finding that
\ timer callbacks are passed 4 parameters: 3 unsigned ints and
\ a double, for a total of 5 stack cells.
\

VARIABLE COUNTER  \ incremented on each entry to callback routine
VARIABLE CBHWND   \ window handle passed to callback routine
VARIABLE CBWMSG   \ message number passed to callback routine
VARIABLE CBWPARAM \ "word param" passed to callback routine
2VARIABLE CBLPARAM \ "long param" passed to callback routine

\ This is the Forth high-level handler for the timer callback.
\ CBHWND CBWMSG CBWPARAM CBLPARAM --- status
: TIMERPROC	CBLPARAM 2!  CBWPARAM !  CBWMSG !  CBHWND ! \ save params
                -1 MessageBeep  \ make a noise
                1 COUNTER  +!  \ increment counter
                0 ;  \ return with zero

\ This is the main demo word. It sets up the callback and
\ then creates the timer.
: DEMO  	COUNTER OFF
		['] TIMERPROC  5  CBALLOC  2DUP  NULPTR=
		ABORT" Can't allocate callback!"
		>R >R	 \ save thunk address for callback
		0 ( window handle )
		1 ( timer identifier ) 
		10000  ( timer interval in msec. = 10 seconds )
		R> R> ( retrieve thunk address )  
		SetTimer  \ create the timer 
		CR ." Timer handle = " . ;


CR
CR .( To run the demo, type the command: DEMO <Enter> )
CR .( DEMO allocates a callback and starts a 10-second timer.) 
CR .( The timer callback handler TIMERPROC saves copies of its )
CR .( parameters, increments the variable COUNTER, and sounds a )
CR .( beep.  You can inspect COUNTER to see it increment at )
CR .( 10-second intervals.)
CR




	   	
