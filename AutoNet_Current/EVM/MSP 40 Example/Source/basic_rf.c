/******************************************************************************
*  Nano-RK, a real-time operating system for sensor networks.
*  Copyright (C) 2007, Real-Time and Multimedia Lab, Carnegie Mellon University
*  All rights reserved.
*
*  This is the Open Source Version of Nano-RK included as part of a Dual
*  Licensing Model. If you are unsure which license to use please refer to:
*  http://www.nanork.org/nano-RK/wiki/Licensing
*
*  This program is free software: you can redistribute it and/or modify
*  it under the terms of the GNU General Public License as published by
*  the Free Software Foundation, version 2.0 of the License.
*
*  This program is distributed in the hope that it will be useful,
*  but WITHOUT ANY WARRANTY; without even the implied warranty of
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*  GNU General Public License for more details.
*
*  You should have received a copy of the GNU General Public License
*  along with this program.  If not, see <http://www.gnu.org/licenses/>.
*
*  Contributing Authors (specific to this file):
*  Chipcon Development Team
*  Anthony Rowe
*  Nuno Pereira
*  Bach Bui 
*******************************************************************************/

#include <include.h>
#include <basic_rf.h>
#include <ulib.h>
#include <nrk.h>
#include <nrk_events.h>
#include <nrk_error.h>
#include <nrk_timer.h>
#include <nrk_cpu.h>
#include "assy_exp4618_cc2420em.h"
#include <hal_cc2420.h>
//#ifndef RADIO_PRIORITY_CEILING
//  #define RADIO_PRIORITY_CEILING	20
//#endif

nrk_sem_t *radio_sem;
uint8_t auto_ack_enable;
uint8_t security_enable;
uint8_t last_pkt_encrypted;
uint16_t mdmctrl0;
uint8_t tx_ctr[4];
uint8_t rx_ctr[4];

// Returns 1 if the last packet was encrypted, 0 otherwise
uint8_t rf_security_last_pkt_status()
{
return last_pkt_encrypted;
}


void rf_security_set_ctr_counter(uint8_t *counter)
{
uint8_t n;
// CTR counter value
cc2420WriteRam(&counter[0],(CC2420RAM_TXNONCE+9),2); 
cc2420WriteRam(&counter[2],(CC2420RAM_TXNONCE+11),2); 
tx_ctr[0]=counter[0];
tx_ctr[1]=counter[1];
tx_ctr[2]=counter[2];
tx_ctr[3]=counter[3];
}


void rf_security_set_key(uint8_t *key)
{
uint8_t n,i;
uint16_t key_buf;

// Set AES key
nrk_spin_wait_us(100); 
for(i=0; i<8; i++ )
	{
    	key_buf=(key[i]<<8)|key[i+1]; 
   	nrk_spin_wait_us(100); 
    	cc2420WriteRamLE((uint8 *)&key_buf,(CC2420RAM_KEY0+(i*2)),2); 
	}

// Set AES nonce to all zeros
nrk_spin_wait_us(100); 
for(i=0; i<7; i++ )
	{
    	key_buf=0; 
    	cc2420WriteRamLE((uint8 *)&key_buf,(CC2420RAM_TXNONCE+(i*2)),2); 
    	cc2420WriteRamLE((uint8 *)&key_buf,(CC2420RAM_RXNONCE+(i*2)),2); 
	}
	// block counter set 1
    	key_buf=1; 
    	cc2420WriteRamLE((uint8 *)&key_buf,(CC2420RAM_TXNONCE+14),2); 
    	cc2420WriteRamLE((uint8 *)&key_buf,(CC2420RAM_RXNONCE+14),2); 
}

void rf_security_enable(uint8_t *key)
{
    cc2420WriteReg(CC2420_SECCTRL0, 0x0306); // Enable CTR encryption with key 0
    cc2420WriteReg(CC2420_SECCTRL1, 0x0e0e); // Encrypt / Decrypt 18 bytes into header

security_enable=1;
}



void rf_security_disable()
{
  cc2420WriteReg(CC2420_SECCTRL0, 0x01C4); // Turn off "Security enable"
  security_enable=0;
}

//-------------------------------------------------------------------------------------------------------
// The RF settings structure is declared here, since we'll always need halRfInit()
volatile RF_SETTINGS rfSettings;
volatile uint8_t rx_ready;
//-------------------------------------------------------------------------------------------------------
nrk_sem_t* rf_get_sem()
{
return radio_sem;
}

void rf_tx_power(uint8_t pwr)
{
uint16_t tmp;
    //tmp=0x5070;
#ifdef RADIO_PRIORITY_CEILING
    nrk_sem_pend (radio_sem);
#endif
    tmp=0xA0E0;
    tmp=tmp | (pwr&0x1F);  
    cc2420WriteReg(CC2420_TXCTRL, tmp);   // Set the FIFOP threshold to maximum
#ifdef RADIO_PRIORITY_CEILING
    nrk_sem_post(radio_sem);
#endif
}
void rf_set_channel( uint8_t channel )
{
#ifdef RADIO_PRIORITY_CEILING
    nrk_sem_pend (radio_sem);
#endif
    halRfSetChannel(channel);
#ifdef RADIO_PRIORITY_CEILING
    nrk_sem_post(radio_sem);
#endif
}


void rf_addr_decode_enable()
{
    mdmctrl0 |= 0x0800;
    cc2420WriteReg(CC2420_MDMCTRL0, mdmctrl0);
}

void rf_addr_decode_disable()
{
    mdmctrl0 &= (~0x0800);
    cc2420WriteReg(CC2420_MDMCTRL0, mdmctrl0);
}


void rf_auto_ack_enable()
{
    auto_ack_enable=1;
    mdmctrl0 |= 0x0010;
    cc2420WriteReg(CC2420_MDMCTRL0, mdmctrl0); 
}

