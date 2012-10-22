\ DEMO14.4TH -- Displays text sample, allows selection
\ of typeface, size, and style via common ChooseFont Dialog.
\ Copyright (C) 1992 LMI

WCB MAINWIN    \ window control block for frame window

CREATE FONTNAME    64 ALLOT  FONTNAME 64 ERASE
VARIABLE FONTSIZE
VARIABLE FONTSTYLE
VARIABLE FONTFAMILY

\ arbitrary identifiers for menu items
100 CONSTANT IDM_FILEEXIT
101 CONSTANT IDM_FILEABOUT
110 CONSTANT IDM_LONGFELLOW
111 CONSTANT IDM_SANDBURG
112 CONSTANT IDM_FROST
113 CONSTANT IDM_POE
120 CONSTANT IDM_CHOOSEFONT

CREATE FROST
,C" Whose woods these are I think I know."
,C" His house is in the village though;"
,C" He will not see me stopping here"
,C" To watch his woods fill up with snow."
,C"  "
,C" My little horse must think it queer"
,C" To stop without a farmhouse near"
,C" Between the woods and frozen lake"
,C" The darkest evening of the year."
,C"  "
,C" He gives his harness bells a shake"
,C" To ask if there is some mistake."
,C" The only other sound's the sweep"
,C" Of easy wind and downy flake."
,C"  "
,C" The woods are lovely, dark and deep,"
,C" But I have promises to keep,"
,C" And miles to go before I sleep,"
,C" And miles to go before I sleep."
,C"  "
,C"               Frost"

0 C, \ null byte marks end of text

CREATE POE
,C" Once upon a midnight dreary, while I pondered, weak and weary,"
,C" Over many a quaint and curious volume of forgotten lore,"
,C" While I nodded, nearly napping, suddenly there came a tapping,"
,C" As of someone gently rapping, rapping at my chamber door."
,C" 'Tis some visitor,' I muttered, 'tapping at my chamber door ---"
,C"    only this, and nothing more.'"
,C"  "
,C"                           Poe"

0 C, \ null byte marks end of text

CREATE SANDBURG
,C" The buffaloes are gone."
,C" And those who saw the buffaloes are gone."
,C" Those who saw the buffaloes by thousands and how they"
,C"   pawed the prairie sod into dust with their hoofs,"
,C"   their great heads down pawing on in a great pageant"
,C"   of dusk,"
,C" Those who saw the buffaloes are gone."
,C" And the buffaloes are gone."
,C"  "
,C"                  Sandburg"

0 C,  \ marks end of text

CREATE LONGFELLOW
,C" Tell me not, in mournful numbers,"
,C"   Life is but an empty dream! ---"
,C" For the soul is dead that slumbers,"
,C"   And things are not what they seem."
,C"  "
,C" Art is long, and Time is fleeting,"
,C"   And our hearts, though stout and brave,"
,C" Still, like muffled drums, are beating"
,C"   Funeral marches, to the grave."
,C"  "
,C" Lives of great men all remind us"
,C"   We can make our lives sublime,"
,C" And departing, leave behind us"
,C"   Footprints on the sands of time."
,C"  "
,C"                Longfellow"

0 C, \ null byte marks end of text

VARIABLE POEMPTR
VARIABLE POEMID

\ initialize poem pointer and poem ID
LONGFELLOW POEMPTR !
IDM_LONGFELLOW POEMID !
    
\ menu for the frame window
MENU APPMENU 
  " &File" POPUP 
          " E&xit"     IDM_FILEEXIT   MF_ENABLED   MENUITEM 
          " "          0              MF_SEPARATOR MENUITEM 
          " A&bout..." IDM_FILEABOUT  MF_ENABLED   MENUITEM 
          END-POPUP 
  " &Poet" POPUP 
          " Frost"      IDM_FROST MF_ENABLED MENUITEM
          " Longfellow" IDM_LONGFELLOW MF_ENABLED MF_CHECKED OR MENUITEM
          " Poe"        IDM_POE MF_ENABLED MENUITEM
          " Sandburg"   IDM_SANDBURG MF_ENABLED MENUITEM
          END-POPUP
  " &Choose Font!" IDM_CHOOSEFONT MF_ENABLED MENUITEM
