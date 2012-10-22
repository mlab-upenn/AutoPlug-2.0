\ DEMO41.4TH -- Test callback allocation and service
\ This program is a simple example of use of an EnumXXX function
\ and its correspnding callback. Similar code can be used to 
\ enumerate fonts, font families, objects, and tasks.
\ Copyright (C) 1992 LMI
\
\ The routine DEMO allocates a callback for the routine
\ ENUMWINDOWSPROC and calls EnumWindows(). Windows then
\ calls ENUMWINDOWSPROC once for each parent window on the
\ screen, passing it the window handle and an application-
\ defined double value.  The callback function must return
\ TRUE to continue enumeration, FALSE to stop enumeraction.
\
\ In order to successfully set up an EnumXXX callbacK with CBALLOC,
\ you have to know two things:
\
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
\ In this particular case we get the CFA of ENUMWINDOWPOC with 
\ the ['] command.  We get the number of stack cells by looking
\ in the Windows API Function reference manual and finding that
\ the ENUMWINDOWSPROC() callback is passed 2 parameters: 1 unsigned 
\ int (a window handle) and 1 double value (application-specific),
\ for a total of 3 stack cells.
\

VARIABLE WINCOUNT

\ This is the Forth high-level handler for the callback.
\ hwnd lparam --- bool
: ENUMWINDOWSPROC 1 WINCOUNT +!
                  2DROP BASE @ >R CR ." Window handle: " HEX U.
                  R> BASE !  TRUE ;

\ This is the main demo word. It sets up the callback and
\ then creates the timer.
: DEMO  	DECIMAL WINCOUNT OFF  \ initialize window counter
                ['] ENUMWINDOWSPROC 3 CBALLOC  2DUP  NULPTR=
		ABORT" Can't allocate callback!"
		0. EnumWindows 0= ABORT" EnumWindows failed!" 
                CR WINCOUNT @ . ." windows found." CR 
                ['] ENUMWINDOWSPROC CBFREE ;

CR
CR .( To run the demo, type the command: DEMO <Enter> )
CR .( DEMO allocates a callback and enumerates parent windows.)
CR .( The callback routine ENUMWINDOWSPROC is entered once for)
CR .( each parent window in the system.)
CR




	   	
