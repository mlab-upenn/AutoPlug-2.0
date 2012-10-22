
     #include "nrk_error.h"
     #include "nrk_task.h"
     #include "nrk.h"
     #include "include.h"
     #include "nrk_error.h"


uint32_t _nrk_signal_list=0;

int8_t nrk_signal_create()
{
	uint8_t i=0;
	for(i=0;i<32;i++)   
	{                         
		if( !(_nrk_signal_list & SIG(i)))
		{    
			_nrk_signal_list|=SIG(i);
			return i;
		}
	}
	return NRK_ERROR;


}



uint32_t nrk_signal_get_registered_mask()
{
        return nrk_cur_task_TCB->registered_signal_mask;
}

int8_t nrk_signal_unregister(int8_t sig_id)
{
uint32_t sig_mask;

sig_mask=SIG(sig_id);

	if(nrk_cur_task_TCB->registered_signal_mask & sig_mask)
	{
		nrk_cur_task_TCB->registered_signal_mask&=~(sig_mask); 	
		nrk_cur_task_TCB->active_signal_mask&=~(sig_mask); 	
	}
	else
		return NRK_ERROR;
return NRK_OK;
}

int8_t nrk_signal_register(int8_t sig_id)
{

	// Make sure the signal was created...
	if(SIG(sig_id) & _nrk_signal_list )
	{
		nrk_cur_task_TCB->registered_signal_mask|=SIG(sig_id); 	
		return NRK_OK;
	}
            
	return NRK_ERROR;
}


//PAJA: CHeck this - important!!!
int8_t nrk_event_signal(int8_t sig_id)
{

//	uint8_t task_ID;
	uint8_t event_occured=0;
	uint32_t sig_mask;
        
        NRK_TCB *currTCB;

	sig_mask=SIG(sig_id);
	// Check if signal was created
	// Signal was not created
	if((sig_mask & _nrk_signal_list)==0 ) { _nrk_errno_set(1); return NRK_ERROR;}
	
	//needs to be atomic otherwise run the risk of multiple tasks being scheduled late and not in order of priority.  
	nrk_int_disable();
        
        currTCB = _headTCB;
///////	for (task_ID=0; task_ID < NRK_MAX_TASKS_TCB; task_ID++){
        while (currTCB!=NULL) {

	//	if (nrk_task_TCB[task_ID].task_state == EVENT_SUSPENDED)   
	//	{
	//	printf( "task %d is event suspended\r\n",task_ID );
//////////			if(nrk_task_TCB[task_ID].event_suspend==SIG_EVENT_SUSPENDED)
//////////				if((nrk_task_TCB[task_ID].active_signal_mask & sig_mask))
//////////				{
//////////					nrk_task_TCB[task_ID].task_state=SUSPENDED;
//////////					nrk_task_TCB[task_ID].next_wakeup=0;
//////////					nrk_task_TCB[task_ID].event_suspend=0;
//////////					// Add the event trigger here so it is returned
//////////					// from nrk_event_wait()
//////////					nrk_task_TCB[task_ID].active_signal_mask=sig_mask;
//////////					event_occured=1;
//////////				}

          if(currTCB->event_suspend==SIG_EVENT_SUSPENDED)
            if((currTCB->active_signal_mask & sig_mask))
            {
              currTCB->task_state=SUSPENDED;
              currTCB->next_wakeup=0;
              currTCB->event_suspend=0;
              // Add the event trigger here so it is returned
              // from nrk_event_wait()
              currTCB->active_signal_mask=sig_mask;
              event_occured=1;
            }
////////////			if(nrk_task_TCB[task_ID].event_suspend==RSRC_EVENT_SUSPENDED)
////////////				if((nrk_task_TCB[task_ID].active_signal_mask == sig_mask))
////////////				{
////////////					nrk_task_TCB[task_ID].task_state=SUSPENDED;
////////////					nrk_task_TCB[task_ID].next_wakeup=0;
////////////					nrk_task_TCB[task_ID].event_suspend=0;
////////////					// Add the event trigger here so it is returned
////////////					// from nrk_event_wait()
////////////					nrk_task_TCB[task_ID].active_signal_mask=0;
////////////					event_occured=1;
////////////				}   
          if(currTCB->event_suspend==RSRC_EVENT_SUSPENDED)
            if((currTCB->active_signal_mask == sig_mask))
            {
             currTCB->task_state=SUSPENDED;
              currTCB->next_wakeup=0;
              currTCB->event_suspend=0;
              // Add the event trigger here so it is returned
              // from nrk_event_wait()
              currTCB->active_signal_mask=0;
              event_occured=1;
            }
          currTCB = currTCB->Next;

	//	}
	}
	nrk_int_enable();
	if(event_occured)
	{
          return NRK_OK;
	} 
	// No task was waiting on the signal
	_nrk_errno_set(2);
	return NRK_ERROR;
}


uint32_t nrk_event_wait(uint32_t event_mask)
{

	// FIXME: Should go through list and check that all masks are registered, not just 1
	if(event_mask &  nrk_cur_task_TCB->registered_signal_mask)
	  {
	   nrk_cur_task_TCB->active_signal_mask=event_mask; 
	   nrk_cur_task_TCB->event_suspend=SIG_EVENT_SUSPENDED; 
	  }
	else
	  {
	   return 0;
	  }

	if(event_mask & SIG(nrk_wakeup_signal))
		nrk_wait_until_nw();
	else
		nrk_wait_until_ticks(0);
	//unmask the signal when its return so it has logical value like 1 to or whatever was user defined
	return ( (nrk_cur_task_TCB->active_signal_mask));
}
