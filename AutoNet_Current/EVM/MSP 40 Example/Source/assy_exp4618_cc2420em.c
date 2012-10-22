/***********************************************************************************
  Filename:     assy_exp4618_cc2420em.c

  Description:  Defines connections between the CCMSP-EM430FG2618 and the CC2420EM

***********************************************************************************/

/***********************************************************************************
* INCLUDES
*/
#include "assy_exp4618_cc2420em.h"


/***********************************************************************************
* GLOBAL VARIABLES
*/

   


/***********************************************************************************
* FUNCTIONS
*/
static void halRadioSpiInit(uint32 divider);
static void halMcuRfInterfaceInit(void);


/***********************************************************************************
* @fn          halRadioSpiInit
*
* @brief       Initalise Radio SPI interface
*
* @param       none
*
* @return      none
*/
static void halRadioSpiInit(uint32 divider)
{
	/*
  U1CTL  = SWRST | MM | SYNC | CHAR;
  U1TCTL = CKPH | STC | SSEL1;
  U1BR0  = 2;
  U1BR1  = 0;
  U1MCTL = 0;
  ME2 |= USPIE1;
  U1CTL &= ~SWRST;
  */
  
  //MSP430F5438
  UCB0CTL1 |= UCSWRST;                      // **Put state machine in reset**
  UCB0CTL0 |= UCMST+UCSYNC+UCCKPH+UCMSB;    // 3-pin, 8-bit SPI master
                                            // Clock polarity high, MSB
  UCB0CTL1 |= UCSSEL_2;                     // SMCLK
  UCB0BR0 = 2;                           // /2
  UCB0BR1 = 0;                              //
  //UCB0MCTL = 0;                             // No modulation
  UCB0CTL1 &= ~UCSWRST;                     // **Initialize USCI state machine**
  //UCB0IE |= UCRXIE; 
  //UCB0IE |= UCRXIE;                        // Enable USCI_A0 RX interrupt
  CC2420_ENABLE_SPI_FUNC(); 
  
}


/***********************************************************************************
* @fn      halMcuRfInterfaceInit
*
* @brief   Initialises SPI interface to CC2520 and configures reset and vreg
*          signals as MCU outputs.
*
* @param   none
*
* @return  none
*/
static void halMcuRfInterfaceInit(void)
{   
    // Initialize the CC2520 interface
    CC2420_SPI_END();
    CC2420_RESET_OPIN(0);
    CC2420_VREG_EN_OPIN(0);
    CC2420_BASIC_IO_DIR_INIT();
}


/***********************************************************************************
* @fn      halAssyInit
*
* @brief   Initialize interfaces between radio and MCU
*
* @param   none
*
* @return  none
*/
void halAssyInit(void)
{
    halRadioSpiInit(0);
    halMcuRfInterfaceInit();
}

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
