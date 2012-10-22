/***********************************************************************************

  Filename:     hal_cc2420.c

  Description:  This file provides access to CC2420 on-chip registers/RAM.

***********************************************************************************/


/***********************************************************************************
* INCLUDES
*/
#include "hal_board.h"
#include "hal_cc2420.h"

#include "assy_exp4618_cc2420em.h"

/***********************************************************************************
* LOCAL FUNCTIONS
*/


static uint8 _CC2420_SPI_TXRX(uint8 x)
{
    CC2420_SPI_TX(x);
    CC2420_SPI_WAIT_RXRDY();
    return CC2420_SPI_RX();
}

static void _CC2420_SPI_TX(uint8 x)
{
    CC2420_SPI_TX(x);
    CC2420_SPI_WAIT_RXRDY();
    CC2420_SPI_RX();
}


static uint8 _CC2420_SPI_RX(void)
{
    CC2420_SPI_TX(0);
    CC2420_SPI_WAIT_RXRDY();
    return CC2420_SPI_RX();
}


/***********************************************************************************
* GLOBAL FUNCTIONS
*/

void cc2420WriteReg(uint8 reg, uint16 v)
{
    CC2420_SPI_BEGIN();

    _CC2420_SPI_TX(reg);
    _CC2420_SPI_TX((uint8) ((v) >> 8));
    _CC2420_SPI_TX((uint8) (v));

    CC2420_SPI_END();
}


uint16 cc2420ReadReg(uint8 reg)
{
    uint16 v;

    CC2420_SPI_BEGIN();

    _CC2420_SPI_TX(reg | 0x40);
    v= _CC2420_SPI_RX() << 8;
    v|= _CC2420_SPI_RX();
    halWait(1);

    CC2420_SPI_END();

    return v;
}


void  cc2420ReadRxFifo(uint8 *p, uint8 n)
{
    CC2420_SPI_BEGIN();

    _CC2420_SPI_TX(CC2420_RXFIFO | 0x40);
    while (n>0) {
    	while (!CC2420_FIFO_IPIN);
        *p++= _CC2420_SPI_RX();
        n--;
    }

    CC2420_SPI_END();
}

void   cc2420ReadRxFifoNoWait(uint8 *p, uint8 n)
{
CC2420_SPI_BEGIN();

    _CC2420_SPI_TX(CC2420_RXFIFO | 0x40);
    while (n>0) {
    	*p++= _CC2420_SPI_RX();
        n--;
    }

    CC2420_SPI_END();
}

void cc2420WriteTxFifo(uint8 *p, uint8 n)
{
    CC2420_SPI_BEGIN();

    _CC2420_SPI_TX(CC2420_TXFIFO);

    while (n>0) {
        _CC2420_SPI_TX(*p++);
        n--;
    }
    CC2420_SPI_END();
}


void cc2420ReadRamLE(uint8 *p, uint16 addr, uint8 count)
{
    CC2420_SPI_BEGIN();
    // Read operation + A6:0
    _CC2420_SPI_TX(0x80 | (addr & 0x7F));
    // B1:0 + RAM bit
    _CC2420_SPI_TX( ((addr >> 1) & 0xC0) | 0x20);

    while(count>0) {
        *p++= _CC2420_SPI_RX();
        count--;
    }
    CC2420_SPI_END();
}

void cc2420ReadRam(uint8 *p, uint16 addr, uint8 count)
{
    CC2420_SPI_BEGIN();
    // Read operation + A6:0
    _CC2420_SPI_TX(0x80 | (addr & 0x7F));
    // B1:0 + RAM bit
    _CC2420_SPI_TX( ((addr >> 1) & 0xC0) | 0x20);

    while(count>0) {
    	count--;
        *(p+count)= _CC2420_SPI_RX();
        
    }
    CC2420_SPI_END();
}

void cc2420WriteRamLE(uint8 *p, uint16 addr, uint8 count)
{
    CC2420_SPI_BEGIN();
    // Read operation + A6:0
    _CC2420_SPI_TX(0x80 | (addr & 0x7F));
    // B1:0 + RAM bit
    _CC2420_SPI_TX( ((addr >> 1) & 0xC0));

    while(count>0) {
        _CC2420_SPI_TX(*p++);
        count--;
    }

    CC2420_SPI_END();
}

void   cc2420WriteRam(uint8 *p, uint16 addr, uint8 count)
{
	CC2420_SPI_BEGIN();
    // Read operation + A6:0
    _CC2420_SPI_TX(0x80 | (addr & 0x7F));
    // B1:0 + RAM bit
    _CC2420_SPI_TX( ((addr >> 1) & 0xC0));

    while(count>0) {
    	count--;
        _CC2420_SPI_TX(*(p+count));
        
    }

    CC2420_SPI_END();
}


uint8 cc2420GetStatus(void)
{
    uint8 s;

    CC2420_SPI_BEGIN();
    s= _CC2420_SPI_TXRX(CC2420_SNOP);
    CC2420_SPI_END();
    return s;
}


void cc2420Strobe(uint8 s)
{
    CC2420_SPI_BEGIN();
    _CC2420_SPI_TX(s);
    CC2420_SPI_END();
}

