#ifndef __nrk_h	/* Only include stuff once */
#define __nrk_h

#include "nrk_task.h"
#include "nrk_cfg.h"
#include "nrk_events.h"
#include "nrk_time.h"

#ifndef  FALSE
#define  FALSE                     0
#endif

#ifndef  TRUE
#define  TRUE                      1
#endif

#define GET_BYTES(x)\
    (((x)>>8) & 0x0000ff00)|(((x)>>8) & 0x000000ff)
    
extern NRK_TCB	nrk_task_TCB;   /* Table of TCBs */
extern NRK_TCB *_headTCB, *_tailTCB;

                   
extern NRK_TCB mallocTCBs[MALLOC_SIZE];
//nrk_queue mallocQueue[MALLOC_SIZE];

extern nrk_queue	_nrk_readyQ[NRK_MAX_TASKS+1];
extern nrk_queue	*_free_node,*_head_node;

extern nrk_sig_t nrk_wakeup_signal;
extern uint8_t 	nrk_cur_task_prio;
extern NRK_TCB	*nrk_cur_task_TCB;

extern uint8_t	nrk_high_ready_prio;
extern NRK_TCB	*nrk_high_ready_TCB;
                              extern nrk_time_t nrk_system_time;
extern uint8_t  _nrk_resource_cnt;
extern NRK_STK *nrk_kernel_stk_ptr;
//#ifdef KERNEL_STK_ARRAY
	extern NRK_STK nrk_kernel_stk[NRK_KERNEL_STACKSIZE];
//#endif
      void _nrk_timer_tick(void);
#endif