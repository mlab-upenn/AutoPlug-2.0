\ DEMO30.4TH    Demo of modal dialog using compiled Forth dialog 
\               template and RUNDLG
\ Copyright 1991-1991 Laboratory Microsystems Inc.

( arbitrary named constants for the dialog's control identifiers) 
1 CONSTANT ID_LTXT    
2 CONSTANT ID_CTXT    
3 CONSTANT ID_RTXT
4 CONSTANT ID_CHKBX   
5 CONSTANT ID_RADIO   
6 CONSTANT ID_PUSHB
7 CONSTANT ID_LSTBX   
8 CONSTANT ID_COMBO   
9 CONSTANT ID_EDIT
10 CONSTANT ID_CTRL

( This is the template for the example dialog, it defines the size, )
( position, and style of the dialog, and the locations and characteristics)
( of the controls in the dialog. )

  " My Dialog"   16 16 128 190 DS_MODALFRAME WS_CAPTION D+ WS_POPUP D+
DIALOG  MYDLG

  " Left static text"    16 8    96 12  ID_LTXT   LTEXT
  " Center static text"  16 20   96 12  ID_CTXT   CTEXT
  " Right static text"   16 32   96 12  ID_RTXT   RTEXT
  " Checkbox"            16 44   96 12  ID_CHKBX  CHECKBOX
  " Radiobutton"         16 56   96 12  ID_RADIO  RADIOBUTTON
                         16 72   96 30  ID_LSTBX  LISTBOX
                         16 108  96 30  ID_COMBO  COMBOBOX
                         16 144  96 16  ID_EDIT   EDITTEXT
  " OK"                  20 166  40 16  ID_PUSHB  DEFPUSHBUTTON

  " Cancel"		 68 166  40 16  ID_CTRL   
  			 BS_PUSHBUTTON WS_CHILD WS_VISIBLE 
			 WS_TABSTOP D+ D+ D+      
                         " BUTTON"                CONTROL	

END-DIALOG

( --- flag ; this is the callback handler for the test dialog )
: MYHANDLER     wMsg WM_INITDIALOG =
                IF    TRUE EXIT
                THEN  wMsg WM_COMMAND =
                IF    wParam ID_PUSHB =
                      IF   0 CLOSEDLG THEN
                THEN  FALSE ;

( --- ; run the test dialog and display the result )
: DEMO          MYDLG ['] MYHANDLER RUNDLG
                CR ." Dialog result = " . CR ;


CR
CR .( To run the modal test dialog enter: DEMO)
CR .( To dismiss the dialog click the OK button or press the <Enter> key.)
CR

