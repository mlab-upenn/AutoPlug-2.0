// Divide by 8 prescaler
// For Timer_A frequency set to 4 KHz
#define NANOS_PER_TICK      61035		//976563
#define US_PER_TICK         61			//977 
#define TICKS_PER_SEC       16384		//1024 



#ifndef NRK_SLEEP_WAKEUP_TIME
#define NRK_SLEEP_WAKEUP_TIME 0    //fix srinivas 
#endif