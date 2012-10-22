\ DEMO52.4TH -- Multi-window demo program.
\ Creates multiple independent windows on the screen.
\ Copyright (C) 1994 LMI
\
\ The routine DEMO allocates a callback for the routine TIMERPROC. 
\ It then starts a 1-second timer specifying the callback address 
\ obtained from CBALLOC.  It also creates a frame window and
\ two auxiliary windows. Each time the timer interval elapses,
\ the timer handler TIMERPROC is entered from Windows.
\ TIMERPROC invalidates WIN1, WIN2, and WIN3, and exits back to
\ Windows. When the window handlers get a WM_PAINT message, 
\ they display the current time in their respective window.
\
\ This demo program illustrates the basic concept of multiwindow
\ programs and intra-app communication in Windows. Each window 
\ has (usually) its own message handler, and each window handler
\ maintains some internal state information about what should be
\ displayed in the window. When the handler gets a WM_PAINT message,
\ it updates the window. Other elements of the application program
\ force a particular message handler to execute and update its 
\ window by invalidating part or all of that window.
\ In this example, the actions taken by the window handlers are
\ trivial, but each could easily carry out completely different
\ actions or much more complex operations while they are handling
\ their respective WM_PAINT messages.  From each handler's point
\ of view, it executes asynchronously and in isolation from the
\ rest of the application; it has no way of knowing whether the
\ WM_PAINT message was forced by another routine in the same program
\ or was the result of an action by another application or operating
\ system component (such as the window being uncovered by the termination
\ of another application).  Of course, an application can also register
\ "private" messages and then use those to communicate among its modules
\ and message handlers, using the standard Windows mechanisms for 
\ message handling and callbacks.  
\
\ DEMO53.4TH is similar to this program but illustrates the steps
\ of creating multiple "child" windows within a parent or "frame" window.
\ See DEMO40.4TH for more discussion of timer creation and callbacks.

\ window control blocks for various windows
WCB WIN1
WCB WIN2
WCB WIN3

0 EQU HTIMER

\ arbitrary identifiers for menu items
100 CONSTANT IDM_FILEEXIT
101 CONSTANT IDM_FILEABOUT

\ menu for the frame window
MENU APPMENU 
  " &File" POPUP 
          " E&xit"     IDM_FILEEXIT   MF_ENABLED   MENUITEM 
          " "          0              MF_SEPARATOR MENUITEM 
          " A&bout..." IDM_FILEABOUT  MF_ENABLED   MENUITEM 
          END-POPUP 
END-MENU 

100 EQU ID_PUSHB  \ control ID for OK pushbutton in About Box

  " About DEMO52..."   
  16 16 128 70 DS_MODALFRAME WS_CAPTION D+ WS_POPUP D+
DIALOG  ABOUTDLG
  " FORTHICON"              12 16          -1        ICON
  " DEMO52.4TH"             32 8    96 12  -1        CTEXT
  " Sample WinForth App"    32 20   96 12  -1        CTEXT
  " (C) 1994 LMI"           32 32   96 12  -1        CTEXT
  " OK"                     44 50   40 16  ID_PUSHB  DEFPUSHBUTTON
END-DIALOG

( --- flag ; this is the callback handler for the About... dialog )
: ABOUTDLGPROC  wMsg WM_INITDIALOG =
                IF    TRUE EXIT
                THEN  wMsg WM_COMMAND =
                IF    wParam ID_PUSHB =
                      IF   0 CLOSEDLG THEN
                THEN  FALSE ;

\ This is the Forth high-level handler for the timer callback.
\ It is entered once per second and triggers update of the application's
\ three windows by invalidating them.
\ CBHWND CBWMSG CBWPARAM CBLPARAM --- status
: TIMERPROC	3DROP 2DROP    \ discard timer message params
                FALSE WIN1 WREPAINT  \ force window updates
                FALSE WIN2 WREPAINT  
                FALSE WIN3 WREPAINT 
                0 ;            \ return with zero

\ ^str --- ; display error message and OK button in message box
: ERRORBOX  " DEMO52"  \ messagebox title
            [ MB_ICONHAND MB_OK OR ] LITERAL \ icon, button
            MSGBOX DROP ;

\ msg --- ; send message to frame window
: MSG>MAINWIN  WIN1 WCB>HWND SWAP 0 0. SendMessage 2DROP ;

\ --- ; process WM_PAINT message for Window #1
: WIN1PAINT " Helv" FF_MODERN 36 FS_ITALIC WIN1 WSETFONT
	  GREEN PEN  0 0 GOTOXY  ." Hello world, it's " .T ." !" ;

\ --- ; process WM_PAINT message for Window #2
: WIN2PAINT " Helv" FF_MODERN 36 FS_BOLD WIN2 WSETFONT
          BLUE PEN 0 0 GOTOXY .T ;

