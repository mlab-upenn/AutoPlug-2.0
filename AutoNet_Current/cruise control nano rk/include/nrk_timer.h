   #ifndef NRK_TIMER_H
#define NRK_TIMER_H


void nrk_high_speed_timer_wait( uint16_t start, uint16_t ticks );
void _nrk_high_speed_timer_stop();
void _nrk_high_speed_timer_start();
void _nrk_high_speed_timer_reset();
uint16_t _nrk_high_speed_timer_get();
         extern uint16_t _nrk_prev_timer_val;
extern uint8_t _nrk_time_trigger;

//fix this why
void _nrk_os_timer_reset();
void _nrk_os_timer_set(uint16_t v);
void _nrk_os_timer_stop();
void _nrk_os_timer_start();
uint16_t _nrk_os_timer_get();
//fix this why
// implemented in hardware sepcific assembly file
void _nrk_timer_suspend_task(void *, NRK_STK *);

void nrk_spin_wait_us(uint16_t timeout);

// Only used for scheduling
void _nrk_setup_timer();
void _nrk_set_next_wakeup(uint16_t nw);
uint16_t _nrk_get_next_wakeup();

void _nrk_start_os_timer();
#endif