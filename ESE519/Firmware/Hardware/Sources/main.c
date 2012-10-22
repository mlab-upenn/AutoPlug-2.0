#include <hidef.h>      /* common defines and macros */
#include <MC9S12C128.h>     /* derivative information */
#include <string.h>
#include "PWM.h"
#include "ADC.h"
#include "common.h"
#include "CAN.h"
#include "SCI.h"
#include "types.h"
#pragma LINK_INFO DERIVATIVE "mc9s12c128"


CarParams carParams;
CarInputs carInputs; 

volatile UINT8 carParamsUpdated = 0;
volatile UINT8 carInputsUpdated = 0;

void init(void);

#pragma CODE_SEG __NEAR_SEG NON_BANKED

interrupt 20 void SCIRx_vect(void)
{
    UINT8 status, dummy;
    static UINT8 serialRxState = 0;
    UINT8 serialData;
    static UINT8 serialDataLength = 0;
    static UINT8 serialRxChksum = 0;
    static UINT8 *rxPtr;

    status = SCISR1;

    if(SCISR1_RDRF == 0)  /* No data */
        return;

    /* Check for Errors (Framing, Noise, Parity) */
    if( (status & 0x07) != 0 )
    {
        dummy = SCIDRL;
        return;
    }

    /* Good Data */
    serialData = SCIDRL; /* load SCI register to data */
    SCIDataFlag = 1;

    switch(serialRxState)
    {
        case 0:
            if(serialData == 0xAA)
            {
                serialRxChksum = 0xAA;
                serialRxState = 1;
            }
            break;

        case 1:
            if(serialData == 0xCC)
            {
                serialDataLength = 8;
                serialRxChksum ^= 0xCC;
                rxPtr = (UINT8*)&carParams;
                serialRxState = 2;
            }
            else
            {
                serialRxState = 0;
            }
            break;

        case 2:
            if(serialDataLength > 0)
            {
                *rxPtr = serialData;
                serialRxChksum ^= serialData;
                rxPtr++;
                serialDataLength--;
            }
            else
            {
                if(serialData == serialRxChksum)
                    carParamsUpdated = 1;
                serialRxState = 0;
            }
            break;
    }
}

interrupt 38 void CANRx_vect(void)
{
    UINT16 identifier;
    UINT8 length;

    identifier = (CANRXIDR0 << 3) + (CANRXIDR1 >> 5);

    length = CANRXDLR & 0x0F;

    if(identifier == CAN_PARAM_MSG_ID)
    {
        if(!carParamsUpdated) // Only update when old values have been used
        {
            if(length > sizeof(CarParams))
                length = sizeof(CarParams);

            memcpy(&carParams, &CANRXDSR0, length);
            carParamsUpdated = 1;
        }
    }
    else if(identifier == CAN_INPUT_MSG_ID)
    {
        if(!carInputsUpdated) // Only update when old values have been used
        {
            if(length > sizeof(BrakeMsg))
                length = sizeof(BrakeMsg);

            memcpy(&carInputs, &CANRXDSR0, length);
            carInputsUpdated = 1;
        }
    }
    CANRFLG_RXF = 1; // Reset the flag
}

#pragma CODE_SEG DEFAULT




void main(void)
{
  UINT8 brakeValue; 
  
  init();
  	
  DDRB = 0xF0;
  
  PWMPER01 = 20000;  
  PWMPER23 =  1000;
  PWME |= 0x0A;    // PWM channel 1 & 2
  
  PWMDTY01 = 950;
  PWMDTY23 = 0;
  
  PORTB = 0x80; // PORTB PIN 7 = 1
  
  EnableInterrupts;
  
  for(;;)
	{
	    if(carInputsUpdated)
	    {  
          brakeValue = carInputs.brake;
          if (brakeValue > 10)
          {
            PORTB = 0x00; // PORTB PIN 7 = 0
          }
          else
          {
            PORTB = 0x80; // PORTB PIN 7 = 1
          }
          
          PWMDTY01 = (((carInputs.steer)*4)+950);
          carInputsUpdated = 0;
	    }
	    
	    if(carParamsUpdated)
	    {
        	if(carParams.wheelSpeedRR < 0)
        	  PWMDTY23 = 0;
        	else 
        	  PWMDTY23 = carParams.wheelSpeedRR*10;
        	carParamsUpdated = 0;
	    }
  } 
}

void init()
{
    SCIInit();
    CANInit();
    //ADCinit();
    PWM_Init();
}
