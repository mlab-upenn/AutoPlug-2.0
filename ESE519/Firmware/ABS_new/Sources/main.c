#include <hidef.h>      /* common defines and macros */
#include <MC9S12C128.h>     /* derivative information */
#pragma LINK_INFO DERIVATIVE "mc9s12c128"
#include <stdlib.h>
#include <string.h>
#include "common.h"
#include "CAN.h"
#include "types.h"
#include "PLL.h"

#define ABS_KP  20
#define TRAC_KP 20
#define STAB_KP 15

void init(void);
void Abs(void);
void Traction(void);
void stabilityControl(void);

CarParams car;
AccelMsg accel_corr;
volatile UINT8 carParamsUpdated = 0;
volatile UINT8 carInputsUpdated = 0;
BrakeMsg brake_msg = {0,0,0,0};
CarInputs driver_input = {0,0,0,0,0,0};
UINT8 buffer[8]; // recives the CAN DATA
const INT16 abs_threshold = 2;
const INT16 tc_threshold = 2;
const INT16 yawRate_threshold = 10;

void main(void)
{
    EnableInterrupts;

    init();

    for(;;)
    {
        if(carParamsUpdated)
        {
            accel_corr.accel = 0;
            
          
             
             
            if((driver_input.controls & STABILITY) && (abs(car.yawRate) > yawRate_threshold))
            {
                stabilityControl();
                Abs();
            }

            if((driver_input.brake > 0) && (driver_input.controls & ABS))
                Abs();

            if((driver_input.accel > 0) && (driver_input.controls & TRACTION))
                Traction();          

            CANTx(CAN_ACCEL_CORR_MSG_ID,&accel_corr,sizeof(AccelMsg));
            CANTx(CAN_BRAKE_MSG_ID,&brake_msg,sizeof(BrakeMsg));
            carParamsUpdated = 0;
        }
        carInputsUpdated = 0;
    }
}

void init()
{
    setclk24();
    CANInit();
}

void Abs()
{
    INT16 avg_ws;
    //avg_ws = (car.wheelSpeedFL + car.wheelSpeedFR+ car.wheelSpeedRL + car.wheelSpeedRR)/4;
    avg_ws = car.speed;

    if(avg_ws-car.wheelSpeedFL > abs_threshold)
        brake_msg.brakeFL = (UINT8) limit((INT16)brake_msg.brakeFL + (car.wheelSpeedFL - avg_ws) * ABS_KP,0,100);

    if(avg_ws-car.wheelSpeedFR > abs_threshold)
        brake_msg.brakeFR = (UINT8) limit((INT16)brake_msg.brakeFR + (car.wheelSpeedFR - avg_ws) * ABS_KP,0,100);

    if(avg_ws-car.wheelSpeedRL> abs_threshold)
        brake_msg.brakeRL = (UINT8) limit((INT16)brake_msg.brakeRL + (car.wheelSpeedRL - avg_ws) * ABS_KP,0,100);

    if(avg_ws-car.wheelSpeedRR > abs_threshold)
        brake_msg.brakeRR = (UINT8) limit((INT16)brake_msg.brakeRR + (car.wheelSpeedRR - avg_ws) * ABS_KP,0,100);
}

void Traction()
{
    INT16 avg_rws;
    INT16 correction = 0;

    avg_rws = (car.wheelSpeedRL + car.wheelSpeedRR)/2;
    if((avg_rws - car.speed) > tc_threshold)
    {
        correction = (avg_rws - car.speed) * TRAC_KP;
    }
    accel_corr.accel = (UINT8) limit(correction,0,100);
}

void stabilityControl()
{
    INT16 correction;
    correction = limit((abs(car.yawRate) - yawRate_threshold)*STAB_KP, 0, 100);

    if(car.yawRate > 0)
        brake_msg.brakeRR = (UINT8) limit(brake_msg.brakeRR + correction, 0, 100);
    else
        brake_msg.brakeRL = (UINT8) limit(brake_msg.brakeRL + correction, 0, 100);
    
    accel_corr.accel = (UINT8) limit(correction,0,100);
}


#pragma CODE_SEG __NEAR_SEG NON_BANKED

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

            memcpy(&driver_input, &CANRXDSR0, length);

            carInputsUpdated = 1;
        }
    }
    else if (identifier == CAN_PARAM_MSG_ID)
    {
        if(length > sizeof(CarParams))
            length = sizeof(CarParams);

        memcpy(&car, &CANRXDSR0, length);

        carParamsUpdated = 1;
    }

    CANRFLG_RXF = 1; // Reset the flag
}

#pragma CODE_SEG DEFAULT
