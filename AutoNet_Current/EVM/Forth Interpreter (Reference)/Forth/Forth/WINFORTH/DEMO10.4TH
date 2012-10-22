\ DEMO10.4TH  Illustrates use of character positioning and
\             EMIT character output in a window message handler.
\ Copyright (C) 1991 LMI

WCB MAINWIN    \ window control block for frame window

0 EQU HEIGHT \ char height for current font
0 EQU WIDTH  \ average char width for current font

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

  " About DEMO10..."   
  16 16 128 70 DS_MODALFRAME WS_CAPTION D+ WS_POPUP D+
DIALOG  ABOUTDLG
  " APPICON"                   12 16          -1        ICON
  " DEMO10.4TH"                32 8    96 12  -1        CTEXT
  " Sample WinForth App"       32 20   96 12  -1        CTEXT
  " (C) 1991 LMI"              32 32   96 12  -1        CTEXT
  " OK"                        44 50   40 16  ID_PUSHB  DEFPUSHBUTTON
END-DIALOG

\ ^str --- ; display error message and OK button in message box
: ERRORBOX  " DEMO10" \ messagebox title
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

\ message handler for the frame window
: WNDPROC   wMsg CASE
            WM_CREATE OF   WGETDC  \ get a device context (DC)
                           \ get char height for current font
	                   MAINWIN WGETCHARSIZE EQU HEIGHT EQU WIDTH
                           WRELDC ENDOF \ release the DC
            WM_PAINT OF    \ window needs updating
                           BASE @ >R  HEX
                           16 0 DO
                              0  I 2+ HEIGHT * WSETXY
                              I 16 * 0 <# ASCII H HOLD # # #> TYPE
                              16 0 DO
                                 I 2+ WIDTH * 3 * \ x
                                 J 2+ HEIGHT *    \ y
                                 WSETXY
                                 J 16 * I + EMIT  \ character code
                              LOOP
                           LOOP  R> BASE !  ENDOF
            WM_SIZE OF     \ change in window size, force complete repaint
                           MAINWIN WREPAINT ENDOF
            WM_COMMAND OF  \ menu command message
                           DOCOMMAND ENDOF
            WM_DESTROY OF  0 PostQuitMessage \ kill message loop
                           ENDOF
            \ default case: pass message to DefWindowProc()
            DEFMSGHANDLER EXIT 
            ENDCASE 0 0 ; \ double value to return from message handler

\ "main word" of sample application;
\ creates the frame window and then enters message loop
: DEMO      ['] WNDPROC MAINWIN SETMSGHANDLER \ install msg handler
            " DEMO10" MAINWIN WSETNAME \ set frame window caption
            " APPICON" MAINWIN WLOADICON DROP \ set icon
            MAINWIN WCREATE 0= \ create the main window
            IF   " Can't create frame window!" ERRORBOX 0 RETURN
            THEN APPMENU MAINWIN WSETMENU FALSE = \ set frame window menu
            IF   " Can't create menu!" ERRORBOX 0 RETURN
            THEN \ set window size according to average character size
            WIDTH 19 * 3 * HEIGHT 21 * MAINWIN WSETSIZE 
            MAINWIN WSHOW \ display frame window
            WINMSGLOOP \ wait for WM_QUIT message
            MAINWIN WCLOSE
            QUIT ( 0 RETURN ) ; 

CR
CR .( To display the ANSI character set, type:  DEMO <Enter> )
CR

