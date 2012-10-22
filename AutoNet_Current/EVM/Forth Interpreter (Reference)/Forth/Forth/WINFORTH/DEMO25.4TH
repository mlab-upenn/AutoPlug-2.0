\ DEMO25.4TH -- Demo of mouse tracking, bit blitting
\ Adapted from the BLOWUP program in Petzold 2nd Edition.
\ Copyright (C) 1991 LMI

WCB MAINWIN    \ window control block for frame window

HEX 

\ magic constants for PatBlt and StretchBlt
00CC0020. SWAP 2CONSTANT SRCCOPY
00550009. SWAP 2CONSTANT DSTINVERT

DECIMAL

\ arbitrary identifiers for menu items
100 CONSTANT IDM_FILEEXIT
101 CONSTANT IDM_FILEABOUT
102 CONSTANT IDM_EDITCAPTURE

0 EQU fCAPTURING  \ true if mouse has been captured
0 EQU fBLOCKING   \ true if outlining a pixel block

2VARIABLE ptBEGIN
2VARIABLE ptEND
CREATE RECT WSIZE 4 * ALLOT
0 EQU hDCTemp

\ menu for the frame window
MENU APPMENU 
  " &File" POPUP 
          " E&xit"     IDM_FILEEXIT   MF_ENABLED   MENUITEM 
          " "          0              MF_SEPARATOR MENUITEM 
          " A&bout..." IDM_FILEABOUT  MF_ENABLED   MENUITEM 
          END-POPUP 
  " &Edit" POPUP 
          " &Capture"  IDM_EDITCAPTURE MF_ENABLED   MENUITEM 
          END-POPUP 
END-MENU 

100 EQU ID_PUSHB  \ control ID for OK pushbutton in About Box

  " About DEMO25..."   
  16 16 128 70 DS_MODALFRAME WS_CAPTION D+ WS_POPUP D+
DIALOG  ABOUTDLG
  " FORTHICON"                 12 16          -1        ICON
  " DEMO25"                    32 8    96 12  -1       CTEXT
  " Sample WinForth App"       32 20   96 12  -1        CTEXT
  " (C) 1991 LMI"              32 32   96 12  -1        CTEXT
  " OK"                        44 50   40 16  ID_PUSHB  DEFPUSHBUTTON
END-DIALOG

\ ^str --- ; display error message and OK button in message box
: ERRORBOX  " DEMO25"  \ messagebox title
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
            IDM_EDITCAPTURE OF TRUE EQU fCAPTURING
                              hWnd SetCapture DROP
                              IDC_CROSS WLOADCURSOR DROP
                              ENDOF
            " Command not implemented" ERRORBOX
            ENDCASE ;

\ ---
: INVERTBLOCK  DS0 " DISPLAY" ASCIIZ 0. 0. 0. CreateDC EQU hDCTemp
	    ptBEGIN D@  ptEND D@ 
            hWnd DS0 ptBEGIN  ClientToScreen 
            hWnd DS0 ptEND  ClientToScreen 
            hDCTemp ptBEGIN D@ 
	    ptEND @  ptBEGIN @ -
	    ptEND 2+ @  ptBEGIN 2+ @ -
	    DSTINVERT PatBlt DROP
            hDCTemp DeleteDC DROP 
            ptEND D!  ptBEGIN D! ;

\ message handler for the frame window
: WNDPROC   wMsg CASE
            WM_LBUTTONDOWN OF fCAPTURING TRUE =  fBLOCKING FALSE = AND
                           IF    TRUE EQU fBLOCKING
                                 lParam ptBEGIN D!
                           THEN  ENDOF
            WM_LBUTTONUP OF fBLOCKING TRUE =
                           IF   FALSE EQU fBLOCKING
                                FALSE EQU fCAPTURING
                                lParam ptEND D!
                                IDC_WAIT WLOADCURSOR DROP
                                hWnd GetDC EQU hDCTemp
                                hWnd DS0 RECT GetClientRect 
                                hDCTemp 0 0 RECT 4 + D@
                                hDCTemp ptBEGIN D@         \ xul yul
				ptEND @  ptBEGIN @ -       \ xwidth 
	    			ptEND 2+ @  ptBEGIN 2+ @ - \ ywidth
                                SRCCOPY StretchBlt DROP
                                hDCTemp ReleaseDC DROP
                                IDC_ARROW WLOADCURSOR DROP
                                ReleaseCapture 
                           THEN ENDOF
            WM_MOUSEMOVE OF fBLOCKING TRUE = 
                           IF   lParam ptEND D!
                                INVERTBLOCK INVERTBLOCK
                           THEN ENDOF
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
            MAINWIN WCREATE 0= 
            IF   " Can't create frame window!" ERRORBOX 0 RETURN
            THEN  " DEMO25" MAINWIN WSETNAME \ set frame window caption
            " APPICON" MAINWIN WLOADICON DROP \ set icon
            APPMENU MAINWIN WSETMENU FALSE = \ set frame window menu
            IF   " Can't create menu!" ERRORBOX 0 RETURN
            THEN 200 200 MAINWIN WSETSIZE \ set window size
            MAINWIN WSHOW \ display frame window
            MAINWIN WSETFOCUS
            WINMSGLOOP \ wait for WM_QUIT message
	    MAINWIN WCLOSE
            QUIT ( 0 RETURN ) ; \ exit to Windows

CR
CR .( To run the "Blowup" demo, type:  DEMO <Enter> )
CR .( Then select "Capture" from the EDIT menu.  The cursor )
CR .( changes to a cross-hair.  Click and drag to outline a )
CR .( box anywhere on the screen.  The selected chunk of the )
CR .( screen will be bit-blitted into the DEMO window.)
CR

