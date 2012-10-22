\ DEMO22.4TH -- Illustrates use of WinForth graphics 
\ functions in a window message handler.  Draws 100
\ random circles in the window with random colors and
\ pen widths and styles.
\ Copyright (C) 1992 LMI

WCB MAINWIN    \ window control block for frame window

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

  " About DEMO22..."   
  16 16 128 70 DS_MODALFRAME WS_CAPTION D+ WS_POPUP D+
DIALOG  ABOUTDLG
  " FORTHICON"              12 16          -1        ICON
  " DEMO22"                 32 8    96 12  -1        CTEXT
  " Sample WinForth App"    32 20   96 12  -1        CTEXT
  " (C) 1992 LMI"           32 32   96 12  -1        CTEXT
  " OK"                     44 50   40 16  ID_PUSHB  DEFPUSHBUTTON
END-DIALOG

VARIABLE SEED

: (RAND) SEED @ 259 * 3 + 32767 AND DUP SEED ! ;
: RANDOM    ( n1 -- n2 )  (RAND) 32767 */ ;
: RXY ( --- x y ) XMAX 1+ RANDOM  YMAX 1+ RANDOM ;

\ --- colorref ; return random nonzero colorref
: RCOLOR   255 RANDOM  255 RANDOM  255 RANDOM  RGB  ;

( --- flag ; this is the callback handler for the test dialog )
: ABOUTDLGPROC  wMsg WM_INITDIALOG =
                IF    TRUE EXIT
                THEN  wMsg WM_COMMAND =
                IF    wParam ID_PUSHB =
                      IF   0 CLOSEDLG THEN
                THEN  FALSE ;

\ msg --- ; send message to frame window
: MSG>MAINWIN  MAINWIN WCB>HWND SWAP 0 0. SendMessage 2DROP ;

\ ^str --- ; display error message and OK button in message box
: ERRORBOX  " TestCircles"  \ messagebox title
            [ MB_ICONHAND MB_OK OR ] LITERAL \ icon, button
            MSGBOX DROP ;

\ --- ; paint 100 random circles
: CIRCLES  100 0
    DO  RCOLOR PEN  I 1 AND
        IF   SOLID PENSTYLE  10 RANDOM PENWIDTH
        ELSE DASHDOTDOT 1+  RANDOM PENSTYLE  1 PENWIDTH
        THEN RXY RXY CIRCLE
    LOOP SOLID PENSTYLE 1 PENWIDTH ;

\ --- This routine handles WM_COMMAND messages from the frame window's menu.
: DOCOMMAND wParam CASE
            IDM_FILEEXIT   OF WM_CLOSE MSG>MAINWIN   ENDOF
            IDM_FILEABOUT  OF ABOUTDLG         \ dialog structure
                              ['] ABOUTDLGPROC \ dialog handler
                              RUNDLG DROP            ENDOF
            ENDCASE ;

\ --- ; force repaint of entire window
: REPAINT  MAINWIN WREPAINT ;

\ message handler for the frame window
: WNDPROC   wMsg CASE
            WM_PAINT OF    \ paint message, generate some new circles
	    		   CIRCLES   ENDOF
            WM_SIZE OF     \ change in window size, force complete repaint
                           REPAINT ENDOF
            WM_COMMAND OF  \ menu command message
                           DOCOMMAND ENDOF
            WM_DESTROY OF  \ kill message loop
                           0 PostQuitMessage ENDOF
            \ default case: pass message to DefWindowProc()
            DEFMSGHANDLER EXIT
            ENDCASE 0 0 ; \ double value to return from message handler

\ "main word" of sample application;
\ creates the frame window and then enters message loop
: DEMO      ['] WNDPROC MAINWIN SETMSGHANDLER \ install msg handler
            " DEMO22" MAINWIN WSETNAME \ set frame window caption
            " FORTHICON" MAINWIN WLOADICON DROP \ set icon
            MAINWIN WCREATE 0= \ create main window
            IF   " Can't create frame window!" ERRORBOX 0 RETURN
            THEN APPMENU MAINWIN WSETMENU FALSE = \ set frame window menu
            IF   " Can't create menu!" ERRORBOX 0 RETURN
            THEN MAINWIN WSHOW \ display frame window
            WINMSGLOOP \ wait for WM_QUIT message
	    MAINWIN WCLOSE \ get rid of frame window
            QUIT ( 0 RETURN ) ; \ exit application

CR
CR .( To run the random circles demo, type:  DEMO <Enter> ) 
CR 

