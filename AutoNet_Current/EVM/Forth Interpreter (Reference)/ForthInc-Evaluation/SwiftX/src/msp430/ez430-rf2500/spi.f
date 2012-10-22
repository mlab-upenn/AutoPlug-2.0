{ ======================================================================
SPI interface

Copyright (C) 2008  FORTH, Inc.

USCI B0 is operated in SPI mode to communicate with the CC2500 RF
Transceiver.

====================================================================== }

TARGET

{ ----------------------------------------------------------------------
API calls

/SPI initializes USCI B0 for SPI mode, as commented.

>SPI is the SPI exchange function.  Clocks out char1, returns clocked
in char2.
---------------------------------------------------------------------- }

HEX

: /SPI ( -- )
   01 UCB0CTL1 C!               \ hold port in reset
   69 UCB0CTL0 C!               \ CKPH normal, CKPL inactive high, master, 8-bit. 3-pin mode
   81 UCB0CTL1 C!               \ SMCLK, still in reset
   2 UCB0BR0 C!  0 UCB0BR1 C!   \ SMCLK/2 (note: can't be <2)
   0B P3DIR C!  0E P3SEL C!     \ P3 pin functions
   80 UCB0CTL1 C! ;             \ release reset


CODE >SPI ( char1 -- char2 )
   T UCB0TXBUF & MOV.B
   BEGIN   UCB0RXIFG # IFG2 & BIT.B   0= NOT UNTIL
   UCB0RXBUF & T MOV.B   RET   END-CODE

DECIMAL
