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
#include "types.h"


#define ABS_KP  20
#define TRAC_KP 20
#define STAB_KP 15

void init(void);
void Abs(void);
void Traction(void);
void stabilityControl(void);

CarParams car;        //speed | engineRPM | wheel speed (FL,FR,RL,RR) | yaw rate
AccelMsg accel_corr;  //accel | clutch | gear
volatile UINT8 carParamsUpdated = 0;
volatile UINT8 carInputsUpdated = 0;
BrakeMsg brake_msg = {0,0,0,0};          //brake FL | FR | RL | RR
CarInputs driver_input = {0,0,0,0,0,0};  //accel | brake | steer | gear | clutch | controls
UINT8 buffer[8]; // recives the CAN DATA
const INT16 abs_threshold = 2;
const INT16 tc_threshold = 2;
const INT16 yawRate_threshold = 10;

int8_t can_rx_pkt_signal;
int8_t can_wait_until_rx_pkt ();


typedef unsigned char		uint8_t;
typedef unsigned int		uint16_t;
typedef int					int16_t;
typedef uint16_t NRK_STK;

NRK_STK Stack1[NRK_APP_STACKSIZE];
nrk_task_type TaskOne;
void Task1(void);

NRK_STK Stack3[NRK_APP_STACKSIZE];
nrk_task_type SuperTask;
void Task3(void);

void nrk_create_taskset();
void init();

uint16_t cnt=0;
       
