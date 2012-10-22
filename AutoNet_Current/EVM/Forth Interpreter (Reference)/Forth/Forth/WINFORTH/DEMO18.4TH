\ DEMO18.4TH -- Simple demonstration of printing
\ Copyright (C) 1993 LMI

WCB MAINWIN    \ window control block for frame window

\ magic numbers from WINDOWS.H
INCLUDE DEVCAPS.4TH

\ arbitrary identifiers for menu items
100 CONSTANT IDM_FILEPRINT
101 CONSTANT IDM_FILEEXIT
102 CONSTANT IDM_FILEABOUT

0 EQU PDC      \ DC for printing
0 EQU CHARY    \ character height, printer font
0 EQU CHARX    \ average character width, printer font
0 EQU PAGEY    \ total page height
0 EQU HORZMARG \ width of each side margin
0 EQU VERTMARG \ height of top & bottom margins

\ Data structure used by various Windows 3.1 printing APIs
CREATE DOCINFO 10 ,  0 , 0 , 0 , 0 ,

\ TEXTMETRICS structure for printer
TM PTM

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

  " About DEMO18..."   
  16 16 128 70 DS_MODALFRAME WS_CAPTION D+ WS_POPUP D+
DIALOG  ABOUTDLG
  " FORTHICON"              12 16          -1        ICON
  " DEMO18.4TH"             32 8    96 12  -1        CTEXT
  " Sample WinForth App"    32 20   96 12  -1        CTEXT
  " (C) 1993 LMI"           32 32   96 12  -1        CTEXT
  " OK"                     44 50   40 16  ID_PUSHB  DEFPUSHBUTTON
END-DIALOG

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
: ERRORBOX  " DEMO18"  \ messagebox title
            [ MB_ICONHAND MB_OK OR ] LITERAL \ icon, button
            MSGBOX DROP ;

\ --- ; force repaint of entire window
: REPAINT  MAINWIN WREPAINT ;

\ --- ; process WM_PAINT message
: DOPAINT " Helv" FF_MODERN 36 FS_ITALIC MAINWIN WSETFONT
	  0 0 GOTOXY ." Select File-Print for demo!" ;
 
\ --- ; process File-Print command
: DOPRINT   PRINTDLG \ show print dialog to user
            IF   2DROP ( discard flags ) EQU PDC ( save printer DC) 
                 3DROP ( discard page numbers etc. )
                 \ print job name into DOCINFO structure
                 " Print Test"  ASCIIZ DOCINFO 2+ !  DS0 DOCINFO 4 + !
                 \ get character size for current printer font
                 PDC DS0 PTM GetTextMetrics DROP
                 PTM 10 + @   EQU CHARX    \ average char width
                 PTM @   PTM 8 +  @ +  EQU CHARY  \ height + leading
                 PDC VERTRES     GetDeviceCaps  EQU PAGEY
                 PDC LOGPIXELSX  GetDeviceCaps  2/  EQU HORZMARG
                 PDC LOGPIXELSY  GetDeviceCaps  2/  EQU VERTMARG
                 \ start print job, start first page
                 PDC DS0 DOCINFO StartDoc DROP   PDC StartPage DROP
                 \ send the test line to the printer
                 PDC ( printer DC )  HORZMARG VERTMARG ( x, y)
                 DS0 " This is some test text for the printer." COUNT
                 TextOut DROP
                 \ clean up everything
                 PDC EndPage DROP  PDC EndDoc DROP
                 PDC DeleteDC \ discard printer DC
            THEN ;

\ --- This routine handles WM_COMMAND messages from the frame window's menu.
: DOCOMMAND wParam 
   CASE
     \ if File-Print, put some text on the printer and eject page
     IDM_FILEPRINT OF  DOPRINT  ENDOF
     \ if File-Exit, send Close message to our main window
     \ simulating user's pick of Close from System Menu
     IDM_FILEEXIT  OF WM_CLOSE MSG>MAINWIN   ENDOF
     \ if File-About, activate About... dialog
     IDM_FILEABOUT OF ABOUTDLG ['] ABOUTDLGPROC RUNDLG DROP ENDOF
   ENDCASE ;

\ message handler for the frame window
: WNDPROC   wMsg CASE
            WM_PAINT OF    \ paint message, write text in window
                           DOPAINT ENDOF
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
            " DEMO18" MAINWIN WSETNAME \ set frame window caption
            " APPICON" MAINWIN WLOADICON DROP \ set icon
            MAINWIN WCREATE 0= \ create main window
            IF   " Can't create frame window!" ERRORBOX 0 RETURN
            THEN APPMENU MAINWIN WSETMENU FALSE = \ set frame window menu
            IF   " Can't create menu!" ERRORBOX 0 RETURN
            THEN MAINWIN WSHOW \ display frame window
            WINMSGLOOP \ wait for WM_QUIT message
	    MAINWIN WCLOSE \ get rid of frame window
            QUIT ( 0 RETURN ) ; \ exit application

CR
CR .( WinForth printing demo application loaded.) 
CR .( To run the demo, type:  DEMO <Enter> ) 
CR .( Exit with Close on System Menu or File-Exit on menu bar.)
CR


