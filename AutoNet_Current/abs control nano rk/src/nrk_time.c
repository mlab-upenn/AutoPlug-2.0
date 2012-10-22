      
         #include "nrk_time.h"
         #include "nrk_platform_time.h"
              typedef unsigned int uint16_t; 
uint16_t _nrk_time_to_ticks(nrk_time_t t)
{
uint16_t ticks;
uint16_t tmp;
// FIXME: This will overflow

if(t.secs>=1)
{
t.nano_secs+=NANOS_PER_SEC;
t.secs--;
ticks=t.nano_secs/(uint32_t)NANOS_PER_TICK;
ticks+=t.secs*TICKS_PER_SEC;
}else
{
ticks=t.nano_secs/(uint32_t)NANOS_PER_TICK;
}

tmp=ticks;
while(tmp>TICKS_PER_SEC)tmp-=TICKS_PER_SEC;
t.secs=tmp*NANOS_PER_TICK;

if(t.nano_secs>t.secs+(NANOS_PER_TICK/2))ticks++;

//ticks=t->nano_secs/(uint32_t)NANOS_PER_TICK;
//ticks+=t->secs*(uint32_t)TICKS_PER_SEC;
return ticks;
}
           