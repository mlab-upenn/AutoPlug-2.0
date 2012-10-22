#include <hidef.h>      /* common defines and macros */
#include <MC9S12C128.h>     /* derivative information */
#pragma LINK_INFO DERIVATIVE "mc9s12c128"
#include "nrk_task.h"
#include "nrk_time.h"
#include "nrk_cfg.h"
#include "nrk_error.h"
#include "nrk_events.h"
#include "common.h"
#include "CAN.h"
#include "PLL.h"
#include "types.h"


#define KP_NUM (5)
#define KP_DEN (1)
#define KI_NUM (1)
#define KI_DEN (20)

int8_t can_rx_pkt_signal;
int8_t can_wait_until_rx_pkt ();

typedef struct _Car
{
    float gearRatio[8];
    float enginerpmRedLine; /* rad/s */
    float SHIFT; /* = 0.95 (% of rpmredline) */
    UINT16 SHIFT_MARGIN;
    float wheelRadius[4];
} Car;

CarInputs carInputs;   //accel | brake | steer | gear | clutch | controls
CarParams carParams;   //speed | engineRPM | wheel speed (FL,FR,RL,RR) | yaw rate

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
    


typedef unsigned char		uint8_t;
typedef unsigned int		uint16_t;
typedef int					int16_t;
typedef uint16_t NRK_STK;

NRK_STK Stack1[NRK_APP_STACKSIZE];
nrk_task_type TaskOne;
void Task1(void);

//NRK_STK Stack2[NRK_APP_STACKSIZE];
//nrk_task_type TaskTwo;
//void Task2 (void);

void nrk_create_taskset();
void init();
INT8 getGear(INT8 currentGear);


void main(void) {
  /* put your own code here */
  //EnableInterrupts;
      nrk_init();
      init();
      DDRB = 0xFF;  //enable portB
    //PORTB = 0x00;
      nrk_create_taskset ();
      nrk_start();
      for(;;) {} /* wait forever */
  /* please make sure that you never leave this function */
}


 void Task1()
{
   //uint16_t cnt=0;
   // DDRB = 0x03;
    INT8 setSpeed = -1;
    INT8 carSpeed = 0;

    INT16 error;
    INT16 errInteg;
    INT16 controlOutput;

    INT8 accel;
    INT8 gear = 0;

    UINT8 cruiseOn = 0;

    AccelMsg accelMsg;
    for(;;)
    {
    nrk_int_enable();
    //_nrk_os_timer_stop();

        if(carParamsUpdated)    //carParamsUpdated = 1 when receive data from simulator
        {
            if(!cruiseOn)
            {
                if(carInputs.gear != -1)
                    gear = (INT8) limit(getGear(gear), 0, 7);
                else
                    gear = -1;           //gear = -1 >> return

                //accelMsg.accel denpends on both data from wiimote and ABC ECU
                accelMsg.accel = (UINT8) limit(carInputs.accel - accelCorrection, 0, 100);
                accelMsg.clutch = carInputs.clutch;
                accelMsg.gear = gear;
            }
            else
            {
                error = (setSpeed - carParams.speed);
                errInteg += error;
                errInteg = limit(errInteg, -100*KI_DEN/KI_NUM, 100*KI_DEN/KI_NUM); 
                
                //intergrate control
                controlOutput = KP_NUM*error/KP_DEN + KI_NUM*errInteg/KI_DEN;
                controlOutput = limit(controlOutput, 0, 100);

                accel = (UINT8) controlOutput;

                gear = (UINT8) limit(getGear(gear), 0, 7);

                accelMsg.accel = (UINT8)limit(accel - accelCorrection, 0, 100) ;
                accelMsg.gear = gear;
                accelMsg.clutch = 0;
            }
            CANTx(CAN_ACCEL_MSG_ID, &accelMsg, sizeof(AccelMsg)); //send acceleration messages
            
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
                    //PORTB = 0x70;
                }
            }
            else
            {
                cruiseOn = 0;
                setSpeed = -1;
                //PORTB = 0xF0;
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
        //can_wait_until_rx_pkt ();
        nrk_wait_until_next_period();
        
    }
    
  /***** this part is just used for test *******
  while(1) {
                if(cnt % 2)
                PORTB |= 0x01;
                else 
                PORTB &= ~0x01;
	nrk_wait_until_next_period();
	cnt++;
	}
	*********************************************/
	
}


