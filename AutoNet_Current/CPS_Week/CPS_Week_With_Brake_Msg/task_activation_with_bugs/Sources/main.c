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

/*
#define KP_NUM (5)
#define KP_DEN (1)
#define KI_NUM (1)
#define KI_DEN (20)  */
#define ECU_ID 2


int8_t can_rx_pkt_signal;
int8_t can_wait_until_rx_pkt ();
uint8_t activated_tasks = 0, suspend_task = 0;
nrk_task_type* task_pointer[] = {0,0,0,0,0,0,0,0};

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
AutoLinkCANMsg task_message = {0,0,0,0,0,0,0};
VerifyMsg verify_message = {0,0}; // overshoot | reserve byte
Task_feedback task_feedback = {0,0}; //task number | action

volatile UINT8 carInputsUpdated = 0;
volatile UINT8 carParamsUpdated = 0;
volatile UINT8 accelCorrection = 0;
volatile UINT8 autolinkUpdated = 0;
volatile UINT8 bugupdated = 0;
UINT16 setSpeed = 0;
UINT8 taskUpdated=0;

/*const Car car = {
    {0, 3.9*4.5, 2.9*4.5, 2.3*4.5, 1.87*4.5, 1.68*4.5, 1.54*4.5, 1.46*4.5},
    1958.26,
    0.95,
    4,
    {0.3024, 0.3024, 0.3151, 0.3151}
};For F1 */

const Car car = {
    {0, 3.81818*3.44444, 2.07545*3.44444, 1.33324*3.44444, 0.898147*3.44444, 0.693399*3.44444, 0.7*3.44444, 0*3.44444},
    785,
    0.95,
    4,
    {0.3014, 0.3014, 0.3059, 0.3059}
};// For new Car
    


typedef unsigned char		uint8_t;
typedef unsigned int		uint16_t;
typedef int					int16_t;
typedef uint16_t NRK_STK;

NRK_STK Stack1[NRK_APP_STACKSIZE];
nrk_task_type TaskOne;
void Task1(void);

NRK_STK Stack2[NRK_APP_STACKSIZE];
nrk_task_type TaskTwo;
void Task2 (void);

NRK_STK Stack5[NRK_APP_STACKSIZE];
nrk_task_type TaskFive;
void Task5 (void);

void nrk_create_taskset();
void nrk_create_sub_taskset(uint8_t);//(unit8_t);
void init();
INT8 getGear(INT8 currentGear);

nrk_sig_t signal_one;
nrk_sig_t signal_two;

int check_state;
int error_detected(INT8 standard, INT16 difference){       //add one more parameter
    
    if (difference > 0.1 * standard){
        
        verify_message.exceed = difference - 0.1 * standard;
        return 1;                 //change to task number
    }
    else {
        verify_message.exceed = 0;
        return 0;
    }
}