\ --- ; process WM_PAINT message for Window #3
: WIN3PAINT " Helv" FF_MODERN 36 FS_BOLD WIN3 WSETFONT
	  RED PEN  0 0 GOTOXY .T ;
 
\ --- ;  This routine handles WM_COMMAND messages 
\ for window #1's menu bar.
: WIN1COMMAND wParam 
   CASE
     \ if File-Exit, send Close message to our main window
     \ simulating user's pick of Close from System Menu
     IDM_FILEEXIT  OF WM_CLOSE MSG>MAINWIN   ENDOF
     \ if File-About, activate About... dialog
     IDM_FILEABOUT OF ABOUTDLG ['] ABOUTDLGPROC RUNDLG DROP ENDOF
   ENDCASE ;

\ --- d; message handler for window #2
: WIN2PROC  wMsg CASE
            WM_PAINT OF    \ paint message for window #2
                           WIN2PAINT ENDOF
            \ default case: pass message to DefWindowProc()
            DEFMSGHANDLER EXIT
            ENDCASE 0 0 ; \ double value to return from message handler

\ --- d; message handler for window #3
: WIN3PROC  wMsg CASE
            WM_PAINT OF    \ paint message for window #3
                           WIN3PAINT ENDOF
            \ default case: pass message to DefWindowProc()
            DEFMSGHANDLER EXIT
            ENDCASE 0 0 ; \ double value to return from message handler

\ --- d; message handler for the frame window
: WIN1PROC  wMsg CASE
            WM_CREATE OF   \ main window #1 is materializing,
                           \ create and display window #2
                           WIN1 WGETSIZE DROP 100 WIN1 WSETSIZE
                           ['] WIN2PROC WIN2 SETMSGHANDLER
                           " DEMO52 Window #2" WIN2 WSETNAME
                           " APPICON" WIN2 WLOADICON DROP
                           WIN2 WCREATE 0= \ create main window
                           IF   " Can't create window #2!" ERRORBOX 
                                0 RETURN 
                           THEN
                           WIN1 WGETSIZE WIN2 WSETSIZE
                           WIN1 WGETPOS 100 + WIN2 WSETPOS
                           WIN2 WSHOW
                           \ create and display window #3
                           ['] WIN3PROC WIN3 SETMSGHANDLER
                           " DEMO52 Window #3" WIN3 WSETNAME
                           " APPICON" WIN3 WLOADICON DROP
                           WIN3 WCREATE 0= \ create main window
                           IF   " Can't create window #3!" ERRORBOX 
                                0 RETURN  
                           THEN
                           WIN2 WGETSIZE WIN3 WSETSIZE
                           WIN2 WGETPOS 100 + WIN3 WSETPOS
                           WIN3 WSHOW  ENDOF
            WM_PAINT OF    \ paint message, update window #1
                           WIN1PAINT ENDOF
            WM_SIZE OF     \ change in window #1 size, repaint
                           FALSE WIN1 WREPAINT ENDOF
            WM_COMMAND OF  \ menu command message for window #1
                           WIN1COMMAND ENDOF
            WM_DESTROY OF  \ kill message loop
                           0 PostQuitMessage ENDOF
            \ default case: pass message to DefWindowProc()
            DEFMSGHANDLER EXIT
            ENDCASE 0 0 ; \ double value from message handler

\ --- ; "main word" of sample application;
\ creates the timer and frame window and then enters message loop
: DEMO      ['] TIMERPROC  5  CBALLOC  2DUP  NULPTR=
            ABORT" Can't allocate callback!"
	    >R >R	 \ save thunk address for callback
	    0 ( window handle )  1 ( timer identifier ) 
	    1000  ( timer interval in msec. = 1 seconds )
            R> R> ( thunk address ) SetTimer  \ create the timer
            EQU HTIMER  \ save timer handle 
            ['] WIN1PROC WIN1 SETMSGHANDLER \ install msg handler
            " DEMO52 Window #1" WIN1 WSETNAME \ set frame window caption
            " APPICON" WIN1 WLOADICON DROP \ set icon
            WIN1 WCREATE 0= \ create main window
            IF   " Can't create frame window!" ERRORBOX 0 RETURN
            THEN APPMENU WIN1 WSETMENU FALSE = \ set frame window menu
            IF   " Can't create menu!" ERRORBOX 0 RETURN
            THEN WIN1 WSHOW \ display frame window
            WINMSGLOOP \ wait for WM_QUIT message
            0 HTIMER KillTimer DROP
	    WIN1 WCLOSE \ get rid of frame window
            WIN2 WCLOSE  WIN3 WCLOSE \ and other windows
            QUIT ( 0 RETURN ) ; \ exit application

CR
CR .( To run the demo, type the command: DEMO <Enter> ) 
CR




	   	
