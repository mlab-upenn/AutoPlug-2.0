/***********************************************************************************
  Filename:     assy_ccmsp4618_cc2420em.h

  Description:  Defines connections between the CCMSP-EM430F2618 and the CC2420EM

***********************************************************************************/

#ifndef ASSY_CCMSP4618_CC2420EM_H
#define ASSY_CCMSP4618_CC2420EM_H

/*************************************************7**********************************
* INCLUDES
*/
#include "msp430x54x.h"
#include "hal_msp430.h"


/***********************************************************************************
* CONSTANTS
*/
// FIFOP MCU connection
#define CC2420_FIFOP_PORT               1
#define CC2420_FIFOP_PIN                6 //MSP430F5438
#define ASSY_EXP4618_CC2420
//#define SECURITY_CCM //fix
/***********************************************************************************
* MACROS
*/

// MCU Pin Access
#ifndef MCU_PIN_DIR_OUT
#define MCU_PIN_DIR_OUT(port,bit)       st( P##port##DIR |= BV(bit); )
#endif
#ifndef MCU_PIN_DIR_IN
#define MCU_PIN_DIR_IN(port,bit)        st( P##port##DIR &= ~BV(bit); )
#endif

// CC2420 I/O Definitions
// Basic I/O pin setup
//#define CC2420_BASIC_IO_DIR_INIT()      st( MCU_PIN_DIR_OUT(1,4); MCU_PIN_DIR_OUT(1,5);\
  //  MCU_PIN_DIR_OUT(4,2);MCU_PIN_DIR_OUT(4,3);MCU_PIN_DIR_OUT(4,5);)
//MSP430F5438
 #define CC2420_BASIC_IO_DIR_INIT()      st( MCU_PIN_DIR_OUT(1,2); MCU_PIN_DIR_OUT(1,4);\
    MCU_PIN_DIR_OUT(3,0);MCU_PIN_DIR_OUT(3,1);MCU_PIN_DIR_OUT(3,3);)



// MCU port control for SPI interface
#define CC2420_DISABLE_SPI_FUNC()       st( P3SEL &= ~(BV(1) | BV(2) | BV(3)); ) //MSP430F5438//st( P4SEL &= ~(BV(3) | BV(4) | BV(5)); ) 
#define CC2420_ENABLE_SPI_FUNC()        st( P3SEL |= BV(1) | BV(2) | BV(3); )  //MSP430F5438 //st( P4SEL |= BV(3) | BV(4) | BV(5); ) 

// Outputs: Power and reset control
#define CC2420_RESET_OPIN(v)            MCU_IO_SET(1,2,v) //MSP430F5438 //MCU_IO_SET(1,4,v)  
#define CC2420_VREG_EN_OPIN(v)          MCU_IO_SET(1,4,v) //MSP430F5438  //MCU_IO_SET(1,5,v)  

// Outputs: SPI interface
#define CC2420_CSN_OPIN(v)              MCU_IO_SET(3,0,v)  //MSP430F5438  //MCU_IO_SET(4,2,v)  
#define CC2420_SCLK_OPIN(v)             MCU_IO_SET(3,3,v)  //MSP430F5438  //MCU_IO_SET(4,5,v)  
#define CC2420_MOSI_OPIN(v)             MCU_IO_SET(3,1,v)  //MSP430F5438  //MCU_IO_SET(4,3,v)  

// Inputs: SPI interface
#define CC2420_MISO_IPIN                MCU_IO_GET(3,2)  //MSP430F5438   //MCU_IO_GET(4,4)   


// Inputs
#define CC2420_FIFO_IPIN                MCU_IO_GET(1,5)   //MSP430F5438//MCU_IO_GET(1,6)  
#define CC2420_FIFOP_IPIN               MCU_IO_GET(1,6) //MSP430F5438//MCU_IO_GET(1,7)  
#define CC2420_CCA_IPIN                 MCU_IO_GET(1,7) //MSP430F5438//MCU_IO_GET(1,2)  
#define CC2420_SFD_IPIN                 MCU_IO_GET(1,3) //MSP430F5438//MCU_IO_GET(1,3)  

// SPI register definitions
#define CC2420_SPI_TX_REG               (UCB0TXBUF)   //MSP430F5438//(U1TXBUF) 
#define CC2420_SPI_RX_REG               (UCB0RXBUF) //MSP430F5438//(U1RXBUF) 
#define CC2420_SPI_RX_IS_READY()        (UCB0IFG&UCRXIFG)  //MSP430F5438//(IFG2 & URXIFG1)
#define CC2420_SPI_RX_NOT_READY()       (UCB0IFG &= ~UCRXIFG)  //MSP430F5438  //(IFG2 &= ~URXIFG1) 
#define CC2420_SPI_TX_IS_READY()        (UCB0IFG & UCTXIFG)   //MSP430F5438//(IFG2 & UTXIFG1) 
#define CC2420_SPI_TX_NOT_READY()       (UCB0IFG &= ~UCTXIFG) //MSP430F5438 //(IFG2 &= ~UTXIFG1) 

