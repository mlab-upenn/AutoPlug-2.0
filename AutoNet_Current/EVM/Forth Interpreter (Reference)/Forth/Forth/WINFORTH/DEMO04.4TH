\ DEMO04.4TH -- WinForth application skeleton with frame window.
\ Copyright (C) 1992 LMI

WCB MAINWIN    \ window control block for frame window

\ ^str --- ; display error message and OK button in message box
: ERRORBOX  " DEMO04"  \ messagebox title
            [ MB_ICONHAND MB_OK OR ] LITERAL \ icon, button
            MSGBOX DROP ;

\ message handler for the frame window
: WNDPROC   wMsg CASE
            WM_DESTROY OF  \ kill message loop
                           0 PostQuitMessage ENDOF
            \ default case: pass message to DefWindowProc()
            DEFMSGHANDLER EXIT
            ENDCASE 0 0 ; \ double value to return from message handler

\ "main word" of sample application;
\ creates the frame window and then enters message loop
: DEMO      ['] WNDPROC MAINWIN SETMSGHANDLER \ install msg handler
            " DEMO04" MAINWIN WSETNAME \ set frame window caption
            " APPICON" MAINWIN WLOADICON DROP \ set icon
            MAINWIN WCREATE 0= \ create main window
            IF   " Can't create frame window!" ERRORBOX 0 RETURN
            THEN MAINWIN WSHOW \ display frame window
            WINMSGLOOP \ wait for WM_QUIT message
	    MAINWIN WCLOSE \ get rid of frame window
            QUIT ( 0 RETURN ) ; \ exit application

CR
CR .( WinForth skeleton application loaded.) 
CR .( To run the demo, type:  DEMO <Enter> ) 
CR .( Exit with Close on System Menu.)
CR

DEMO
S

