\ UNLOAD2.4TH - translates a binary image into an Intel HEX
\ file (required by EPROM programmers & other such gizmos).

\ This code is provided as an example only and no warranty
\ of merchantibility, fitness, or correctness is given or implied.
\ Copyright (c) 1986-1993 Laboratory Microsystems Inc.
\ P. O. Box 10430, Marina del Rey, CA 90295
\ All Rights Reserved.

\ UNLOAD1.4TH demonstrates use of first-level file interface.
\ UNLOAD2.4TH demonstrates use of second-level file interface.


FORTH DEFINITIONS HEX

DOSINT                     ( load Level 2 interface if needed )

VARIABLE CSUM                                      ( checksum )
VARIABLE ADDR                           ( target location ptr )
VARIABLE TEMP                    ( temp storage for character )

HCB IFILE              ( handle control block for source file )
HCB OFILE         ( handle control block for destination file )

VARIABLE >OBUF   >OBUF OFF         ( pointer to output record )

20  ( 32. )  CONSTANT B/IBUF      ( size of input file buffer )
100 ( 256. ) CONSTANT B/OBUF     ( size of output file buffer )

CREATE IBUF   B/IBUF ALLOT             ( data from input file )
CREATE OBUF   B/OBUF ALLOT            ( data from output file )

( --- ; close input and/or output files, if prev. opened )
: close-files   IFILE FCLOSE DROP
                OFILE FCLOSE DROP  ;

( flag ^str --- ; if flag=T show error msg, close files, exit )
: unl-err       SWAP                               ( get flag )
                IF   CR CR ." UNLOAD error:  "  ( display msg )
                     COUNT TYPE  CR CR
                     close-files          ( if any files open )
                     QUIT               ( exit to interpreter )
                ELSE DROP          ( false flag, discard ^str )
                THEN  ;

( ^str --- ; open input and output files, output file has )
( same filename as input and extension HEX )
: open-files    DUP IFILE NAME>HCB            ( set filenames )
                -EXT " .HEX" +EXT OFILE NAME>HCB
                CR CR ." Input file:  " IFILE .FNAME
		CR ." Output file: " OFILE .FNAME
                IFILE O_RD FOPEN            ( open input file )
                " input file not found"  unl-err
                OFILE 0 FMAKE            ( create output file )
                " can't create output file"  unl-err ;

( --- ; write a record to output file )
: !rec          OFILE   OBUF  >OBUF @ FWRITE DROP
                >OBUF OFF ;

( b --- ; add one byte to output record )
: !char         >OBUF @  OBUF +  C!         ( store character )
                1 >OBUF +! ;                   ( incr pointer )

( 4bits --- ; convert 4 bits to ASCII char, send to output )
: !nibl         0F AND >DIGIT !char ;

( b --- ; convert 8 bits to 2 ASCII chars, send to output )
: !byte         0FF AND DUP CSUM +! DUP -4 SHIFT !nibl !nibl ;

( n --- ; convert 16 bits to 4 ASCII chars, send to output )
: !word         DUP >< !byte !byte ;

( --- ; send start of record marker to output, init chksum )
: !header       ASCII :  !char  CSUM OFF ;

( --- ; send checksum and New-Line to output )
: !csum         CSUM @ NEGATE !byte                ( checksum )
                0D !char  0A !char                 ( New-Line )
                !rec ;                   ( force record write )

( --- ; send special end of file record to output )
: !eof          !header  0 !byte  0 !word  1 !byte  !csum ;

( addr length --- )
: !record       !header                ( send : , init chksum )
                DUP !byte                       ( send length )
                ADDR @ !word            ( send target address )
                0 !byte                         ( send 0 byte )
                DUP ADDR +!                ( incr target addr )
                OVER + SWAP
                ?DO   I C@ !byte        ( convert & send data )
                LOOP
                !csum ;                       ( send checksum )

( ^filename origin --- )
: unload        ADDR !               ( set target origin addr )
                open-files        ( open input, create output )
                BEGIN   IFILE IBUF B/IBUF       ( hcb addr len)
                        FREAD DUP       ( get data from input )
                WHILE   IBUF SWAP !record        ( convert it )
                REPEAT  DROP               ( discard 0 length )
                !eof                ( send End-Of-File record )
                close-files ;    ( close input & output files )

DECIMAL

( --- )
: UNLOAD  CR CR  ." UNLOAD binary to HEX file"
        CR  ." Copyright (c) 1986 Laboratory Microsystems Inc."
        CR CR ." Enter source file name:     "
        HERE 30 EXPECT   HERE SPAN @ BL SKIP STRPCK
        CR CR ." Enter target origin (hex):  "
        HERE 30 ERASE    HERE 1+ 30 EXPECT  SPAN @ HERE C!
        HEX HERE NUMBER? DECIMAL  0=   " Bad address!"  unl-err
        DROP unload CR CR ." HEX file written."  CR CR ;

CR
CR .( UNLOAD utility to demonstrate use of first-level file interface.)
CR .( To run the utility, type the command: UNLOAD <Enter> )
CR .( You will be prompted for the input file name and base address.)
CR .( The output file will have the same name but will have the )
CR .( extension .HEX.  Any previous file with the same name as the )
CR .( new output file will be overwritten.)
CR

