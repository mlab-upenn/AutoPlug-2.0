#include <hidef.h>      /* common defines and macros */
#include <MC9S12C128.h>     /* derivative information */
#include "ADC.h"
#pragma LINK_INFO DERIVATIVE "mc9s12c128"

  
void ADCinit(void) {
  ATDCTL2 = 0xE0;
  wait20us();
  ATDCTL3 = 0x22;
  ATDCTL4 = 0x80;
   
}

void wait20us(void){
  TSCR1 = 0x90;
  TSCR2 = 0;
  TIOS = 0x01;
  TC0 = TCNT + 480;
  while(!(TFLG1_C0F));
}
  
  