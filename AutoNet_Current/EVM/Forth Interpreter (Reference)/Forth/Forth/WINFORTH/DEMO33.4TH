\ DEMO33.4TH    Simple Test of modeless LOADDLG using the AboutDialog 
\               resource defined in FORTH.RC
\ Copyright (c) 1992 Laboratory Microsystems Inc.

\ arbitrary constants for dialog controls, from FORTH.H
702 CONSTANT IDD_CODE
703 CONSTANT IDD_DATA
704 CONSTANT IDD_HEADERS

( --- flag ; this is the callback handler for the test dialog )
: MYHANDLER     wMsg WM_INITDIALOG =
                IF    \ update code, data, header space available
                      hWnd IDD_CODE    CLIMIT  CP @ -  0  SetDlgItemInt
                      hWnd IDD_DATA    LIMIT   DP @ -  0  SetDlgItemInt
                      hWnd IDD_HEADERS HLIMIT  HP @ -  0  SetDlgItemInt
                      TRUE EXIT
                THEN  wMsg WM_COMMAND =
                IF    wParam IDOK =
                      \ modeless dialogs are killed by WM_CLOSE message,
                      \ either explicit or from CLOSE item on system menu
                      IF   0 CLOSEDLG
                      THEN
                THEN  FALSE ;

( --- ; run the test dialog and display the result )
: DEMO          " AboutDialog"  ['] MYHANDLER MODELESS LOADDLG
                CR ." Dialog result = " . CR ;


CR
CR .( To test the modeless About... dialog, enter: DEMO)
CR .( To dismiss the dialog click the OK button )
CR .( or press the <Enter> key.  Note that since the dialog is )
CR .( modeless, you can click in the Forth workspace window to )
CR .( give it back the focus, then type in the Forth workspace window even )
CR .( while the dialog is still active.  )
CR