/******* Start Task 2 from here ****************
void Task2()
{
uint16_t cnt=0;
  while(1) {
                
                if(cnt % 2)
                PORTB |= 0x02;
                else 
                PORTB &= ~0x02;
                 
                
	nrk_wait_until_next_period();
	cnt++;
	}
}
***********************************************/


void
nrk_create_taskset()
{

  nrk_task_set_entry_function( &TaskOne, (uint32_t)Task1);
  nrk_task_set_stk( &TaskOne, Stack1, NRK_APP_STACKSIZE);
  TaskOne.prio = 1;
  TaskOne.FirstActivation = TRUE;
  TaskOne.Type = BASIC_TASK;
  TaskOne.SchType = PREEMPTIVE;
  TaskOne.period.secs = 0;
  TaskOne.period.nano_secs = 2*NANOS_PER_MS;    // 2 ms
  TaskOne.cpu_reserve.secs = 0;
  TaskOne.cpu_reserve.nano_secs = 0*NANOS_PER_MS;
  TaskOne.offset.secs = 0;
  TaskOne.offset.nano_secs= 0;
  nrk_activate_task (&TaskOne);
  
  /*
  nrk_task_set_entry_function( &TaskTwo, (uint32_t)Task2);
  nrk_task_set_stk( &TaskTwo, Stack2, NRK_APP_STACKSIZE);
  TaskTwo.prio = 2;
  TaskTwo.FirstActivation = TRUE;
  TaskTwo.Type = BASIC_TASK;
  TaskTwo.SchType = PREEMPTIVE;
  TaskTwo.period.secs = 0;
  TaskTwo.period.nano_secs = 500*NANOS_PER_MS;
  TaskTwo.cpu_reserve.secs = 0;
  TaskTwo.cpu_reserve.nano_secs = 0*NANOS_PER_MS;
  TaskTwo.offset.secs = 0;
  TaskTwo.offset.nano_secs= 0;
  nrk_activate_task (&TaskTwo);
  */
  
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
        return currentGear + 1;               //shift gear
    }
    else
    {
        float gr_down = car.gearRatio[currentGear - 1];
        omega = car.enginerpmRedLine/gr_down;
        if ( (currentGear > 1) && (rearWheelSpeed + car.SHIFT_MARGIN < omega*wr*car.SHIFT) )
            return currentGear - 1;           //shift gear
    }
    return currentGear;
}

void init()
{
    setclk24();    // scale ECLOCK to 24 MHz from 4 MHz OSC
    CANInit();
    can_rx_pkt_signal=nrk_signal_create();
     if(can_rx_pkt_signal==NRK_ERROR)
	{
//	nrk_kprintf(PSTR("RT-Link ERROR: creating rx signal failed\r\n"));
	//nrk_kernel_error_add(NRK_SIGNAL_CREATE_ERROR,nrk_cur_task_TCB->task_ID);
	//return NRK_ERROR;
	}

}

#pragma CODE_SEG __NEAR_SEG NON_BANKED

interrupt 38 void CANRx_vect(void)
{
    UINT16 identifier;
    UINT8 length;
    

    identifier = (CANRXIDR0 << 3) + (CANRXIDR1 >> 5);

    length = CANRXDLR & 0x0F;

    if(identifier == CAN_INPUT_MSG_ID)   //receive messages from wiimote
    {
        if(!carInputsUpdated) // Only update when old value has been used
        {
            if(length > sizeof(CarInputs))
                length = sizeof(CarInputs);

            memcpy(&carInputs, &CANRXDSR0, length);
            carInputsUpdated = 1;
        }
    }
    else if (identifier == CAN_PARAM_MSG_ID)  //receive messages from simulator (TORCS)
    {
    
        if(!carParamsUpdated) // Only update when old value has been used
        {
            if(length > sizeof(CarParams))
                length = sizeof(CarParams);

            memcpy(&carParams, &CANRXDSR0, length);
            carParamsUpdated = 1;
        }
    }
    else if (identifier == CAN_ACCEL_CORR_MSG_ID)  //receive messages from ABS ECU
    {                                              //correct acceleration information
        accelCorrection = CANRXDSR0;
    }

    CANRFLG_RXF = 1; // Reset the flag
   // nrk_event_signal (can_rx_pkt_signal);
}

int8_t can_wait_until_rx_pkt ()
{
    nrk_signal_register(can_rx_pkt_signal);
    //if (rtl_rx_pkt_check() != 0)
    //  return NRK_OK;
      
    nrk_event_wait (SIG(can_rx_pkt_signal));
    return NRK_OK;
}

