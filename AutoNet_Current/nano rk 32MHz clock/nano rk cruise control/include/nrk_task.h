                #ifndef _NRK_TASK_h	/* Only include stuff once */
#define _NRK_TASK_h
                #include "nrk_time.h"
                #include "nrk_cfg.h"
            typedef unsigned char		uint8_t;
typedef unsigned int		uint16_t;
typedef signed int					int16_t;
 typedef signed char					int8_t;
  typedef uint16_t  NRK_STK;
  //typedef unsigned long		uint32_t;
                typedef  int8_t	nrk_status_t;

typedef	int	_Bool;
typedef	_Bool bool;	

#define TRUE    1
#define FALSE   0

#define F_BUS (24000000UL)

#define min(a, b) (((a) > (b)) ? (b) : (a))
#define max(a, b) (((a) > (b)) ? (a) : (b))
#define limit(x,a,b) ((x) > (b) ? (b) : ((x) < (a) ? (a) : (x)))

              
     
               extern uint8_t tasksNumber;
  
 typedef struct os_tcb {
	NRK_STK        *OSTaskStkPtr;        /* Pointer to current top of stack */
	NRK_STK        *OSTCBStkBottom;     /* Pointer to bottom of stack    */
        
        struct os_tcb *Next;
        struct os_tcb *Prev;

	bool      elevated_prio_flag;
	bool      suspend_flag;
	bool      nw_flag;                // allows user to wake up on event or nw;
	uint8_t   event_suspend;          // event 0 = no event ; 1-255 event type;
	int8_t	  task_ID;                // For quick reference later, -1 means not active 	
	uint8_t   task_state;             // Task status    
	uint8_t   task_prio;              // Task priority (0 == highest, 63 == lowest) 
	uint8_t   task_prio_ceil;         // Task priority (0 == highest, 63 == lowest)    
	uint8_t   errno;                  // 0 no error 1-255 error code 
	uint32_t  registered_signal_mask; // List of events that are registered 
	uint32_t  active_signal_mask;     // List of events currently waiting on
    uint8_t	  SchType;
	// Inside TCB, all timer values stored in tick multiples to save memory
	uint16_t  next_wakeup;
	uint16_t  next_period;
	uint16_t  cpu_remaining;	
	uint16_t  period;
	uint16_t  cpu_reserve;
	uint16_t  num_periods;
	
	

} NRK_TCB;
  
  typedef struct node {
	uint8_t	task_ID;
	struct node *Prev;
	struct node *Next;
        NRK_TCB *taskTCB;
} nrk_queue;    
     
    
      
typedef struct task_type {

	int8_t	task_ID;
	void *Ptos;
	void *Pbos;
	uint32_t task;	
	bool	FirstActivation;
	uint8_t	prio;
	uint8_t	Type;
	uint8_t	SchType;
	nrk_time_t period;
	nrk_time_t cpu_reserve;
	nrk_time_t offset;
        NRK_TCB *taskTCB;

} nrk_task_type;

        #define TIME_PAD  2

#define	RUNNING   		0
#define	WAITING   		1
#define	READY     		2
#define	SUSPENDED 		3
#define FINISHED        	4
#define EVENT_SUSPENDED	        5

#define SIG_EVENT_SUSPENDED       1
#define RSRC_EVENT_SUSPENDED      2

#define NONPREEMPTIVE	0
#define PREEMPTIVE    	1

#define	INVALID_TASK 	0
#define	BASIC_TASK    	1
#define	IDLE_TASK      	2

#define TCB_EMPTY_PRIO	99
#define RES_FREE		99

                  uint8_t nrk_get_pid();
int8_t nrk_wait_until_next_period();
int8_t nrk_wait_until_next_n_periods(uint16_t p);
int8_t nrk_wait_until(nrk_time_t t);
int8_t nrk_wait(nrk_time_t t);
int8_t nrk_wait_until_ticks(uint16_t ticks);
int8_t nrk_wait_ticks(uint16_t ticks);
int8_t nrk_wait_until_nw();
int8_t nrk_set_next_wakeup(nrk_time_t t);

           extern nrk_queue mallocQueue[MALLOC_SIZE];

//nrk_status_t nrk_activate_task(nrk_task_type *);
       void nrk_add_to_readyQ(int8_t task_ID,NRK_TCB *taskTCBin);
       NRK_TCB *nrk_get_high_ready_task_ID();
       void nrk_rem_from_readyQ(int8_t task_ID);

#endif
