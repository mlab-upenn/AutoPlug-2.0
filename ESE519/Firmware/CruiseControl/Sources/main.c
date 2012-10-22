#include <hidef.h>      /* common defines and macros */
#include <MC9S12C128.h> /* derivative information */
#pragma LINK_INFO DERIVATIVE "mc9s12c128"
#include <string.h>

#include "common.h"
#include "CAN.h"
#include "SCI.h"
#include "types.h"
#include "PLL.h"

#define KP_NUM (5)
#define KP_DEN (1)
#define KI_NUM (1)
#define KI_DEN (20)

typedef struct _Car
{
    float gearRatio[8];
    float enginerpmRedLine; /* rad/s */
    float SHIFT; /* = 0.95 (% of rpmredline) */
    UINT16 SHIFT_MARGIN;
    float wheelRadius[4];
} Car;

CarInputs carInputs;
CarParams carParams;

volatile UINT8 carInputsUpdated = 0;
volatile UINT8 carParamsUpdated = 0;
volatile UINT8 accelCorrection = 0;

const Car car = {
    {0, 3.9*4.5, 2.9*4.5, 2.3*4.5, 1.87*4.5, 1.68*4.5, 1.54*4.5, 1.46*4.5},
    1958.26,
    0.95,
    4,
    {0.3024, 0.3024, 0.3151, 0.3151}
};


void init(void);
INT8 getGear(INT8 currentGear);

void main(void)
{
    INT8 setSpeed = -1;
    INT8 carSpeed = 0;

    INT16 error;
    INT16 errInteg;
    INT16 controlOutput;

    INT8 accel;
    INT8 gear = 0;

    UINT8 cruiseOn = 0;

    AccelMsg accelMsg;

    init();

    DDRB = 0xF0;
    PORTB = 0xF0;

    EnableInterrupts;

    for(;;)
    {
        if(carParamsUpdated)
        {
            if(!cruiseOn)
            {
                if(carInputs.gear != -1)
                    gear = (INT8) limit(getGear(gear), 0, 7);
                else
                    gear = -1;

                accelMsg.accel = (UINT8) limit(carInputs.accel - accelCorrection, 0, 100);
                accelMsg.clutch = carInputs.clutch;
                accelMsg.gear = gear;
            }
            else
            {
                error = (setSpeed - carParams.speed);
                errInteg += error;
                errInteg = limit(errInteg, -100*KI_DEN/KI_NUM, 100*KI_DEN/KI_NUM);

                controlOutput = KP_NUM*error/KP_DEN + KI_NUM*errInteg/KI_DEN;
                controlOutput = limit(controlOutput, 0, 100);

                accel = (UINT8) controlOutput;

                gear = (UINT8) limit(getGear(gear), 0, 7);

                accelMsg.accel = (UINT8)limit(accel - accelCorrection, 0, 100) ;
                accelMsg.gear = gear;
                accelMsg.clutch = 0;
            }
            CANTx(CAN_ACCEL_MSG_ID, &accelMsg, sizeof(AccelMsg));
            carParamsUpdated = 0;
        }
        else if(carInputsUpdated)
        {
            if((carInputs.controls & CRUISE) && (carParams.speed > 0))
            {
                if(!cruiseOn)
                {
                    setSpeed = carParams.speed;
                    cruiseOn = 1;
                    errInteg = 0;
                    PORTB = 0x70;
                }
            }
            else
            {
                cruiseOn = 0;
                setSpeed = -1;
                PORTB = 0xF0;
            }
            if(!cruiseOn)
            {
                if(carInputs.gear != -1)
                    gear = (UINT8)limit(getGear(gear), 0, 7);
                else
                    gear = -1;

                accelMsg.accel = (UINT8)limit(carInputs.accel - accelCorrection, 0, 100);
                accelMsg.clutch = carInputs.clutch;
                accelMsg.gear = gear;
            }
            carInputsUpdated = 0;
        }
    }
}

/* Compute gear */
INT8 getGear(INT8 currentGear)
{
    float gr_up, omega, wr;
    float rearWheelSpeed;

    if (currentGear <= 0)
        return 1;

    //rearWheelSpeed = (carParams.wheelSpeedRL + carParams.wheelSpeedRR)/2;
    rearWheelSpeed = carParams.speed;

    gr_up = car.gearRatio[currentGear];
    omega = car.enginerpmRedLine/gr_up;
    wr = car.wheelRadius[2];

    if (rearWheelSpeed > omega*wr*car.SHIFT)
    {
        return currentGear + 1;
    }
    else
    {
        float gr_down = car.gearRatio[currentGear - 1];
        omega = car.enginerpmRedLine/gr_down;
        if ( (currentGear > 1) && (rearWheelSpeed + car.SHIFT_MARGIN < omega*wr*car.SHIFT) )
            return currentGear - 1;
    }
    return currentGear;
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

            memcpy(&carInputs, &CANRXDSR0, length);
            carInputsUpdated = 1;
        }
    }
    else if (identifier == CAN_PARAM_MSG_ID)
    {
        if(!carParamsUpdated) // Only update when old value has been used
        {
            if(length > sizeof(CarParams))
                length = sizeof(CarParams);

            memcpy(&carParams, &CANRXDSR0, length);
            carParamsUpdated = 1;
        }
    }
    else if (identifier == CAN_ACCEL_CORR_MSG_ID)
    {
        accelCorrection = CANRXDSR0;
    }

    CANRFLG_RXF = 1; // Reset the flag
}

#pragma CODE_SEG DEFAULT


void init()
{
    setclk24();
    CANInit();

}
