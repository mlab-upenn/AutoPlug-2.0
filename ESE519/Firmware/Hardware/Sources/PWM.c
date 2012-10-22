#include <hidef.h>      /* common defines and macros */
#include <MC9S12C128.h>     /* derivative information */
#include "PWM.h"
#pragma LINK_INFO DERIVATIVE "mc9s12c128"



void PWM_Init(void){

  
//PWMCTL = 0x0C ;   //select 8 bit mode
//PWMCAE = 1;       //center aligned disable , left aligned enable
//PWMCLK = 0;       // source is clock A
//PWMPOL =0;        // Start with low level--> 0 , start with high level --> 1 
//PWMPRCLK = 0x02;  // prescaler set to Eclock/4

PWMCTL = 0x3C ;   //select 8 bit mode
PWMCAE = 1;       //center aligned disable , left aligned enable
PWMCLK = 0;       // source is clock A
PWMPOL =2;        // Start with low level--> 0 , start with high level --> 1 
PWMPRCLK = 0x01;  // prescaler set to Eclock/1

  
}