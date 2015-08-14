/* $Id: $ */
/*
 * Copyright (c) 2015 University of Luebeck (UzL).
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
  DAMAGE.
 */

/**
 * @author Christian Renner
 * @date February 18th 2015
 */
#include "DdcForecastMsg.h"

configuration OrinocoDisseminationLayerC {
  provides {
    // beacons
    interface Receive as BeaconReceive;
    interface AMSend as BeaconSend;
    interface Packet as BeaconPacket;
    
    // data
    interface Receive as DataReceive;
    interface AMSend as DataSend;
    interface Packet as DataPacket;
    
    // dissemination
    interface OrinocoDissemination;
    interface DisseminationValue<DdcForecastMsg>  as Value;	
    interface DisseminationUpdate<DdcForecastMsg> as Update;
  }
  uses {
    // beacons
    interface AMSend as BeaconSubSend;
    interface Receive as BeaconSubReceive;
    interface Packet as BeaconSubPacket;
    
    // data
    interface AMSend as DataSubSend;
    interface Receive as DataSubReceive;
    interface Packet as DataSubPacket;
    
    // am ids
    interface AMPacket;
        
#ifdef PRINTF_H
    interface LocalTime<TMilli>;
#endif
  }
}
implementation {
  components OrinocoDisseminationLayerP;
  BeaconReceive        = OrinocoDisseminationLayerP.BeaconReceive;
  BeaconSend           = OrinocoDisseminationLayerP.BeaconSend;
  BeaconPacket         = OrinocoDisseminationLayerP.BeaconPacket;
  
  DataReceive          = OrinocoDisseminationLayerP.DataReceive;
  DataSend             = OrinocoDisseminationLayerP.DataSend;
  DataPacket           = OrinocoDisseminationLayerP.DataPacket;

  Value = OrinocoDisseminationLayerP;
  Update = OrinocoDisseminationLayerP;
  
  OrinocoDissemination = OrinocoDisseminationLayerP;
  
  BeaconSubReceive     = OrinocoDisseminationLayerP.BeaconSubReceive;
  BeaconSubSend        = OrinocoDisseminationLayerP.BeaconSubSend;
  BeaconSubPacket      = OrinocoDisseminationLayerP.BeaconSubPacket;
  
  DataSubReceive       = OrinocoDisseminationLayerP.DataSubReceive;
  DataSubSend          = OrinocoDisseminationLayerP.DataSubSend;
  DataSubPacket        = OrinocoDisseminationLayerP.DataSubPacket;
  
  AMPacket             = OrinocoDisseminationLayerP;
  
#ifdef PRINTF_H
  LocalTime            = OrinocoDisseminationLayerP;
#endif
  
  //PacketDelayMilli = OrinocoDisseminationLayerP;

  //components LocalTimeMilliC;
  //OrinocoDisseminationLayerP.LocalTimeMilli -> LocalTimeMilliC;
}
