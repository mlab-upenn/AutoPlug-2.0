{ =====================================================================
Register and vector equates for MSP430x2132

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
\ section of the MSP430x14x User's Guide for details about LPM.

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
\  HARDWARE MULTIPLIER not available
\ ***********************************************************


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
\  DIGITAL I\O Port3
\ ***********************************************************

$0010 EQU P3REN                 \ Port P3 resistor enable
$001B EQU P3SEL                 \ Port P3 selection
$001A EQU P3DIR                 \ Port P3 direction
$0019 EQU P3OUT                 \ Port P3 output
$0018 EQU P3IN                  \ Port P3 input

\ ***********************************************************
\ USCI
\ ***********************************************************

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
$005D EQU UCA0ABCTL             \ USCI A0 auto baud rate control
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

\ ***********************************************************
\  Timer A0
\ ***********************************************************

$0176 EQU TA0CCR2                \ Timer_A3 Capture\compare register 2
$0174 EQU TA0CCR1                \ Timer_A3 Capture\compare register 1
$0172 EQU TA0CCR0                \ Timer_A3 Capture\compare register 0
$0170 EQU TA0R                   \ Timer_A register

$0166 EQU TA0CCTL2               \ Capture\compare control 2
$0164 EQU TA0CCTL1               \ Capture\compare control 1
$0162 EQU TA0CCTL0               \ Capture\compare control 0
$0160 EQU TA0CTL                 \ Timer_A control
$012E EQU TA0IV                  \ Timer_A interrupt vector

\ Alternate register names - compatibility

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
\  Timer A1
\ ***********************************************************


$0194 EQU TA1CCR1                \ Capture\compare register 1
$0192 EQU TA1CCR0                \ Capture\compare register 0
$0190 EQU TA1R                   \ Timer_A1 register
$0184 EQU TA1CCTL1               \ Capture\compare control 1
$0182 EQU TA1CCTL0               \ Capture\compare control 0
$0180 EQU TA1CTL                 \ Timer_A1 control
$011E EQU TA1IV                  \ Timer_A1 interrupt vector




\ ***********************************************************
\  Basic Clock Module
\ ***********************************************************

$10FE EQU CAL_DCO_1MHZ		  \ Clock Cal value for 1 MHz
$10FF EQU CAL_BC1_1MHZ		  \ Clock Cal Value for 1 MHZ
$10FC EQU CAL_DCO_8MHZ		  \ Clock Cal value for 8 MHz
$10FD EQU CAL_BC1_8MHZ		  \ Clock Cal Value for 8 MHZ


$0053 EQU BCSCTL3               \ Basic clock system control3
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
\  ADC10
\ ***********************************************************

$01BC EQU ADC10SA 		\ ADC data transfer start address
$01B4 EQU ADC10MEM		\ ADC memory
$01B2 EQU ADC10CTL1		\ ADC control register 1
$01B0 EQU ADC10CTL0		\ ADC control register 0
$004A EQU ADC10AE0		\ ADC analog enable 0
$004B EQU ADC10AE1 		\ ADC analog enable 1
$0049 EQU ADC10DTC0		\ ADC data transfer control register 0
$0048 EQU ADC10DTC1		\ ADC data transfer control register 0

\ ***********************************************************
\  Interrupt Vectors
\ ***********************************************************

\ $FFE0 EQU Not Used
\ $FFE2 EQU Not Used
$FFE4 EQU PORT1_VECTOR
$FFE6 EQU PORT2_VECTOR
\ $FFE8 EQU Not Used
$FFEA EQU ADC_VECTOR
$FFEC EQU USCI0TX_VECTOR
$FFEE EQU USCI0RX_VECTOR
$FFF0 EQU TA01_VECTOR
$FFF2 EQU TA00_VECTOR
$FFF4 EQU WDT_VECTOR
$FFF6 EQU COMPARATORA_VECTOR
$FFF8 EQU TA11_VECTOR
$FFFA EQU TA10_VECTOR
$FFFC EQU NMI_VECTOR
$FFFE EQU RESET_VECTOR