END-MENU 

100 EQU ID_PUSHB  \ control ID for OK pushbutton in About Box

  " About DEMO14..."
  16 16 128 70 DS_MODALFRAME WS_CAPTION D+ WS_POPUP D+
DIALOG  ABOUTDLG
  " FORTHICON"              12 16          -1        ICON
  " DEMO14"                 32 8    96 12  -1        CTEXT
  " Sample WinForth App"    32 20   96 12  -1        CTEXT
  " (C) 1992 LMI"           32 32   96 12  -1        CTEXT
  " OK"                     44 50   40 16  ID_PUSHB  DEFPUSHBUTTON
END-DIALOG

\ ^str --- ; display error message and OK button in message box
: ERRORBOX  " DEMO14"  \ messagebox title
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

\ --- ; force repaint of main window
: REPAINT   MAINWIN WREPAINT ;

\ addr --- ; set address of poem to display
: SETPOEM   POEMPTR !  REPAINT
            POEMID @ MAINWIN MUNCHECK
            wParam DUP POEMID !  MAINWIN MCHECK ;

\ --- ;  handles WM_COMMAND messages from the frame window's menu.
: DOCOMMAND wParam CASE
            IDM_CHOOSEFONT OF FONTDLG 
                              IF   FONTSTYLE !  FONTSIZE !  FONTFAMILY !
                                   FONTNAME STRCPY  REPAINT
	                      THEN ENDOF
            IDM_FILEEXIT   OF WM_CLOSE MSG>MAINWIN   ENDOF
            IDM_FILEABOUT  OF ABOUTDLG         \ dialog structure
                              ['] ABOUTDLGPROC \ dialog handler
                              RUNDLG DROP            ENDOF
            IDM_FROST      OF FROST            SETPOEM         ENDOF
            IDM_SANDBURG   OF SANDBURG         SETPOEM         ENDOF
            IDM_POE        OF POE              SETPOEM         ENDOF
            IDM_LONGFELLOW OF LONGFELLOW       SETPOEM         ENDOF
            ( default case)  " Command not implemented" ERRORBOX
            ENDCASE ;

\ --- ; displays text sample in window using current font
: SHOWTEXT  CR  POEMPTR @
            BEGIN  DUP C@                    \ end of strings?
            WHILE  CR DUP COUNT TYPE         \ display a line
                   COUNT +                   \ move to next string
            REPEAT DROP ;

\ message handler for the frame window
: WNDPROC   wMsg CASE
            WM_PAINT OF    FONTNAME C@
                           IF   FONTNAME FONTFAMILY @ FONTSIZE @ FONTSTYLE @
                                MAINWIN WSETFONT  
                           THEN SHOWTEXT  ENDOF
            WM_SIZE OF     \ change in window size, force complete repaint
                           MAINWIN WCB>HWND 0. TRUE InvalidateRect
                           ENDOF
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
            MAINWIN WCREATE 0= 
            IF   " Can't create frame window!" ERRORBOX 0 RETURN
            THEN 
            " DEMO14" MAINWIN WSETNAME \ set frame window caption
            " APPICON" MAINWIN WLOADICON DROP \ set icon
            APPMENU MAINWIN WSETMENU FALSE = \ set frame window menu
            IF   " Can't create menu!" ERRORBOX 0 RETURN
            THEN 
            MAINWIN WGETSIZE  SWAP 350 MIN SWAP MAINWIN WSETSIZE
            MAINWIN WSHOW \ display frame window
            WINMSGLOOP \ wait for WM_QUIT message
	    MAINWIN WCLOSE
            QUIT ( 0 RETURN ) ; 

CR
CR .( To run the ChooseFont common dialog demo, type:  DEMO <Enter> )
CR


