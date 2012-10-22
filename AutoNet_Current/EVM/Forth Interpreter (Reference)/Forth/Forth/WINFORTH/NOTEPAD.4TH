\ NOTEPAD2.4TH -- Sample Windows application for WinForth.
\ This code implements a simple Notepad-style text editor
\ using a multiline edit control. Differs from NOTEPAD.4TH
\ by the addition of printing support.
\ Copyright (C) 1993 Laboratory Microsystems Inc.

\ CAVEAT:  No AbortProc implemented yet.
\ Tab expansions not right yet.
\ Uses the default font.  Ignores first page, last page,
\ and other stuff returned by PRINTDLG.

DOSINT \ load file interface

\ magic numbers from WINDOWS.H
INCLUDE DEVCAPS.4TH

HCB EDITHCB \ handle control block for file being edited
0 EQU EDITSIZE \ length of text from file
NULPTR PTR EDITPTR \ pointer to edit buffer

1 CONSTANT CF_TEXT \ clipboard format for plain text

WCB MAINWIN    \ window control block for Notepad frame window
0 EQU HWNDEDIT \ handle for multiline edit control
0 EQU HWNDCANCEL \ handle for nonmodal cancel dialog
0 EQU PDC      \ DC for printing

0 EQU MAXLINE  \ number of lines in edit control
0 EQU CURLINE  \ current line being printed
0 EQU CHARY    \ character height, printer font
0 EQU CHARX    \ average character width, printer font
0 EQU PAGEY    \ total page height
0 EQU HORZMARG \ width of each side margin
0 EQU VERTMARG \ height of top & bottom margins
0 EQU CURY     \ vertical coordinate, current page
0 EQU ILINE    \ character index, start of current line
0 EQU CLINE    \ length of current line

0 EQU PCANCEL  \ print cancel flag
0 EQU PABORT   \ print abort flag

\ Data structure used by various Windows 3.1 printing APIs
CREATE DOCINFO 10 ,  0 , 0 , 0 , 0 ,

\ TEXTMETRICS structure for printer
TM PTM

\ Build up style parameter for child multiline edit control
WS_CHILD WS_VISIBLE D+ WS_HSCROLL D+ WS_VSCROLL D+
WS_BORDER D+ ES_LEFT D+ ES_MULTILINE D+ ES_AUTOHSCROLL D+
ES_AUTOVSCROLL D+  2CONSTANT EDITSTYLE

\ arbitrary identifier for multiline edit control
1 CONSTANT IDC_EDIT

\ arbitrary identifiers for menu items
100 CONSTANT IDM_FILENEW
101 CONSTANT IDM_FILEOPEN
102 CONSTANT IDM_FILESAVE
103 CONSTANT IDM_FILESAVEAS
104 CONSTANT IDM_FILEPRINT
105 CONSTANT IDM_FILEEXIT
106 CONSTANT IDM_FILEABOUT
107 CONSTANT IDM_EDITUNDO
108 CONSTANT IDM_EDITCUT
109 CONSTANT IDM_EDITCOPY
110 CONSTANT IDM_EDITPASTE
111 CONSTANT IDM_EDITCLEAR

\ menu for the Notepad frame window
MENU NOTEPADMENU 
  " &File" POPUP 
          " &New"      IDM_FILENEW    MF_ENABLED   MENUITEM 
          " &Open"     IDM_FILEOPEN   MF_ENABLED   MENUITEM 
          " &Save"     IDM_FILESAVE   MF_ENABLED   MENUITEM 
          " Save &As"  IDM_FILESAVEAS MF_ENABLED   MENUITEM 
          " &Print"    IDM_FILEPRINT  MF_ENABLED   MENUITEM
          " "          0              MF_SEPARATOR MENUITEM 
          " E&xit"     IDM_FILEEXIT   MF_ENABLED   MENUITEM 
          " "          0              MF_SEPARATOR MENUITEM 
          " A&bout..." IDM_FILEABOUT  MF_ENABLED   MENUITEM 
          END-POPUP 
  " &Edit" POPUP 
          " &Undo"     IDM_EDITUNDO   MF_GRAYED    MENUITEM 
          " "          0              MF_SEPARATOR MENUITEM 
          " Cu&t"      IDM_EDITCUT    MF_ENABLED   MENUITEM 
          " &Copy"     IDM_EDITCOPY   MF_ENABLED   MENUITEM 
          " &Paste"    IDM_EDITPASTE  MF_GRAYED    MENUITEM 
          " C&lear"    IDM_EDITCLEAR  MF_ENABLED   MENUITEM 
          END-POPUP 
