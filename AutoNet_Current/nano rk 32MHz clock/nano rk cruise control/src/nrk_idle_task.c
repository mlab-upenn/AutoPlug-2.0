#include "nrk_task.h"

    #include "nrk_idle_task.h"
                #include "nrk_platform_time.h"
                  #include "nrk_scheduler.h"
void nrk_idle_task()
{
volatile unsigned char *stkc;
// unsigned int *stk ;  // 2 bytes
while(1)
{

  nrk_stack_check(); 
  
  if(_nrk_get_next_wakeup()<=NRK_SLEEP_WAKEUP_TIME) 
    {
	    _nrk_cpu_state=1;
	    nrk_idle();
    }
    else {
	#ifndef NRK_NO_POWER_DOWN
	    // Allow last UART byte to get out
    	    //nrk_spin_wait_us(10);  
	    _nrk_cpu_state=2;
	    nrk_sleep();
	#else
	    nrk_idle();
	#endif
    }
 
#ifdef NRK_STACK_CHECK
   if(nrk_idle_task_stk[0]!=STK_CANARY_VAL) nrk_error_add(NRK_STACK_SMASH);
   #ifdef KERNEL_STK_ARRAY
   	if(nrk_kernel_stk[0]!=STK_CANARY_VAL) nrk_error_add(NRK_STACK_SMASH);
   #else
   	stkc=(unsigned char*)(NRK_KERNEL_STK_TOP-NRK_KERNEL_STACKSIZE);
   	if(*stkc!=STK_CANARY_VAL) nrk_error_add(NRK_STACK_SMASH);
   #endif
#endif



}


}
