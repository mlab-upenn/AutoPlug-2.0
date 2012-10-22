/* MATLAB - CAN gateway
 *
 * Receives driver inputs from MATLAB and sends them on the CAN bus
 * Receives car parameters from the CAN bus and sends them to MATLAB
 */

#include <hidef.h>      /* common defines and macros */
#include <MC9S12C128.h>     /* derivative information */
#pragma LINK_INFO DERIVATIVE "mc9s12c128"
#include <string.h>
#include "common.h"
#include "CAN.h"
#include "SCI.h"
#include "types.h"
#include "PLL.h"

CarInputs carInputs;
//CarParams carParams;
UINT8 serialRxBuffer[sizeof(CarInputs)];
volatile UINT8 carInputsUpdated = 0;
volatile UINT8 carParamsUpdated = 0;
volatile UINT8 brakeParamsUpdated = 0;

//BrakeMsg Brakeparams;
  
typedef struct _Allparams{
        CarParams carParams;
        BrakeMsg Brakeparams;
}Allparams;
        
 volatile Allparams params; 


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
            if(serialData == 0xCC && serialRxState == 1)
            {
                serialDataLength = sizeof(CarInputs);
                serialRxChksum ^= 0xCC;
                rxPtr = serialRxBuffer;
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
                {
                    if(!carInputsUpdated) // Only update when old value has been used
                    {
                        memcpy(&carInputs, serialRxBuffer, sizeof(CarInputs));
                        carInputsUpdated = 1;
                    }
                }
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

    if(identifier == CAN_INPUT_MSG_ID)
    {
        if(!carInputsUpdated) // Only update when old value has been used
        {
            if(length > sizeof(CarInputs))
                length = sizeof(CarInputs);

            memcpy(&carInputs, &CANRXDSR0, length);
            carInputsUpdated = 1;
        }
    }
    else if(identifier == CAN_PARAM_MSG_ID)
    {
        if(!carParamsUpdated) // Only update when old values have been used
        {
            if(length > sizeof(CarParams))
                length = sizeof(CarParams);

            memcpy(&(params.carParams), &CANRXDSR0, length);
            carParamsUpdated = 1;
        }
    }
    else if(identifier == CAN_BRAKE_MSG_ID)
    {
        //if(!brakeParamsUpdated) // Only update when old values have been used
        {
            if(length > sizeof(BrakeMsg))
                length = sizeof(BrakeMsg);

            memcpy(&(params.Brakeparams), &CANRXDSR0, length);
            brakeParamsUpdated = 1;
        }
    }
    CANRFLG_RXF = 1; // Reset the flag
}

#pragma CODE_SEG DEFAULT


void main(void)
{
    UINT16 i;
    
    
    init();
     setclk24();    // set Eclock to 24 MHZ

    EnableInterrupts;

    for(;;)
    {
        if(carInputsUpdated)
        {
            CANTx(CAN_INPUT_MSG_ID, &carInputs, sizeof(CarInputs));
            carInputsUpdated = 0;
        }

        if(brakeParamsUpdated)
        {
            SCITxPkt(&params, sizeof(Allparams));
            carParamsUpdated = 0;
            brakeParamsUpdated = 0;
            //for(i = 0; i < 1000; i++);
        }
    }
}

void init()
{
    setclk24();    // set Eclock to 24 MHZ
    SCIInit();
    CANInit();
}
