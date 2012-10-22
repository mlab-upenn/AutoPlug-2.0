     #include "nrk_task.h"
     #include "nrk.h"
     #include "nrk_error.h"
       uint8_t error_task;
uint8_t error_num;

void nrk_kernel_error_add (uint8_t n, uint8_t task) 
{
  error_num = n;
  error_task = task;
  
#ifdef NRK_REPORT_ERRORS
   // nrk_error_print ();
  
#endif  /*  */
} 
 void _nrk_errno_set (NRK_ERRNO error_code) 
{
  nrk_cur_task_TCB->errno = error_code;
} 