void rf_auto_ack_disable()
{
    auto_ack_enable=0;
    mdmctrl0 &= (~0x0010);
    cc2420WriteReg(CC2420_MDMCTRL0, mdmctrl0);  
}


void rf_addr_decode_set_my_mac(uint16_t my_mac)
{
uint8_t n;
    rfSettings.myAddr = my_mac;
    nrk_spin_wait_us(500);
    cc2420WriteRamLE((uint8 *)&my_mac, CC2420RAM_SHORTADDR, 2);
    nrk_spin_wait_us(500);
}



void rf_set_rx(RF_RX_INFO *pRRI, uint8_t channel )
{

#ifdef RADIO_PRIORITY_CEILING
    nrk_sem_pend (radio_sem);
#endif

    cc2420Strobe(CC2420_SFLUSHRX);
    cc2420Strobe(CC2420_SFLUSHRX);
    halRfSetChannel(channel);
    rfSettings.pRxInfo = pRRI;

#ifdef RADIO_PRIORITY_CEILING
    nrk_sem_post(radio_sem);
#endif
}
//-------------------------------------------------------------------------------------------------------
//  void rf_init(RF_RX_INFO *pRRI, uint8_t channel, WORD panId, WORD myAddr)
//
//  DESCRIPTION:
//      Initializes CC2420 for radio communication via the basic RF library functions. Turns on the
//		voltage regulator, resets the CC2420, turns on the crystal oscillator, writes all necessary
//		registers and protocol addresses (for automatic address recognition). Note that the crystal
//		oscillator will remain on (forever).
//
//  ARGUMENTS:
//      RF_RX_INFO *pRRI
//          A pointer the RF_RX_INFO data structure to be used during the first packet reception.
//			The structure can be switched upon packet reception.
//      uint8_t channel
//          The RF channel to be used (11 = 2405 MHz to 26 = 2480 MHz)
//      WORD panId
//          The personal area network identification number
//      WORD myAddr
//          The 16-bit short address which is used by this node. Must together with the PAN ID form a
//			unique 32-bit identifier to avoid addressing conflicts. Normally, in a 802.15.4 network, the
//			short address will be given to associated nodes by the PAN coordinator.
//-------------------------------------------------------------------------------------------------------
void rf_init(RF_RX_INFO *pRRI, uint8_t channel, uint16_t panId, uint16_t myAddr) {
    uint8_t n;
    uint16_t f;
    uint8_t spiStatusByte;
#ifdef RADIO_PRIORITY_CEILING
   int8_t v;
    radio_sem = nrk_sem_create(1,RADIO_PRIORITY_CEILING);
    if (radio_sem == NULL)
      nrk_kernel_error_add (NRK_SEMAPHORE_CREATE_ERROR, nrk_get_pid ());

  v = nrk_sem_pend (radio_sem);
  if (v == NRK_ERROR) {
    nrk_kprintf (PSTR ("CC2420 ERROR:  Access to semaphore failed\r\n"));
  }
#endif

    // Make sure that the voltage regulator is on, and that the reset pin is inactive
    SET_VREG_ACTIVE();
    halWait(1000);
    SET_RESET_ACTIVE();
    halWait(1);
    SET_RESET_INACTIVE();
    halWait(100);

    // Initialize the FIFOP external interrupt
    //FIFOP_INT_INIT();
    //ENABLE_FIFOP_INT();

    // Turn off all interrupts while we're accessing the CC2420 registers
	DISABLE_GLOBAL_INT();

    // Register modifications
    cc2420Strobe(CC2420_SXOSCOFF);
    cc2420Strobe(CC2420_SXOSCON);
    mdmctrl0=0x02E2;
    cc2420WriteReg(CC2420_MDMCTRL0, mdmctrl0);  // Std Preamble, CRC, no auto ack, no hw addr decoding 
    //FASTSPI_SETREG(CC2420_MDMCTRL0, 0x0AF2);  // Turn on automatic packet acknowledgment
						// Turn on hw addre decoding 
    cc2420WriteReg(CC2420_MDMCTRL1, 0x0500); // Set the correlation threshold = 20
    cc2420WriteReg(CC2420_IOCFG0, 0x007F);   // Set the FIFOP threshold to maximum
    cc2420WriteReg(CC2420_SECCTRL0, 0x01C4); // Turn off "Security"
    cc2420WriteReg(CC2420_RXCTRL1, 0x1A56); // All default except
					    // reference bias current to RX
					    // bandpass filter is set to 3uA 

/*
    // FIXME: remove later for auto ack
    myAddr=MY_MAC;
    panId=0x02;
    FASTSPI_SETREG(CC2420_MDMCTRL0, 0x0AF2);  // Turn on automatic packet acknowledgment
//    FASTSPI_SETREG(CC2420_MDMCTRL0, 0x0AE2);  // Turn on automatic packet acknowledgment
    nrk_spin_wait_us(500);
    nrk_spin_wait_us(500);
    FASTSPI_WRITE_RAM_LE(&myAddr, CC2420RAM_SHORTADDR, 2, n);
    nrk_spin_wait_us(500);
    FASTSPI_WRITE_RAM_LE(&panId, CC2420RAM_PANID, 2, n);
    nrk_spin_wait_us(500);
    
   printf( "myAddr=%d\r\n",myAddr );
*/

    nrk_spin_wait_us(500);
    cc2420WriteRamLE((uint8 *)&panId, CC2420RAM_PANID, 2);
    nrk_spin_wait_us(500);

  	ENABLE_GLOBAL_INT();

    // Set the RF channel
    //halRfSetChannel(channel);
    
	
	
	
	
	f= cc2420ReadReg(CC2420_FSCTRL);

    // Mask bit 0-9 to 0
    f &= 0x3C00;

    // Set bit 0-9
    f |= 357 + ((channel - 11) * 5)+0x4000;

    DISABLE_GLOBAL_INT();
	cc2420WriteReg(CC2420_FSCTRL, f);
	ENABLE_GLOBAL_INT();

    // Turn interrupts back on
	ENABLE_GLOBAL_INT();

	// Set the protocol configuration
	rfSettings.pRxInfo = pRRI;
	rfSettings.panId = panId;
	rfSettings.myAddr = myAddr;
	rfSettings.txSeqNumber = 0;
        rfSettings.receiveOn = FALSE;

	// Wait for the crystal oscillator to become stable
    //halRfWaitForCrystalOscillator();
      

    // Poll the SPI status byte until the crystal oscillator is stable
    do {
	    DISABLE_GLOBAL_INT();
	    spiStatusByte=cc2420GetStatus();
	    ENABLE_GLOBAL_INT();
    } while (!(spiStatusByte & (BM(CC2420_XOSC16M_STABLE))));



	// Write the short address and the PAN ID to the CC2420 RAM (requires that the XOSC is on and stable)
   //	DISABLE_GLOBAL_INT();
//    FASTSPI_WRITE_RAM_LE(&myAddr, CC2420RAM_SHORTADDR, 2, n);
//    FASTSPI_WRITE_RAM_LE(&panId, CC2420RAM_PANID, 2, n);
  //	ENABLE_GLOBAL_INT();

#ifdef RADIO_PRIORITY_CEILING
  v = nrk_sem_post (radio_sem);
  if (v == NRK_ERROR) {
    nrk_kprintf (PSTR ("CC2420 ERROR:  Release of semaphore failed\r\n"));
    _nrk_errno_set (2);
  }
#endif

auto_ack_enable=0;
security_enable=0;
last_pkt_encrypted=0;
} // rf_init() 


