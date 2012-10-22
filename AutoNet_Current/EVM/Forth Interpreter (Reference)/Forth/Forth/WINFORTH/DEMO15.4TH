\ DEMO15.4TH -- Displays text sample, allows selection
\ of typeface, size, and style from menu bar.
\ Copyright (C) 1991 LMI

WCB MAINWIN    \ window control block for frame window

\ arbitrary identifiers for menu items
100 CONSTANT IDM_FILEEXIT
101 CONSTANT IDM_FILEABOUT

110 CONSTANT IDM_SYSTEM
111 CONSTANT IDM_ARIAL
112 CONSTANT IDM_HELV
113 CONSTANT IDM_TMSRMN
114 CONSTANT IDM_TMSNEW
115 CONSTANT IDM_COURIER
116 CONSTANT IDM_COURNEW
117 CONSTANT IDM_SCRIPT
118 CONSTANT IDM_SYMBOL

140 CONSTANT IDM_BOLD 
141 CONSTANT IDM_ITALIC
142 CONSTANT IDM_UNDER
143 CONSTANT IDM_STRIKE

150 CONSTANT IDM_LONGFELLOW
151 CONSTANT IDM_SANDBURG
152 CONSTANT IDM_FROST
153 CONSTANT IDM_POE

200 CONSTANT IDM_POINTS
208 CONSTANT IDM_P08
210 CONSTANT IDM_P10
212 CONSTANT IDM_P12
214 CONSTANT IDM_P14
216 CONSTANT IDM_P16
218 CONSTANT IDM_P18
220 CONSTANT IDM_P20
224 CONSTANT IDM_P24
230 CONSTANT IDM_P30
236 CONSTANT IDM_P36
248 CONSTANT IDM_P48

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

CREATE TYPEFACE  32 ALLOT  \ storage for fontname
VARIABLE TYPEID
VARIABLE FAMILY
VARIABLE POINTS
VARIABLE STYLE
VARIABLE POEMPTR
VARIABLE POEMID

\ initialize font as default system nonproportional font
" System" TYPEFACE STRCPY
IDM_SYSTEM TYPEID !
12 POINTS !
FF_DONTCARE FAMILY !
0 STYLE !
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
  " &Typeface" POPUP
          " System"       IDM_SYSTEM  MF_ENABLED MF_CHECKED OR MENUITEM
          " Arial"        IDM_ARIAL   MF_ENABLED MENUITEM
          " Helvetica"    IDM_HELV    MF_ENABLED MENUITEM
          " Times Roman"  IDM_TMSRMN  MF_ENABLED MENUITEM
          " Times New Roman" IDM_TMSNEW MF_ENABLED MENUITEM
          " Courier"      IDM_COURIER MF_ENABLED MENUITEM
          " Courier New"  IDM_COURNEW MF_ENABLED MENUITEM
          " Script"       IDM_SCRIPT  MF_ENABLED MENUITEM
          " Symbol"       IDM_SYMBOL  MF_ENABLED MENUITEM
          END-POPUP
  " &Size" POPUP
          " 8"   IDM_P08  MF_ENABLED MENUITEM
          " 10"  IDM_P10  MF_ENABLED MENUITEM
          " 12"  IDM_P12  MF_ENABLED MF_CHECKED OR MENUITEM
          " 14"  IDM_P14  MF_ENABLED MENUITEM
          " 16"  IDM_P16  MF_ENABLED MENUITEM
          " 18"  IDM_P18  MF_ENABLED MENUITEM 
          " 20"  IDM_P20  MF_ENABLED MENUITEM
          " 24"  IDM_P24  MF_ENABLED MENUITEM
          " 30"  IDM_P30  MF_ENABLED MENUITEM
          " 36"  IDM_P36  MF_ENABLED MENUITEM
          " 48"  IDM_P48  MF_ENABLED MENUITEM
          END-POPUP
  " &Attributes" POPUP
          " Bold"         IDM_BOLD    MF_ENABLED MENUITEM
          " Italic"       IDM_ITALIC  MF_ENABLED MENUITEM
          " Underline"    IDM_UNDER   MF_ENABLED MENUITEM
          " Strikethrough" IDM_STRIKE MF_ENABLED MENUITEM
          END-POPUP 
END-MENU 

100 EQU ID_PUSHB  \ control ID for OK pushbutton in About Box

  " About DEMO15..."   
  16 16 128 70 DS_MODALFRAME WS_CAPTION D+ WS_POPUP D+
DIALOG  ABOUTDLG
  " APPICON"              12 16          -1        ICON
  " DEMO15"               32 8    96 12  -1        CTEXT
  " Sample WinForth App"  32 20   96 12  -1        CTEXT
  " (C) 1992 LMI"         32 32   96 12  -1        CTEXT
  " OK"                   44 50   40 16  ID_PUSHB  DEFPUSHBUTTON