END-MENU 

100 EQU ID_PUSHB  \ control ID for OK pushbutton in About Box

  " About WinForth NotePad2..."   
  16 16 128 70 DS_MODALFRAME WS_CAPTION D+ WS_POPUP D+
DIALOG  ABOUTDLG
  " FORTHICON"            12 16          -1        ICON
  " NotePad Clone #2"     32 8    96 12  -1        CTEXT
  " Sample WinForth App"  32 20   96 12  -1        CTEXT
  " (C) 1993 LMI"         32 32   96 12  -1        CTEXT
  " OK"                   44 50   40 16  ID_PUSHB  DEFPUSHBUTTON
END-DIALOG

  " WinForth NotePad2 Example"   
  16 16 128 40 DS_MODALFRAME WS_CAPTION D+ WS_VISIBLE D+
DIALOG  CANCELDLG
  " Printing file..."     16 8    96 12  -1        CTEXT
  " Cancel"               44 20   40 16  ID_PUSHB  DEFPUSHBUTTON
END-DIALOG

( --- flag ; the callback handler for the About... dialog )
: ABOUTDLGPROC  wMsg WM_INITDIALOG =
                IF    TRUE EXIT
                THEN  wMsg WM_COMMAND =
                IF    wParam ID_PUSHB =
                      IF   0 CLOSEDLG THEN
                THEN  FALSE ;

\  --- flag ; the callback handler for the print cancel dialog 
\ We don't issue a CLOSEDLG call in this handler, because the
\ dialog is modeless and will be destroyed by PrintFile anyway.
: CANCELDLGPROC wMsg WM_INITDIALOG =
                IF    FALSE EQU PCANCEL
                      hWnd EQU HWNDCANCEL
                      TRUE EXIT
                THEN  wMsg WM_COMMAND =
                IF    wParam ID_PUSHB =
                      IF  TRUE EQU PCANCEL THEN
                THEN  FALSE ;

CREATE msg 32 ALLOT

\ hdc errorcode --- int ; callback for AbortProc() 
\ returns TRUE to continue printing, FALSE to abort
: ABORTPROC     IF   FALSE EXIT \ error, cancel printing now
                ELSE \ check for waiting messages
                     BEGIN  DS0 msg 0 0 0 1 PeekMessage
                            PCANCEL NOT  AND
                     WHILE  HWNDCANCEL DS0 msg IsDialogMessage
                            HWNDCANCEL OR
                            IF  DS0 msg TranslateMessage
                                DS0 msg DispatchMessage
                            THEN
                     REPEAT
                THEN PCANCEL NOT ; 
                             
\ --- flag ; has data changed in edit window?
: CHANGED?  HWNDEDIT EM_GETMODIFY 0 0. SendMessage OR 0<> ;

\ flag menuitem --- ; set status of menuitem;
\ item enabled if flag = TRUE; grayed-out if flag = FALSE
: UPDATEITEM MAINWIN ROT  \ --- menuitem wcb flag
            IF MENABLE ELSE MGRAY THEN ;

