\ DEMO03.4TH Simple Messagebox-based Application
\ using direct calls to the Windows API function MessageBox.
\ Copyright (c) 1992 Laboratory Microsystems Inc.

: HELLO	  hwndFrame DS0 " Hello World!" ASCIIZ
          DS0 " WinForth" ASCIIZ MB_OK MessageBox DROP ;

CR CR .( Type HELLO <Enter> to execute the application.) CR 

