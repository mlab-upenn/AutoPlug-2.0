#include "nrk_task.h"

#include <hidef.h>      /* common defines and macros */
#include <MC9S12C128.h>     /* derivative information */
void nrk_start_high_ready_task(NRK_TCB *task){

void *stkPtr;

       stkPtr=(void *)task->OSTaskStkPtr;
       //DisableInterrupts;
       asm("lds stkPtr");
       asm("rti");



}