\ This routine updates the menu bar whenever we get a WM_INITMENU message.
\ --- ; it returns to the main window handler which returns double 0
: UPDATEMENU  HWNDEDIT EM_GETSEL 0 0. SendMessage <> DUP DUP \ anything selected?
            IDM_EDITCUT UPDATEITEM  IDM_EDITCOPY UPDATEITEM  IDM_EDITCLEAR UPDATEITEM
            HWNDEDIT EM_CANUNDO 0 0. SendMessage OR \ can undo?
            IDM_EDITUNDO UPDATEITEM
            CF_TEXT IsClipboardFormatAvailable \ anything to paste?
            IDM_EDITPASTE UPDATEITEM
            CHANGED?  \ has buffer been changed?
            IDM_FILESAVE UPDATEITEM ;

\ --- ; set filename in window title bar
: SETCAPTION MAINWIN WCB>HWND DS0  " NotePad2 - " COUNT 
            EDITHCB HCB>N COUNT STRCAT STRPCK ASCIIZ SetWindowText ;

\ ^str --- flag ; display Yes/No dialog, return flag TRUE=YES FALSE=NO
: YESNOBOX  " NotePad2" \ messagebox title
            [ MB_ICONQUESTION MB_YESNO OR ] LITERAL \ icon, buttons
            MSGBOX 6 = ;

\ ^str --- ; display error message and OK button in message box
: ERRORBOX  " TestPaint"  \ messagebox title
            [ MB_ICONHAND MB_OK OR ] LITERAL \ icon, button
            MSGBOX DROP ;

\ msg --- ; send message to frame window
: MSG>MAINWIN  MAINWIN WCB>HWND SWAP 0 0. SendMessage 2DROP ;

\ msg --- ; send message to multiline edit control
: MSG>EDITWIN  HWNDEDIT SWAP 0 0. SendMessage 2DROP ;

\ --- ; save contents of edit buffer to new filename
: SAVEFILE  HWNDEDIT GetWindowTextLength EQU EDITSIZE \ get bytes to write
            EDITHCB 0 FMAKE \ create the file
            IF   " Can't create file!" ERRORBOX  EXIT
            THEN HWNDEDIT EDITPTR EDITSIZE 1+ GetWindowText DROP \ retrieve text
            EDITHCB EDITPTR EDITSIZE FWRITEL EDITSIZE <> \ write to disk
            IF   " Disk full!" ERRORBOX 
            THEN EDITHCB FCLOSE DROP \ close the file
            HWNDEDIT EM_SETMODIFY 0 0. SendMessage 2DROP ; \ turn off change flag

\ --- ; save contents of edit buffer
: SAVEFILEAS EDITHCB HCB>N SAVEASDLG \ propose filename
            EDITHCB NAME>HCB SETCAPTION \ save actual filename
            SAVEFILE ;  \ now write file

\ --- ; check if edit buffer has been changed, if so prompt
\ use whether to write buffer or discard changes
: ?SAVEFILE CHANGED? \ buffer changed since created or last written?
            IF  EDITHCB HCB>N COUNT \ display filename in message box
                "  has been changed.  Write file?" COUNT 
                STRCAT STRPCK YESNOBOX
                IF   SAVEFILEAS   THEN \ save file if YES button clicked
            THEN ;

\ --- ; display open file dialog, open & read file
: OPENFILE  ?SAVEFILE  \ if dirty buffer, ask whether to write
            " Forth source files|*.4TH|All files|*.*" 
	    OPENDLG \ get filename from user
            DUP C@ 0= \ check if null string
            IF   DROP EXIT \ bail out, no filename entered
            THEN EDITHCB NAME>HCB \ put name into HCB
            EDITHCB 0 FOPEN \ open the file now
            IF   " Can't open file!" ERRORBOX EXIT \ exit, open failed
            THEN EDITHCB EDITPTR 32768 FREADL \ read entire file
            EQU EDITSIZE \ save the file length
            EDITHCB FCLOSE DROP \ close the file again
            0 EDITPTR EDITSIZE >PTR C!L \ set terminal null
            HWNDEDIT EDITPTR SetWindowText \ update edit control
            SETCAPTION ; \ put filename into window title bar

