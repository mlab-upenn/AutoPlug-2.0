/******************************************************************************
*  Nano-RK, a real-time operating system for sensor networks.
*  Copyright (C) 2007, Real-Time and Multimedia Lab, Carnegie Mellon University
*  All rights reserved.
*
*  This is the Open Source Version of Nano-RK included as part of a Dual
*  Licensing Model. If you are unsure which license to use please refer to:
*  http://www.nanork.org/nano-RK/wiki/Licensing
*
*  This program is free software: you can redistribute it and/or modify
*  it under the terms of the GNU General Public License as published by
*  the Free Software Foundation, version 2.0 of the License.
*
*  This program is distributed in the hope that it will be useful,
*  but WITHOUT ANY WARRANTY; without even the implied warranty of
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*  GNU General Public License for more details.
*
*  You should have received a copy of the GNU General Public License
*  along with this program.  If not, see <http://www.gnu.org/licenses/>.
*
*  Contributing Authors (specific to this file):
*  Anthony Rowe
*  Zane Starr
*  Anand Eswaren
*******************************************************************************/

#include "nrk.h"
#include "nrk_task.h"
#include "nrk_defs.h"
#include "nrk_error.h"
#include "nrk_events.h"
#include "nrk_scheduler.h"
#include "include.h"

#include "nrk_timer.h"
#include "nrk_time.h"
#include "nrk_cfg.h"
#include "nrk_cpu.h"

#include "nrk_platform_time.h"

// 750 measure to 100uS
// 800 * .125 = 100us
#define CONTEXT_SWAP_TIME_BOUND    1500   //750          //fix srinivas

uint8_t _nrk_cpu_state;//koji cei ?????????????
uint16_t next_next_wakeup;

