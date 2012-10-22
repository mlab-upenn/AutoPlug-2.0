\ DEMO53.4TH -- Multi-window demo program.
\ Creates multiple child windows within a single frame window.
\ Copyright (C) 1994 LMI
\
\ The routine DEMO allocates a callback for the routine TIMERPROC. 
\ It then starts a 1-second timer specifying the callback address 
\ obtained from CBALLOC.  It also creates a frame window and
\ three child windows. Each time the timer interval elapses,
\ the timer handler TIMERPROC is entered from Windows.
\ TIMERPROC invalidates one of the three child windows, depending 
\ on the current time (seconds MOD 3), and then exits back to
\ Windows. When the child window handlers get a WM_PAINT message, 
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
\ DEMO52.4TH is similar to this program but illustrates the steps
\ of creating multiple independent windows on the screen.
\ See DEMO40.4TH for more discussion of timer creation and callbacks.
\
\ Modified 8/10/94 to resize child windows in response to 
\ WM_SIZE message to frame window.
\

\ window control blocks for various windows
WCB WINP   \ parent window
WCB WIN1   \ child window #1
WCB WIN2   \ child window #2
WCB WIN3   \ child window #3

\ construct a style for this app's child windows
WS_CHILD WS_VISIBLE D+  WS_BORDER D+  2CONSTANT WS_APPCHILD

\ handle for 1-second timer
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

  " About DEMO53..."   
  16 16 128 70 DS_MODALFRAME WS_CAPTION D+ WS_POPUP D+
DIALOG  ABOUTDLG
  " FORTHICON"              12 16          -1        ICON
  " DEMO53.4TH"             32 8    96 12  -1        CTEXT
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
\ It is entered once per second and triggers update of one of
\ the three child windows by invalidating it. The child window
\ is selected on the basis of the current time (seconds MOD 3).
\ CBHWND CBWMSG CBWPARAM CBLPARAM --- status
: TIMERPROC     3DROP 2DROP    \ discard timer message params
                @TIME NIP >< 255 AND 3 MOD  \ seconds MOD 3
                CASE  \ force appropriate window update
                0 OF  FALSE WIN1 WREPAINT  ENDOF
                1 OF  FALSE WIN2 WREPAINT  ENDOF
                2 OF  FALSE WIN3 WREPAINT  ENDOF
                ENDCASE 0 ;    \ return with zero

\ ^str --- ; display error message and OK button in message box
: ERRORBOX  " DEMO53"  \ messagebox title
            [ MB_ICONHAND MB_OK OR ] LITERAL \ icon, button
            MSGBOX DROP ;

\ msg --- ; send message to frame window
: MSG>MAINWIN  WINP WCB>HWND SWAP 0 0. SendMessage 2DROP ;

\ --- ; process WM_PAINT message for child window #1
: WIN1PAINT " Helv" FF_MODERN 36 FS_NORMAL WIN1 WSETFONT
          GREEN PEN  0 0 GOTOXY  ." Child window #1 at " .T ;

\ --- ; process WM_PAINT message for child window #2
: WIN2PAINT " Helv" FF_MODERN 36 FS_BOLD WIN2 WSETFONT
          BLUE PEN 0 0 GOTOXY  ." Child window #2 at " .T ;

\ --- ; process WM_PAINT message for child window #3
: WIN3PAINT " Helv" FF_MODERN 36 FS_ITALIC WIN3 WSETFONT
          RED PEN  0 0 GOTOXY  ." Child window #3 at " .T ;
 
\ --- d; message handler for child window #1
: WIN1PROC  wMsg CASE
            WM_PAINT OF    \ paint message for window #1
                           WIN1PAINT ENDOF
            \ default case: pass message to DefWindowProc()
            DEFMSGHANDLER EXIT
            ENDCASE 0 0 ; \ double value to return from message handler

\ --- d; message handler for child window #2
: WIN2PROC  wMsg CASE
            WM_PAINT OF    \ paint message for window #2
                           WIN2PAINT ENDOF
            \ default case: pass message to DefWindowProc()
            DEFMSGHANDLER EXIT
            ENDCASE 0 0 ; \ double value to return from message handler

\ --- d; message handler for child window #3
: WIN3PROC  wMsg CASE
            WM_PAINT OF    \ paint message for window #3
                           WIN3PAINT ENDOF
            \ default case: pass message to DefWindowProc()
            DEFMSGHANDLER EXIT
            ENDCASE 0 0 ; \ double value to return from message handler

