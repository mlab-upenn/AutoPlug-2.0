#ifndef NRK_EVENTS_H
#define NRK_EVENTS_H

#include "nrk_task.h"
#define SIG(x)  ((uint32_t)1)<<x
    extern uint32_t _nrk_signal_list;
    
       typedef int8_t nrk_sig_t;
typedef uint32_t nrk_sig_mask_t;
    
uint32_t nrk_signal_get_registered_mask();
int8_t nrk_signal_delete(nrk_sig_t sig_id); //removes any tasks association with signal including unsuspends tasks that wer waiting on signal removed
int8_t nrk_signal_unregister(int8_t sig_id);
int8_t nrk_signal_register(int8_t sig_id);
int8_t nrk_signal_create(); // returns signal

int8_t nrk_event_signal(int8_t event_num);
uint32_t nrk_event_wait(uint32_t event_num);
     typedef struct semaphore_type {
int8_t count;
int8_t resource_ceiling;
int8_t value;
} nrk_sem_t;

#endif