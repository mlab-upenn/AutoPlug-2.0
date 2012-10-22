{ =====================================================================
UART terminal tasks

Copyright (C) 2002  FORTH, Inc.

This file supplies the vectored I/O functions for the UART ports
as well as initialization, power management for the UARTS and
high-speed oscillator, and initialization routines.

Usage rules:

1) Be sure your system inialization code configures the required port
pins for their UART functions.  The pin assignments vary among the
many MSP430 variants, so this can't be done here in the /UART
functions.

2) Call /UARTS in your initialization procedure

3) Assign port and vectors to task by calling UART0 or UART1 from
the task's start-up code

The following parameters must be supplied by CONFIG.F:

ACLK    The CPU ACLK frequency (usually the crystal 1 frequency)
MCLK    The CPU MCLK frequency (usually the crystal 2 frequency);
        only required if ACLK <> BCLK.
BCLK    The UART baud rate clock (either ACLK or MCLK)
U0BAUD  UART 0 baud rate (if UART 0 is to be used)
U1BAUD  UART 1 baud rate (if UART 1 is to be used)

Support code for UARTx is only compiled if the appropriate UxBAUD is
defined when this file is loaded.

Any task using the queued UART input routines must have its DEVICE
user variable pointing to the queue from which characters are to be
received (e.g. RQ0 or RQ1).
===================================================================== }

TARGET

{ ---------------------------------------------------------------------
Port settings and control

>BR converts baud rate u1 to the parameters for setting the UART:
   u2 = divisor low byte
   u3 = divisor high byte
   u4 = modulation control

/UART0 and /UART1 initialize the UART ports.  The TX and RX pins must
be set for correct operation for this MCU.  Various members of the
MSP430 family have I/O pins assigned differently.  If any of the PxSEL
or PxDIR bits need to be set, you must do this before attempting to use
the corresponding UART port.
--------------------------------------------------------------------- }

INTERPRETER

: >BR ( u1 -- u2 u3 u4 )
   >R  BCLK R@ /MOD  SWAP >R  0 1 R> R> M*/ 2DUP 0
   8 0 DO  >R  DUP >R  2OVER D+  DUP R> <>  R>
   SWAP 1 I LSHIFT AND OR  LOOP  >R 2DROP 2DROP
   256 /MOD  R> ;

TARGET

BCLK ACLK = [IF]  $19 EQU K(TCTL)  [ELSE]
BCLK MCLK = [IF]  $29 EQU K(TCTL)  [THEN] [THEN]

[DEFINED] U0BAUD [IF]

U0BAUD >BR ( l h m )                    \ Calculate baud rate constants

CODE /UART0 ( -- )
   URXE0 UTXE0 + # ME1 & BIS.B          \ Turn on UART modules
   $11 # U0CTL & MOV.B
   K(TCTL) # U0TCTL & MOV.B
   $08 # U0RCTL & MOV.B                 \ Interrupt on Rx error
   ( m) # U0MCTL & MOV.B
   ( h) # U0BR1 & MOV.B
   ( l) # U0BR0 & MOV.B
   1 # U0CTL & BIC.B                    \ Clear SWRST bit
   URXIE0 # IE1 & BIS.B                 \ Enable interrupt
   RET   END-CODE

[THEN]


[DEFINED] U1BAUD [IF]

U1BAUD >BR ( l h m )

CODE /UART1 ( -- )
   URXE1 UTXE1 + # ME2 & BIS.B          \ Turn on UART modules
   $11 # U1CTL & MOV.B
   K(TCTL) # U1TCTL & MOV.B
   $08 # U1RCTL & MOV.B                 \ Interrupt on Rx error
   ( m) # U1MCTL & MOV.B
   ( h) # U1BR1 & MOV.B
   ( l) # U1BR0 & MOV.B
   1 # U1CTL & BIC.B                    \ Clear SWRST bit
   URXIE1 # IE2 & BIS.B                 \ Enable interrupt
   RET   END-CODE

[THEN]

{ ---------------------------------------------------------------------
Polled output

These are the vectored EMIT and TYPE functions for polled UART output.
Note that we PAUSE until the character clears the transmitter buffer
after we write the character so we know it's safe to enter LPM.
--------------------------------------------------------------------- }

