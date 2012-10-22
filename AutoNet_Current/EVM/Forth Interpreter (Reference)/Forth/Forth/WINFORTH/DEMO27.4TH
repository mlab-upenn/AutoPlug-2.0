\ DEMO27.4TH -- Illustrates use of GDI drawing
\ functions with the printer.
\ Copyright (C) 1993 LMI

\ magic numbers from WINDOWS.H
INCLUDE DEVCAPS.4TH

WCB MAINWIN    \ window control block for frame window

\ arbitrary identifiers for menu items
100 CONSTANT IDM_FILEPRINT
101 CONSTANT IDM_FILEEXIT
102 CONSTANT IDM_FILEABOUT

0 EQU PDC      \ DC for printing
0 EQU CHARY    \ character height, printer font
0 EQU CHARX    \ average character width, printer font
0 EQU PAGEY    \ total page height
0 EQU PAGEX    \ total page width
0 EQU HORZMARG \ width of each side margin
0 EQU VERTMARG \ height of top & bottom margins

\ Data structure used by various Windows 3.1 printing APIs
CREATE DOCINFO 10 ,  0 , 0 , 0 , 0 ,

\ menu for the frame window
MENU APPMENU 
  " &File" POPUP 
          " &Print"    IDM_FILEPRINT  MF_ENABLED   MENUITEM
          " E&xit"     IDM_FILEEXIT   MF_ENABLED   MENUITEM 
          " "          0              MF_SEPARATOR MENUITEM 
          " A&bout..." IDM_FILEABOUT  MF_ENABLED   MENUITEM 
          END-POPUP 
END-MENU 

100 EQU ID_PUSHB  \ control ID for OK pushbutton in About Box

  " About DEMO27..."   
  16 16 128 70 DS_MODALFRAME WS_CAPTION D+ WS_POPUP D+
DIALOG  ABOUTDLG
  " APPICON"                12 16          -1        ICON
  " DEMO27"                 32 8    96 12  -1        CTEXT
  " Sample WinForth App"    32 20   96 12  -1        CTEXT
  " (C) 1993 LMI"           32 32   96 12  -1        CTEXT
  " OK"                     44 50   40 16  ID_PUSHB  DEFPUSHBUTTON
END-DIALOG

\ ^str --- ; display error message and OK button in message box
: ERRORBOX  " DEMO27"     \ messagebox title
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

\ --- ; process WM_PAINT message for frame window
: DOPAINT   YMAX 0 
            DO  hDC 0 0 MoveTo 2DROP
                hDC XMAX I LineTo DROP
            10 +LOOP
            XMAX 0 
            DO  hDC 0 0 MoveTo 2DROP
                hDC I YMAX LineTo DROP
            10 +LOOP
            hDC 32 32 XMAX 32 - YMAX 32 - Ellipse DROP ;

\ --- ; process File-Print command
: DOPRINT   PRINTDLG \ show print dialog to user
            IF   2DROP ( discard flags ) EQU PDC ( save printer DC) 
                 3DROP ( discard page numbers etc. )
                 \ print job name into DOCINFO structure
                 " Print Test"  ASCIIZ DOCINFO 2+ !  DS0 DOCINFO 4 + !
                 PDC VERTRES     GetDeviceCaps  EQU PAGEY
                 PDC HORZRES     GetDeviceCaps  EQU PAGEX
                 PDC LOGPIXELSX  GetDeviceCaps  2/  EQU HORZMARG
                 PDC LOGPIXELSY  GetDeviceCaps  2/  EQU VERTMARG  
                 \ start print job, start first page
                 PDC DS0 DOCINFO StartDoc DROP   PDC StartPage DROP

                 \ Draw pattern of lines from upper left corner
                 PAGEY VERTMARG -  VERTMARG 
                 DO  PDC  HORZMARG VERTMARG    MoveTo  2DROP
                     PDC  PAGEX HORZMARG -  I  LineTo  DROP
                 10 +LOOP
                 PAGEX HORZMARG -  HORZMARG 
                 DO  PDC HORZMARG VERTMARG     MoveTo  2DROP
                     PDC I PAGEY VERTMARG -    LineTo  DROP
                 10 +LOOP
              
                 \ draw an ellipse on the page
                 PDC HORZMARG 2* VERTMARG 2*   
                    PAGEX 2 PICK -  PAGEY 2 PICK - Ellipse DROP 

                 \ clean up everything
                 PDC EndPage DROP  PDC EndDoc DROP
                 PDC DeleteDC \ discard printer DC
            THEN ;

\ --- This routine handles WM_COMMAND messages from the frame window's menu.
: DOCOMMAND wParam CASE
            IDM_FILEPRINT  OF DOPRINT  ENDOF
            IDM_FILEEXIT   OF WM_CLOSE MSG>MAINWIN   ENDOF
            IDM_FILEABOUT  OF ABOUTDLG         \ dialog structure
                              ['] ABOUTDLGPROC \ dialog handler
                              RUNDLG DROP            ENDOF
            " Command not implemented" ERRORBOX 
            ENDCASE ;

\ message handler for the frame window
: WNDPROC   wMsg CASE
            WM_PAINT OF  DOPAINT  ENDOF
            WM_SIZE OF     \ change in window size, force complete repaint
                           MAINWIN WREPAINT ENDOF
            WM_COMMAND OF  \ menu command message
                           DOCOMMAND ENDOF
            WM_DESTROY OF  0 PostQuitMessage \ kill message loop
                           ENDOF
            \ default case: pass message to DefWindowProc()
            DEFMSGHANDLER EXIT 
            ENDCASE 0 0 ; \ double value to return from message handler

\ "main word" of sample TESTPAINT application;
\ creates the frame window and then enters message loop
: DEMO      ['] WNDPROC MAINWIN SETMSGHANDLER \ install msg handler
            " DEMO27" MAINWIN WSETNAME \ set frame window caption
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
CR .( To run the demo, type:  DEMO <Enter> )
CR .( Paints a pattern in the window. Sends the same pattern to )
CR .( the printer when you select Print from the File menu.)
CR

