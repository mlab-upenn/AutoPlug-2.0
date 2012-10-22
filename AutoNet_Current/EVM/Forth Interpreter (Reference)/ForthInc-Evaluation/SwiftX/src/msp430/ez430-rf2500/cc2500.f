{ ======================================================================
CC2500 interface

Copyright (C) 2008  FORTH, Inc.

This file supplies the interface to the CC2500 RF transceiver.  Requires
SPI interface.  SPI needs to be initialized before using this interface.

====================================================================== }

TARGET

{ ----------------------------------------------------------------------
Command strobes
---------------------------------------------------------------------- }

HEX

30 CONSTANT SRES
31 CONSTANT SFSTXON
33 CONSTANT SCAL
34 CONSTANT SRX
35 CONSTANT STX
36 CONSTANT SIDLE
38 CONSTANT SWOR
39 CONSTANT SPWD
3A CONSTANT SFRX
3B CONSTANT SFTX
3D CONSTANT SNOP

DECIMAL

72 CONSTANT #RSSI               \ RSSI offset (subtract from sign-extended reading)

{ ----------------------------------------------------------------------
Low-level interface

+CS asserts the CC2500 chip select.
-CS de-asserts it.
---------------------------------------------------------------------- }

CODE +CS ( -- )   $1 # P3OUT BIC.B   RET   END-CODE
CODE -CS ( -- )   $1 # P3OUT BIS.B   RET   END-CODE

{ ----------------------------------------------------------------------
Register interface

@REG reads CC2500 register r.
!REG writes CC2500 register r.
!CMD sends a command byte.
@STS returns the status.

Register r encoding:
  RBAAAAAA

  R  1=read, 0=write
  B  1=burst, 0=single (except for regs 30-3F)
  A  6-bit register number

!FIFO writes addr u to the transmit FIFO.

@FIFO fills addr from receive FIFO, returns the number bytes received
including RSSI.
---------------------------------------------------------------------- }

: @REG ( r -- char )   +CS  $80 OR >SPI DROP  0 >SPI  -CS ;
: !REG ( char r -- )   +CS  >SPI DROP  >SPI DROP  -CS ;
: !CMD ( r -- )   +CS  >SPI DROP  -CS ;
: @STS   ( -- b )   +CS  SNOP >SPI  -CS ;

: !FIFO ( addr u -- )   ?DUP IF
      +CS  $7F >SPI DROP  0 DO  COUNT >SPI DROP  LOOP
   -CS  THEN DROP ;