// SPI access macros
#define CC2420_SPI_BEGIN()              st( CC2420_CSN_OPIN(0); )
#define CC2420_SPI_TX(x)                st( UCB0IFG &= ~UCRXIFG; UCB0TXBUF= x;)  //MSP430F5438   //st( IFG2 &= ~URXIFG1; U1TXBUF= x;)
#define CC2420_SPI_RX()                 (UCB0RXBUF)  //MSP430F5438  (U1RXBUF)
#define CC2420_SPI_WAIT_RXRDY()         st( while (!CC2420_SPI_RX_IS_READY()); )
#define CC2420_SPI_END()                st( CC2420_CSN_OPIN(1); )

#define SPI_ENABLE()                    CC2420_SPI_BEGIN()    // ENABLE CSn (active low)
#define SPI_DISABLE()	                CC2420_SPI_END()      // DISABLE CSn (active low)

#define	SPI_WAITFOREOTx()	            st( while (!CC2420_SPI_TX_IS_READY()); ) // USART1 Tx buffer ready?
#define	SPI_WAITFOREORx()	            CC2420_SPI_WAIT_RXRDY()  // USART1 Rx buffer ready?

#define ENABLE_GLOBAL_INT()         do { _enable_interrupt(); } while (0)
#define DISABLE_GLOBAL_INT()        do { _disable_interrupt(); } while (0)

// The CC2420 VREGen pin
#define SET_VREG_ACTIVE()               CC2420_VREG_EN_OPIN(1)
#define SET_VREG_INACTIVE()             CC2420_VREG_EN_OPIN(0)

// The CC2420 reset pin
#define SET_RESET_INACTIVE()            CC2420_RESET_OPIN(1)
#define SET_RESET_ACTIVE()              CC2420_RESET_OPIN(0)

#define FASTSPI_READ_FIFO_BYTE(b) \
    do { \
        SPI_ENABLE(); \
        CC2420_SPI_TX(CC2420_RXFIFO | 0x40); \
        CC2420_SPI_WAIT_RXRDY(); \
    CC2420_SPI_RX(); \
        CC2420_SPI_TX(0); \
    CC2420_SPI_WAIT_RXRDY(); \
        b=CC2420_SPI_RX(); \
        SPI_DISABLE(); \
    } while (0); 
    
#define FASTSPI_READ_FIFO_GARBAGE(c) \
    do { \
    	uint8_t spiCnt; \
        SPI_ENABLE(); \
        CC2420_SPI_TX(CC2420_RXFIFO | 0x40); \
        CC2420_SPI_WAIT_RXRDY(); \
    CC2420_SPI_RX(); \
        for (spiCnt = 0; ((spiCnt < (c)) && (CC2420_FIFO_IPIN)); spiCnt++) { \
        	CC2420_SPI_TX(0); \
    CC2420_SPI_WAIT_RXRDY(); \
    CC2420_SPI_RX(); \
       } \
        SPI_DISABLE(); \
    } while (0);
/***********************************************************************************
* GLOBAL VARIABLES
*/


/***********************************************************************************
* PUBLIC FUNCTIONS
*/
void halAssyInit(void);


/***********************************************************************************
  Copyright 2007 Texas Instruments Incorporated. All rights reserved.

  IMPORTANT: Your use of this Software is limited to those specific rights
  granted under the terms of a software license agreement between the user
  who downloaded the software, his/her employer (which must be your employer)
  and Texas Instruments Incorporated (the "License").  You may not use this
  Software unless you agree to abide by the terms of the License. The License
  limits your use, and you acknowledge, that the Software may not be modified,
  copied or distributed unless embedded on a Texas Instruments microcontroller
  or used solely and exclusively in conjunction with a Texas Instruments radio
  frequency transceiver, which is integrated into your product.  Other than for
  the foregoing purpose, you may not use, reproduce, copy, prepare derivative
  works of, modify, distribute, perform, display or sell this Software and/or
  its documentation for any purpose.

  YOU FURTHER ACKNOWLEDGE AND AGREE THAT THE SOFTWARE AND DOCUMENTATION ARE
  PROVIDED “AS IS” WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED,
  INCLUDING WITHOUT LIMITATION, ANY WARRANTY OF MERCHANTABILITY, TITLE,
  NON-INFRINGEMENT AND FITNESS FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL
  TEXAS INSTRUMENTS OR ITS LICENSORS BE LIABLE OR OBLIGATED UNDER CONTRACT,
  NEGLIGENCE, STRICT LIABILITY, CONTRIBUTION, BREACH OF WARRANTY, OR OTHER
  LEGAL EQUITABLE THEORY ANY DIRECT OR INDIRECT DAMAGES OR EXPENSES
  INCLUDING BUT NOT LIMITED TO ANY INCIDENTAL, SPECIAL, INDIRECT, PUNITIVE
  OR CONSEQUENTIAL DAMAGES, LOST PROFITS OR LOST DATA, COST OF PROCUREMENT
  OF SUBSTITUTE GOODS, TECHNOLOGY, SERVICES, OR ANY CLAIMS BY THIRD PARTIES
  (INCLUDING BUT NOT LIMITED TO ANY DEFENSE THEREOF), OR OTHER SIMILAR COSTS.

  Should you have any questions regarding your right to use this Software,
  contact Texas Instruments Incorporated at www.TI.com.
***********************************************************************************/


#endif
