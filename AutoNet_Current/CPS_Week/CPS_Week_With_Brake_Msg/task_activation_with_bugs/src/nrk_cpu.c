#include "nrk.h"
 #include "nrk_stack_check.h" 
 #include "nrk_task.h"
 #include <hidef.h>      /* common defines and macros */
#include <MC9S12C128.h>     /* derivative information */
 
      #define GET_BYTES(x)\
    (((x)>>8) & 0x0000ff00)|(((x)>>8) & 0x000000ff)
 void nrk_sleep()
{
/*
    set_sleep_mode (SLEEP_MODE_PWR_SAVE);
    sleep_mode ();
*/
}

void nrk_idle()
{
/*
    set_sleep_mode( SLEEP_MODE_IDLE);
    sleep_mode ();
*/
}

void nrk_battery_save()
{
	//_nrk_set_next_wakeup(250);
/*
#ifdef NRK_BATTERY_SAVE
 	_nrk_stop_os_timer();
        
        nrk_led_clr(0);
        nrk_led_set(1);
        nrk_led_clr(2);
        nrk_led_clr(3);
        SET_VREG_INACTIVE();
        nrk_sleep();
#endif
*/
}
void nrk_target_start(void)
{

  _nrk_setup_timer();
  EnableInterrupts;
  nrk_int_enable();  
	
}
void nrk_stack_pointer_restore()
{
//unsigned char *stkc;
uint16_t *stkc;
               uint32_t funcdata;
//#ifdef KERNEL_STK_ARRAY
        stkc = (uint16_t*)&nrk_kernel_stk[NRK_KERNEL_STACKSIZE-1];
//#else
  //      stkc = (uint16_t*)NRK_KERNEL_STK_TOP;
//#endif
	//MSP: bytes are swapped
 //       *stkc++ = (uint16_t)((uint16_t)_nrk_timer_tick&0xff);
  //      *stkc = (uint16_t)((uint16_t)_nrk_timer_tick>>8);
	funcdata= (uint32_t)_nrk_timer_tick;
	*stkc = GET_BYTES(funcdata);
}
void nrk_stack_pointer_init()
{
	uint16_t *stkc;
	uint32_t funcdata;
//#ifdef KERNEL_STK_ARRAY
        stkc = (uint16_t*)&nrk_kernel_stk[NRK_KERNEL_STACKSIZE-1];
        nrk_kernel_stk[0]=STK_CANARY_VAL;
        nrk_kernel_stk_ptr = &nrk_kernel_stk[NRK_KERNEL_STACKSIZE-1];
  //  #else
    //    stkc = (uint16_t*)(NRK_KERNEL_STK_TOP-NRK_KERNEL_STACKSIZE);
      //  *stkc = STK_CANARY_VAL;
        //stkc = (uint16_t*)NRK_KERNEL_STK_TOP;
        //nrk_kernel_stk_ptr = (uint16_t*)NRK_KERNEL_STK_TOP;
    //#endif

    //MSP: bytes are swapped
    //TODO: switch these?
    //*stkc = (uint16_t)((uint16_t)_nrk_timer_tick>>8);
    //*stkc++ = (uint16_t)((uint16_t)_nrk_timer_tick&0xFF);
	funcdata= (uint32_t)_nrk_timer_tick;
	*stkc = GET_BYTES(funcdata);

}
void nrk_task_set_entry_function( nrk_task_type *task, uint32_t func )
{
	//task->task = (void*)((((uint16_t)func >> 8) & 0xff) | (((uint16_t)func << 8) & 0xff00));
//	task->task = (void(*)())SWAP_BYTES(func);
task->task=func;
}


void nrk_task_set_stk( nrk_task_type *task, NRK_STK stk_base[], uint16_t stk_size )
{
	void* addr;
//	if(stk_size<32) nrk_error_add(NRK_STACK_TOO_SMALL);

	//TODO: why aren't these swapped?
	addr=&(stk_base[stk_size-2]);
	//task->Ptos = ((addr << 8) & 0xff00) | ((addr >> 8) & 0x00ff);
	task->Ptos = addr;
	addr=&(stk_base[0]);
	//task->Pbos = ((addr << 8) & 0xff00) | ((addr >> 8) & 0x00ff);
	task->Pbos = addr;

	//task->Pbos = (void *) &stk_base[0];
}


void *nrk_task_stk_init (uint32_t task, void *ptos, void *pbos)
{
    uint16_t *stk ;  // 2 bytes
    uint8_t *stkc; // 1 byte
    stk    = (unsigned int *)pbos;          /* Load stack pointer */
    stkc = (unsigned char*)stk;
    *stkc = STK_CANARY_VAL;  // Flag for Stack Overflow   
    stk    = (unsigned int *)ptos;
    --stk;
    //*stkc=()(task1 & 0x00ff);
    //--stk;
   // funcdata=(uint32_t)task;
   
    *stk=GET_BYTES(task);
    --stk;
    --stk;
    --stk;
    stkc = (unsigned char *) stk;
    --stkc;
    *stkc=0x00;
    return (void *)stkc;
}