void main(void) {
  /* put your own code here */
  //EnableInterrupts;
      nrk_init();
      init();
      
      nrk_create_taskset ();
      DDRB = 0xF0;    //enable portB
      PORTB = 0x00;
      nrk_start();
      for(;;) {} /* wait forever */
  /* please make sure that you never leave this function */
}

 void Task1()
{  
  int16_t i,j;
  //DDRB = 0xFF;
  for(;;)
    {
    
        PORTB = 0xF0;
        
        for (i=0; i< 100; i++){
          for (j=0; j < 100; j++){
              //PORTB = 0x00;
          }
        }
           
    
    
        /*if(carParamsUpdated)     //carParamsUpdated = 1 when simulator (TORCS) sends data
        {
            accel_corr.accel = 0;

            brake_msg.brakeFL = driver_input.brake;
            brake_msg.brakeFR = driver_input.brake;
            brake_msg.brakeRL = driver_input.brake;
            brake_msg.brakeRR = driver_input.brake;
            
            
            //perform Stability Control if yawrate is larget than threshold 
            if((driver_input.controls & STABILITY) && (abs(car.yawRate) > yawRate_threshold)) 
            {
                stabilityControl();
                Abs();
            }
            
            //perform ABS Control
            if((driver_input.brake > 0) && (driver_input.controls & ABS))
                Abs();
            
            //perform Traction Control
            if((driver_input.accel > 0) && (driver_input.controls & TRACTION))
                Traction();
            
            
            CANTx(CAN_ACCEL_CORR_MSG_ID,&accel_corr,sizeof(AccelMsg)); //send acceleration correction information via CAN bus
            CANTx(CAN_BRAKE_MSG_ID,&brake_msg,sizeof(BrakeMsg));       //send brake information via CAN bus
            carParamsUpdated = 0;
        }
        carInputsUpdated = 0;   */
    
      //can_wait_until_rx_pkt ();
      cnt++;
      //if ((cnt == 20000)||(cnt == 40001)){
      if (cnt > 200){
        
        nrk_terminate_task(&TaskOne);
        
      }
      else{      
        
      nrk_wait_until_next_period();
      }
    }
 
 
 /****** this part is just used for test ******
 
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


/****** Start Task 2 from here ****************/

void Task3()
{ 
  uint16_t i,j;
  
  while(1) {
                
  if (cnt == 100){
 
  nrk_task_set_entry_function( &TaskOne, (uint32_t)Task1);
  nrk_task_set_stk( &TaskOne, Stack1, NRK_APP_STACKSIZE);
  TaskOne.prio = 1;
  TaskOne.FirstActivation = TRUE;
  TaskOne.Type = BASIC_TASK;
  TaskOne.SchType = PREEMPTIVE;
  TaskOne.period.secs = 0;
  TaskOne.period.nano_secs = 200*NANOS_PER_MS;
  TaskOne.cpu_reserve.secs = 0;
  TaskOne.cpu_reserve.nano_secs = 0*NANOS_PER_MS;
  TaskOne.offset.secs = 0;
  TaskOne.offset.nano_secs= 0;
  nrk_activate_task (&TaskOne);  
  //k = 1;
  }
  
  //PORTB = 0xF0;
  for (i=0; i< 100; i++){
          for (j=0; j < 100; j++){
            /*if (k == 1){
              PORTB = 0x00;
            }else{
              
            PORTB = 0xF0;
            } */
          }
        }
  cnt++;              
	nrk_wait_until_next_period();
	
	}
}

  /*********************************************/
  
  
  
  
void
nrk_create_taskset()
{
  /*
  nrk_task_set_entry_function( &TaskOne, (uint32_t)Task1);
  nrk_task_set_stk( &TaskOne, Stack1, NRK_APP_STACKSIZE);
  TaskOne.prio = 1;
  TaskOne.FirstActivation = TRUE;
  TaskOne.Type = BASIC_TASK;
  TaskOne.SchType = PREEMPTIVE;
  TaskOne.period.secs = 0;
  TaskOne.period.nano_secs = 200*NANOS_PER_MS;
  TaskOne.cpu_reserve.secs = 0;
  TaskOne.cpu_reserve.nano_secs = 0*NANOS_PER_MS;
  TaskOne.offset.secs = 0;
  TaskOne.offset.nano_secs= 0;
  nrk_activate_task (&TaskOne);
                                */
  
  
  nrk_task_set_entry_function( &SuperTask, (uint32_t)Task3);
  nrk_task_set_stk( &SuperTask, Stack3, NRK_APP_STACKSIZE);
  SuperTask.prio = 10;
  SuperTask.FirstActivation = TRUE;
  SuperTask.Type = BASIC_TASK;
  SuperTask.SchType = PREEMPTIVE;
  SuperTask.period.secs = 0;
  SuperTask.period.nano_secs = 200*NANOS_PER_MS;
  SuperTask.cpu_reserve.secs = 0;
  SuperTask.cpu_reserve.nano_secs = 0*NANOS_PER_MS;
  SuperTask.offset.secs = 0;
  SuperTask.offset.nano_secs= 0;
  nrk_activate_task (&SuperTask);
  
  
}




void init()
{
    setclk24();  // scale ECLOCK to 24 MHz from 4 MHz OSC
    CANInit();
    can_rx_pkt_signal=nrk_signal_create();
     if(can_rx_pkt_signal==NRK_ERROR)
	{
  //nrk_kprintf(PSTR("RT-Link ERROR: creating rx signal failed\r\n"));
	//nrk_kernel_error_add(NRK_SIGNAL_CREATE_ERROR,nrk_cur_task_TCB->task_ID);
	//return NRK_ERROR;
	}

}



#pragma CODE_SEG __NEAR_SEG NON_BANKED

interrupt 38 void CANRx_vect(void)      //receive data from wiimote & simulator (TORCS) via CAN bus
{
    UINT16 identifier;
    UINT8 length;

    identifier = (CANRXIDR0 << 3) + (CANRXIDR1 >> 5);

    length = CANRXDLR & 0x0F;

    if(identifier == CAN_INPUT_MSG_ID)         //data sent by wiimote
    {
        if(!carInputsUpdated) // Only update when old value has been used
        {
            if(length > sizeof(CarInputs))
                length = sizeof(CarInputs);

            memcpy(&driver_input, &CANRXDSR0, length);

            carInputsUpdated = 1;
        }
    }
    else if (identifier == CAN_PARAM_MSG_ID)   //data sent by simulator (TORCS)
    {
        if(length > sizeof(CarParams))
            length = sizeof(CarParams);

        memcpy(&car, &CANRXDSR0, length);

        carParamsUpdated = 1;
    }

    CANRFLG_RXF = 1; // Reset the flag
    //nrk_event_signal (can_rx_pkt_signal);
}

void Abs()   //ABS Control block
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

void Traction()  //Traction Control block
{
    INT16 avg_rws;
    INT16 correction = 0;

    avg_rws = (car.wheelSpeedRL + car.wheelSpeedRR)/2;
    if((avg_rws - car.speed) > tc_threshold)
    {
        correction = (avg_rws - car.speed) * TRAC_KP;    //proportional control
    }
    accel_corr.accel = (UINT8) limit(correction,0,100);
}

void stabilityControl()   //Stablility Control block
{
    INT16 correction;
    correction = limit((abs(car.yawRate) - yawRate_threshold)*STAB_KP, 0, 100); //proportional control

    if(car.yawRate > 0)
        brake_msg.brakeRR = (UINT8) limit(brake_msg.brakeRR + correction, 0, 100);
    else
        brake_msg.brakeRL = (UINT8) limit(brake_msg.brakeRL + correction, 0, 100);
    
    accel_corr.accel = (UINT8) limit(correction,0,100);
}

int8_t can_wait_until_rx_pkt ()
{
    nrk_signal_register(can_rx_pkt_signal);
    //if (rtl_rx_pkt_check() != 0)
      //  return NRK_OK;
      
    nrk_event_wait (SIG(can_rx_pkt_signal));
    return NRK_OK;
}