//-------------------------------------------------------------------------------------------------------
//  void rf_rx_on(void)
//
//  DESCRIPTION:
//      Enables the CC2420 receiver and the FIFOP interrupt. When a packet is received through this
//      interrupt, it will call rf_rx_callback(...), which must be defined by the application
//-------------------------------------------------------------------------------------------------------
void rf_rx_on(void) {
#ifdef RADIO_PRIORITY_CEILING
    nrk_sem_pend (radio_sem);
#endif
    	rfSettings.receiveOn = TRUE;
	cc2420Strobe(CC2420_SFLUSHRX);
	cc2420Strobe(CC2420_SRXON);
	
	rx_ready=0;
#ifdef RADIO_PRIORITY_CEILING
    nrk_sem_post(radio_sem);
#endif
    //	ENABLE_FIFOP_INT();
} // rf_rx_on() 

void rf_polling_rx_on(void) {
#ifdef RADIO_PRIORITY_CEILING
    nrk_sem_pend (radio_sem);
#endif
    	rfSettings.receiveOn = TRUE;
	cc2420Strobe(CC2420_SFLUSHRX);
	cc2420Strobe(CC2420_SRXON);
	
	rx_ready=0;
#ifdef RADIO_PRIORITY_CEILING
    nrk_sem_post(radio_sem);
#endif
} // rf_rx_on() 


/**********************************************************
// Here is a sample of the rf_rx_callback() that should
// be placed in your application

RF_RX_INFO* rf_rx_callback(RF_RX_INFO *pRRI) {
	// Its okay to leave this empty...    
	return pRRI;
}  
***********************************************************/




//-------------------------------------------------------------------------------------------------------
//  void rf_rx_off(void)
//
//  DESCRIPTION:
//      Disables the CC2420 receiver and the FIFOP interrupt.
//-------------------------------------------------------------------------------------------------------
void rf_rx_off(void) {
#ifdef RADIO_PRIORITY_CEILING
    nrk_sem_pend (radio_sem);
#endif
	// XXX
    	//SET_VREG_INACTIVE();	
	rfSettings.receiveOn = FALSE;
	cc2420Strobe(CC2420_SRFOFF);
	rx_ready=0;
#ifdef RADIO_PRIORITY_CEILING
    nrk_sem_post(radio_sem);
#endif
    //	DISABLE_FIFOP_INT();
} // rf_rx_off() 


