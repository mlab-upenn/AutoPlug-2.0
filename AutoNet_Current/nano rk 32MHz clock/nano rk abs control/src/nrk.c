#include <hidef.h>      /* common defines and macros */
#include <MC9S12C128.h>     /* derivative information */
#include "nrk_task.h"
    #include "nrk.h"
    #include "nrk_defs.h"
        #include "include.h"
        #include "nrk_error.h"
        #include "nrk_events.h"
        #include "nrk_idle_task.h"
        #include "nrk_stack_check.h"
        #include "nrk_cpu.h"
        #include "nrk_defs.h"
                              //malloc simulation
NRK_TCB mallocTCBs[MALLOC_SIZE];
nrk_queue mallocQueue[MALLOC_SIZE];
NRK_STK nrk_kernel_stk[NRK_KERNEL_STACKSIZE];
        uint8_t nrk_task_init_cnt = 0;
        NRK_STK *nrk_kernel_stk_ptr;
        uint8_t tasksNumber;
        NRK_STK	nrk_idle_task_stk[NRK_TASK_IDLE_STK_SIZE];  /* Idle task stack   */
        nrk_queue	_nrk_readyQ[NRK_MAX_TASKS+1];
nrk_queue	*_free_node,*_head_node;
nrk_sig_t nrk_wakeup_signal;
uint8_t  nrk_cur_task_prio ;
NRK_TCB	*nrk_cur_task_TCB;

NRK_TCB	nrk_task_TCB;   /* Table of TCBs  - here just the idle task*/
NRK_TCB *_headTCB, *_tailTCB;

uint8_t	nrk_high_ready_prio;
NRK_TCB	*nrk_high_ready_TCB;
uint8_t  _nrk_resource_cnt;
nrk_sem_t nrk_sem_list[NRK_MAX_RESOURCE_CNT];
nrk_time_t nrk_system_time;
void nrk_int_disable(void) {
  DisableInterrupts;
}

void nrk_int_enable(void) {
  EnableInterrupts;
}
  void _nrk_timer_tick(void)
{
	// want to do something before the scheduler gets called? 
	// Go ahead and put it here...

	_nrk_scheduler();

  	return;
}
 void nrk_start (void)
{
 nrk_cur_task_TCB = nrk_get_high_ready_task_ID(); //taskTCB
    /////task_ID=taskTCB->task_ID;//////task_ID = nrk_get_high_ready_task_ID();	
    nrk_high_ready_prio = nrk_cur_task_TCB->task_prio;
    nrk_high_ready_TCB = nrk_cur_task_TCB;// = taskTCB;           
    nrk_cur_task_prio = nrk_high_ready_prio;
    nrk_target_start();
	nrk_stack_pointer_init(); 
	nrk_start_high_ready_task(nrk_high_ready_TCB);	

    // you should never get here    
    while(1);
}
void nrk_init()
{
	
    uint8_t i;	
//    unsigned char *stkc;
	
   nrk_task_type IdleTask;
   nrk_wakeup_signal = nrk_signal_create();
   if(nrk_wakeup_signal==NRK_ERROR) nrk_kernel_error_add(NRK_SIGNAL_CREATE_ERROR,0);
	
   //if((volatile)TCCR1B!=0) nrk_kernel_error_add(NRK_STACK_OVERFLOW,0); 
   /*
   if(_nrk_startup_ok()==0) nrk_kernel_error_add(NRK_BAD_STARTUP,0); 
   #ifdef NRK_STARTUP_VOLTAGE_CHECK
   	if(nrk_voltage_status()==0) nrk_kernel_error_add(NRK_LOW_VOLTAGE,0);
   #endif

   #ifdef NRK_REBOOT_ON_ERROR
   #ifndef NRK_WATCHDOG
   while(1)
   {
     nrk_kprintf( PSTR("KERNEL CONFIG CONFLICT:  NRK_REBOOT_ON_ERROR needs watchdog!\r\n") );
     for (i = 0; i < 100; i++)
       nrk_spin_wait_us (1000);
   }
   #endif
   #endif

    #ifdef NRK_WATCHDOG
    if(nrk_watchdog_check()==NRK_ERROR) 
	{
    	nrk_watchdog_disable();
	nrk_kernel_error_add(NRK_WATCHDOG_ERROR,0);
	}
    nrk_watchdog_enable();
    #endif
  
  // nrk_stack_pointer_init(); 

    */
    nrk_cur_task_prio = 0;
    nrk_cur_task_TCB = NULL;
    
    nrk_high_ready_TCB = NULL;
    nrk_high_ready_prio = 0;
    /* 

    #ifdef NRK_MAX_RESERVES 
    // Setup the reserve structures
    _nrk_reserve_init();
    #endif
      */
    _nrk_resource_cnt=0; //NRK_MAX_RESOURCE_CNT;
    
    //PAJA: CHECK THIS
    for(i=0;i<NRK_MAX_RESOURCE_CNT;i++)
    {
      nrk_sem_list[i].count=-1;
      nrk_sem_list[i].value=-1;
      nrk_sem_list[i].resource_ceiling=-1;
      //nrk_resource_count[i]=-1;
      //nrk_resource_value[i]=-1;
      //nrk_resource_ceiling[i]=-1;
      
    }  
//////    //PAJA: CHECK THIS
//////    for (i= 0; i<NRK_MAX_TASKS_TCB; i++)
//////    {
//////      nrk_task_TCB[i].task_prio = TCB_EMPTY_PRIO;
//////      nrk_task_TCB[i].task_ID = -1;
//////      nrk_task_TCB[i].Next = NULL;        //PAJA:check this
//////      nrk_task_TCB[i].Prev = NULL;
//////    }
//////    
//////    _headTCB = &nrk_task_TCB[0];
//////    _tailTCB = _headTCB;
    tasksNumber = 1;        //idle tasks
    nrk_task_init_cnt = 1;
    
    nrk_task_TCB.task_prio = TCB_EMPTY_PRIO;
    nrk_task_TCB.task_ID = -1;
    nrk_task_TCB.Next = NULL;        //PAJA:check this
    nrk_task_TCB.Prev = NULL;
    
    _headTCB = &nrk_task_TCB;
    _tailTCB = _headTCB;
    
    
    // Setup a double linked list of Ready Tasks 
    for (i=0;i<NRK_MAX_TASKS;i++)
    {
      _nrk_readyQ[i].Next	=	&_nrk_readyQ[i+1];
      _nrk_readyQ[i+1].Prev	=	&_nrk_readyQ[i];
    }
    
    _nrk_readyQ[0].Prev	=	      NULL; 
    _nrk_readyQ[NRK_MAX_TASKS].Next = NULL;
    _head_node = NULL;
    _free_node = &_nrk_readyQ[0];
	
    
    
    nrk_task_set_entry_function( &IdleTask, (uint32_t)nrk_idle_task);
    nrk_task_set_stk( &IdleTask, nrk_idle_task_stk, NRK_TASK_IDLE_STK_SIZE);
    nrk_idle_task_stk[0]=STK_CANARY_VAL;	
    //IdleTask.task_ID = NRK_IDLE_TASK_ID;
    IdleTask.prio = 0;
    IdleTask.offset.secs = 0;
    IdleTask.offset.nano_secs = 0;
    IdleTask.FirstActivation = TRUE;
    IdleTask.Type = IDLE_TASK;
    IdleTask.SchType = PREEMPTIVE;
    nrk_activate_task(&IdleTask);
    
}



