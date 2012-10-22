\ DEMO37.4TH -- demonstration of listbox in a dialog
\ Copyright (C) 1992 LMI

WCB MAINWIN    \ window control block for frame window

\ arbitrary identifiers for menu items
100 CONSTANT IDM_FILEEXIT
101 CONSTANT IDM_FILEABOUT
102 CONSTANT IDM_EDITENTER

\ arbitrary identifier for demo dialog listbox
100 CONSTANT IDD_LISTBOX

\ misc buffers for use by demo dialog
CREATE LBBUF   256 ALLOT 

\ save last listbox selection here; -1 if never any selection
-1 EQU LBSEL

\ menu for the frame window
MENU APPMENU 
  " &File" POPUP 
          " E&xit"     IDM_FILEEXIT   MF_ENABLED   MENUITEM 
          " "          0              MF_SEPARATOR MENUITEM 
          " A&bout..." IDM_FILEABOUT  MF_ENABLED   MENUITEM 
          END-POPUP 
  " &Edit" POPUP
          " &Enter..." IDM_EDITENTER  MF_ENABLED   MENUITEM
          END-POPUP
END-MENU 


  " About DEMO37..."   
  16 16 128 70 DS_MODALFRAME WS_CAPTION D+ WS_POPUP D+
DIALOG  ABOUTDLG
  " FORTHICON"              12 16          -1        ICON
  " DEMO37.4TH"             32 8    96 12  -1        CTEXT
  " Sample WinForth App"    32 20   96 12  -1        CTEXT
  " (C) 1992 LMI"           32 32   96 12  -1        CTEXT
  " OK"                     44 50   40 16  IDOK      DEFPUSHBUTTON
END-DIALOG


" Demo Dialog..."   16 16   148 84
    DS_MODALFRAME WS_CAPTION D+ WS_POPUP D+  DIALOG  DEMODLG
                      8  8  132 54    IDD_LISTBOX  LISTBOX
        " OK"        38 64   32 16    IDOK         DEFPUSHBUTTON
        " Cancel"    78 64   32 16    IDCANCEL     PUSHBUTTON

END-DIALOG


\ --- n ; dialog message handler for "Demo Dialog..." dialog
\ returns TRUE if message was processed, FALSE otherwise
: DEMODLGPROC  wMsg WM_INITDIALOG =
            IF   IDD_LISTBOX 0 " Athens"      DSETLBTEXT
                 IDD_LISTBOX 1 " Bombay"      DSETLBTEXT
                 IDD_LISTBOX 2 " Cincinnati"  DSETLBTEXT
                 IDD_LISTBOX 3 " Dartmouth"   DSETLBTEXT
                 IDD_LISTBOX 4 " Frankfurt"   DSETLBTEXT
                 IDD_LISTBOX 5 " Helsinki"    DSETLBTEXT
                 IDD_LISTBOX 6 " Jakarta"     DSETLBTEXT
                 IDD_LISTBOX 7 " London"      DSETLBTEXT
                 IDD_LISTBOX 8 " Munich"      DSETLBTEXT
                 IDD_LISTBOX 9 " Prague"      DSETLBTEXT
                 LBSEL -1 <>  \ was there previous selection?
                 IF   IDD_LISTBOX LBSEL DSETLBSEL \ yes, highlight it
                 THEN TRUE EXIT
            THEN wMsg WM_COMMAND =
            IF   wParam IDOK =  \ OK button was clicked
                 IF   \ retrieve selection from listbox into LBBUF
                      IDD_LISTBOX DGETLBSEL  \ get index to selected string
                      DUP EQU LBSEL \ save it for next time
                      DUP 0> \ anything selected?
                      IF   IDD_LISTBOX SWAP DGETLBTEXT \ retrieve actual string
                           LBBUF STRCPY \ copy string to static storage
                      ELSE DROP
                      THEN
                      1 CLOSEDLG          \ if OK button, return 1
                 ELSE wParam IDCANCEL =   \ if CANCEL button, return 0
                      IF   0 CLOSEDLG   THEN   
                 THEN
            THEN FALSE ;

( --- flag ; this is the callback handler for the test dialog )
: ABOUTDLGPROC  wMsg WM_INITDIALOG =
                IF    TRUE EXIT
                THEN  wMsg WM_COMMAND =
                IF    wParam IDOK =
                      IF   0 CLOSEDLG THEN
                THEN  FALSE ;

\ msg --- ; send message to frame window
: MSG>MAINWIN  MAINWIN WCB>HWND SWAP 0 0. SendMessage 2DROP ;

\ ^str --- ; display error message and OK button in message box
: ERRORBOX  " DEMO37"  \ messagebox title
            [ MB_ICONHAND MB_OK OR ] LITERAL \ icon, button
            MSGBOX DROP ;

\ --- ; force repaint of entire window
: REPAINT  MAINWIN WREPAINT ;

\ --- ; process WM_PAINT message
: DOPAINT  " Helv" FF_MODERN 24 FS_ITALIC MAINWIN WSETFONT
           0 0 GOTOXY
           LBBUF C@
           IF    ." The selected city is:   "  LBBUF COUNT TYPE  CR
           ELSE  ." No data entered yet!"
           THEN  ;
 
\ --- ; this routine runs the demo listbox dialog.  It is called
\ by the window message processor in response to the Edit-Enter
\ menu command
: DODIALOG  DEMODLG ['] DEMODLGPROC RUNDLG
            IF   \ this code runs if OK button was clicked   
            ELSE \ this code runs if CANCEL button was clicked
            THEN ;

\ --- This routine handles WM_COMMAND messages from the frame window's menu.
: DOCOMMAND wParam 
   CASE
     \ if File-Exit, send Close message to our main window
     \ simulating user's pick of Close from System Menu
     IDM_FILEEXIT  OF WM_CLOSE MSG>MAINWIN   ENDOF
     \ if File-About, activate About... dialog
     IDM_FILEABOUT OF ABOUTDLG ['] ABOUTDLGPROC RUNDLG DROP ENDOF
     \ if Edit-Enter, activate demo listbox dialog
     IDM_EDITENTER OF DODIALOG  REPAINT  ENDOF
   ENDCASE ;

\ message handler for the frame window
: WNDPROC   wMsg CASE
            WM_PAINT OF    \ time to repaint window
                           DOPAINT  ENDOF
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
            " DEMO37" MAINWIN WSETNAME \ set frame window caption
            " APPICON" MAINWIN WLOADICON DROP \ set icon
            MAINWIN WCREATE 0= \ create main window
            IF   " Can't create frame window!" ERRORBOX 0 RETURN
            THEN APPMENU MAINWIN WSETMENU FALSE = \ set frame window menu
            IF   " Can't create menu!" ERRORBOX 0 RETURN
            THEN MAINWIN WSHOW \ display frame window
            LBBUF OFF   \ default = no string was ever selected
            WINMSGLOOP \ wait for WM_QUIT message
	    MAINWIN WCLOSE \ get rid of frame window
            QUIT ( 0 RETURN ) ; \ exit application


CR
CR .( WinForth dialog listbox demo application loaded.) 
CR .( To run the demo, type:  DEMO <Enter> ) 
CR .( Exit with Close on System Menu or File-Exit on menu bar.)
CR