/**************************************************************************
This function is the same as normal TX, only it waits until the last
second to send the duty out with the high speed timer.  And by duty, I mean
the packet BIATCH...
**************************************************************************/
uint8_t rf_tx_tdma_packet(volatile RF_TX_INFO *pRTI, uint16_t slot_start_time, uint16_t tx_guard_time) {
	uint16_t frameControlField;
    	uint8_t packetLength;
    	uint8_t success;
    	uint8_t spiStatusByte;
   	uint8_t checksum,i;
	uint8_t timestamp;

#ifdef RADIO_PRIORITY_CEILING
nrk_sem_pend (radio_sem);
#endif
	timestamp=_nrk_os_timer_get();
	// XXX 2 below are hacks...
	cc2420Strobe(CC2420_SFLUSHRX);
	cc2420Strobe(CC2420_SFLUSHRX);
    // Wait until the transceiver is idle
     while (CC2420_FIFOP_IPIN || CC2420_SFD_IPIN);
    // Turn off global interrupts to avoid interference on the SPI interface
      DISABLE_GLOBAL_INT();
	// Flush the TX FIFO just in case...
	cc2420Strobe(CC2420_SFLUSHTX);
	cc2420Strobe(CC2420_SFLUSHTX);

    checksum=0;
    for(i=0; i<pRTI->length; i++ )
    {
	// lets do our own payload checksum because we don't trust the CRC
	checksum+=pRTI->pPayload[i];
    }
    packetLength = pRTI->length + RF_PACKET_OVERHEAD_SIZE + CHECKSUM_OVERHEAD;
    //nrk_set_led(3);
    //do { } while(_nrk_get_high_speed_timer()<(tx_guard_time));
    
    // Write the packet to the TX FIFO (the FCS is appended automatically when AUTOCRC is enabled)
    // These are only the MAC AGNOSTIC parameters...
    // Slots for example are at a higher layer since they assume TDMA
    
    cc2420WriteTxFifo((uint8_t*)&packetLength, 1);               // Packet length
    frameControlField = pRTI->ackRequest ? RF_FCF_ACK : RF_FCF_NOACK;
    cc2420WriteTxFifo((uint8_t*) &frameControlField, 2);         // Frame control field
    cc2420WriteTxFifo((uint8_t*) &rfSettings.txSeqNumber, 1);    // Sequence number
    cc2420WriteTxFifo((uint8_t*) &rfSettings.panId, 2);          // Dest. PAN ID
    cc2420WriteTxFifo((uint8_t*) &pRTI->destAddr, 2);            // Dest. address
    cc2420WriteTxFifo((uint8_t*) &rfSettings.myAddr, 2);         // Source address
    //P1OUT |= (0x01);
    nrk_high_speed_timer_wait(slot_start_time,tx_guard_time);
    
    //nrk_clr_led(3);
    /*
	DISABLE_GLOBAL_INT();
     nrk_set_led(3);
    last=0;
	do {
	if(last==_nrk_get_high_speed_timer())
		{
		//while(1)
		//printf( "TX ERROR %d vs %d\r\n",_nrk_get_high_speed_timer(),tx_guard_time );
		break;
		}	
	last=_nrk_get_high_speed_timer();
	}
	while((volatile)last<(tx_guard_time));
     
    ENABLE_GLOBAL_INT();
	nrk_clr_led(3);
*/
/*
    // Turn on RX if necessary
    if (!rfSettings.receiveOn) {
		FASTSPI_STROBE(CC2420_SRXON);
		}

    // Wait for the RSSI value to become valid
    do {
        FASTSPI_UPD_STATUS(spiStatusByte);
    } while (!(spiStatusByte & BM(CC2420_RSSI_VALID)));

	// TX begins after the CCA check has passed
    do {
		FASTSPI_STROBE(CC2420_STXONCCA);
		FASTSPI_UPD_STATUS(spiStatusByte);
		halWait(100);
    } while (!(spiStatusByte & BM(CC2420_TX_ACTIVE)));
*/
if (pRTI->cca == TRUE)
    {
    uint8_t cnt;
      if (!rfSettings.receiveOn)
	{
	  cc2420Strobe (CC2420_SRXON);
	}

      // Wait for the RSSI value to become valid
      do
	{
	  spiStatusByte=cc2420GetStatus ();
	}
      while (!(spiStatusByte & BM (CC2420_RSSI_VALID)));

      // TX begins after the CCA check has passed
      cnt = 0;
      do
	{
	  cc2420Strobe (CC2420_STXONCCA);
	  spiStatusByte=cc2420GetStatus ();
	  cnt++;
	  if (cnt > 100)
	    {
	      ENABLE_GLOBAL_INT ();
		nrk_sem_post(radio_sem);
	      return FALSE;
	    }
	  halWait (100);
	}
      while (!(spiStatusByte & BM (CC2420_TX_ACTIVE)));
    }
  else
    cc2420Strobe (CC2420_STXON);
	 //nrk_gpio_set(DEBUG_0);


    // Fill in the rest of the packet now
    cc2420WriteTxFifo((uint8_t*) pRTI->pPayload, pRTI->length);  // Payload
    cc2420WriteTxFifo((uint8_t*) &checksum, 1);         // Checksum


   
    //nrk_spin_wait_us(200);
//  FASTSPI_STROBE(CC2420_STXON);
   // Wait for the transmission to begin before exiting (makes sure that this function cannot be called
	// a second time, and thereby cancelling the first transmission (observe the FIFOP + SFD test above).
	while (!CC2420_SFD_IPIN);
	success = TRUE;

	// Turn interrupts back on
//	ENABLE_GLOBAL_INT();

    // Wait for the acknowledge to be received, if any
    /*if (pRTI->ackRequest) {
		rfSettings.ackReceived = FALSE;

		// Wait for the SFD to go low again
		while (SFD_IS_1);
        // We'll enter RX automatically, so just wait until we can be sure that the ack reception should have finished
        // The timeout consists of a 12-symbol turnaround time, the ack packet duration, and a small margin
        halWait((12 * RF_SYMBOL_DURATION) + (RF_ACK_DURATION) + (2 * RF_SYMBOL_DURATION) + 100);

		// If an acknowledgment has been received (by the FIFOP interrupt), the ackReceived flag should be set
		success = rfSettings.ackReceived;
    }*/

    
	// Turn off the receiver if it should not continue to be enabled
    DISABLE_GLOBAL_INT();
    // XXX hack, temp out
    //if (!rfSettings.receiveOn) { while (SFD_IS_1); /*FASTSPI_STROBE(CC2420_SRFOFF);*/ }
    // while (SFD_IS_1); 
    while (CC2420_SFD_IPIN); // wait for packet to finish
    	
	cc2420Strobe(CC2420_SFLUSHRX);
	cc2420Strobe(CC2420_SFLUSHRX);
	cc2420Strobe(CC2420_SFLUSHTX);
	cc2420Strobe(CC2420_SFLUSHTX);

cc2420Strobe(CC2420_SRFOFF);  // shut off radio
    ENABLE_GLOBAL_INT();
    

    // Increment the sequence number, and return the result
    rfSettings.txSeqNumber++;
//	while (SFD_IS_1);
#ifdef RADIO_PRIORITY_CEILING
nrk_sem_post(radio_sem);
#endif
   
    return success;

}

