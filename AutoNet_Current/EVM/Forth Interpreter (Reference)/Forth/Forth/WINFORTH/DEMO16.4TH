\ DEMO16.4TH -- Illustrates use of caret, EMIT, and GOTOXY
\               in a window message handler.
\ Copyright (C) 1992 LMI
\
\ This simple program does not buffer text, so if you move, resize, or
\ iconize/restore the window, the window's contents are lost.
\ Note that the preferred time to paint text within a window is during
\ a WM_PAINT message.  When you paint text at any other time, you have
\ to use WGETDC/WRELDC to allocate/release a device context, and you have
\ to be careful to hide the caret before painting and show it again afterwards.

WCB MAINWIN    \ window control block for frame window

0 EQU HEIGHT \ char height for current font
0 EQU WIDTH \ char width for current font
0 EQU LINES \ lines within client area
0 EQU CURY \ X cursor coordinate
0 EQU CURX \ Y cursor coordinate

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

  " About DEMO16..."   
  16 16 128 70 DS_MODALFRAME WS_CAPTION D+ WS_POPUP D+
DIALOG  ABOUTDLG
  " FORTHICON"            12 16          -1        ICON
  " DEMO16"               32 8    96 12  -1        CTEXT
  " Sample WinForth App"  32 20   96 12  -1        CTEXT
  " (C) 1992 LMI"         32 32   96 12  -1        CTEXT
  " OK"                   44 50   40 16  ID_PUSHB  DEFPUSHBUTTON
END-DIALOG

\ ^str --- ; display error message and OK button in message box
: ERRORBOX  " DEMO16"  \ messagebox title
            [ MB_ICONHAND MB_OK OR ] LITERAL \ icon, button
            MSGBOX DROP ;

( --- flag ; this is the callback handler for the test dialog )
: ABOUTDLGPROC  wMsg WM_INITDIALOG =
                IF    TRUE EXIT
                THEN  wMsg WM_COMMAND =
                IF    wParam ID_PUSHB =
                      IF   0 CLOSEDLG THEN
                THEN  FALSE ;

\ msg --- ; send message to frame window
: MSG>MAINWIN  MAINWIN WCB>HWND SWAP 0 0. SendMessage 2DROP ;

\ --- This routine handles WM_COMMAND messages from the frame window's menu.
: DOCOMMAND wParam CASE
	    IDM_FILEEXIT   OF WM_CLOSE MSG>MAINWIN   ENDOF
            IDM_FILEABOUT  OF ABOUTDLG         \ dialog structure
                              ['] ABOUTDLGPROC \ dialog handler
                              RUNDLG DROP            ENDOF
            " Command not implemented" ERRORBOX
            ENDCASE ;

\ --- ; handle WM_SIZE message, get size of window, character
: DOSIZE    hDC DUP >R 0= IF WGETDC THEN
            \ get char height and width for current font
	    MAINWIN WGETCHARSIZE EQU HEIGHT EQU WIDTH 
            \ calc lines within client area
            YMAX HEIGHT / EQU LINES
            \ initialize cursor coordinate
	    0 EQU CURY   0 EQU CURX  
            \ position the cursor
            CURX CURY GOTOXY
            \ release DC if necessary
            R> 0= IF WRELDC THEN ;

\ --- ; handle WM_CREATE message
: DOCREATE  " Courier" FF_MODERN 10 FS_NORMAL MAINWIN WSETFONT 
            DOSIZE \ find size of window, characters 
            0 0 WIDTH HEIGHT MAINWIN WMAKECARET ;  \ create caret

\ --- ; increment cursor Y position or scroll window as necessary
: CURYINC   CURY 1+ LINES =
            IF   hWnd 0 HEIGHT NEGATE 0. 0. ScrollWindow
                 hWnd UpdateWindow
            ELSE CURY 1+ EQU CURY
            THEN ;

\ --- ; increment cursor X position
: CURXINC   CURX 1+ EQU CURX  CURX 80 =  
            IF CURYINC  0 EQU CURX  THEN ;

\ --- ; handle WM_CHAR message - position cursor, display character
\ we must hide caret temporarily because we are not in WM_PAINT message
: DOCHAR    WGETDC  MAINWIN WHIDECARET  wParam 255 AND CASE
            13 OF   0 EQU CURX  CURYINC  ENDOF  \ CR
            10 OF   CURYINC  ENDOF              \ LF
             8 OF   CURX 0=                     \ BS
                    IF   0 MessageBeep \ can't back up
                    ELSE CURX 1- EQU CURX \ back up cursor
                         CURX CURY GOTOXY \ position cursor
                         BL EMIT \ erase prev char
                    THEN ENDOF
                    \ default case
                    CURX CURY GOTOXY  \ position cursor
                    wParam 255 AND EMIT  \ send character
                    CURXINC  \ increment cursor position
            ENDCASE CURX CURY GOTOXY  MAINWIN WSHOWCARET  WRELDC ;

\ message handler for the frame window
: WNDPROC   wMsg CASE
	    WM_CREATE OF   DOCREATE  ENDOF
            WM_CHAR  OF    DOCHAR  ENDOF
            WM_SIZE OF     \ change in window size, erase window,
	                   \ get size, reset cursor position
                           DOSIZE  
                           MAINWIN WREPAINT ENDOF
            WM_COMMAND OF  \ menu command message
                           DOCOMMAND ENDOF
            WM_CLOSE OF    MAINWIN WKILLCARET \ destroy caret
                           hWnd DestroyWindow DROP ENDOF
            WM_DESTROY OF  0 PostQuitMessage \ kill message loop
                           ENDOF
            \ default case: pass message to DefWindowProc()
            DEFMSGHANDLER EXIT 
            ENDCASE 0 0 ; \ double value to return from message handler

\ "main word" of sample TYPER application;
\ creates the frame window and then enters message loop
: DEMO      ['] WNDPROC MAINWIN SETMSGHANDLER \ install msg handler
            " DEMO16" MAINWIN WSETNAME \ set frame window caption
            " APPICON" MAINWIN WLOADICON DROP \ set icon
            MAINWIN WCREATE 0= \ create main window
            IF   " Can't create frame window!" ERRORBOX 0 RETURN
            THEN APPMENU MAINWIN WSETMENU FALSE = \ set frame window menu
            IF   " Can't create menu!" ERRORBOX 0 RETURN
            THEN MAINWIN WSHOW \ display frame window
            WINMSGLOOP \ wait for WM_QUIT message
	    MAINWIN WCLOSE \ close main window
            QUIT ( 0 RETURN ) ; \ exit to Windows

CR
CR .( To run the glass teletype demo, type:  DEMO <Enter> )
CR .( Then type within the window, hitting the return key. )
CR .( to move to a new line when desired.)
CR


            






 
