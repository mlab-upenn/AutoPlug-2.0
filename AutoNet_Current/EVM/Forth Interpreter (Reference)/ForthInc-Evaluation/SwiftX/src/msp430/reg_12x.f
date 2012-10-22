{ =====================================================================
Register and vector equates for MSP430x12x

Copyright (C) 2002  FORTH, Inc.

Standard register, bit, and interrupt vector definitions for the
Texas Instruments MSP430 microcontroller.

===================================================================== }

ASSEMBLER

\ ***********************************************************
\  STATUS REGISTER BITS
\ ***********************************************************

$0001 CONSTANT C
$0002 CONSTANT Z
$0004 CONSTANT N
$0100 CONSTANT V
$0008 CONSTANT GIE
$0010 CONSTANT CPUOFF
$0020 CONSTANT OSCOFF
$0040 CONSTANT SCG0
$0080 CONSTANT SCG1

\ Low Power Modes coded with Bits 4-7 in SR.  See "OPERATING MODES"
\ section of the MSP430x13x User's Guide for details about LPM.

0                               EQU AM          \ Active Mode
CPUOFF                          EQU LPM0        \ Low Power Mode 0
SCG0 CPUOFF +                   EQU LPM1        \ etc...
SCG1 CPUOFF +                   EQU LPM2
SCG1 SCG0 CPUOFF + +            EQU LPM3
SCG1 SCG0 OSCOFF CPUOFF + + +   EQU LPM4

SCG1 SCG0 OSCOFF CPUOFF + + +   EQU &LPM        \ LPM bit mask

TARGET

\ ***********************************************************
\  SPECIAL FUNCTION REGISTER ADDRESSES + CONTROL BITS
\ ***********************************************************

$0000 EQU IE1
$01 EQU WDTIE
$02 EQU OFIE
$10 EQU NMIIE
$20 EQU ACCVIE

$0002 EQU IFG1
$01 EQU WDTIFG
$02 EQU OFIFG
$10 EQU NMIIFG

$0001 EQU IE2
$01 EQU URXIE0
$02 EQU UTXIE0

$0003 EQU IFG2
$01 EQU URXIFG0
$02 EQU UTXIFG0

$0005 EQU ME2
$01 EQU URXE0
$01 EQU USPIE0
$02 EQU UTXE0

\ ***********************************************************
\  WATCHDOG TIMER
\ ***********************************************************

$0120 EQU WDTCTL

$0001 EQU WDTIS0
$0002 EQU WDTIS1
$0004 EQU WDTSSEL
$0008 EQU WDTCNTCL
$0010 EQU WDTTMSEL
$0020 EQU WDTNMI
$0040 EQU WDTNMIES
$0080 EQU WDTHOLD

$5A00 EQU WDTPW

\ ***********************************************************
\  DIGITAL I/O Port1/2
\ ***********************************************************

$0020 EQU P1IN
$0021 EQU P1OUT
$0022 EQU P1DIR
$0023 EQU P1IFG
$0024 EQU P1IES
$0025 EQU P1IE
$0026 EQU P1SEL

$0028 EQU P2IN
$0029 EQU P2OUT
$002A EQU P2DIR
$002B EQU P2IFG
$002C EQU P2IES
$002D EQU P2IE
$002E EQU P2SEL

\ ***********************************************************
\  DIGITAL I/O Port3
\ ***********************************************************

$0018 EQU P3IN
$0019 EQU P3OUT
$001A EQU P3DIR
$001B EQU P3SEL

\ ***********************************************************
\  USART
\ ***********************************************************

$80 EQU PENA
$40 EQU PEV
$20 EQU SPB
$10 EQU CHARB
$08 EQU LISTEN
$04 EQU SYNC
$02 EQU MM
$01 EQU SWRST

$80 EQU CKPH
$40 EQU CKPL
$20 EQU SSEL1
$10 EQU SSEL0
$08 EQU URXSE
$04 EQU TXWAKE
$02 EQU STC
$01 EQU TXEPT

$80 EQU FE
$40 EQU PE
$20 EQU OE
$10 EQU BRK
$08 EQU URXEIE
$04 EQU URXWIE
$02 EQU RXWAKE
$01 EQU RXERR

\ ***********************************************************
\  USART 0
\ ***********************************************************

$0070 EQU U0CTL
$0071 EQU U0TCTL
$0072 EQU U0RCTL
$0073 EQU U0MCTL
$0074 EQU U0BR0
$0075 EQU U0BR1
$0076 EQU U0RXBUF
$0077 EQU U0TXBUF

\  Alternate register names