//-------------------------------------------------------------------------------------------------------
//  BYTE rf_tx_packet(RF_TX_INFO *pRTI)
//
//  DESCRIPTION:
//		Transmits a packet using the IEEE 802.15.4 MAC data packet format with short addresses. CCA is
//		measured only once before backet transmission (not compliant with 802.15.4 CSMA-CA).
//		The function returns:
//			- When pRTI->ackRequest is FALSE: After the transmission has begun (SFD gone high)
//			- When pRTI->ackRequest is TRUE: After the acknowledgment has been received/declared missing.
//		The acknowledgment is received through the FIFOP interrupt.
//
//  ARGUMENTS:
//      RF_TX_INFO *pRTI
//          The transmission structure, which contains all relevant info about the packet.
//
//  RETURN VALUE:
//		uint8_t
//			Successful transmission (acknowledgment received)
//-------------------------------------------------------------------------------------------------------
uint8_t rf_tx_packet(RF_TX_INFO *pRTI) {
	uint16_t frameControlField;
    uint8_t packetLength, length;
    uint8_t success;
    uint8_t spiStatusByte;
   uint8_t checksum,i;
	
#ifdef RADIO_PRIORITY_CEILING
nrk_sem_pend(radio_sem);
#endif

if(security_enable)
    cc2420Strobe(CC2420_STXENC);

    checksum=0;
    for(i=0; i<pRTI->length; i++ )
    {
	// lets do our own payload checksum because we don't trust the CRC
	checksum+=pRTI->pPayload[i];
    }
    // Write the packet to the TX FIFO (the FCS is appended automatically when AUTOCRC is enabled)

    // These are only the MAC AGNOSTIC parameters...
    // Slots for example are at a slighly higher later since they assume TDMA
    packetLength = pRTI->length + RF_PACKET_OVERHEAD_SIZE + CHECKSUM_OVERHEAD;
    if(security_enable) packetLength+=4;  // for CTR counter


   	// XXX 2 below are hacks...
	//FASTSPI_STROBE(CC2420_SFLUSHRX);
	//FASTSPI_STROBE(CC2420_SFLUSHRX);
    // Wait until the transceiver is idle
    while (CC2420_FIFOP_IPIN || CC2420_SFD_IPIN);
    // Turn off global interrupts to avoid interference on the SPI interface
    DISABLE_GLOBAL_INT();
	// Flush the TX FIFO just in case...
    cc2420Strobe(CC2420_SFLUSHTX);
    cc2420Strobe(CC2420_SFLUSHTX);

/*
    // Turn on RX if necessary
    if (!rfSettings.receiveOn) {
		FASTSPI_STROBE(CC2420_SRXON);
		}

    // Wait for the RSSI value to become valid
    do {
        FASTSPI_UPD_STATUS(spiStatusByte);
    } while (!(spiStatusByte & BM(CC2420_RSSI_VALID)));

	// TX begins after the CCA check has passed
    do {
		FASTSPI_STROBE(CC2420_STXONCCA);
		FASTSPI_UPD_STATUS(spiStatusByte);
		halWait(100);
    } while (!(spiStatusByte & BM(CC2420_TX_ACTIVE)));
*/

    cc2420WriteTxFifo((uint8_t*)&packetLength, 1);               // Packet length
    frameControlField = RF_FCF_NOACK;   // default
    if(auto_ack_enable) frameControlField |= RF_ACK_BM;
    if(security_enable) frameControlField |= RF_SEC_BM;
    cc2420WriteTxFifo((uint8_t*) &frameControlField, 2);         // Frame control field
    cc2420WriteTxFifo((uint8_t*) &rfSettings.txSeqNumber, 1);    // Sequence number
    cc2420WriteTxFifo((uint8_t*) &rfSettings.panId, 2);          // Dest. PAN ID
    cc2420WriteTxFifo((uint8_t*) &pRTI->destAddr, 2);            // Dest. address
    cc2420WriteTxFifo((uint8_t*) &rfSettings.myAddr, 2);         // Source address
    if(security_enable)
    	cc2420WriteTxFifo((uint8_t*) &tx_ctr, 4);         // CTR counter 
   
    cc2420WriteTxFifo((uint8_t*) pRTI->pPayload, pRTI->length);  // Payload
    cc2420WriteTxFifo((uint8_t*) &checksum, 1);         // Checksum

if (pRTI->cca == TRUE)
{
    uint8_t cnt;
     if (!rfSettings.receiveOn)
	{
	  cc2420Strobe (CC2420_SRXON);
	}
      
      // Wait for the RSSI value to become valid
      do
	{
	  spiStatusByte=cc2420GetStatus ();
	}
      while (!(spiStatusByte & BM (CC2420_RSSI_VALID)));      
      // TX begins after the CCA check has passed
      cnt = 0;
      do
	{
	  cc2420Strobe (CC2420_STXONCCA);
	  spiStatusByte=cc2420GetStatus ();
	  cnt++;
	  if (cnt > 100)
	    {
	      ENABLE_GLOBAL_INT ();
	      nrk_sem_post(radio_sem);
	      return FALSE;
	    }
	  halWait (100);
	}
      while (!(spiStatusByte & BM (CC2420_TX_ACTIVE)));
    }
  else
    cc2420Strobe (CC2420_STXON); 


  ENABLE_GLOBAL_INT();
	// Wait for the transmission to begin before exiting (makes sure that this function cannot be called
	// a second time, and thereby cancelling the first transmission (observe the FIFOP + SFD test above).
  while (!CC2420_SFD_IPIN);
  success = TRUE;

	// Turn interrupts back on
//	ENABLE_GLOBAL_INT();

    while (CC2420_SFD_IPIN); // wait for packet to finish

    // Wait for the acknowledge to be received, if any
    if (auto_ack_enable) {
//		rfSettings.ackReceived = FALSE;

		// Wait for the SFD to go low again
		//	while (SFD_IS_1);
        // We'll enter RX automatically, so just wait until we can be sure that the 
	// ack reception should have finished
        // The timeout consists of a 12-symbol turnaround time, the ack packet duration, 
	// and a small margin
        halWait((12 * RF_SYMBOL_DURATION) + (RF_ACK_DURATION) + (2 * RF_SYMBOL_DURATION) + 100);

	if(CC2420_FIFO_IPIN)
	{
	FASTSPI_READ_FIFO_BYTE(length);
	length &= RF_LENGTH_MASK; // Ignore MSB
	    success = TRUE;

	}else
	{
	    cc2420Strobe(CC2420_SFLUSHRX);
	    cc2420Strobe(CC2420_SFLUSHRX);
	    success = FALSE;
	}

    }

    
	// Turn off the receiver if it should not continue to be enabled
    
    DISABLE_GLOBAL_INT();	
	//FASTSPI_STROBE(CC2420_SFLUSHRX);
	//FASTSPI_STROBE(CC2420_SFLUSHRX);
	//FASTSPI_STROBE(CC2420_SFLUSHTX);
	//FASTSPI_STROBE(CC2420_SFLUSHTX);
    
	cc2420Strobe(CC2420_SRFOFF);  // shut off radio
    ENABLE_GLOBAL_INT();

    // agr XXX hack to test time issue
    //rf_rx_on(); 

    // Increment the sequence number, and return the result
    rfSettings.txSeqNumber++;
//	while (SFD_IS_1);
#ifdef RADIO_PRIORITY_CEILING
nrk_sem_post(radio_sem);
#endif
    return success;

}