\ --- ;  This routine handles WM_COMMAND messages
\ for the frame window's menu bar
: WINCOMMAND wParam 
   CASE
     \ if File-Exit, send Close message to our main window
     \ simulating user's pick of Close from System Menu
     IDM_FILEEXIT  OF WM_CLOSE MSG>MAINWIN   ENDOF
     \ if File-About, activate About... dialog
     IDM_FILEABOUT OF ABOUTDLG ['] ABOUTDLGPROC RUNDLG DROP ENDOF
   ENDCASE ;

\ --- ; process WM_PAINT message for parent window
\ by invalidating all three of the child windows
: WINPAINT FALSE WIN1 WREPAINT 
           FALSE WIN2 WREPAINT   
           FALSE WIN3 WREPAINT ;

\ --- d; message handler for the frame window
: WINPROC  wMsg CASE
            WM_CREATE OF   \ frame window is materializing,
                           \ install message handlers for
                           \ child windows
                           ['] WIN1PROC WIN1 SETMSGHANDLER
                           ['] WIN2PROC WIN2 SETMSGHANDLER
                           ['] WIN3PROC WIN3 SETMSGHANDLER
                           \ set handle of parent (frame) window
                           \ into WCB for each child window
                           hWnd WIN1 WSETPARENT
                           hWnd WIN2 WSETPARENT
                           hWnd WIN3 WSETPARENT
                           \ set styles of child windows
                           WS_APPCHILD WIN1 WSETSTYLE
                           WS_APPCHILD WIN2 WSETSTYLE
                           WS_APPCHILD WIN3 WSETSTYLE
                           \ create the 3 child windows
                           WIN1 WCREATE 0=  \ create child window #1
                           IF   " Can't create child window #1!" ERRORBOX 
                                0 RETURN 
                           THEN 
                           WIN2 WCREATE 0=  \ create child window #2
                           IF   " Can't create child window #2!" ERRORBOX 
                                0 RETURN 
                           THEN
                           WIN3 WCREATE 0=  \ create child window #3
                           IF   " Can't create child window #3!" ERRORBOX 
                                0 RETURN 
                           THEN
                           \ reveal child windows
                           WIN1 WSHOW  WIN2 WSHOW  WIN3 WSHOW
                           ENDOF
            WM_SIZE OF     \ frame window has been moved or resized,
                           \ set size & position of child windows;
                           \ in a real application we would do this 
                           \ a little more carefully to take account of
                           \ border widths and to allow for the fact
                           \ that the frame window y-dimension is not
                           \ necessarily a multiple of 3.
                           WINP WGETCLIENTSIZE   \ x y
                           3 / >R     \ parent y dimension/3
                           DUP R@  WIN1 WSETSIZE
                           DUP R@  WIN2 WSETSIZE
                               R@  WIN3 WSETSIZE
                           0 0     WIN1 WSETPOS
                           0 R@    WIN2 WSETPOS
                           0 R> 2* WIN3 WSETPOS
                           \ force repaint of frame window
                           FALSE WINP WREPAINT 
                           ENDOF
            WM_PAINT OF    \ paint message, update frame window
                           WINPAINT ENDOF
            WM_COMMAND OF  \ menu command message for frame window 
                           WINCOMMAND ENDOF
            WM_DESTROY OF  \ kill message loop
                           0 PostQuitMessage ENDOF
            \ default case: pass message to DefWindowProc()
            DEFMSGHANDLER EXIT
            ENDCASE 0 0 ; \ double value from message handler

\ --- ; "main word" of sample application;
\ creates the timer and frame window and then enters message loop
: DEMO      ['] TIMERPROC  5  CBALLOC  2DUP  NULPTR=
            ABORT" Can't allocate callback!"
            >R >R        \ save thunk address for callback
            0 ( window handle )  1 ( timer identifier ) 
            1000  ( timer interval in msec. = 1 seconds )
            R> R> ( thunk address ) SetTimer  \ create the timer
            EQU HTIMER  \ save timer handle 
            ['] WINPROC WINP SETMSGHANDLER \ install msg handler
            " DEMO53" WINP WSETNAME \ set frame window caption
            " APPICON" WINP WLOADICON DROP \ set icon
            APPMENU WINP WSETMENU FALSE = \ set frame window menu
            IF   " Can't create menu!" ERRORBOX 0 RETURN
            THEN WINP WCREATE 0= \ create main window
            IF   " Can't create frame window!" ERRORBOX 0 RETURN
            THEN WINP WSHOW \ display frame window
            WINMSGLOOP \ wait for WM_QUIT message
            0 HTIMER KillTimer DROP
            WIN1 WCLOSE  \ get rid of child windows
            WIN2 WCLOSE  
            WIN3 WCLOSE
            WINP WCLOSE  \ get rid of frame window
            QUIT ( 0 RETURN ) ; \ exit application

CR
CR .( To run the demo, type the command: DEMO <Enter> ) 
CR




                