: @FIFO ( addr -- u )
  +CS  $FF >SPI DROP                   \ CS lower, RX FIFO addr access for burst mode
      0 >SPI 1+ DUP >R OVER + SWAP     \ #bytes + 1 for RSSI, store
      0 >SPI DROP                      \ drop adr byte (already checked or we wouldn't be here)
      DO  0 >SPI  I C!  LOOP           \ get one byte and store it
   -CS R> ;

{ ----------------------------------------------------------------------
Commands/status

@STATE returns the current state of the CC2500 state machine.
IDLE forces the state to idle.
CAL issues a calibrate command.

(CMD-SYNC) issues CC2500 cmd, awaits sync int.

TX-FRAME transmits a frame.  It forces the CC2500 into the idle state,
flushes the TX FIFO, writes the buffer to the TX FIFO, issues a transmit
command and waits until the state returns to IDLE.

RX-FRAME receives a frame into the buffer at addr, returning the
received length u.
---------------------------------------------------------------------- }

: @STATE ( -- b )   $F5 @REG  $1F AND ;
: @RXLEN ( -- u )   $FB @REG  $3F AND ;

: IDLE ( -- )   SIDLE !CMD ;
: CAL ( -- )   SCAL !CMD ;

: FLUSH-RX ( -- )   SFRX !CMD ;
: FLUSH-TX ( -- )   SFTX !CMD ;

LABEL <SYNC>
   P2IE & CLR.B                         \ Disable interrupt
   WAKE # 'R0 & MOV                     \ Awaken operator task
   &LPM # 0 (R) BIC                     \ Allow return to active mode
   RETI   END-CODE

: (CMD-SYNC) ( cmd -- )
   0 P2IFG C!  $40 P2IE C!  !CMD  STOP ;

: TX-FRAME ( addr u -- )
   IDLE  FLUSH-TX  !FIFO  STX (CMD-SYNC)
   BEGIN  PAUSE  @STATE 1 = UNTIL  ;

: RX-FRAME ( addr -- u )
   IDLE  FLUSH-RX  SRX (CMD-SYNC)
   BEGIN  PAUSE  @STATE  1 = UNTIL              \ Wait until not rx
   @RXLEN IF  @FIFO EXIT  THEN  DROP 0 ;        \ Return RX FIFO contents, 0 if none

{ ----------------------------------------------------------------------
Initialization
---------------------------------------------------------------------- }

HEX

: /CC2500 ( -- )
   06 00 !REG           \ IOCFG2 (x)
   2E 01 !REG           \ IOCFG1
   06 02 !REG           \ IOCFG0 (x) generates p2.6 int on sync pulse
   07 03 !REG           \ FIFOTHR
   D3 04 !REG           \ SYNC1
   91 05 !REG           \ SYNC0
   3F 06 !REG           \ PKTLEN (x)    63 bytes: 1 len + 62 data (+addr = 64)
   0F 07 !REG           \ PKTCTRL1 (x)  CRC autoflush, append sts, addr chk (0,FF bcast)
   05 08 !REG           \ PKTCTRL0 (x)  variable len packets: first byte is length!
   ME 09 !REG           \ ADDR (x)      My addr
   01 0A !REG           \ CHANNR (x)
   09 0B !REG           \ FSCTRL1 (x)
   00 0C !REG           \ FSCTRL0 (x)
   5D 0D !REG           \ FREQ2 (x)
   93 0E !REG           \ FREQ1 (x)
   B1 0F !REG           \ FREQ0 (x)
   2D 10 !REG           \ MDMCFG4 (x)
   3B 11 !REG           \ MDMCFG3 (x)
   73 12 !REG           \ MDMCFG2 (x)
   22 13 !REG           \ MDMCFG1 (x)
   F8 14 !REG           \ MDMCFG0 (x)
   01 15 !REG           \ DEVIATN (x)
   07 16 !REG           \ MCSM2
   30 17 !REG           \ MCSM1
   18 18 !REG           \ MCSM0 (x)
   1D 19 !REG           \ FOCCFG (x)
   1C 1A !REG           \ BSCFG (x)
   C7 1B !REG           \ AGCCTRL2 (x)
   00 1C !REG           \ AGCCTRL1 (x)
   B2 1D !REG           \ AGCCTRL0 (x)
   87 1E !REG           \ WOREVT1
   6B 1F !REG           \ WOREVT0
   F8 20 !REG           \ WORCTRL
   B6 21 !REG           \ FREND1 (x)
   10 22 !REG           \ FREND0 (x)
   EA 23 !REG           \ FSCAL3 (x)
   0A 24 !REG           \ FSCAL2 (x)
   00 25 !REG           \ FSCAL1 (x)
   11 26 !REG           \ FSCAL0 (x)
   7F 2A !REG           \ PTEST
   88 2C !REG           \ TEST2 (x)
   31 2D !REG           \ TEST1 (x)
   0B 2E !REG           \ TEST0 (x)
   BB 3E !REG           \ PATABLE[0] = 0 dBm
   00 P2SEL C!          \ P2.6 and P2.7 are GPIO
   40 P2IES C!          \ Use falling edge of sync pulse on P2.6
   <SYNC> PORT2_VECTOR INTERRUPT ;

DECIMAL

: .CC ( -- ) \ Read all of the cc2500 registers
   $2F 0 DO I @REG  CR ." R" I 2 .HEX ." = " 2 .HEX  LOOP ;
