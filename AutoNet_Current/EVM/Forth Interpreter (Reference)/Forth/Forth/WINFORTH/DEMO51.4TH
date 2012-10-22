\ DEMO51.4TH -- WinForth application simple drag-and-drop target
\ Copyright (C) 1993 LMI

WCB MAINWIN    \ window control block for frame window

\ arbitrary identifiers for menu items
100 CONSTANT IDM_FILEEXIT
101 CONSTANT IDM_FILEABOUT

CREATE LASTFILE 256 ALLOT   \ allocate memory to hold
       LASTFILE 256 ERASE   \ name of dropped file

\ menu for the frame window
MENU APPMENU 
  " &File" POPUP 
          " E&xit"     IDM_FILEEXIT   MF_ENABLED   MENUITEM 
          " "          0              MF_SEPARATOR MENUITEM 
          " A&bout..." IDM_FILEABOUT  MF_ENABLED   MENUITEM 
          END-POPUP 
END-MENU 

100 EQU ID_PUSHB  \ control ID for OK pushbutton in About Box

  " About DEMO51..."   
  16 16 128 70 DS_MODALFRAME WS_CAPTION D+ WS_POPUP D+
DIALOG  ABOUTDLG
  " FORTHICON"              12 16          -1        ICON
  " DEMO51.4TH"             32 8    96 12  -1        CTEXT
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
: ERRORBOX  " DEMO51"  \ messagebox title
            [ MB_ICONHAND MB_OK OR ] LITERAL \ icon, button
            MSGBOX DROP ;

\ --- ; force repaint of entire window
: REPAINT  MAINWIN WREPAINT ;

\ --- ; process WM_PAINT message
: DOPAINT " Helv" FF_MODERN 18 FS_NORMAL MAINWIN WSETFONT
	  0 0 GOTOXY ." Drag and Drop to This Window!"
          CR ." Last file dropped: "  
          LASTFILE -ASCIIZ COUNT TYPE ;
 
\ --- This routine handles WM_COMMAND messages from the frame window's menu.
: DOCOMMAND wParam 
   CASE
     \ if File-Exit, send Close message to our main window
     \ simulating user's pick of Close from System Menu
     IDM_FILEEXIT  OF WM_CLOSE MSG>MAINWIN   ENDOF
     \ if File-About, activate About... dialog
     IDM_FILEABOUT OF ABOUTDLG ['] ABOUTDLGPROC RUNDLG DROP ENDOF
   ENDCASE ;

\ --- ; process WM_CREATE message
: DOCREATE  hWnd TRUE DragAcceptFiles ;

\ --- ; process WM_DESTROY message
: DODESTROY 
     hWnd FALSE DragAcceptFiles  \ disable drop target
     0 PostQuitMessage ;         \ send WM_QUIT message

\ --- ; process WM_DROPFILES message by retrieving name of
\ first dropped file, then forcing window repaint to display name
: DODROPFILES wParam 0 DS0 LASTFILE 256 DragQueryFile DROP 
            wParam DragFinish  REPAINT ;

\ message handler for the frame window
: WNDPROC   wMsg CASE
            WM_PAINT OF    \ paint message, write text in window
                           DOPAINT ENDOF
            WM_SIZE OF     \ change in window size, force complete repaint
                           REPAINT ENDOF
            WM_COMMAND OF  \ menu command message
                           DOCOMMAND ENDOF
            WM_CREATE OF   \ frame window is being created
                           DOCREATE ENDOF
            WM_DROPFILES OF \ file being dropped on window
                           DODROPFILES ENDOF
            WM_DESTROY OF  \ kill message loop
                           DODESTROY  ENDOF
            \ default case: pass message to DefWindowProc()
            DEFMSGHANDLER EXIT
            ENDCASE 0 0 ; \ double value to return from message handler

\ "main word" of sample application;
\ creates the frame window and then enters message loop
: DEMO      " <None>" DUP ASCIIZ LASTFILE ROT C@ 1+ CMOVE \ init filename
            ['] WNDPROC MAINWIN SETMSGHANDLER \ install msg handler
            " DEMO51" MAINWIN WSETNAME \ set frame window caption
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
CR .( WinForth drag-and-drop demo application loaded.) 
CR .( To run the demo, type:  DEMO <Enter> ) CR
CR .( Drag and drop a file from the File Manager to the demo )
CR .( program's window to see the dropped file's name appear.)
CR .( If multiple files are dropped together, only the first )
CR .( file's name is displayed.  ) CR
CR .( Exit with Close on System Menu or File-Exit on menu bar.)
CR