\ --- ; discard edit buffer, prepare new untitled file
: NEWFILE   ?SAVEFILE  \ if dirty buffer, ask whether to write
            0 EDITPTR 0 >PTR C!L  0 EQU EDITSIZE \ set zero length
            HWNDEDIT EDITPTR SetWindowText \ update edit window
            " Untitled" EDITHCB NAME>HCB \ set default filename
            SETCAPTION \ put filename into window title bar
            EM_SETMODIFY MSG>EDITWIN  ; \ clear changed flag

\ --- ; print contents of edit control, line by line
: PRINTLINES 
            BEGIN  CURLINE MAXLINE <   \ if more lines to print
                   PCANCEL NOT AND     \ and CANCEL button not pushed
            WHILE  \ get offset, length of current line
                   HWNDEDIT EM_LINEINDEX  CURLINE 0. 
                           SendMessage DROP EQU ILINE
                   HWNDEDIT EM_LINELENGTH ILINE 0. 
                           SendMessage DROP EQU CLINE
                   \ paint the current line
                   PDC ( printer DC )  HORZMARG ( left margin ) 
                   CURY  ( current vertical page position )
                   EDITPTR ILINE >PTR  CLINE \ addr, len of line
                   0  0.  0 ( misc unused tab stuff )
                   TabbedTextOut DROP
                   \ count lines, advance page coordinate
                   CURLINE 1+ EQU CURLINE
                   CURY CHARY + DUP EQU CURY PAGEY VERTMARG - >
                   IF  \ end of page reached, eject sheet
                       VERTMARG EQU CURY
                        PDC EndPage DROP  PDC StartPage DROP
                   THEN
            REPEAT ;

