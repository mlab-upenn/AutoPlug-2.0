{ =====================================================================
Register and vector equates for MSP430x24x

Copyright 2008 by FORTH, Inc.

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
\ section of the MSP430x24x User's Guide for details about LPM.

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

$0000 EQU IE1       \ SFR interrupt enable1
$01 EQU WDTIE
$02 EQU OFIE
$10 EQU NMIIE
$20 EQU ACCVIE

$0001 EQU IE2       \ SFR interrupt enable2
$01 EQU UCA0RXIE
$02 EQU UCA0TXIE
$04 EQU UCB0RXIE
$08 EQU UCB0TXIE

$0002 EQU IFG1                  \ SFR interrupt flag1
$01 EQU WDTIFG
$02 EQU OFIFG
$04 EQU PORIFG
$08 EQU RSTIFG
$10 EQU NMIIFG

$0003 EQU IFG2                  \ SFR interrupt flag2
$01 EQU UCA0RXIFG
$02 EQU UCA0TXIFG
$04 EQU UCB0RXIFG
$08 EQU UCB0TXIFG


$0055 EQU SVSCTL                \ SVS control register (reset by brownout signal)

\ ***********************************************************
\  WATCHDOG TIMER
\ ***********************************************************

$0120 EQU WDTCTL                \ Watchdog Timer control

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
\  HARDWARE MULTIPLIER
\ ***********************************************************

$013E EQU SUMEXT                \ Hardware Sum extend
$013C EQU RESHI                 \ Multiplier Result high word
$013A EQU RESLO                 \ Result low word
$0138 EQU OP2                   \ Second operand
$0136 EQU MACS                  \ Multiply signed + accumulate\operand1
$0134 EQU MAC                   \ Multiply + accumulate\operand1
$0132 EQU MPYS                  \ Multiply signed\operand1
$0130 EQU MPY                   \ Multiply unsigned\operand1

\ ***********************************************************
\  DIGITAL I\O Port1\2
\ ***********************************************************

$002F EQU P2REN                 \ Port P2 resistor enable
$002E EQU P2SEL                 \ Port P2 selection
$002D EQU P2IE                  \ Port P2 interrupt enable
$002C EQU P2IES                 \ Port P2 interrupt-edge select
$002B EQU P2IFG                 \ Port P2 interrupt flag
$002A EQU P2DIR                 \ Port P2 direction
$0029 EQU P2OUT                 \ Port P2 output
$0028 EQU P2IN                  \ Port P2 input
$0027 EQU P1REN                 \ Port P1 resistor enable
$0026 EQU P1SEL                 \ Port P1 selection
$0025 EQU P1IE                  \ Port P1 interrupt enable
$0024 EQU P1IES                 \ Port P1 interrupt-edge select
$0023 EQU P1IFG                 \ Port P1 interrupt flag
$0022 EQU P1DIR                 \ Port P1 direction
$0021 EQU P1OUT                 \ Port P1 output
$0020 EQU P1IN                  \ Port P1 input

\ ***********************************************************
\  DIGITAL I\O Port3\4
\ ***********************************************************

$0011 EQU P4REN                 \ Port P4 resistor enable
$001F EQU P4SEL                 \ Port P4 selection
$001E EQU P4DIR                 \ Port P4 direction
$001D EQU P4OUT                 \ Port P4 output
$001C EQU P4IN                  \ Port P4 input
$0010 EQU P3REN                 \ Port P3 resistor enable
$001B EQU P3SEL                 \ Port P3 selection
$001A EQU P3DIR                 \ Port P3 direction
$0019 EQU P3OUT                 \ Port P3 output
$0018 EQU P3IN                  \ Port P3 input

\ ***********************************************************
\  DIGITAL I\O Port5\6
\ ***********************************************************

$0013 EQU P6REN                 \ Port P6 resistor enable
$0037 EQU P6SEL                 \ Port P6 selection
$0036 EQU P6DIR                 \ Port P6 direction
$0035 EQU P6OUT                 \ Port P6 output
$0034 EQU P6IN                  \ Port P6 input
$0012 EQU P5REN                 \ Port P5 resistor enable
$0033 EQU P5SEL                 \ Port P5 selection
$0032 EQU P5DIR                 \ Port P5 direction
$0031 EQU P5OUT                 \ Port P5 output
$0030 EQU P5IN                  \ Port P5 input


\ ***********************************************************
\ USCI
\ ***********************************************************

$005D EQU UCA0ABCTL             \ USCI A0 auto baud rate control
$0067 EQU UCA0TXBUF             \ USCI A0 transmit buffer
$0066 EQU UCA0RXBUF             \ USCI A0 receive buffer
$0065 EQU UCA0STAT              \ USCI A0 status
$0064 EQU UCA0MCTL              \ USCI A0 modulation control
$0063 EQU UCA0BR1               \ USCI A0 baud rate control 1
$0062 EQU UCA0BR0               \ USCI A0 baud rate control 0
$0061 EQU UCA0CTL1              \ USCI A0 control 1
$0060 EQU UCA0CTL0              \ USCI A0 control 0
$005F EQU UCA0IRRCTL            \ USCI A0 IrDA receive control
$005E EQU UCA0IRTCLT            \ USCI A0 IrDA \ transmit control
$006F EQU UCB0TXBUF             \ USCI B0 transmit buffer
$006E EQU UCB0RXBUF             \ USCI B0 receive buffer
$006D EQU UCB0STAT              \ USCI B0 status
$006C EQU UCB0CIE               \ USCI B0 I2C Interrupt enable
$006B EQU UCB0BR1               \ USCI B0 baud rate control 1
$006A EQU UCB0BR0               \ USCI B0 baud rate control 0
$0069 EQU UCB0CTL1              \ USCI B0 control 1
$0068 EQU UCB0CTL0              \ USCI B0 control \ 0
$011A EQU UCB0SA                \ USCI B0 I2C slave address
$0118 EQU UCB0OA                \ USCI B0 I2C own address
$00CD EQU UCA1ABCTL             \ USCI A1 auto baud rate control
$00D7 EQU UCA1TXBUF             \ USCI A1 transmit buffer
$00D6 EQU UCA1RXBUF             \ USCI A1 receive buffer
$00D5 EQU UCA1STAT              \ USCI A1 status
$00D4 EQU UCA1MCTL              \ USCI A1 modulation control
$00D3 EQU UCA1BR1               \ USCI A1 baud rate control 1
$00D2 EQU UCA1BR0               \ USCI A1 baud rate control 0
$00D1 EQU UCA1CTL1              \ USCI A1 control 1
$00D0 EQU UCA1CTL0              \ USCI A1 control 0
$00CF EQU UCA1IRRCTL            \ USCI A1 IrDA receive control
$00CE EQU UCA1IRTCLT            \ USCI A1 IrDA \ transmit control
$00DF EQU UCB1TXBUF             \ USCI B1 transmit buffer
$00DE EQU UCB1RXBUF             \ USCI B1 receive buffer
$00DD EQU UCB1STAT              \ USCI B1 status
$00DC EQU UCB1CIE               \ USCI B1 I2C Interrupt enable
$00DB EQU UCB1BR1               \ USCI B1 baud rate control 1
$00DA EQU UCB1BR0               \ USCI B1 baud rate control 0
$00D9 EQU UCB1CTL1              \ USCI B1 control 1
$00D8 EQU UCB1CTL0              \ USCI B1 control 0
$017E EQU UCB1SA                \ USCI B1 I2C slave address
$017C EQU UCB1OA                \ USCI B1 I2C own address
$0006 EQU UC1IE                 \ USCI A1\B1 interrupt enable
$0007 EQU UC1IFG                \ USCI A1\B1 interrupt flag


\ ***********************************************************
\  Timer A
\ ***********************************************************

$0176 EQU TACCR2                \ Timer_A3 Capture\compare register 2
$0174 EQU TACCR1                \ Timer_A3 Capture\compare register 1
$0172 EQU TACCR0                \ Timer_A3 Capture\compare register 0
$0170 EQU TAR                   \ Timer_A register

$0166 EQU TACCTL2               \ Capture\compare control 2
$0164 EQU TACCTL1               \ Capture\compare control 1
$0162 EQU TACCTL0               \ Capture\compare control 0
$0160 EQU TACTL                 \ Timer_A control
$012E EQU TAIV                  \ Timer_A interrupt vector

\ Alternate register names - compatibility

TACCTL0 EQU CCTL0
TACCTL1 EQU CCTL1
TACCTL2 EQU CCTL2
TACCR0  EQU CCR0
TACCR1  EQU CCR1
TACCR2  EQU CCR2

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
\  Timer B
\ ***********************************************************

$019E EQU TBCCR6                \ Capture\compare register 6
$019C EQU TBCCR5                \ Capture\compare register 5
$019A EQU TBCCR4                \ Capture\compare register 4
$0198 EQU TBCCR3                \ Capture\compare register 3
$0196 EQU TBCCR2                \ Capture\compare register 2
$0194 EQU TBCCR1                \ Capture\compare register 1
$0192 EQU TBCCR0                \ Capture\compare register 0
$0190 EQU TBR                   \ Timer_B register
$018E EQU TBCCTL6               \ Capture\compare control 6
$018C EQU TBCCTL5               \ Capture\compare control 5
$018A EQU TBCCTL4               \ Capture\compare control 4
$0188 EQU TBCCTL3               \ Capture\compare control 3
$0186 EQU TBCCTL2               \ Capture\compare control 2
$0184 EQU TBCCTL1               \ Capture\compare control 1
$0182 EQU TBCCTL0               \ Capture\compare control 0
$0180 EQU TBCTL                 \ Timer_B control
$011E EQU TBIV                  \ Timer_B interrupt vector

$4000 EQU TBCLGRP1
$2000 EQU TBCLGRP0
$1000 EQU CNTL1
$0800 EQU CNTL0
$0200 EQU TBSSEL1
$0100 EQU TBSSEL0
\ $0080 EQU ID1   same as TA
\ $0040 EQU ID0   same as TA
\ $0020 EQU MC1   same as TA
\ $0010 EQU MC0   same as TA
$0004 EQU TBCLR
$0002 EQU TBIE
$0001 EQU TBIFG

\ $8000 EQU CM1   same as TA
\ $4000 EQU CM0   same as TA
\ $2000 EQU CCIS1   same as TA
\ $1000 EQU CCIS0   same as TA
\ $0800 EQU SCS   same as TA
$0400 EQU CLLD1
$0200 EQU CLLD0
\ $0100 EQU CAP   same as TA
\ $0080 EQU OUTMOD2   same as TA
\ $0040 EQU OUTMOD1   same as TA
\ $0020 EQU OUTMOD0   same as TA
\ $0010 EQU CCIE   same as TA
\ $0008 EQU CCI   same as TA
\ $0004 EQU OUT   same as TA
\ $0002 EQU COV   same as TA
\ $0001 EQU CCIFG  same as TA

\ ***********************************************************
\  Basic Clock Module
\ ***********************************************************

$0053 EQU BCSCTL3               \ Basic Clock Basic clock system control3
$0058 EQU BCSCTL2               \ Basic clock system control2
$0057 EQU BCSCTL1               \ Basic clock system control1
$0056 EQU DCOCTL                \ DCO clock frequency control

\ ************************************************************
\  Flash Memory
\ ************************************************************

$01BE EQU FCTL4                 \ Flash control 4
$012C EQU FCTL3                 \ Flash control 3
$012A EQU FCTL2                 \ Flash control 2
$0128 EQU FCTL1                 \ Flash control 1

$9600 EQU FRKEY
$A500 EQU FWKEY
$3300 EQU FXKEY

$0002 EQU ERAS                  \ Renamed -- conflicts with standard ERASE
$0004 EQU MERAS
$0008 EQU EEI
$0010 EQU EEIEX
$0040 EQU WRT
$0080 EQU BLKWRT

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
$0008 EQU FWAIT                 \ Renamed -- conflicts with Multitasker WAIT
$0010 EQU LOCK
$0020 EQU EMEX
$0040 EQU LOCKA
$0080 EQU FAIL

\ ***********************************************************
\  Comparator A
\ ***********************************************************

$005B EQU CAPD                  \ Comparator_A+ Comparator_A port disable
$005A EQU CACTL2                \ Comparator_A control2
$0059 EQU CACTL1                \ Comparator_A control1

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
$10 EQU P2CA2
$20 EQU P2CA3
$40 EQU P2CA4
$80 EQU CASHORT

$01 EQU CAPD0
$02 EQU CAPD1
$04 EQU CAPD2
$08 EQU CAPD3
$10 EQU CAPD4
$20 EQU CAPD5
$40 EQU CAPD6
$80 EQU CAPD7

\ ***********************************************************
\  ADC12
\ ***********************************************************

$01A8 EQU ADC12IV               \  Interrupt-vector-word register
$01A6 EQU ADC12IE               \ Interrupt-enable register
$01A4 EQU ADC12IFG              \ Interrupt-flag register
$01A2 EQU ADC12CTL1             \ Control register1
$01A0 EQU ADC12CTL0             \ Control register0
$015E EQU ADC12MEM15            \ Conversion memory 15
$015C EQU ADC12MEM14            \ Conversion memory 14
$015A EQU ADC12MEM13            \ Conversion memory 13
$0158 EQU ADC12MEM12            \ Conversion memory 12
$0156 EQU ADC12MEM11            \ Conversion memory 11
$0154 EQU ADC12MEM10            \ Conversion memory 10
$0152 EQU ADC12MEM9             \ Conversion memory 9
$0150 EQU ADC12MEM8             \ Conversion memory 8
$014E EQU ADC12MEM7             \ Conversion memory 7
$014C EQU ADC12MEM6             \ Conversion memory 6
$014A EQU ADC12MEM5             \ Conversion memory 5
$0148 EQU ADC12MEM4             \ Conversion memory 4
$0146 EQU ADC12MEM3             \ Conversion memory 3
$0144 EQU ADC12MEM2             \ Conversion memory 2
$0142 EQU ADC12MEM1             \ Conversion memory 1
$0140 EQU ADC12MEM0             \ Conversion memory 0
$008F EQU ADC12MCTL15           \ ADC memory-control register15
$008E EQU ADC12MCTL14           \ ADC memory-control register14
$008D EQU ADC12MCTL13           \ ADC memory-control register13
$008C EQU ADC12MCTL12           \ ADC memory-control register12
$008B EQU ADC12MCTL11           \ ADC memory-control register11
$008A EQU ADC12MCTL10           \ ADC memory-control register10
$0089 EQU ADC12MCTL9            \ ADC memory-control register9
$0088 EQU ADC12MCTL8            \ ADC memory-control register8
$0087 EQU ADC12MCTL7            \ ADC memory-control register7
$0086 EQU ADC12MCTL6            \ ADC memory-control register6
$0085 EQU ADC12MCTL5            \ ADC memory-control register5
$0084 EQU ADC12MCTL4            \ ADC memory-control register4
$0083 EQU ADC12MCTL3            \ ADC memory-control register3
$0082 EQU ADC12MCTL2            \ ADC memory-control register2
$0081 EQU ADC12MCTL1            \ ADC memory-control register1
$0080 EQU ADC12MCTL0            \ ADC memory-control register0


$0001 EQU ADC12SC
$0002 EQU ENC
$0004 EQU ADC12TOVIE
$0008 EQU ADC12OVIE
$0010 EQU ADC12ON
$0020 EQU REFON
$0040 EQU REF2_5V
$0080 EQU MSC
$0100 EQU SHT00
$0200 EQU SHT01
$0400 EQU SHT02
$0800 EQU SHT03
$1000 EQU SHT10
$2000 EQU SHT11
$4000 EQU SHT12
$8000 EQU SHT13

$0001 EQU ADC12BUSY

$0100 EQU ISSH
$0200 EQU SHP

00 EQU INCH_0
01 EQU INCH_1
02 EQU INCH_2
03 EQU INCH_3
04 EQU INCH_4
05 EQU INCH_5
06 EQU INCH_6
07 EQU INCH_7
08 EQU INCH_8
09 EQU INCH_9
10 EQU INCH_10
11 EQU INCH_11
12 EQU INCH_12
13 EQU INCH_13
14 EQU INCH_14
15 EQU INCH_15

$80 EQU EOS

\ ***********************************************************
\  Interrupt Vectors
\ ***********************************************************

$FFE0 EQU USCI1TX_VECTOR
$FFE2 EQU USCI1RX_VECTOR
$FFE4 EQU PORT1_VECTOR
$FFE6 EQU PORT2_VECTOR
\ $FFE8 EQU Not Used
$FFEA EQU ADC_VECTOR
$FFEC EQU USCI0TX_VECTOR
$FFEE EQU USCI0RX_VECTOR
$FFF0 EQU TIMERA1_VECTOR
$FFF2 EQU TIMERA0_VECTOR
$FFF4 EQU WDT_VECTOR
$FFF6 EQU COMPARATORA_VECTOR
$FFF8 EQU TIMERB1_VECTOR
$FFFA EQU TIMERB0_VECTOR
$FFFC EQU NMI_VECTOR
$FFFE EQU RESET_VECTOR

