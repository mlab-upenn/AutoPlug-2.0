 #ifndef NRK_TIME_H
#define NRK_TIME_H 
   #define NANOS_PER_SEC       1000000000
#define US_PER_SEC          1000000
#define NANOS_PER_MS        1000000
#define NANOS_PER_US        1000



 typedef unsigned long		uint32_t;
/*struct  xtime {
   unsigned long secs;
   unsigned long nano_secs;
   int x;
} ;
  */
//nrk_time_t;

   


//nrk_time_t; 
struct ntime {
       unsigned long secs;
   unsigned long nano_secs;
}  ;

typedef struct ntime nrk_time_t;

#endif