[DEFINED] U0BAUD [IF]

: (U0-EMIT) ( char -- )   U0TXBUF C!
   BEGIN  PAUSE  U0TCTL C@  1 AND UNTIL ;

: (U0-TYPE) ( addr u -- )
   0 DO  COUNT (U0-EMIT)  LOOP DROP ;

[THEN]

[DEFINED] U1BAUD [IF]

: (U1-EMIT) ( char -- )   U1TXBUF C!
   BEGIN  PAUSE  U1TCTL C@  1 AND UNTIL ;

: (U1-TYPE) ( addr u -- )
   0 DO  COUNT (U1-EMIT)  LOOP DROP ;

[THEN]

{ --------------------------------------------------------------------
Queue structure

RQ: defines the offsets into the receive data queue structure.
The target run-time code returns the address in the queue whose
address is in user variable DEVICE.

RTASK, RIN, ROUT, and RDATA are offsets in the receive queue structure.
The RIN and ROUT indexes are masked with the queue size -1.
Therefore, the queue size, |RDATA|, must be a power of 2.  This is
checked for at compile-time.

|RDATA| defaults to 32.  This may be overridden by defining |RDATA|
in Config.f for your project, but the value MUST be a power of 2.
This restriction is checked at compile-time below.

NOTASK is a dummy location to put in RTASK when no task is waiting
on the queue.

/RQ initializes the port's receive queue.
-------------------------------------------------------------------- }

[UNDEFINED] |RDATA| [IF]  32 EQU |RDATA|  [THEN]
|RDATA| 1- EQU &RDATA

|RDATA| &RDATA AND 0<>
-24 AND HOST THROW  TARGET    \ |RDATA| must be a power of 2

INTERPRETER

: RQ: ( u1 u2 -- u2 )   OVER TWIN  CREATE  OVER , +
   DOES>  @  DEVICE @ + ;

TARGET  SAVE-SECTIONS  CDATA

0  CELL RQ: RIN          \ Circular Receive queue input index
   CELL RQ: ROUT         \ Receive queue output index (must follow RIN for KEY?)
   CELL RQ: RTASK        \ Address of task awaiting input
|RDATA| RQ: RDATA        \ Receive queue data offset

EQU |RQ|           \ Total size of queue structure

RESTORE-SECTIONS

VARIABLE NOTASK

: /RQ ( -- )   0 RIN !  0 ROUT !  NOTASK RTASK ! ;

{ ---------------------------------------------------------------------
Queued serial input

(RQ-KEY?) is the vectored KEY? behavior for queued serial input.
It returns true if there's something in the input queue.

(RQ-KEY) is the vectored KEY behavior for queued serial input.  If the
input queue is empty, it suspends the task until awakened by the interrupt
handler.  Returns next character from the queue.  The PAUSE at the end
is critical to prevent a race condition with the interrupt handler.
This ensures that the task is not marked as awake for the chacter
we've already removed from the queue.
--------------------------------------------------------------------- }

: (RQ-KEY?) ( -- flag )   PAUSE  RIN 2@ <> ;

: (RQ-KEY) ( -- char )
   STATUS RTASK !  RIN 2@ = IF  STOP  THEN
   RDATA ROUT @ &RDATA AND + C@  1 ROUT +!
   NOTASK RTASK !  PAUSE ;

{ ---------------------------------------------------------------------
Queued input interrupts

<URX0> and <URX1> are the receive interrupt handlers.  There are two
possible conditions that vector to these interrupts:

   1) The leading edge of a start bit (with URXSE set).  Enable MCLK
   by clearing all but the CPUOFF bits in the LPM bits in the SR in the
   interrupt stack frame and turn off the URXSE bit to allow the character
   to be received when it's ready.

   2) A new character has been received.  Put it in the queue, awaken any
   waiting task, and turn URXSE back on for next time.

<URX> is the common code for enqueuing a character and awakening
the appropriate task.
--------------------------------------------------------------------- }

