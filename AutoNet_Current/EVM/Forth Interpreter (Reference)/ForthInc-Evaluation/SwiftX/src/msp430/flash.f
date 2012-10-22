{ =====================================================================
FLASH PROGRAMMING

Copyright (C) 2001  FORTH, Inc.

Any flash memory segment can be erased or programmed with these
routines.
===================================================================== }

TARGET

{ ---------------------------------------------------------------------
Flash erase/program

SegmentA and SegmentB are the 128-byte "information"
memory segments.  These reside in the same location in all the
MSP430F parts.  Main memory is allocated in 512-byte sectors.

FLASH-ERASE erases the sector of flash memory which contains addr.
Returns true if the operation was successful.  The address must be
in Flash memory!

FLASH-PROGRAM writes u bytes from source address addr1 to destination
address addr2.  Returns true if the operation was successful.
Size and destination address must be word-aligned.  Destination
address must be in Flash memory!
--------------------------------------------------------------------- }

HEX

1000 CONSTANT SegmentA          \ 1st "Information Memory" segment
1080 CONSTANT SegmentB          \ 2nd "Information Memory" segment
1100 CONSTANT SegmentN          \ Main memory segments

CODE FLASH-ERASE ( addr -- flag )
   -80 # R8 MOV   SegmentN # T CMP      \ Mask/counter in R8
   CS IF   -200 # R8 MOV   THEN         \ Adjust for info or main mem
   DINT                                 \ Disable interrupts
   A544 # FCTL2 & MOV                   \ Source = MCLK, DIV = 5.
   A500 # FCTL3 & MOV                   \ Clear bits
   A502 # FCTL1 & MOV                   \ Set 'Erase' bits
   R8 T AND   0 (T) CLR                 \ Dummy write to flash memory
   BEGIN  BUSY # FCTL3 & BIT            \ Test 'Busy' bit
   0= UNTIL                             \ Spin until not busy
   A500 # FCTL1 & MOV                   \ Clear flash function
   BEGIN   -1 # 0 (T) CMP   0= WHILE    \ Check if segment is erased
   T INCD   R8 INCD   0= UNTIL   THEN   \ Bail if not
   R8 TST   -1 # T MOV                  \ Return true if okay
   0= NOT IF   T CLR   THEN             \ Return false if compare failed
   EINT   RET   END-CODE                \ Enable interrupts, return

CODE FLASH-PROGRAM ( addr1 addr2 u -- flag )
   @S+ R9 MOV   @S+ R8 MOV              \ R8=src addr, R9=dest addr, T=count
   DINT                                 \ Disable interrupts
   A544 # FCTL2 & MOV                   \ Source = MCLK, DIV = 5.
   A500 # FCTL3 & MOV                   \ Clear bits
   A540 # FCTL1 & MOV                   \ Set 'Wrt' bit
   BEGIN   A500 # FCTL3 & MOV           \ Clear bits
      @R8 0 (R9) MOV                    \ Write word
      BEGIN   BUSY # FCTL3 & BIT        \ Test 'Busy' bit
      0= UNTIL                          \ Spin until not busy
      @R8+ 0 (R9) CMP                   \ Compare result
      0= WHILE   R9 INCD                \ Bail if no match, advance src ptr
   T DECD   0= UNTIL   THEN             \ Loop until done
   A500 # FCTL1 & MOV                   \ Clear flash function
   T TST   -1 # T MOV                   \ Return true if okay
   0= NOT IF   T CLR   THEN             \ Return false if compare failed
   EINT   RET   END-CODE                \ Enable interrupts, return

DECIMAL

