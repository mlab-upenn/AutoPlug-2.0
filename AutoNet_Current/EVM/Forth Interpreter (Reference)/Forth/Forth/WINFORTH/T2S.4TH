\ Text to screen (block) file conversion 
\ Copyright 1986-1993 Laboratory Microsystems Inc.

FORTH DEFINITIONS DECIMAL       

DOSINT \ load file interface if not already loaded

HCB IFILE               ( handle control block for input file )
HCB OFILE              ( handle control block for output file )

CREATE BUFF 128 ALLOT                   ( buffer for file i/o )
VARIABLE TEMP

13 CONSTANT ASCII_CR                        ( carriage return )
10 CONSTANT ASCII_LF                              ( line feed )

( hcb --- )
: INPUT-FILENAME    
        HERE 30 EXPECT ( read console )
        HERE SPAN @ STRPCK  SWAP NAME>HCB ;

( --- )
: GET_FILE_NAMES
        BEGIN CR
              CR ." Enter name of source file:      "
              IFILE INPUT-FILENAME
              CR ." Enter name of destination file: "
              OFILE INPUT-FILENAME    CR
              CR ." Source file      = " IFILE HCB>N .FILE
              CR ." Destination file = " OFILE HCB>N .FILE
              CR CR ." OK? " 
	      KEY   DUP EMIT  32 OR    ASCII y =
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
: CLOSE_FILES   IFILE FCLOSE DROP  OFILE FCLOSE DROP ;

( --- )
: WRITE_FORTH_LINE      
        OFILE BUFF 64 FWRITE 64 <>
        IF   CR ." Destination media is full"
             CR CLOSE_FILES QUIT  
	THEN ;


( --- status ; 0 or EOF )
: READ_TXT_LINE  BUFF 128 BLANK     0
        BEGIN   IFILE TEMP 1 FREAD 0=
                IF   DROP FALSE EXIT  ( end of file, return F )
                THEN
                TEMP C@  ASCII_CR =    ( if return, line done )
                IF   DROP TRUE EXIT         ( return status=T )
                THEN TEMP C@ ASCII_LF <> ( discard line feeds )
                IF   TEMP C@  OVER BUFF +  C!  1+
                THEN
        AGAIN ;

( -- ; convert text file to screen file)
: T2S   CR ." Convert TEXT file to SCREEN file"
        GET_FILE_NAMES  OPEN_FILES
        CR ." Processing..."
        BEGIN  READ_TXT_LINE
        WHILE  WRITE_FORTH_LINE
        REPEAT CR CR  IFILE 0. 2 FSEEK
        CR ." Source file =      " D.  ." bytes"
        OFILE  0. 2 FSEEK
        CR ." Destination file = " D. ." bytes"
        CLOSE_FILES
        CR CR ." Conversion completed." CR CR ;

CR CR .( Enter T2S to run conversion utility.) CR CR