$0070 EQU UCTL0
$0071 EQU UTCTL0
$0072 EQU URCTL0
$0073 EQU UMCTL0
$0074 EQU UBR00
$0075 EQU UBR10
$0076 EQU RXBUF0
$0077 EQU TXBUF0

\ ***********************************************************
\  Timer A
\ ***********************************************************

$012E EQU TAIV
$0160 EQU TACTL
$0162 EQU TACCTL0
$0164 EQU TACCTL1
$0166 EQU TACCTL2
$0170 EQU TAR
$0172 EQU TACCR0
$0174 EQU TACCR1
$0176 EQU TACCR2

\  Alternate register names

$0162 EQU CCTL0
$0164 EQU CCTL1
$0166 EQU CCTL2
$0172 EQU CCR0
$0174 EQU CCR1
$0176 EQU CCR2

$0400 EQU TASSEL2
$0200 EQU TASSEL1
$0100 EQU TASSEL0
$0080 EQU ID1
$0040 EQU ID0
$0020 EQU MC1
$0010 EQU MC0
$0004 EQU TACLR
$0002 EQU TAIE
$0001 EQU TAIFG

$8000 EQU CM1
$4000 EQU CM0
$2000 EQU CCIS1
$1000 EQU CCIS0
$0800 EQU SCS
$0400 EQU SCCI
$0100 EQU CAP
$0080 EQU OUTMOD2
$0040 EQU OUTMOD1
$0020 EQU OUTMOD0
$0010 EQU CCIE
$0008 EQU CCI
$0004 EQU OUT
$0002 EQU COV
$0001 EQU CCIFG

\ ***********************************************************
\  Basic Clock Module
\ ***********************************************************

$0056 EQU DCOCTL
$0057 EQU BCSCTL1
$0058 EQU BCSCTL2

$01 EQU MOD0
$02 EQU MOD1
$04 EQU MOD2
$08 EQU MOD3
$10 EQU MOD4
$20 EQU DCO0
$40 EQU DCO1
$80 EQU DCO2

$01 EQU RSEL0
$02 EQU RSEL1
$04 EQU RSEL2
$08 EQU XT5V
$10 EQU DIVA0
$20 EQU DIVA1
$40 EQU XTS
$80 EQU XT2OFF

$01 EQU DCOR
$02 EQU DIVS0
$04 EQU DIVS1
$08 EQU SELS
$10 EQU DIVM0
$20 EQU DIVM1
$40 EQU SELM0
$80 EQU SELM1

\ ***********************************************************
\  Flash Memory
\ ***********************************************************

$0128 EQU FCTL1
$012A EQU FCTL2
$012C EQU FCTL3

$9600 EQU FRKEY
$A500 EQU FWKEY
$3300 EQU FXKEY

$0002 EQU ERAS
$0004 EQU MERAS
$0040 EQU WRT
$0080 EQU SEGWRT

$0001 EQU FN0
$0002 EQU FN1
$0004 EQU FN2
$0008 EQU FN3
$0010 EQU FN4
$0020 EQU FN5
$0040 EQU FSSEL0
$0080 EQU FSSEL1

$0001 EQU BUSY
$0002 EQU KEYV
$0004 EQU ACCVIFG
$0008 EQU FWAIT         \ Renamed -- conflicts with Multitasker WAIT
$0010 EQU LOCK
$0020 EQU EMEX

\ ***********************************************************
\  Comparator A
\ ***********************************************************

$0059 EQU CACTL1
$005A EQU CACTL2
$005B EQU CAPD

$01 EQU CAIFG
$02 EQU CAIE
$04 EQU CAIES
$08 EQU CAON
$10 EQU CAREF0
$20 EQU CAREF1
$40 EQU CARSEL
$80 EQU CAEX

$01 EQU CAOUT
$02 EQU CAF
$04 EQU P2CA0
$08 EQU P2CA1
$10 EQU CACTL24
$20 EQU CACTL25
$40 EQU CACTL26
$80 EQU CACTL27

$01 EQU CAPD0
$02 EQU CAPD1
$04 EQU CAPD2
$08 EQU CAPD3
$10 EQU CAPD4
$20 EQU CAPD5
$40 EQU CAPD6
$80 EQU CAPD7

\ ***********************************************************
\  Interrupt Vectors
\ ***********************************************************

$FFE4 EQU PORT1_VECTOR
$FFE6 EQU PORT2_VECTOR
$FFEC EQU UART0TX_VECTOR
$FFEE EQU UART0RX_VECTOR
$FFF0 EQU TIMERA1_VECTOR
$FFF2 EQU TIMERA0_VECTOR
$FFF4 EQU WDT_VECTOR
$FFF6 EQU COMPARATORA_VECTOR
$FFFC EQU NMI_VECTOR
$FFFE EQU RESET_VECTOR

