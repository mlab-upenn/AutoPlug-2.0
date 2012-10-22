    #ifndef NRK_ERROR_H
#define NRK_ERROR_H
               #include "nrk_task.h"
#define NRK_OK		  1
#define NRK_ERROR	(-1)

#define NRK_UNKOWN		        0
#define NRK_STACK_OVERFLOW		1
#define NRK_RESERVE_ERROR		2
#define NRK_RESERVE_VIOLATED    	3
#define NRK_WAKEUP_MISSED		4
#define NRK_DUP_TASK_ID			5
#define NRK_BAD_STARTUP			6
#define NRK_EXTRA_TASK      		7
#define NRK_STACK_SMASH			8
#define NRK_LOW_VOLTAGE			9
#define NRK_SEG_FAULT		        10	
#define NRK_TIMER_OVERFLOW		11	
#define NRK_DEVICE_DRIVER		12	
#define NRK_UNIMPLEMENTED		13	
#define NRK_SIGNAL_CREATE_ERROR		14
#define NRK_SEMAPHORE_CREATE_ERROR	15
#define NRK_WATCHDOG_ERROR		16
#define NRK_STACK_TOO_SMALL		17
#define NRK_INVALID_STACK_POINTER	18
#define NRK_NUM_ERRORS			19
typedef uint8_t NRK_ERRNO;


#endif