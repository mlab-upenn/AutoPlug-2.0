#include "nrk.h"
#include "nrk_task.h"



void nrk_stack_check()
{
#ifdef NRK_STACK_CHECK

unsigned int *stk ;  // 2 bytes
unsigned char *stkc; // 1 byte
    
    stk  = (unsigned int *)nrk_cur_task_TCB->OSTCBStkBottom;          /* Load stack pointer */ 
    stkc = (unsigned char*)stk;
    if(*stkc != STK_CANARY_VAL) {
	    	#ifdef NRK_REPORT_ERRORS
	    	 dump_stack_info();
		#endif
	   	 nrk_error_add( NRK_STACK_OVERFLOW ); 
		 *stkc=STK_CANARY_VAL; 
    		  } 
 
    stk  = (unsigned int *)nrk_cur_task_TCB->OSTaskStkPtr;          /* Load stack pointer */ 
    stkc = (unsigned char*)stk;
    if(stkc > (unsigned char *)RAMEND ) {
	    	#ifdef NRK_REPORT_ERRORS
	    	 dump_stack_info();
		#endif
	   	 nrk_error_add( NRK_INVALID_STACK_POINTER); 
    		 } 




#endif
}