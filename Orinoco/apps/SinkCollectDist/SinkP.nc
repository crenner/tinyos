/* $Id: $ */
/*
 * Copyright (c) 2011 Hamburg University of Technology (TUHH).
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * - Redistributions of source code must retain the above copyright
 *   notice, this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright
 *   notice, this list of conditions and the following disclaimer in the
 *   documentation and/or other materials provided with the
 *   distribution.
 * - Neither the name of the Hamburg University of Technology nor
 *   the names of its contributors may be used to endorse or promote
 *   products derived from this software without specific prior written
 *   permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE
 * HAMBURG UNIVERSITY OF TECHNOLOGY OR ITS CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT
 * OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
 * BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
 * USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
 * DAMAGE.
 */

/**
 * @author Christian Renner
 * @date December 14 2011
 */

#include "AM.h"
#include "Serial.h"
#include "Reporting.h"

#include "OrinocoDebugReportingMsg.h"
#include "OrinocoBeaconMsg.h"

#ifndef SLEEP_DURATION
#  define SLEEP_DURATION 128
#endif

#define BLOOM_ADD_NODE_INTVL  (10*60*1024UL)
#define BLOOM_ADDR_MAX         70
  

module SinkP @safe() {
  uses {
    interface Boot;
    interface SplitControl as RadioControl;
    interface StdControl as RoutingControl;
    
    interface RootControl;
    interface OrinocoRoutingRoot;

    interface OrinocoConfig;

    interface Timer<TMilli> as BootTimer;
    interface Timer<TMilli> as DistTimer;

    // radio
    interface Packet as RadioPacket;
    interface CollectionPacket;
    interface Receive as RadioReceive[collection_id_t];
    interface QueueSend as RadioSend[collection_id_t];

    interface PacketDelay<TMilli> as PacketDelayMilli;

    interface Receive as OrinocoStatsReporting;
    interface Receive as OrinocoDebugReporting;

    interface LocalTime<TMilli>;  
  }
}
implementation
{
  event void Boot.booted() {

    // set static wake-up interval for orinoco
    call OrinocoConfig.setWakeUpInterval(SLEEP_DURATION); // ms

    // bring the components up
    call RootControl.setRoot();
    call RoutingControl.start();
    call RadioControl.start();

    call BootTimer.startOneShot(1024);
    call DistTimer.startPeriodic(BLOOM_ADD_NODE_INTVL);
  }

  event void BootTimer.fired() {
    // we need to delay this because printf is only set up at Boot.booted() and we cannot influence the order of event signalling
    printf("%lu: %u reset\n", call LocalTime.get(), TOS_NODE_ID);
    printfflush();
  }
  
  am_addr_t addr = 0;
  event void DistTimer.fired() {
    if (addr++ > BLOOM_ADDR_MAX) {
      addr = 1;
    }
    call OrinocoRoutingRoot.resetAndAddDestination(addr);
    #ifdef PRINTF_H
    printf("%lu: %u bf-set %u\n", call LocalTime.get(), TOS_NODE_ID, addr);
    printfflush();
    #endif
  }

  event message_t * OrinocoStatsReporting.receive(message_t * msg, void * payload, uint8_t len) {
    //call RadioSend.send[CID_ORINOCO_STATS_REPORT](msg, len);  // packet is copied or rejected
    return msg;
  }

  event message_t * OrinocoDebugReporting.receive(message_t * msg, void * payload, uint8_t len) {
    //call RadioSend.send[CID_ORINOCO_DEBUG_REPORT](msg, len);  // packet is copied or rejected
    
    #ifdef PRINTF_H
    OrinocoDebugReportingMsg * m = (OrinocoDebugReportingMsg *)payload;
    printf("%lu: %u dbg %u %u %u %lu %lu %u %lu %lu %lu %u %lu %u %u\n",
      call LocalTime.get(),    //  1
      TOS_NODE_ID,             //  2
      m->seqno,                //  3
      m->qs.numPacketsDropped, //  4
      m->qs.numDuplicates,     //  5
      m->ps.numTxBeacons,      //  6
      m->ps.numTxAckBeacons,   //  7
      m->ps.numTxBeaconsFail,  //  8
      m->ps.numRxBeacons,      //  9
      m->ps.numIgnoredBeacons, // 10
      m->ps.numTxPackets,      // 11
      m->ps.numTxPacketsFail,  // 12
      m->ps.numRxPackets,      // 13
      m->ps.numTxTimeouts,     // 14
      m->ps.numMetricResets);  // 15
    printfflush();
    #endif
    
    return msg;
  }


  event void RadioControl.startDone(error_t error) {}

  event void RadioControl.stopDone(error_t error) {}



  event message_t *
  RadioReceive.receive[collection_id_t type](message_t * msg, void * payload, uint8_t len) {
    #ifdef PRINTF_H
    uint8_t hops = ((orinoco_data_header_t *)(payload + len))->hopCnt;
    printf("%lu: %u data-rx %u %u %u %u %u\n", call LocalTime.get(), TOS_NODE_ID, call CollectionPacket.getOrigin(msg), type, *((nx_uint16_t *)payload), hops, call RadioPacket.payloadLength(msg));
    printfflush();
    
    if (type != 33) {  // DEBUGGING HACK TO FIND packet corruption bug
      len += sizeof(orinoco_data_header_t);
      ((uint8_t*)payload)[len] = '\0';
      printf("%lu: %u XXX %u %s\n", call LocalTime.get(), TOS_NODE_ID, len, (char*)payload);
      printfflush();
    }
    #endif
    
    return msg;
  }
}  
