\ DEMO13.4TH -- Sampler of standard windows screen fonts 
\ Copyright (C) 1991 LMI

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

  " About DEMO13..."   
  16 16 128 70 DS_MODALFRAME WS_CAPTION D+ WS_POPUP D+
DIALOG  ABOUTDLG
  " APPICON"               12 16          -1        ICON
  " DEMO13"                32 8    96 12  -1        CTEXT
  " Demo WinForth App"     32 20   96 12  -1        CTEXT
  " (C) 1991 LMI"          32 32   96 12  -1        CTEXT
  " OK"                    44 50   40 16  ID_PUSHB  DEFPUSHBUTTON
END-DIALOG


\ color tables for conversion from integers 0-7
CREATE COLORTABLE  RED , ,      GREEN , ,     BLUE , ,    BLACK , , 
                   CYAN , ,     MAGENTA , ,   YELLOW , ,  BLACK , , 

\ n --- colorref ; converts integer value to 32-bit colorref value
: N>COLOR    7 MOD 4 * COLORTABLE + 2@  ;

\ ^str --- ; display error message and OK button in message box
: ERRORBOX  " DEMO13"  \ messagebox title
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

: SHOWSIZE ( ^string --- ; display fontname, char height and width )
        CR  COUNT TYPE
        MAINWIN WGETCHARSIZE >R >R
        ." , width = "   R> .
        ."  height = "   R> . ;

: SHOWFONTS ( --- ; display font samples )  
        0 N>COLOR PEN
	\ System default proportional font sample
	" System" FF_DONTCARE 12 FS_NORMAL MAINWIN WSETFONT
	" System 12 point font" SHOWSIZE
        CR  ." MAINWIN = "   MAINWIN U.   ."   pWCB = "  pWCB U.
        \ show current font parameters
        CR ." X pixels/logical inch = " 
        hDC 88 GetDeviceCaps .
        ." ,  Y pixels/logical inch = " 
        hDC 90 GetDeviceCaps .
        hDC GetWindowExt SWAP
        CR ." X window extent = "     .
        ." ,  Y window extent = "     .
        hDC GetViewportExt SWAP
        ." ,  X viewport extent = "    .
        ." ,  Y viewport extent = "    .
        1 N>COLOR PEN
	\ Helvetica typeface samples
	" Helv" FF_SWISS 8 FS_NORMAL MAINWIN WSETFONT
	" Helvetica 8 point font" SHOWSIZE
	" Helv" FF_SWISS 10 FS_NORMAL MAINWIN WSETFONT
	" Helvetica 10 point font" SHOWSIZE
	" Helv" FF_SWISS 12 FS_NORMAL MAINWIN WSETFONT
	" Helvetica 12 point font normal" SHOWSIZE
	" Helv" FF_SWISS 12 FS_BOLD MAINWIN WSETFONT
	" Helvetica 12 point font bold" SHOWSIZE
	" Helv" FF_SWISS 12 FS_ITALIC MAINWIN WSETFONT
	" Helvetica 12 point font italic" SHOWSIZE
	" Helv" FF_SWISS 12 FS_UNDERLINE MAINWIN WSETFONT
	" Helvetica 12 point font underline" SHOWSIZE
	" Helv" FF_SWISS 12 FS_STRIKEOUT MAINWIN WSETFONT
	" Helvetica 12 point font strikeout" SHOWSIZE
	" Helv" FF_SWISS 14 FS_NORMAL MAINWIN WSETFONT
	" Helvetica 14 point font" SHOWSIZE
	" Helv" FF_SWISS 18 FS_NORMAL MAINWIN WSETFONT
	" Helvetica 20 point font" SHOWSIZE
        2 N>COLOR PEN
	\ Times Roman typeface samples
	" Tms Rmn" FF_ROMAN 8 FS_NORMAL MAINWIN WSETFONT
	" Times Roman 8 point font" SHOWSIZE
	" Tms Rmn" FF_ROMAN 10 FS_NORMAL MAINWIN WSETFONT
	" Times Roman 10 point font" SHOWSIZE
	" Tms Rmn" FF_ROMAN 12 FS_NORMAL MAINWIN WSETFONT
	" Times Roman 12 point font" SHOWSIZE
	" Tms Rmn" FF_ROMAN 14 FS_NORMAL MAINWIN WSETFONT
	" Times Roman 14 point font" SHOWSIZE
	" Tms Rmn" FF_ROMAN 20 FS_NORMAL MAINWIN WSETFONT
	" Times Roman 20 point font" SHOWSIZE
        3 N>COLOR PEN
	\ Symbol samples
	" Symbol" FF_DECORATIVE 8 FS_NORMAL MAINWIN WSETFONT
	" Symbol 8 point font" SHOWSIZE
	" Symbol" FF_DECORATIVE 10 FS_NORMAL MAINWIN WSETFONT
	" Symbol 10 point font" SHOWSIZE
	" Symbol" FF_DECORATIVE 12 FS_NORMAL MAINWIN WSETFONT
	" Symbol 12 point font" SHOWSIZE
	" Symbol" FF_DECORATIVE 14 FS_NORMAL MAINWIN WSETFONT
	" Symbol 14 point font" SHOWSIZE
	" Symbol" FF_DECORATIVE 20 FS_NORMAL MAINWIN WSETFONT
	" Symbol 20 point font" SHOWSIZE
        4 N>COLOR PEN
        \ Script sample
        " Script" FF_SCRIPT 24 FS_NORMAL MAINWIN WSETFONT
	" Script 24 point font" SHOWSIZE
        5 N>COLOR PEN
	\ Courier samples
	" Courier" FF_MODERN 8 FS_NORMAL MAINWIN WSETFONT
	" Courier 8 point font" SHOWSIZE
	" Courier" FF_MODERN 10 FS_NORMAL MAINWIN WSETFONT
	" Courier 10 point font" SHOWSIZE
	" Courier" FF_MODERN 12 FS_NORMAL MAINWIN WSETFONT
	" Courier 12 point font" SHOWSIZE
	" Courier" FF_MODERN 14 FS_NORMAL MAINWIN WSETFONT
	" Courier 14 point font" SHOWSIZE
	" Courier" FF_MODERN 20 FS_NORMAL MAINWIN WSETFONT
	" Courier 20 point font" SHOWSIZE ;