void main(void) {
  /* put your own code here */
  //EnableInterrupts;
      nrk_init();
      init();
      DDRB = 0xFF;  //enable portB
    //PORTB = 0x00;
      signal_one = nrk_signal_create();
      signal_two = nrk_signal_create();
      nrk_create_taskset ();
      nrk_start();
      for(;;) {} /* wait forever */
  /* please make sure that you never leave this function */
}


 void Task1()//Normal Cruise Control
{
    
     
   //uint16_t cnt=0;
   // DDRB = 0x03;
   
    UINT8 KP_NUM = 75;
    UINT8 KP_DEN = 100;
    UINT8 KI_NUM = 5;
    UINT8 KI_DEN = 10;
    UINT8 KD_NUM = 5;
    UINT8 KD_DEN = 100;
    //UINT8 TS_NUM = 1;
    //UINT16 TS_DEN = 100;
    //UINT16 earr[]={0,0,0};
    //INT16 uarr[]={0,0};
        
    //INT8 setSpeed = -1;
    INT8 carSpeed = 0;

    INT8 error;
    INT16 errInteg;
    INT8 controlOutput;

    UINT8 accel;
    UINT8 gear = 0;

    UINT8 cruiseOn = 0;
    UINT8 task_state = 0;

    AccelMsg accelMsg;
    nrk_signal_register(signal_one);
    
    for(;;)
    {
    nrk_int_enable();
    //_nrk_os_timer_stop();
    
        if (task_feedback.tasknum != 1)
        {
            task_state = 1;
            task_feedback.action = TASK_ACTIVATE;
            task_feedback.tasknum = 1;
            taskUpdated=1;
        }
        

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
                /*error = (setSpeed - carParams.speed);
                
                //error_detected function is used to mark if there's an error detected
                check_state = error_detected(setSpeed, error);
                
                errInteg += error;
                errInteg = limit(errInteg, -100*KI_DEN/KI_NUM, 100*KI_DEN/KI_NUM); 
                
                //intergrate control
                controlOutput = limit(KP_NUM*error/KP_DEN + KI_NUM*errInteg/KI_DEN, 0, 100);
                //controlOutput = limit(controlOutput, 0, 100);

                accel = (UINT8) controlOutput;

                gear = (UINT8) limit(getGear(gear), 0, 7);

                accelMsg.accel = (UINT8)limit(accel - accelCorrection, 0, 100) ;
                accelMsg.gear = gear;
                accelMsg.clutch = 0; */
                
                error = (setSpeed - carParams.engineRPM);
                /*earr[2]=earr[1];
                earr[1]=earr[0];
                earr[0]=error;*/
                
                //error_detected function is used to mark if there's an error detected
                //check_state = error_detected(setSpeed, error);
                
                errInteg += error;
                errInteg = limit(errInteg, -100*KI_DEN/KI_NUM, 100*KI_DEN/KI_NUM); 
                
                //intergrate control
                controlOutput = KP_NUM*error/KP_DEN + KI_NUM*errInteg/KI_DEN;
                controlOutput = limit(controlOutput, 0, 100);
               
                /*
                uarr[0]=uarr[1] + KP_NUM*(earr[0]-earr[1]) + (KP_NUM*TS_NUM*TI_DEN*earr[0])/(TI_NUM*TS_DEN) + ((KP_NUM*TD_NUM*TS_DEN)*(earr[0]-2*earr[1]-earr[2]))/(TD_DEN*TS_NUM);

                uarr[1]=uarr[0];
                uarr[0] = limit(uarr[0], 0, 100);
                 */
                accel = (UINT8) controlOutput;

                gear = (UINT8) limit(getGear(gear), 0, 7);

                accelMsg.accel = (UINT8)limit(accel - accelCorrection, 0, 100) ;
                accelMsg.gear = gear;
                accelMsg.clutch = 0;
                
            }
            CANTx(CAN_ACCEL_MSG_ID, &accelMsg, sizeof(AccelMsg)); //send acceleration messages
            
            
            CANTx(CAN_CRUISE_SPEED_ID, &setSpeed, sizeof(INT8)); //send desired speed to Matlab gateway
                        
            carParamsUpdated = 0;
        }
        else if(carInputsUpdated)
        {
            if((carInputs.controls & CRUISE) && (carParams.speed > 0))
            {
                if(!cruiseOn)
                {
                    //setSpeed = carParams.speed;
                    setSpeed = 900;
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
        
        if (suspend_task & 0x01){
        
            /*if (task_state == 1)
            {
                task_state ==0;
                matlab_gui.task_feedback.action = TASK_SUSPEND;
                matlab_gui.task_feedback.tasknum = 1;
            } */
            task_state ==0;
            nrk_event_wait(SIG(signal_one));
            
        } 
        else {
          
        nrk_wait_until_next_period();
        
        }
    }
	
}


void Task2()//Bad parameter settings
{
   //uint16_t cnt=0;
   // DDRB = 0x03;
    UINT8 KP = 50;
    UINT8 KI_NUM = 1;
    UINT8 KI_DEN = 50;  
    UINT8 delay = 0;
    UINT8 deviation = 0;
    UINT8 rand_noise = 0;
    UINT8 KD_NUM = 0;
    UINT8 KD_DEN = 20;
    //INT8 setSpeed = -1;
    INT8 carSpeed = 0;

    INT8 error;
    INT16 errInteg=0;
    INT8 controlOutput;
    INT8 brakes;
    INT8 errDiff=0;

    INT8 accel;
    INT8 gear = 0;

    UINT8 cruiseOn = 0;
    UINT8 task_state = 0;

    AccelMsg accelMsg;
    BrakeMsg brakeMsg;
    nrk_signal_register(signal_two);
    
    for(;;)
    {
    nrk_int_enable();
    //_nrk_os_timer_stop();
    
        if (task_feedback.tasknum != 2)
        {
            task_state = 1;
            task_feedback.action = TASK_ACTIVATE;
            task_feedback.tasknum = 2;
            taskUpdated=1;
        }
    

        if (bugupdated)
        {
            KP = task_message.ecu_packet.action[0];
            KI_NUM = task_message.ecu_packet.action[1];    //the value of KI should >1
            
            delay = task_message.ecu_packet.action[2];
            deviation = task_message.ecu_packet.action[3] ;  //sensor noise
        
            bugupdated = 0;
        }
          
          


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
                if(deviation>0)
                  rand_noise = rand()%deviation;
                else
                  rand_noise=0;
                error = (setSpeed - (carParams.speed + rand_noise));
               
                //time delay if value has been assigned
                if (delay > 0){
                
                    nrk_spin_wait_us(delay*1000);
                
                }
                
                //error_detected function is used to mark if there's an error detected
                check_state = error_detected(setSpeed, error);
                
                errInteg += error;
                //errInteg = limit(errInteg, -100*KI_DEN/KI_NUM, 100*KI_DEN/KI_NUM); 
                
                errDiff -= error;
                
                //intergrate control
                if(KP*error + KI_NUM*errInteg/KI_DEN <0) {
                  brakes = 100 ;
                  controlOutput = 0;
                }
                else {
                  
                  controlOutput = limit(KP*error + KI_NUM*errInteg/KI_DEN, 0, 100);
                  brakes = 0;
                }
                //controlOutput = limit(controlOutput, 0, 100);


                accel = (UINT8) controlOutput;

                gear = (UINT8) limit(getGear(gear), 0, 7);

                accelMsg.accel = (UINT8)limit(accel - accelCorrection, 0, 100) ;
                accelMsg.gear = gear;
                accelMsg.clutch = 0;
                brakeMsg.brakeFL=brakes;
                brakeMsg.brakeFR=brakes;
                brakeMsg.brakeRL=brakes;
                brakeMsg.brakeRR=brakes;
            }
            CANTx(CAN_ACCEL_MSG_ID, &accelMsg, sizeof(AccelMsg)); //send acceleration messages
            //CANTx(CAN_BRAKE_MSG_ID, &brakeMsg, sizeof(BrakeMsg)); //send brake messages
            
            
            CANTx(CAN_CRUISE_SPEED_ID, &setSpeed, sizeof(INT8)); //send current and desired speed to Matlab gateway
            
            carParamsUpdated = 0;
        }
        else if(carInputsUpdated)
        {
            if((carInputs.controls & CRUISE) && (carParams.speed > 0))
            {
                if(!cruiseOn)
                {
                    //setSpeed = carParams.speed;
                    setSpeed = 20;
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
        
        if (suspend_task & 0x02){
        
           /* if (task_state == 1)
            {
                task_state ==0;
                matlab_gui.task_feedback.action = TASK_SUSPEND;
                matlab_gui.task_feedback.tasknum = 2;
            }*/
            task_state ==0;
            nrk_event_wait(SIG(signal_two));
            
        } 
        else {
          
        nrk_wait_until_next_period();
        
        }
        
    }
	
}



void Task5(){

    uint8_t k, bit_mask = 0x01;
    uint8_t task_action=0;
    suspend_task = 0;
       
    while(1){
      
      if (check_state){
         
              CANTx(CAN_VERIFY_MSG_ID, &verify_message, sizeof(VerifyMsg));
              verify_message.exceed = 0; 
              verify_message.delay = 0; 
           
      }
      
      if (taskUpdated){
        
              CANTx(CAN_TASK_FEEDBACK_ID, &task_feedback, sizeof(Task_feedback));
              taskUpdated=0;
      }
              
      
      
      if(autolinkUpdated==1){
          
          if(task_message.ecu_packet.ecu_id == ECU_ID){
            
            switch(task_message.action_type){
              
              case TASK_MANIP: //Task Manipulation 
                
                
                
                for(k=0;k<8;k++){
                  
                  if(bit_mask & task_message.ecu_packet.tasks){
                    
                    task_action=(task_message.ecu_packet.action[k/2] >> ((k+1) % 2)*4) & 0x0F;
                     
                  
                    switch (task_action){
                                          
                      case TASK_ACTIVATE:
                      
                        if(activated_tasks & bit_mask) {
                          
                            if (bit_mask & 0x01)
                              nrk_event_signal(signal_one);
                            else if (bit_mask & 0x02)
                              nrk_event_signal(signal_two);
                            else{
                            }
                        }
                        else
                          nrk_create_sub_taskset(k+1);
                        
                          suspend_task&=~(bit_mask);
                        break;  
                        
                      case TASK_SUSPEND:
                      
                        suspend_task|=(bit_mask);
                        break;
                        
                      case TASK_TERMINATE:
                        
                        nrk_terminate_task(task_pointer[k]);
                        task_feedback.action = TASK_TERMINATE;  //terminate feedback info
                        task_feedback.tasknum = k+1;  //
                        activated_tasks&=~(bit_mask);
                        break;
                      
                    }
                    
                    
                  }
                  
                  bit_mask<<=1;
                }
                  
                break;  //Break for case 1
                
                  
                case TASK_BUGS:  //Software bugs is introduced
                      
                bugupdated = 1;
                break;
            }
                 
          }
    
      }  
        
      autolinkUpdated=0;
      bit_mask=0x01;
             
      nrk_wait_until_next_period();
    }
}


void
nrk_create_taskset()
{   
  
  nrk_task_set_entry_function( &TaskFive, (uint32_t)Task5);
  nrk_task_set_stk( &TaskFive, Stack5, NRK_APP_STACKSIZE);
  TaskFive.prio = 10;
  TaskFive.FirstActivation = TRUE;
  TaskFive.Type = BASIC_TASK;
  TaskFive.SchType = PREEMPTIVE;
  TaskFive.period.secs = 0;
  TaskFive.period.nano_secs = 200*NANOS_PER_MS;
  TaskFive.cpu_reserve.secs = 0;
  TaskFive.cpu_reserve.nano_secs = 0*NANOS_PER_MS;
  TaskFive.offset.secs = 0;
  TaskFive.offset.nano_secs= 0;
  nrk_activate_task (&TaskFive);
    
  
}


void nrk_create_sub_taskset(uint8_t task) 
{

    switch(task){
      
      case 1:
      
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
        activated_tasks |= 0x01;
        task_pointer[0] = &TaskOne;
        break;
        
      case 2:
        nrk_task_set_entry_function( &TaskTwo, (uint32_t)Task2);
        nrk_task_set_stk( &TaskTwo, Stack2, NRK_APP_STACKSIZE);
        TaskTwo.prio = 2;
        TaskTwo.FirstActivation = TRUE;
        TaskTwo.Type = BASIC_TASK;
        TaskTwo.SchType = PREEMPTIVE;
        TaskTwo.period.secs = 0;
        TaskTwo.period.nano_secs = 2*NANOS_PER_MS;
        TaskTwo.cpu_reserve.secs = 0;
        TaskTwo.cpu_reserve.nano_secs = 0*NANOS_PER_MS;
        TaskTwo.offset.secs = 0;
        TaskTwo.offset.nano_secs= 0;
        nrk_activate_task (&TaskTwo);
        activated_tasks |= 0x02;
        task_pointer[1] = &TaskTwo;
        break; 
        
     
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
    
    else if (identifier == AUTOLINK_MSG_ID)   //receive messages from Matlab GUI
    {
        if(length > sizeof(AutoLinkCANMsg))
        {
            length = sizeof(AutoLinkCANMsg);
        }
        
        memcpy(&task_message, &CANRXDSR0, length);
        autolinkUpdated = 1;
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