uint8_t rf_busy()
{
return CC2420_SFD_IPIN;
}

uint8_t rf_rx_check_fifop()
{
return CC2420_FIFOP_IPIN;
}


uint8_t rf_rx_check_sfd()
{
return CC2420_SFD_IPIN;
}
uint16_t tmp_blah;

int8_t rf_polling_rx_packet()
{
uint8_t tmp;
	
#ifdef RADIO_PRIORITY_CEILING
nrk_sem_pend(radio_sem);
#endif

    if(CC2420_FIFOP_IPIN )
    {
	uint16_t frameControlField;
	int8_t length;
	uint8_t pFooter[2];
	uint8_t checksum,rx_checksum,i;
			
	last_pkt_encrypted=0;

//	FASTSPI_STROBE(CC2420_SRXON);
//	FASTSPI_STROBE(CC2420_SFLUSHRX);
    
//	while(!SFD_IS_1);
//  XXX Need to make sure SFD has gone down to be sure packet finished!
//	while(SFD_IS_1);
    // Clean up and exit in case of FIFO overflow, which is indicated by FIFOP = 1 and FIFO = 0
	if((CC2420_FIFOP_IPIN) && (!(CC2420_FIFO_IPIN))) {	   
	    // always read 1 byte before flush (data sheet pg 62)
	    FASTSPI_READ_FIFO_BYTE(tmp);  
	    cc2420Strobe(CC2420_SFLUSHRX);
	    cc2420Strobe(CC2420_SFLUSHRX);
#ifdef RADIO_PRIORITY_CEILING
	    nrk_sem_post(radio_sem);
#endif
	    return -1;
	}

	// Payload length
	FASTSPI_READ_FIFO_BYTE(length);
	length &= RF_LENGTH_MASK; // Ignore MSB
    // Ignore the packet if the length is too short
    if(length<=0){  
	    // always read 1 byte before flush (data sheet pg 62)
	    FASTSPI_READ_FIFO_BYTE(tmp);  
	    cc2420Strobe(CC2420_SFLUSHRX);
	    cc2420Strobe(CC2420_SFLUSHRX);
#ifdef RADIO_PRIORITY_CEILING
	    nrk_sem_post(radio_sem);
#endif
	return -2;
	}
    if (length < (RF_PACKET_OVERHEAD_SIZE + CHECKSUM_OVERHEAD)/*RF_ACK_PACKET_SIZE*/ || (length-RF_PACKET_OVERHEAD_SIZE)> rfSettings.pRxInfo->max_length) {
    	FASTSPI_READ_FIFO_GARBAGE(length);
	    FASTSPI_READ_FIFO_BYTE(tmp);  
	    cc2420Strobe(CC2420_SFLUSHRX);
	    cc2420Strobe(CC2420_SFLUSHRX);
#ifdef RADIO_PRIORITY_CEILING
	    nrk_sem_post(radio_sem);
#endif
	return -3;
	//printf_u( "Bad length: %d %d\n",length, rfSettings.pRxInfo->max_length );
    // Otherwise, if the length is valid, then proceed with the rest of the packet
    } else {
        // Register the payload length
        rfSettings.pRxInfo->length = length - RF_PACKET_OVERHEAD_SIZE - CHECKSUM_OVERHEAD;
        // Read the frame control field and the data sequence number
        cc2420ReadRxFifoNoWait((uint8_t*) &frameControlField, 2);
        rfSettings.pRxInfo->ackRequest = !!(frameControlField & RF_FCF_ACK_BM);
    	FASTSPI_READ_FIFO_BYTE(rfSettings.pRxInfo->seqNumber);

		// Is this an acknowledgment packet?
/*
    	if ((length == RF_ACK_PACKET_SIZE) && (frameControlField == RF_ACK_FCF) && (rfSettings.pRxInfo->seqNumber == rfSettings.txSeqNumber)) {

 	       	// Read the footer and check for CRC OK
			FASTSPI_READ_FIFO_NO_WAIT((uint8_t*) pFooter, 2);

			// Indicate the successful ack reception (this flag is polled by the transmission routine)
			if (pFooter[1] & RF_CRC_OK_BM) rfSettings.ackReceived = TRUE;
 
		// Too small to be a valid packet?
		} else if (length < RF_PACKET_OVERHEAD_SIZE) {
			FASTSPI_READ_FIFO_GARBAGE(length - 3);

		// Receive the rest of the packet
		} else {
*/
			// Skip the destination PAN and address (that's taken care of by harware address recognition!)
		FASTSPI_READ_FIFO_GARBAGE(4);

			// Read the source address
			cc2420ReadRxFifoNoWait((uint8_t*) &rfSettings.pRxInfo->srcAddr, 2);

		        if(frameControlField & RF_SEC_BM)
			{
				uint8_t n;
				// READ rx_ctr and set it
				cc2420ReadRxFifoNoWait((uint8_t*) &rx_ctr, 4);
				cc2420WriteRam(&rx_ctr[0],(CC2420RAM_RXNONCE+9),2); 
				cc2420WriteRam(&rx_ctr[2],(CC2420RAM_RXNONCE+11),2); 
				cc2420Strobe(CC2420_SRXDEC);  // if packet is encrypted then decrypt 
				last_pkt_encrypted=1;
        			rfSettings.pRxInfo->length -= 4;
			}
	
			// Read the packet payload
			cc2420ReadRxFifoNoWait(rfSettings.pRxInfo->pPayload, rfSettings.pRxInfo->length);
			cc2420ReadRxFifoNoWait(&rx_checksum, 1 );

			// Read the footer to get the RSSI value
			cc2420ReadRxFifoNoWait((uint8_t*) pFooter, 2);
			rfSettings.pRxInfo->rssi = pFooter[0];
			checksum=0;	
			for(i=0; i<rfSettings.pRxInfo->length; i++ )
			{
				checksum+=rfSettings.pRxInfo->pPayload[i];
				//printf( "%d ", rfSettings.pRxInfo->pPayload[i]);
			}

			if(checksum!=rx_checksum) {
				//printf( "Checksum failed %d %d\r",rx_checksum, checksum );
	    			// always read 1 byte before flush (data sheet pg 62)
	   			FASTSPI_READ_FIFO_BYTE(tmp);  
	    			cc2420Strobe(CC2420_SFLUSHRX);
	    			cc2420Strobe(CC2420_SFLUSHRX);
#ifdef RADIO_PRIORITY_CEILING
	    			nrk_sem_post(radio_sem);
#endif
				return -4;
			}	
			if (pFooter[1] & RF_CRC_OK_BM) {
				//rfSettings.pRxInfo = rf_rx_callback(rfSettings.pRxInfo);
				rx_ready++;
#ifdef RADIO_PRIORITY_CEILING
	    			nrk_sem_post(radio_sem);
#endif
				return 1;
			} else
	    		{
	    		// always read 1 byte before flush (data sheet pg 62)
	   		FASTSPI_READ_FIFO_BYTE(tmp);  
			cc2420Strobe(CC2420_SFLUSHRX);
	    		cc2420Strobe(CC2420_SFLUSHRX);
#ifdef RADIO_PRIORITY_CEILING
	    		nrk_sem_post(radio_sem);
#endif
			return -5;
			}
//		}
    
	}


    }
#ifdef RADIO_PRIORITY_CEILING
nrk_sem_post(radio_sem);
#endif
return 0;
}