\ message handler for the frame window
: WNDPROC   wMsg CASE
            WM_PAINT OF    SHOWFONTS  ENDOF
            WM_SIZE OF     \ change in window size, force complete repaint
                           MAINWIN WREPAINT ENDOF
            WM_COMMAND OF  \ menu command message
                           DOCOMMAND ENDOF
            WM_DESTROY OF  0 PostQuitMessage \ kill message loop
                           ENDOF
            \ default case: pass message to DefWindowProc()
            DEFMSGHANDLER EXIT 
            ENDCASE 0 0 ; \ double value to return from message handler

\ "main word" of sample TestType application;
\ creates the frame window and then enters message loop
: DEMO      ['] WNDPROC MAINWIN SETMSGHANDLER \ install msg handler
            " DEMO13" MAINWIN WSETNAME \ set frame window caption
            " APPICON" MAINWIN WLOADICON DROP \ set icon
            MAINWIN WCREATE 0= 
            IF   " Can't create frame window!" ERRORBOX 0 RETURN
            THEN APPMENU MAINWIN WSETMENU FALSE = \ set frame window menu
            IF   " Can't create menu!" ERRORBOX 0 RETURN
            THEN MAINWIN WSHOW \ display frame window
            WINMSGLOOP \ wait for WM_QUIT message
	    MAINWIN WCLOSE
            QUIT ( 0 RETURN ) ; 

CR
CR .( To run the fonts demo, type:  DEMO <Enter> )
CR