END-DIALOG

\ ^str --- ; display error message and OK button in message box
: ERRORBOX  " DEMO15"  \ messagebox title
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

\ ^typeface family --- ; set family, typeface name, then repaint window
: SETFACE   TYPEID @ MAINWIN MUNCHECK
            wParam  DUP TYPEID !  MAINWIN MCHECK
            FAMILY !  TYPEFACE STRCPY   REPAINT ;

\ --- ; set pointsize, update menu, repaint window
: SETPOINTS POINTS @ IDM_POINTS + MAINWIN MUNCHECK
            wParam IDM_POINTS -  POINTS !  REPAINT
            wParam MAINWIN MCHECK ;

\ style --- ; toggle style bit, update menu, repaint window
: SETSTYLE  DUP STYLE @    XOR  DUP STYLE !  AND >R  REPAINT 
            wParam MAINWIN R> IF MCHECK ELSE MUNCHECK THEN ;

\ addr --- ; set address of poem to display
: SETPOEM   POEMPTR !  REPAINT
            POEMID @ MAINWIN MUNCHECK
            wParam DUP POEMID !  MAINWIN MCHECK ;

\ --- ;  handles WM_COMMAND messages from the frame window's menu.
: DOCOMMAND wParam IDM_POINTS >= wParam IDM_P48 <= AND
            IF    SETPOINTS   EXIT
            THEN  wParam CASE
            IDM_FILEEXIT   OF WM_CLOSE MSG>MAINWIN   ENDOF
            IDM_FILEABOUT  OF ABOUTDLG         \ dialog structure
                              ['] ABOUTDLGPROC \ dialog handler
                              RUNDLG DROP            ENDOF
            IDM_ARIAL      OF " Arial"   FF_SWISS      SETFACE ENDOF
            IDM_HELV       OF " Helv"    FF_SWISS      SETFACE ENDOF
            IDM_TMSRMN     OF " Tms Rmn" FF_ROMAN      SETFACE ENDOF
            IDM_TMSNEW     OF " Times New Roman" FF_ROMAN SETFACE ENDOF
            IDM_SYSTEM     OF " System"  FF_DONTCARE   SETFACE ENDOF
            IDM_COURIER    OF " Courier" FF_MODERN     SETFACE ENDOF
            IDM_COURNEW    OF " Courier New" FF_MODERN SETFACE ENDOF
            IDM_SCRIPT     OF " Script"  FF_SCRIPT     SETFACE ENDOF
            IDM_SYMBOL     OF " Symbol"  FF_DECORATIVE SETFACE ENDOF
            IDM_BOLD       OF FS_BOLD          SETSTYLE        ENDOF
            IDM_ITALIC     OF FS_ITALIC        SETSTYLE        ENDOF
            IDM_STRIKE     OF FS_STRIKEOUT     SETSTYLE        ENDOF
            IDM_UNDER      OF FS_UNDERLINE     SETSTYLE        ENDOF
            IDM_FROST      OF FROST            SETPOEM         ENDOF
            IDM_SANDBURG   OF SANDBURG         SETPOEM         ENDOF
            IDM_POE        OF POE              SETPOEM         ENDOF
            IDM_LONGFELLOW OF LONGFELLOW       SETPOEM         ENDOF
            ( default case)  " Command not implemented" ERRORBOX
            ENDCASE ;

\ --- ; displays text sample in window using current font
: SHOWTEXT  TYPEFACE FAMILY @ POINTS @ STYLE @ MAINWIN WSETFONT
            CR  POEMPTR @
            BEGIN  DUP C@                    \ end of strings?
            WHILE  CR DUP COUNT TYPE         \ display a line
                   COUNT +                   \ move to next string
            REPEAT DROP ;

\ message handler for the frame window
: WNDPROC   wMsg CASE
            WM_PAINT OF    SHOWTEXT  ENDOF
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
            MAINWIN WCREATE 0= 
            IF   " Can't create frame window!" ERRORBOX 0 RETURN
            THEN 
            " DEMO15" MAINWIN WSETNAME \ set frame window caption
            " APPICON" MAINWIN WLOADICON DROP \ set icon
            APPMENU MAINWIN WSETMENU FALSE = \ set frame window menu
            IF   " Can't create menu!" ERRORBOX 0 RETURN
            THEN 
            MAINWIN WGETSIZE  SWAP 350 MIN SWAP MAINWIN WSETSIZE
            MAINWIN WSHOW \ display frame window
            WINMSGLOOP \ wait for WM_QUIT message
	    MAINWIN WCLOSE
            QUIT ( 0 RETURN ) ; \ exit to Windows

CR
CR .( To run the demo, type:  DEMO <Enter> )
CR