int8_t rf_rx_packet()
{
int8_t tmp;
if(rx_ready>0) { tmp=rx_ready; rx_ready=0; return tmp;}
return 0;
}


inline void rf_flush_rx_fifo()
{
        cc2420Strobe(CC2420_SFLUSHRX);
        cc2420Strobe(CC2420_SFLUSHRX);
}

void rf_set_cca_thresh(int8_t t)
{
// default is -32
// Higher number is less sensitive
uint16_t val;
#ifdef RADIO_PRIORITY_CEILING
nrk_sem_pend(radio_sem);
#endif

val=(t<<8) | 0x80;
cc2420WriteReg(CC2420_RSSI, val); 

#ifdef RADIO_PRIORITY_CEILING
nrk_sem_post(radio_sem);
#endif
}

void rf_test_mode()
{

#ifdef RADIO_PRIORITY_CEILING
nrk_sem_pend(radio_sem);
#endif
        cc2420Strobe(CC2420_SRFOFF); //stop radio
	// NOTE ON SETTING CC2420_MDMCTRL1
	// 
	// RF studio" uses TX_MODE=3 (CC2420_MDMCTRL1=0x050C)
	// to send an unmodulated carrier; data sheet says TX_MODE 
	// can be 2 or 3. So it should not matter...
	// HOWEVER, using (TX_MODE=3) sometimes causes problems when 
	// going back to "data" mode!
	cc2420WriteReg(CC2420_MDMCTRL1, 0x0508); // MDMCTRL1 with TX_MODE=2
	cc2420WriteReg(CC2420_DACTST, 0x1800); // send unmodulated carrier
	rf_flush_rx_fifo();

#ifdef RADIO_PRIORITY_CEILING
nrk_sem_post(radio_sem);
#endif
}


/**********************************************************
 * set the radio into "normal" mode (buffered TXFIFO) and go into (data) receive */
void rf_data_mode() {
#ifdef RADIO_PRIORITY_CEILING
nrk_sem_pend(radio_sem);
#endif
        cc2420Strobe(CC2420_SRFOFF); //stop radio
        cc2420WriteReg(CC2420_MDMCTRL1, 0x0500); // default MDMCTRL1 value
        cc2420WriteReg(CC2420_DACTST, 0); // default value
        rf_flush_rx_fifo();
#ifdef RADIO_PRIORITY_CEILING
nrk_sem_post(radio_sem);
#endif
}


/**********************************************************
 * Set the radio into serial unbuffered RX mode
 * RX data is received through sampling the FIFO pin, timing is done using FIFOP 
 * Use rf_rx_on() to start rcv, then wait for SFD / FIFOP. Sample during each high edge of FIFOP
 * This can be undone by using rf_data_mode()
 */
