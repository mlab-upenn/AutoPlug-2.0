#include "nrk_task.h"
#include <hidef.h>      /* common defines and macros */
#include <MC9S12C128.h>     /* derivative information */
#include "nrk_timer.h"
#include "nrk.h"

         uint16_t _nrk_prev_timer_val;
         uint16_t prev_timer=0;
uint8_t _nrk_time_trigger;
void *stkPtr;
void nrk_spin_wait_us(uint16_t timeout)
{
    // This sequence uses exactly 8 clock cycle for each round
    do {
        asm("nop");
        asm("nop");
        asm("nop");
        asm("nop");
    } while (--timeout);
}



void _nrk_setup_timer()
{
	_nrk_prev_timer_val = 20000;//254;
TSCR1 = 0x90;
  TSCR2 = 0x0F;
  TIOS |= 0x80;
  //TCTL1 = 0x0C;
  TFLG1 = 0xFF;
  TC7   = TCNT + 10;
  while(TFLG1 & 0x80);
  //TCTL1 = 0x04;
  TC7 += 100;
  //TC7=TC5;
  TIE |= 0x80;
 TIE &= ~0x80;
  TC7=_nrk_prev_timer_val;
  prev_timer=TCNT;
	_nrk_os_timer_reset();
	_nrk_os_timer_start();
	_nrk_time_trigger = 0;
	//eint(); //enable interrupts FIXME: should probably be doing this somewhere else
}

void _nrk_high_speed_timer_stop()
{
	// TODO: implement
	//TA1CTL &= ~MC_3;
}

void _nrk_high_speed_timer_start()
{
	// TODO: implement
	//TA1R = 0;
//	TA1CTL |= MC_2;
    
}


void _nrk_high_speed_timer_reset()
{
	// TODO: implement
//	TA1R = 0;
}

void nrk_high_speed_timer_wait( uint16_t start, uint16_t ticks )
{
	// TODO: implement
	uint32_t tmp;
if(start>65400) start=0;
tmp=(uint32_t)start+(uint32_t)ticks;
if(tmp>65536) 
	{
	tmp-=65536;
	do{}while(_nrk_high_speed_timer_get()>start);
	}

ticks=tmp;
do{}while(_nrk_high_speed_timer_get()<ticks);
}

uint16_t _nrk_high_speed_timer_get()
{
	// TODO: implement
//	return TA1R;
}
void _nrk_os_timer_stop()
{

	
	TIE &= ~0x80;
}
void _nrk_os_timer_reset()
{
TCNT=0;
	_nrk_time_trigger = 0;
	_nrk_prev_timer_val = 0;
}
void _nrk_os_timer_start()
{
TSCR1 = 0x90;
  TSCR2 = 0x0F;
  TIOS |= 0x80;
  //TCTL1 = 0x0C;
  TFLG1 = 0xFF;
  TC7   = TCNT + 10;
  while(TFLG1 & 0x80);
  //TCTL1 = 0x04;
  TC7 += 100;
  //TC7=TC5;
  TIE |= 0x80;
  //TIE &= ~0x80;
  TC7=20000;
}

    void _nrk_os_timer_set(uint16_t v)
{
TCNT=v;
//TCNT = v + prev_timer;
}
uint16_t _nrk_get_next_wakeup()
{   
	return TC7;
	//return (TC5-prev_timer);  
}

void _nrk_set_next_wakeup(uint16_t nw)
{   TC7 = nw;
	
}

uint16_t _nrk_os_timer_get()
{
	return TCNT;
	
}
#pragma CODE_SEG __NEAR_SEG NON_BANKED
interrupt 15 void oc5ISR(void) {
                   // nrk_int_disable();
                     //                 EnableInterrupts;
                //PORTB ^= 0x01;
                TCNT=0;
                      
         
                //stkPtr=&nrk_cur_task_TCB->OSTaskStkPtr;
               asm("sts stkPtr");
               nrk_cur_task_TCB->OSTaskStkPtr=stkPtr;
               //stkPtr=nrk_kernel_stk_pointer;
               asm("lds nrk_kernel_stk_ptr");
                           
               asm("rts");
               
               

}