LABEL <URX>
   RIN (R9) R10 MOV   &RDATA # R10 AND          \ Calculate RIN offset
   R9 R10 ADD   R8 RDATA (R10) MOV.B            \ Put at at RIN offset into RDATA
   RIN (R9) INC   RTASK (R9) R10 MOV            \ Increment RIN, get RTASK pointer
   WAKE # 0 (R10) MOV   NOTASK # RTASK (R9) MOV \ Awaken task, point RTASK to dummy
   R10 POP   R9 POP   R8 POP                    \ Restore saved registers
   &LPM # 0 (R) BIC   RETI   END-CODE           \ Return to Active Mode

[DEFINED] U0BAUD [IF]

|RQ| BUFFER: RQ0        \ Input queue for UART0

LABEL <URX0>
   URXIFG0 # IFG1 & BIT.B  0= NOT IF            \ Test RXIFG: 1=char or error, 0=start edge
      RXERR # U0RCTL & BIT.B   0= NOT IF        \ Test RXERR: 1=error, 0=char
      U0RXBUF & TST.B   RETI   THEN             \ On error, read and discard char
      R8 PUSH   R9 PUSH   R10 PUSH              \ If set, either Rx char or error
      U0RXBUF & R8 MOV.B   RQ0 # R9 MOV         \ Read char from buffer
   <URX> JMP   THEN                             \ Put in queue
   BCLK MCLK = [IF]   SCG1 # 0 (R) BIC   [THEN] \ Turn on SMCLK if it's the clk src
   URXSE # U0TCTL & BIC.B                       \ Toggle receive-start edge interrupt enable
   URXSE # U0TCTL & BIS.B
   RETI   END-CODE

[THEN]

[DEFINED] U1BAUD [IF]

|RQ| BUFFER: RQ1        \ Input queue for UART1

LABEL <URX1>
   URXIFG1 # IFG2 & BIT.B  0= NOT IF            \ Test RXIFG: 1=char or error, 0=start edge
      RXERR # U1RCTL & BIT.B   0= NOT IF        \ Test RXERR: 1=error, 0=char
      U1RXBUF & TST.B   RETI   THEN             \ On error, read and discard char
      R8 PUSH   R9 PUSH   R10 PUSH              \ If set, either Rx char or error
      U1RXBUF & R8 MOV.B   RQ1 # R9 MOV         \ Read char from buffer
   <URX> JMP   THEN                             \ Put in queue
   BCLK MCLK = [IF]   SCG1 # 0 (R) BIC   [THEN] \ Turn on SMCLK if it's the clk src
   URXSE # U1TCTL & BIC.B                       \ Toggle receive-start edge interrupt enable
   URXSE # U1TCTL & BIS.B
   RETI   END-CODE

[THEN]

{ ---------------------------------------------------------------------
Initialization

UART0 and UART1 set the calling tasks terminal I/O vectors to use
the corresponding UART.

/UARTS initializes the input queues, interrupt vectors, and UARTS.
--------------------------------------------------------------------- }

: UART-TERMINAL ( -- )
   ['] (RQ-KEY?) 'KEY? !  ['] (RQ-KEY) 'KEY !
   ['] (ACCEPT) 'ACCEPT !  ['] (STRAIGHT) 'STRAIGHT ! ;

[DEFINED] U0BAUD [IF]

: UART0 ( -- )
   ['] (U0-EMIT) 'EMIT !  ['] (U0-TYPE) 'TYPE !  RQ0 DEVICE !
   UART-TERMINAL ;

[THEN]

[DEFINED] U1BAUD [IF]

: UART1 ( -- )
   ['] (U1-EMIT) 'EMIT !  ['] (U1-TYPE) 'TYPE !  RQ1 DEVICE !
   UART-TERMINAL ;

[THEN]

: /UARTS ( -- )
   [DEFINED] U0BAUD [IF]  RQ0 DEVICE !  /RQ  <URX0> UART0RX_VECTOR INTERRUPT  /UART0  [THEN]
   [DEFINED] U1BAUD [IF]  RQ1 DEVICE !  /RQ  <URX1> UART1RX_VECTOR INTERRUPT  /UART1  [THEN] ;
