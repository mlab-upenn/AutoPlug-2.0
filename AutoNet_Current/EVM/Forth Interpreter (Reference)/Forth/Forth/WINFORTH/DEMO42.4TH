\ DEMO42.4TH -- Test callback allocation and service
\ This program is a simple example of use of an EnumXXX function
\ and its correspnding callback. 
\ Copyright (C) 1992 LMI
\
\ The routine DEMO allocates a callback for the routine
\ ENUMFONTSPROC and calls EnumFonts().  Windows then
\ calls ENUMFONTSPROC once for each font family, passing
\ far pointers to data structures describing the font.
\ The callback function must return TRUE to continue enumeration, 
\ FALSE to stop enumeraction.
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
\ In this particular case we get the CFA of ENUMFONTSPROC with 
\ the ['] command.  We get the number of stack cells by looking
\ in the Windows API Function reference manual and finding that
\ ENUMFONTSPROC() callbacks are passed 4 parameters: 1 unsigned 
\ int (a code for the font type) and 3 double values (two far
\ pointers, and one application-specific value), for a total of 
\ 7 stack cells.
\

FORTH DEFINITIONS DECIMAL

0. PTR LFPTR

\ This is the Forth high-level handler for the callback.
\ lplf lpntm n_fontype lparam --- bool
: ENUMFONTSPROC   DROP 2DROP 2DROP  \ discard top 3 parameters
		  PTR LFPTR \ save pointer to LOGFONT struct
		  LFPTR 18 >PTR HERE ADDR>PTR 64 CMOVEL
		  HERE -ASCIIZ CR COUNT TYPE
                  TRUE ; \ return TRUE to continue enumeration

\ This is the main demo word. It sets up the callback and
\ then creates the timer.
: DEMO          ['] ENUMFONTSPROC 7 CBALLOC  2DUP  NULPTR=
		ABORT" Can't allocate callback!"
		>R >R  \ save callback address
		WGETDC \ get device context for display
		hDC 0. R> R> 0. EnumFonts 
                CR ." EnumFonts result = " . CR
                WRELDC  \ release device context
                ['] ENUMFONTSPROC CBFREE ;

CR
CR .( To run the demo, type the command: DEMO <Enter> )
CR .( DEMO allocates a callback and enumerates fonts.)
CR .( The callback routine ENUMFONTSPROC is entered once for)
CR .( each font family in the system.)
CR




	   	
