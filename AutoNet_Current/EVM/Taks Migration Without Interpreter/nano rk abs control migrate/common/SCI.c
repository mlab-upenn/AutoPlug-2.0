#pragma CODE_SEG DEFAULT

#include <hidef.h>      /* common defines and macros */
#include <MC9S12C128.h> /* derivative information */
#include <stdlib.h>
#include <string.h>
//#include "common.h"
#include "SCI.h"
#include "nrk_task.h"
#pragma LINK_INFO DERIVATIVE "mc9s12c128"

uint8_t SCIData;
uint8_t SCIDataFlag;

/*****************************************************************************
 * Method: SCIInit
 * Used to Initialize the SCI module for debuging purposes
 *****************************************************************************/
void SCIInit(void)
{
    SCIBDH = BAUDH;
    SCIBDL = BAUDL;

    SCICR1 = 0x00;          /*SCI0CR2 = 0x0C;  8 bit, TE and RE set */
    SCICR2 = 0x2C;          /* TE and RE enable, Enable RX interrupt */
}

void SCITxBuf(uint8_t *buf, uint8_t length)
{
    uint8_t i;

    for(i = 0; i < length; i++)
    {
        SCITx(buf[i]);
    }
}

void SCITx(uint8_t cData)
{
    while(!SCISR1_TDRE) ;   /* ensure Tx data buffer empty */
    SCIDRL = cData;         /* load data to SCI2 register */
    while(!SCISR1_TC) ;     /* wait for Tx complete */
}

void SCITxStr(char *pStr)
{
    uint16_t i;
    uint16_t nStrLen = strlen( (const char *)pStr );

    for(i = 0; i < nStrLen; i++)
    {
        SCITx(pStr[i]);
    }
}

void SCITxPkt(void *data, uint8_t length)
{
    uint8_t txBuf[16];
    uint8_t chkSum = 0;
    uint8_t i;

    /* Packet format:
     * | 0xAA | 0xCC | Data | ... | Chksum |
     */

    if( length > (sizeof(txBuf) - 3) )
        return;

    txBuf[0] = 0xAA;
    txBuf[1] = 0xCC;

    memcpy(&txBuf[2], data, length);

    for(i = 0; i < 2 + length; i++)
    {
        chkSum ^= txBuf[i];
    }
    txBuf[2 + length] = chkSum;

    SCITxBuf(txBuf, 2 + length + 1);
}

uint8_t SCIRx(void)
{
    while(!SCISR1_RDRF) ;
    return (SCIDRL);
}

#pragma CODE_SEG DEFAULT