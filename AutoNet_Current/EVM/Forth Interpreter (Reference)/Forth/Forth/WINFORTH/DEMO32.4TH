\ DEMO32.4TH    Simple Test of model LOADDLG using AboutDialog resource
\               defined in FORTH.RC
\ Copyright (c) 1991 Laboratory Microsystems Inc.

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
                      IF   0 CLOSEDLG THEN
                THEN  FALSE ;

( --- ; run the test dialog and display the result )
: DEMO          " AboutDialog"  ['] MYHANDLER LOADDLG
                CR ." Dialog result = " . CR ;


CR
CR .( To test the modal version of the dialog enter: DEMO)
CR .( To dismiss the dialog click the OK button or press the <Enter> key.)
CR