void rf_rx_set_serial()
{
    cc2420Strobe(CC2420_SRFOFF);           // stop radio
    cc2420WriteReg(CC2420_MDMCTRL1, 0x0501); // Set RX_MODE to 1
    rf_flush_rx_fifo();
}

/**********************************************************
 * Put the radio in serial TX mode, where data is sampled from the FIFO
 * pin to send after SFD, and timing is done using FIFOP
 * use rf_carrier_on() to start, set FIFO to first bit, then wait for it
 * to go up and down, then set next bit etc.
 * NOTE: You must set the FIFO pin to output mode in order to do this!
 * This can be undone by calling rf_data_mode()
 */
void rf_tx_set_serial()
{
    cc2420WriteReg(CC2420_MDMCTRL1, 0x0504); // set TXMODE to 1
    rf_flush_rx_fifo();
}

/**********************************************************
 * start sending a carrier pulse
 * assumes wdrf_radio_test_mode() was called before doing this
 */
void rf_carrier_on()
{
#ifdef RADIO_PRIORITY_CEILING
nrk_sem_pend(radio_sem);
#endif
        cc2420Strobe(CC2420_STXON); // tell radio to start sending
#ifdef RADIO_PRIORITY_CEILING
nrk_sem_post(radio_sem);
#endif
}

/**********************************************************
 * stop sending a carrier pulse; set the radio to idle state
 */
void rf_carrier_off()
{
#ifdef RADIO_PRIORITY_CEILING
nrk_sem_pend(radio_sem);
#endif
        cc2420Strobe(CC2420_SRFOFF); // stop radio
#ifdef RADIO_PRIORITY_CEILING
nrk_sem_post(radio_sem);
#endif
}




//-------------------------------------------------------------------------------------------------------
//  SIGNAL(SIG_INTERRUPT0) - CC2420 FIFOP interrupt service routine
//
//  DESCRIPTION:
//
//      Note: Packets are acknowledged automatically by CC2420 through the auto-acknowledgment feature.
//-------------------------------------------------------------------------------------------------------
/*SIGNAL(SIG_INTERRUPT0) 
{
	uint16_t frameControlField;
	int8_t length;
	uint8_t pFooter[2];

//	FASTSPI_STROBE(CC2420_SRXON);
//	FASTSPI_STROBE(CC2420_SFLUSHRX);
    
//	while(!SFD_IS_1);
//	while(SFD_IS_1);
    // Clean up and exit in case of FIFO overflow, which is indicated by FIFOP = 1 and FIFO = 0
	if((FIFOP_IS_1) && (!(FIFO_IS_1))) {	   
	    FASTSPI_STROBE(CC2420_SFLUSHRX);
	    FASTSPI_STROBE(CC2420_SFLUSHRX);
	}

	// Payload length
	FASTSPI_READ_FIFO_uint8_t(length);
	length &= RF_LENGTH_MASK; // Ignore MSB

    // Ignore the packet if the length is too short
    if (length < RF_ACK_PACKET_SIZE) {
    	FASTSPI_READ_FIFO_GARBAGE(length);

    // Otherwise, if the length is valid, then proceed with the rest of the packet
    } else {
        // Register the payload length
        rfSettings.pRxInfo->length = length - RF_PACKET_OVERHEAD_SIZE;

        // Read the frame control field and the data sequence number
        FASTSPI_READ_FIFO_NO_WAIT((uint8_t*) &frameControlField, 2);
        rfSettings.pRxInfo->ackRequest = !!(frameControlField & RF_FCF_ACK_BM);
    	FASTSPI_READ_FIFO_BYTE(rfSettings.pRxInfo->seqNumber);

		// Is this an acknowledgment packet?
    	if ((length == RF_ACK_PACKET_SIZE) && (frameControlField == RF_ACK_FCF) && (rfSettings.pRxInfo->seqNumber == rfSettings.txSeqNumber)) {

 	       	// Read the footer and check for CRC OK
			FASTSPI_READ_FIFO_NO_WAIT((uint8_t*) pFooter, 2);

			// Indicate the successful ack reception (this flag is polled by the transmission routine)
			if (pFooter[1] & RF_CRC_OK_BM) rfSettings.ackReceived = TRUE;
 
		// Too small to be a valid packet?
		} else if (length < RF_PACKET_OVERHEAD_SIZE) {
			FASTSPI_READ_FIFO_GARBAGE(length - 3);

		// Receive the rest of the packet
		} else {

			// Skip the destination PAN and address (that's taken care of by harware address recognition!)
			FASTSPI_READ_FIFO_GARBAGE(4);

			// Read the source address
			FASTSPI_READ_FIFO_NO_WAIT((BYTE*) &rfSettings.pRxInfo->srcAddr, 2);

			// Read the packet payload
			FASTSPI_READ_FIFO_NO_WAIT(rfSettings.pRxInfo->pPayload, rfSettings.pRxInfo->length);

			// Read the footer to get the RSSI value
			FASTSPI_READ_FIFO_NO_WAIT((BYTE*) pFooter, 2);
			rfSettings.pRxInfo->rssi = pFooter[0];

			//if(pFooter[1] & RF_CRC_OK_BM) return 1;
			// Notify the application about the received _data_ packet if the CRC is OK
			//if (((frameControlField & (RF_FCF_BM)) == RF_FCF_NOACK) && (pFooter[1] & RF_CRC_OK_BM)) {
			if (pFooter[1] & RF_CRC_OK_BM) {
				rfSettings.pRxInfo = rf_rx_callback(rfSettings.pRxInfo);
				rx_ready++;
			}
		}
    
	}

}  //SIGNAL(SIG_INTERRUPT0)
*/