\ --- ; print contents of edit buffer
: PRINTFILE PRINTDLG \ show print dialog to user
            IF   2DROP ( discard flags ) EQU PDC ( save printer DC) 
                 3DROP ( discard page numbers etc. )
                 \ print job name into DOCINFO structure
                 EDITHCB HCB>N ASCIIZ DOCINFO 2+ !  DS0 DOCINFO 4 + !
                 \ get copy of text to our buffer
                 HWNDEDIT GetWindowTextLength EQU EDITSIZE
                 HWNDEDIT EDITPTR EDITSIZE 1+ GetWindowText DROP
                 \ get no. of lines in edit control
                 HWNDEDIT EM_GETLINECOUNT 0 0. SendMessage DROP EQU MAXLINE
                 \ get character size for current printer font
                 PDC DS0 PTM GetTextMetrics DROP
                 PTM 10 + @   EQU CHARX    \ average char width
                 PTM @   PTM 8 +  @ +  EQU CHARY  \ height + leading
                 PDC VERTRES     GetDeviceCaps  EQU PAGEY
                 PDC LOGPIXELSX  GetDeviceCaps  2/  EQU HORZMARG
                 PDC LOGPIXELSY  GetDeviceCaps  2/  DUP EQU VERTMARG  EQU CURY
                 \ start print job, start first page, init linecount
                 PDC DS0 DOCINFO StartDoc DROP   PDC StartPage DROP
                 0 EQU CURLINE
                 \ disable our frame window
                 MAINWIN WCB>HWND FALSE EnableWindow DROP
                 \ install print abort callback
                 ['] ABORTPROC 2 CBALLOC 
                 PDC -ROT  SetAbortProc  DROP
                 \ create modeless "Print Cancel" dialog
                 CANCELDLG ['] CANCELDLGPROC MODELESS RUNDLG DROP
                 \ print contents of edit control, line by line
                 PRINTLINES
                  \ destroy modeless print cancel dialog
                 HWNDCANCEL WM_CLOSE 0 0. SendMessage 2DROP
                 \ re-enable our frame window 
                 MAINWIN WCB>HWND TRUE EnableWindow DROP
                 MAINWIN WSETFOCUS
                \ clean up everything
                 PDC EndPage DROP  PDC EndDoc DROP
                 PDC DeleteDC \ discard printer DC
                 0 EQU HWNDCANCEL     \ signal dialog not active
                 ['] ABORTPROC CBFREE \ release abort callback
            THEN ;

\ --- This routine handles WM_COMMAND messages from the frame window's menu.
: DOCOMMAND wParam CASE
            IDM_FILENEW    OF NEWFILE                ENDOF
            IDM_FILEOPEN   OF OPENFILE               ENDOF
            IDM_FILESAVE   OF SAVEFILE               ENDOF
            IDM_FILESAVEAS OF SAVEFILEAS             ENDOF
            IDM_FILEEXIT   OF ?SAVEFILE
                              WM_CLOSE MSG>MAINWIN   ENDOF
            IDM_FILEPRINT  OF PRINTFILE              ENDOF
            IDM_FILEABOUT  OF ABOUTDLG         \ dialog structure
                              ['] ABOUTDLGPROC \ dialog handler
                              RUNDLG DROP            ENDOF
            IDM_EDITUNDO   OF WM_UNDO MSG>EDITWIN    ENDOF
            IDM_EDITCUT    OF WM_CUT MSG>EDITWIN     ENDOF
            IDM_EDITCOPY   OF WM_COPY MSG>EDITWIN    ENDOF
            IDM_EDITPASTE  OF WM_PASTE MSG>EDITWIN   ENDOF
            IDM_EDITCLEAR  OF WM_CLEAR MSG>EDITWIN   ENDOF
            ENDCASE ;

\ message handler for the Notepad frame window
: WNDPROC   wMsg CASE
            WM_CREATE OF \ when frame window created, create ML edit control
                           DS0 " edit" ASCIIZ    \ class= MLE control
                           0.                    \ lpWindowName
                           EDITSTYLE SWAP        \ dwStyle
                           0 0 0 0               \ position, size
                           hWnd IDC_EDIT         \ hwndParent, childID
                           hInstance 0.          \ hInstancE, lpParam
                           CreateWindow EQU HWNDEDIT \ save handle for control
                           ENDOF
            WM_SETFOCUS OF \ when frame gets focus, pass it to edit control
                           HWNDEDIT SetFocus DROP  ENDOF
            WM_SIZE OF     \ size edit control to fit client area of frame window
                           HWNDEDIT 0 0 lParam TRUE
                           MoveWindow DROP ENDOF
            WM_COMMAND OF  wParam IDC_EDIT =  lParam NIP EN_ERRSPACE = AND
                           IF   " Edit control out of memory!" ERRORBOX
                           ELSE DOCOMMAND \ decode menu command
                           THEN ENDOF
            WM_DESTROY OF  0 PostQuitMessage \ kill message loop
                           ENDOF
            WM_INITMENU OF UPDATEMENU    ENDOF
            \ default case: pass message to DefWindowProc()
            DEFMSGHANDLER EXIT
            ENDCASE 0 0 ; \ double value to return from message handler

\ "main word" of sample Notepad application;
\ creates the frame window and then enters message loop
: NOTEPAD   32768 MALLOC PTR EDITPTR  EDITPTR NULPTR= \ allocate edit buffer
            IF   " Can't allocate memory!" ERRORBOX 0 RETURN
            THEN ['] WNDPROC MAINWIN SETMSGHANDLER \ install msg handler
            " Notepad" MAINWIN WSETNAME \ set frame window caption
            " APPICON" MAINWIN WLOADICON DROP \ set icon
            MAINWIN WCREATE 0= \ create the frame window
            IF   " Can't create frame window!" ERRORBOX 0 RETURN
            THEN NOTEPADMENU MAINWIN WSETMENU FALSE = \ set frame window menu
            IF   " Can't create menu!" ERRORBOX 0 RETURN
            THEN MAINWIN WSHOW \ display frame window
            NEWFILE \ start out with "untitled" file
            WINMSGLOOP \ wait for WM_QUIT message
            MAINWIN WCLOSE \ destroy our editing window
            EDITPTR FREE \ release global memory block
            QUIT ; \ exit to Forth interpreter

CR CR .( Type: NOTEPAD to start the program.) CR CR
