#ifndef _NRK_SCHEDULER_h	/* Only include stuff once */
#define _NRK_SCHEDULER_h


#include "nrk_cpu.h" /* New add on */
#include "nrk_cfg.h"
#include "nrk.h"
#include "nrk_time.h"

#define MAX_SCHED_WAKEUP_TIME		1000
#define SCHED_ONE_PASS_DELAY		100

extern uint8_t _nrk_cpu_state;

void _nrk_scheduler(void);

extern uint16_t next_next_wakeup;
uint16_t _nrk_get_next_next_wakeup();

// defined in hardware specific assembly file
void nrk_start_high_ready_task(NRK_TCB *);

#endif