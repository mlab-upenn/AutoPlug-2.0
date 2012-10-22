\ Screen (block) to text file conversion 
\ Copyright 1986-1993 Laboratory Microsystems Inc.

FORTH DEFINITIONS DECIMAL   

DOSINT \ load file interface if not already loaded

HCB IFILE               ( handle control block for input file )
HCB OFILE              ( handle control block for output file )

VARIABLE BUFF    128 ALLOT            ( buffer for input file )

13 CONSTANT ASCII_CR                        ( carriage return )
10 CONSTANT ASCII_LF                              ( line feed )

( hcb --- )
: INPUT-FILENAME    
          HERE 30 EXPECT             ( read console )
          HERE SPAN @ STRPCK  SWAP NAME>HCB ;

( --- )
: GET_FILE_NAMES
  BEGIN   CR CR ." Enter name of source file:      "
          IFILE INPUT-FILENAME
          CR ." Enter name of destination file: "
          OFILE INPUT-FILENAME    CR
          CR ." Source file      = " IFILE HCB>N .FILE
          CR ." Destination file = " OFILE HCB>N .FILE
          CR CR ." OK? " 
	  KEY DUP EMIT  32 OR    ASCII y =
  UNTIL   CR CR ;

( --- )
: OPEN_FILES    
          IFILE O_RD FOPEN
          IF   CR ." Source file not found" CR QUIT
          THEN OFILE 0 FMAKE
          IF   CR ." Can't make destination file" CR
               IFILE FCLOSE DROP QUIT
          THEN ;

( --- )
: CLOSE_FILES   
          IFILE FCLOSE DROP
          OFILE FCLOSE DROP ;

( --- length )
: READ_FORTH_LINE   
          IFILE BUFF 64 FREAD ;

( --- length )
: FORTH_TO_TXT      
          BUFF  64 -TRAILING SWAP DROP
          ASCII_CR OVER BUFF  + C! 1+
          ASCII_LF OVER BUFF  + C! 1+ ;

( length --- )
: WRITE_TXT_LINE    
          >R OFILE BUFF  R@ FWRITE  R> <>
          IF CR ." Destination media is full"
          CR CLOSE_FILES QUIT THEN ;

( --- )
: S2T     CR ." Convert screen file to standard text file"
          GET_FILE_NAMES  OPEN_FILES
          CR ." Processing..."
          BEGIN  READ_FORTH_LINE
          WHILE  FORTH_TO_TXT  WRITE_TXT_LINE
          REPEAT CR CR
          IFILE 0. 2 FSEEK
          CR ." Source file =      " D.  ." bytes"
          OFILE 0. 2 FSEEK
          CR ." Destination file = " D. ." bytes"
          CLOSE_FILES
          CR CR ." Conversion completed." CR CR ;

CR CR .( Enter S2T to run conversion utility.) CR CR

