#ifndef _SCI_H
#define _SCI_H
    #include "nrk_task.h"
#define SCI_FBUS F_BUS
#define BAUDH 0
#define BAUDL (SCI_FBUS / 16 / 115200)

#pragma CODE_SEG DEFAULT

extern uint8_t SCIData;
extern uint8_t SCIDataFlag;

void SCIInit(void);
void SCITx(uint8_t cData);
void SCITxStr(char *pStr);
void SCITxBuf(uint8_t *buf, uint8_t length);
void SCITxPkt(void *data, uint8_t length);

uint8_t SCIRx(void);

#pragma CODE_SEG __NEAR_SEG NON_BANKED
interrupt void SCIRx_vect();
#pragma CODE_SEG DEFAULT

#endif