void _nrk_scheduler()
{	   
	int8_t task_ID;
        NRK_TCB *currTCB;
	uint16_t next_wake;
	uint16_t start_time_stamp;

nrk_int_disable();   // this should be removed...  Not needed

#ifndef NRK_NO_BOUNDED_CONTEXT_SWAP
	_nrk_high_speed_timer_reset();
	start_time_stamp=_nrk_high_speed_timer_get();
	
#endif

	_nrk_set_next_wakeup(MAX_SCHED_WAKEUP_TIME);
	// Set to huge number which will later get set to min
	next_wake=500000;
	// Safety zone starts here....
	#ifdef NRK_WATCHDOG
	nrk_watchdog_reset();
	#endif


	#ifdef NRK_KERNEL_TEST
	if(_nrk_cpu_state && _nrk_os_timer_get()>nrk_max_sleep_wakeup_time)
		nrk_max_sleep_wakeup_time=_nrk_os_timer_get();
	#endif
	//while(_nrk_time_trigger>0)
	//{
	nrk_system_time.nano_secs+=((uint32_t)_nrk_prev_timer_val*NANOS_PER_TICK);
	nrk_system_time.nano_secs-=(nrk_system_time.nano_secs%(uint32_t)NANOS_PER_TICK);


	while(nrk_system_time.nano_secs>=NANOS_PER_SEC)
	{
		nrk_system_time.nano_secs-=NANOS_PER_SEC;
		nrk_system_time.secs++;
		nrk_system_time.nano_secs-=(nrk_system_time.nano_secs%(uint32_t)NANOS_PER_TICK);
	}
	//  _nrk_time_trigger--;
	//}  
	if(nrk_cur_task_TCB->suspend_flag==1 && nrk_cur_task_TCB->task_state!=FINISHED)
	{
	//	nrk_cur_task_TCB->task_state = EVENT_SUSPENDED;
		
		if(nrk_cur_task_TCB->event_suspend==RSRC_EVENT_SUSPENDED)  
			nrk_cur_task_TCB->task_state = EVENT_SUSPENDED;
		else if( nrk_cur_task_TCB->event_suspend>0 && nrk_cur_task_TCB->nw_flag==0) 
			nrk_cur_task_TCB->task_state = EVENT_SUSPENDED;
		else if( nrk_cur_task_TCB->event_suspend>0 && nrk_cur_task_TCB->nw_flag==1) 
			nrk_cur_task_TCB->task_state = SUSPENDED;
		else	
		{
			nrk_cur_task_TCB->task_state = SUSPENDED;
			nrk_cur_task_TCB->event_suspend=0;
			nrk_cur_task_TCB->nw_flag=0;
		}
		nrk_rem_from_readyQ(nrk_cur_task_TCB->task_ID);
	}
	// nrk_print_readyQ();

	// Update cpu used value for ended task
	// If the task has used its reserve, suspend task
	// Don't disable IdleTask which is 0
	// Don't decrease cpu_remaining if reserve is 0 and hence disabled
	if(nrk_cur_task_TCB->cpu_reserve!=0 && nrk_cur_task_TCB->task_ID!=NRK_IDLE_TASK_ID && nrk_cur_task_TCB->task_state!=FINISHED )
	{
		if(nrk_cur_task_TCB->cpu_remaining<_nrk_prev_timer_val)
		{

			nrk_kernel_error_add(NRK_RESERVE_ERROR,nrk_cur_task_TCB->task_ID);
			nrk_cur_task_TCB->cpu_remaining=0;
		}else
			nrk_cur_task_TCB->cpu_remaining-=_nrk_prev_timer_val;

		task_ID = nrk_cur_task_TCB->task_ID;

		if (nrk_cur_task_TCB->cpu_remaining ==0 ) {

			nrk_kernel_error_add(NRK_RESERVE_VIOLATED,task_ID);
			nrk_cur_task_TCB->task_state = SUSPENDED;
			nrk_rem_from_readyQ(task_ID);
		} 
	}

	// Check I/O nrk_queues to add tasks with remaining cpu back...

	// Add eligable tasks back to the ready Queue
	// At the same time find the next earliest wakeup
        currTCB = _headTCB;
////////	for (task_ID=0; task_ID < NRK_MAX_TASKS_TCB; task_ID++){
        while (currTCB!=NULL) {  
          
//////////////////////////		if(nrk_task_TCB[task_ID].task_ID==-1) continue;
          
//////////////////////////          nrk_task_TCB[task_ID].suspend_flag=0;
          currTCB->suspend_flag=0;

//////////////////////////          if( nrk_task_TCB[task_ID].task_ID!=NRK_IDLE_TASK_ID && nrk_task_TCB[task_ID].task_state!=FINISHED )
//////////////////////////          {
//////////////////////////            if(  nrk_task_TCB[task_ID].next_wakeup >= _nrk_prev_timer_val )
//////////////////////////              nrk_task_TCB[task_ID].next_wakeup-=_nrk_prev_timer_val;
//////////////////////////            else 
//////////////////////////              nrk_task_TCB[task_ID].next_wakeup=0;
//////////////////////////            
//////////////////////////            // Do next period book keeping.
//////////////////////////            // next_period needs to be set such that the period is kept consistent even if other
//////////////////////////            // wait until functions are called.
//////////////////////////            if( nrk_task_TCB[task_ID].next_period >= _nrk_prev_timer_val )
//////////////////////////              nrk_task_TCB[task_ID].next_period-=_nrk_prev_timer_val;
//////////////////////////            else {
//////////////////////////              if(nrk_task_TCB[task_ID].period>_nrk_prev_timer_val)
//////////////////////////                nrk_task_TCB[task_ID].next_period= nrk_task_TCB[task_ID].period-_nrk_prev_timer_val;
//////////////////////////              else
//////////////////////////                nrk_task_TCB[task_ID].next_period= _nrk_prev_timer_val % nrk_task_TCB[task_ID].period;
//////////////////////////            }
//////////////////////////            if(nrk_task_TCB[task_ID].next_period==0) nrk_task_TCB[task_ID].next_period=nrk_task_TCB[task_ID].period;
//////////////////////////            
//////////////////////////          }
          if( currTCB->task_ID != NRK_IDLE_TASK_ID && currTCB->task_state != FINISHED )
          {
            if( currTCB->next_wakeup >= _nrk_prev_timer_val )
              currTCB->next_wakeup -= _nrk_prev_timer_val;
            else 
              currTCB->next_wakeup=0;
            
            // Do next period book keeping.
            // next_period needs to be set such that the period is kept consistent even if other
            // wait until functions are called.
            if( currTCB->next_period >= _nrk_prev_timer_val )
              currTCB->next_period -= _nrk_prev_timer_val;
            else {
              if(currTCB->period > _nrk_prev_timer_val)
                currTCB->next_period = currTCB->period - _nrk_prev_timer_val;
              else
                currTCB->next_period = _nrk_prev_timer_val % currTCB->period;
            }
            if(currTCB->next_period == 0) currTCB->next_period = currTCB->period;
          }

          // Look for Next Task that Might Wakeup to interrupt current task
//////////////////////          if (nrk_task_TCB[task_ID].task_state == SUSPENDED ) {
//////////////////////            // printf( "Task: %d nw: %d\n",task_ID,nrk_task_TCB[task_ID].next_wakeup);
//////////////////////            // If a task needs to become READY, make it ready
//////////////////////            if (nrk_task_TCB[task_ID].next_wakeup == 0) {
//////////////////////              // printf( "Adding back %d\n",task_ID );
//////////////////////              if(nrk_task_TCB[task_ID].event_suspend>0 && nrk_task_TCB[task_ID].nw_flag==1) nrk_task_TCB[task_ID].active_signal_mask=SIG(nrk_wakeup_signal);
//////////////////////              //if(nrk_task_TCB[task_ID].event_suspend==0) nrk_task_TCB[task_ID].active_signal_mask=0;
//////////////////////              nrk_task_TCB[task_ID].event_suspend=0;
//////////////////////              nrk_task_TCB[task_ID].nw_flag=0;
//////////////////////              nrk_task_TCB[task_ID].suspend_flag=0;
//////////////////////              if(nrk_task_TCB[task_ID].num_periods==1) 
//////////////////////              {
//////////////////////                nrk_task_TCB[task_ID].cpu_remaining = nrk_task_TCB[task_ID].cpu_reserve;
//////////////////////                nrk_task_TCB[task_ID].task_state = READY;
//////////////////////                nrk_task_TCB[task_ID].next_wakeup = nrk_task_TCB[task_ID].next_period;
//////////////////////                nrk_add_to_readyQ(task_ID, &nrk_task_TCB[task_ID] );	//PAJA:CHECK			
//////////////////////              } else 
//////////////////////              {
//////////////////////                nrk_task_TCB[task_ID].cpu_remaining = nrk_task_TCB[task_ID].cpu_reserve;
//////////////////////                //nrk_task_TCB[task_ID].next_wakeup = nrk_task_TCB[task_ID].next_period;
//////////////////////                //nrk_task_TCB[task_ID].num_periods--;
//////////////////////                nrk_task_TCB[task_ID].next_wakeup = (nrk_task_TCB[task_ID].period*(nrk_task_TCB[task_ID].num_periods-1));
//////////////////////                nrk_task_TCB[task_ID].next_period = (nrk_task_TCB[task_ID].period*(nrk_task_TCB[task_ID].num_periods-1));
//////////////////////                nrk_task_TCB[task_ID].num_periods=1;
//////////////////////                //			printf( "np = %d\r\n",nrk_task_TCB[task_ID].next_wakeup);
//////////////////////                //			nrk_task_TCB[task_ID].num_periods=1; 
//////////////////////              }
//////////////////////            }
          if (currTCB->task_state == SUSPENDED ) {
            // printf( "Task: %d nw: %d\n",task_ID,nrk_task_TCB[task_ID].next_wakeup);
            // If a task needs to become READY, make it ready
            if (currTCB->next_wakeup == 0) {
              // printf( "Adding back %d\n",task_ID );
              if(currTCB->event_suspend>0 && currTCB->nw_flag==1) 
                currTCB->active_signal_mask=SIG(nrk_wakeup_signal);
              //if(nrk_task_TCB[task_ID].event_suspend==0) nrk_task_TCB[task_ID].active_signal_mask=0;
              currTCB->event_suspend=0;
              currTCB->nw_flag=0;
              currTCB->suspend_flag=0;
              if (currTCB->num_periods == 1) 
              {
                currTCB->cpu_remaining = currTCB->cpu_reserve;
                currTCB->task_state = READY;
                currTCB->next_wakeup = currTCB->next_period;
//////////////                nrk_add_to_readyQ(task_ID, currTCB);	//PAJA:CHECK
                nrk_add_to_readyQ(currTCB->task_ID, currTCB);	//PAJA:CHECK	
              } else 
              {
                currTCB->cpu_remaining = currTCB->cpu_reserve;
                //nrk_task_TCB[task_ID].next_wakeup = nrk_task_TCB[task_ID].next_period;
                //nrk_task_TCB[task_ID].num_periods--;
                currTCB->next_wakeup = (currTCB->period*(currTCB->num_periods-1));
                currTCB->next_period = (currTCB->period*(currTCB->num_periods-1));
                currTCB->num_periods=1;
                //			printf( "np = %d\r\n",nrk_task_TCB[task_ID].next_wakeup);
                //			nrk_task_TCB[task_ID].num_periods=1; 
              }
            }
////////////////////            if(nrk_task_TCB[task_ID].next_wakeup!=0 && 
////////////////////               nrk_task_TCB[task_ID].next_wakeup<next_wake )
////////////////////            {
////////////////////              // Find closest next_wake task
////////////////////              next_wake=nrk_task_TCB[task_ID].next_wakeup;
////////////////////            }
            if(currTCB->next_wakeup!=0 && currTCB->next_wakeup<next_wake )
            {
              // Find closest next_wake task
              next_wake = currTCB->next_wakeup;
            }
          }		
////////// paja          if (currTCB == _tailTCB) continue;
          currTCB = currTCB->Next;
	}


//////////////////////////////	task_ID = nrk_get_high_ready_task_ID(); 
        nrk_high_ready_TCB = nrk_get_high_ready_task_ID();
        task_ID = nrk_high_ready_TCB->task_ID;
//////////////////////////////	nrk_high_ready_prio = nrk_task_TCB[task_ID].task_prio;
        nrk_high_ready_prio = nrk_high_ready_TCB->task_prio;
//////////////	nrk_high_ready_TCB = &nrk_task_TCB[task_ID];

	// next_wake should hold next time when a suspended task might get run
	// task_ID holds the highest priority READY task ID
	// So nrk_task_TCB[task_ID].cpu_remaining holds the READY task's end time 

	// Now we pick the next wakeup (either the end of the current task, or the possible resume
	// of a suspended task) 
	if(task_ID!=NRK_IDLE_TASK_ID) 
	{
		// You are a non-Idle Task
////////		if(nrk_task_TCB[task_ID].cpu_reserve!=0 && nrk_task_TCB[task_ID].cpu_remaining<MAX_SCHED_WAKEUP_TIME)
////////		{
////////			if(next_wake>nrk_task_TCB[task_ID].cpu_remaining)
////////				next_wake=nrk_task_TCB[task_ID].cpu_remaining;
////////		}
////////		else 
////////		{ 
////////			if(next_wake>MAX_SCHED_WAKEUP_TIME) next_wake=MAX_SCHED_WAKEUP_TIME; 
////////		}
          if(nrk_high_ready_TCB->cpu_reserve!=0 && nrk_high_ready_TCB->cpu_remaining<MAX_SCHED_WAKEUP_TIME)
          {
            if(next_wake > nrk_high_ready_TCB->cpu_remaining)
              next_wake = nrk_high_ready_TCB->cpu_remaining;
          }
          else 
          { 
            if(next_wake>MAX_SCHED_WAKEUP_TIME) next_wake=MAX_SCHED_WAKEUP_TIME; 
          }
	} 
	else {
		// This is the idle task
		// Make sure you wake up from the idle task a little earlier
		// if you would go into deep sleep...
		// After waking from deep sleep, the next context swap must be at least
  		// NRK_SLEEP_WAKEUP_TIME-1 away to make sure the CPU wakes up in time. 
			
		if(next_wake>NRK_SLEEP_WAKEUP_TIME) 
		{
			if(next_wake-NRK_SLEEP_WAKEUP_TIME<MAX_SCHED_WAKEUP_TIME)
			{
				if(next_wake-NRK_SLEEP_WAKEUP_TIME<NRK_SLEEP_WAKEUP_TIME){
					next_wake=NRK_SLEEP_WAKEUP_TIME-1;  // fix srinivas
				}
				else {
					next_wake=next_wake-NRK_SLEEP_WAKEUP_TIME;
				}
			} else if(next_wake>NRK_SLEEP_WAKEUP_TIME+MAX_SCHED_WAKEUP_TIME){ 
				if(next_wake>MAX_SCHED_WAKEUP_TIME+SCHED_ONE_PASS_DELAY) {	//fix srinivas			/* If the scheduler wakes up SCHED_ONE_PASS_DELAY
																							//before the task invocation spot then we can't
																							//make it on time! */   
					next_wake=MAX_SCHED_WAKEUP_TIME;
				}  //fix srinivas
			} else {
				next_wake=MAX_SCHED_WAKEUP_TIME-NRK_SLEEP_WAKEUP_TIME;
			}
		} 
	}

	/*
	// Some code to catch the case when the scheduler wakes up
	// from deep sleep and has to execute again before NRK_SLEEP_WAKEUP_TIME-1
	if(_nrk_cpu_state==2 && next_wake<NRK_SLEEP_WAKEUP_TIME-1)
	{
	nrk_int_disable();
	while(1)
		{
		nrk_spin_wait_us(60000);
		nrk_led_toggle(RED_LED);
		nrk_spin_wait_us(60000);
		nrk_led_toggle(GREEN_LED);
		printf( "crash: %d %d %d\r\n",task_ID,next_wake,_nrk_cpu_state);
		}
	}*/

	//printf( "nw = %d %d %d\r\n",task_ID,_nrk_cpu_state,next_wake);
	nrk_cur_task_prio = nrk_high_ready_prio;
	nrk_cur_task_TCB  = nrk_high_ready_TCB;

	#ifdef NRK_KERNEL_TEST
	if(nrk_high_ready_TCB==NULL)
		{
		nrk_kprintf( PSTR( "KERNEL TEST: BAD TCB!\r\n" ));
		}
	#endif
	_nrk_prev_timer_val=next_wake;


	if(_nrk_os_timer_get()>=next_wake)  // just bigger then, or equal? 
	{
		// FIXME: Terrible Terrible...
		// Need to find out why this is happening...

		#ifdef NRK_KERNEL_TEST
		// Ignore if you are the idle task coming from deep sleep
		if(!(task_ID==NRK_IDLE_TASK_ID && _nrk_cpu_state==2))
			nrk_kernel_error_add(NRK_WAKEUP_MISSED,task_ID);
		#endif

		// This is bad news, but keeps things running
		// +2 just in case we are on the edge of the last tick
		next_wake=_nrk_os_timer_get()+2;  //fix srinivas
		_nrk_prev_timer_val=next_wake;
	} 

	if(task_ID!=NRK_IDLE_TASK_ID) _nrk_cpu_state=0;
	//if(task_ID==2) 
	
	
	//_nrk_set_next_wakeup(next_wake);
	
	//if(task_ID == NRK_IDLE_TASK_ID){    // fix srinivas
		//if(next_wake > 3) _nrk_set_next_wakeup(next_wake-3); //fix srinivas
	//else {
	_nrk_set_next_wakeup(next_wake);
	//timerArray[(timerIndex++)%2000]=_nrk_prev_timer_val;
	
	
	//}
	//}
	
#ifndef NRK_NO_BOUNDED_CONTEXT_SWAP
	// Bound Context Swap to 100us 
	nrk_high_speed_timer_wait(start_time_stamp,CONTEXT_SWAP_TIME_BOUND);
	
#endif	

	nrk_stack_pointer_restore();
	//nrk_int_enable();
	nrk_start_high_ready_task(nrk_high_ready_TCB);
}