/*This function will ensure that each new task will have a unique task_ID.
task_ID 's must be different for two different tasks.This is required because
the nrk_add_readyQ and nrk_rem_from_readyQ takes task_ID as parameter..fix srinivas
*/
void check_taskID_conflict(){
NRK_TCB *currTCB;
currTCB = _headTCB;
while(currTCB != NULL){
if(currTCB->task_ID==nrk_task_init_cnt){
nrk_task_init_cnt++;
currTCB = _headTCB;
}
else currTCB = currTCB->Next;
}
}

int8_t nrk_TCB_init(nrk_task_type *Task, NRK_STK *ptos, NRK_STK *pbos, uint16_t stk_size, void *pext, uint16_t opt)
//////////NRK_TCB *nrk_TCB_init(nrk_task_type *Task, NRK_STK *ptos, NRK_STK *pbos, uint16_t stk_size, void *pext, uint16_t opt)
{
    NRK_TCB *newTCB;///////////// = malloc(sizeof(NRK_TCB));
	
    //  Already in critical section so no needenter critical section
    if(Task->Type!=IDLE_TASK){
	//check for task id conflict..fix srinivas
    	check_taskID_conflict();
    	Task->task_ID=nrk_task_init_cnt;
    }
    else Task->task_ID=NRK_IDLE_TASK_ID;

//////////    if(nrk_task_init_cnt>=NRK_MAX_TASKS_TCB) nrk_kernel_error_add(NRK_EXTRA_TASK,0);
   // if(tasksNumber>=NRK_MAX_TASKS_ALLOWED) nrk_kernel_error_add(NRK_EXTRA_TASK,0);
    
    if(Task->Type!=IDLE_TASK) {
      nrk_task_init_cnt++; 
      newTCB = &mallocTCBs[tasksNumber-1];//malloc(sizeof(NRK_TCB));
      //newTCB = (NRK_TCB *)nrk_malloc(sizeof(NRK_TCB));
      tasksNumber++;
    }//PAJA:Check, 2 loooks the same, put in the same if part !!!!! optimize
    else {
      newTCB = &nrk_task_TCB;
    }


 
    //initialize member of TCB structure
    
    //Paja: Check this in CS 
//////////    newTCB = &nrk_task_TCB[Task->task_ID];        
    Task->taskTCB = newTCB;
    
    if (Task->Type!=IDLE_TASK) {
    _tailTCB->Next = newTCB;
    newTCB->Prev = _tailTCB;
    newTCB->Next = NULL;
    _tailTCB = newTCB;
    }
    
    newTCB->OSTaskStkPtr = ptos;
    newTCB->task_prio = Task->prio;
    newTCB->task_state = SUSPENDED;
    newTCB->event_suspend=0;//fix srinivas
    newTCB->SchType=Task->SchType;//fix srinivas
    newTCB->task_ID = Task->task_ID;
    newTCB->suspend_flag = 0;
    newTCB->period= _nrk_time_to_ticks( Task->period );
    newTCB->next_wakeup= _nrk_time_to_ticks( Task->offset);
    newTCB->next_period= newTCB->period+newTCB->next_wakeup;
    newTCB->cpu_reserve= _nrk_time_to_ticks(Task->cpu_reserve);
    newTCB->cpu_remaining = newTCB->cpu_reserve;
    newTCB->num_periods = 1;
    newTCB->OSTCBStkBottom = pbos;
    newTCB->errno= NRK_OK;

    return NRK_OK;
//////        return newTCB;
}
