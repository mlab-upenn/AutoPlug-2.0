\ DEMO24.4TH -- Illustrates painting and mouse tracking.
\ Modeled after from SCRIBBLE.C program in Petzold 2nd Edition.
\ Copyright (C) 1992 LMI

WCB MAINWIN    \ window control block for frame window

100 CONSTANT POINT#MAX
0 EQU POINT#

CREATE POINTS POINT#MAX WSIZE * 2* ALLOT

\ arbitrary identifiers for menu items
100 CONSTANT IDM_FILEEXIT
101 CONSTANT IDM_FILEABOUT
102 CONSTANT IDM_EDITCLEAR

\ menu for the frame window
MENU APPMENU 
  " &File" POPUP 
          " E&xit"     IDM_FILEEXIT   MF_ENABLED   MENUITEM 
          " "          0              MF_SEPARATOR MENUITEM 
          " A&bout..." IDM_FILEABOUT  MF_ENABLED   MENUITEM 
          END-POPUP 
  " &Edit" POPUP 
          " C&lear"    IDM_EDITCLEAR  MF_ENABLED   MENUITEM 
          END-POPUP 
END-MENU 

100 EQU ID_PUSHB  \ control ID for OK pushbutton in About Box

  " About DEMO24..."
  16 16 128 70 DS_MODALFRAME WS_CAPTION D+ WS_POPUP D+
DIALOG  ABOUTDLG
  " FORTHICON"              12 16          -1        ICON
  " DEMO24"                 32 8    96 12  -1        CTEXT
  " Sample WinForth App"    32 20   96 12  -1        CTEXT
  " (C) 1992 LMI"           32 32   96 12  -1        CTEXT
  " OK"                     44 50   40 16  ID_PUSHB  DEFPUSHBUTTON
END-DIALOG

\ ^str --- ; display error message and OK button in message box
: ERRORBOX  " DEMO24"  \ messagebox title
            [ MB_ICONHAND MB_OK OR ] LITERAL \ icon, button
            MSGBOX DROP ;

( --- flag ; this is the callback handler for the about dialog )
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
            IDM_EDITCLEAR  OF 0 EQU POINT#
                              MAINWIN WREPAINT ENDOF
            " Command not implemented" ERRORBOX
            ENDCASE ;

\ --- ; process WM_PAINT message
: DOPAINT POINT# 1 >
       IF   POINT# 1- 0 
            DO   POINT# 1
                 DO   hDC J 2* WSIZE * POINTS +
                      2@ MoveTo 2DROP
                      hDC I 2* WSIZE * POINTS +
                      2@ LineTo DROP
                 LOOP
            LOOP
      THEN ;

\ message handler for the frame window
: WNDPROC   wMsg CASE
            WM_PAINT OF    \ window needs updating
			   DOPAINT  ENDOF	
            WM_LBUTTONDOWN OF \ left mouse button pressed
                           POINT# POINT#MAX < 
                           IF  lParam POINTS POINT# WSIZE * 2* + 2!
                               POINT# 1+ EQU POINT#
                           THEN ENDOF
            WM_LBUTTONUP OF \ left button released, repaint window
                           MAINWIN WREPAINT ENDOF
            WM_CREATE OF   \ when frame window created, 
                           ENDOF
            WM_SIZE OF     \ change in window size, force complete repaint
                           MAINWIN WREPAINT ENDOF
            WM_COMMAND OF  \ menu command message
                           DOCOMMAND ENDOF
            WM_DESTROY OF  0 PostQuitMessage \ kill message loop
                           ENDOF
            \ default case: pass message to DefWindowProc()
            DEFMSGHANDLER EXIT 
            ENDCASE 0 0 ; \ double value to return from message handler

\ "main word" of sample SCRIBBLE application;
\ creates the frame window and then enters message loop
: DEMO      ['] WNDPROC MAINWIN SETMSGHANDLER \ install msg handler
            " DEMO24" MAINWIN WSETNAME \ set frame window caption
            " APPICON" MAINWIN WLOADICON DROP \ set icon
            MAINWIN WCREATE 0= \ create main window
            IF   " Can't create frame window!" ERRORBOX 0 RETURN
            THEN APPMENU MAINWIN WSETMENU FALSE = \ set frame window menu
            IF   " Can't create menu!" ERRORBOX 0 RETURN
            THEN MAINWIN WSHOW \ display frame window
            WINMSGLOOP \ wait for WM_QUIT message
	    MAINWIN WCLOSE
            QUIT ( 0 RETURN ) ; \ exit to Windows

CR
CR .( To run the "scribble" demo, type:  DEMO <Enter> )
CR .( Click the left mouse button at different points in )
CR .( the window and see what happens.)
CR


            
