
  #ifndef __nrk_cfg_h	
#define __nrk_cfg_h

#define NRK_MAX_TASKS       		0   // Max number of tasks in your application
#define NRK_N_SYS_TASKS    		1    // you need at least the idle task
                         #define NRK_MAX_TASKS_ALLOWED           8
#define MALLOC_SIZE                     3  

#define NRK_TASK_IDLE_STK_SIZE         128   // Idle task stack size min=32 
#define NRK_APP_STACKSIZE              64 
#define NRK_KERNEL_STACKSIZE           128 
#define NRK_MAX_RESOURCE_CNT           1


#endif