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
#include "DdcForecastMsg.h"
#include "SinkAck.h"
#ifdef USE_PRINTF
  #define NEW_PRINTF_SEMANTICS
  #include "printf.h"
#endif

configuration SinkC {
}
implementation {
  components SinkP;
  
  components MainC;
  SinkP.Boot             -> MainC;

#ifdef PRINTF_H
  components PrintfC;
  components SerialStartC;
#endif

  components new TimerMilliC() as BootTimer;
  SinkP.BootTimer -> BootTimer;
  
  components new TimerMilliC() as DistTimer;
  SinkP.DistTimer -> DistTimer;

  components OrinocoP as Radio;
  SinkP.RootControl      -> Radio;
  SinkP.RoutingControl   -> Radio;
  SinkP.RadioControl     -> Radio;

  SinkP.OrinocoConfig    -> Radio;
  //SinkP.OrinocoRoutingRoot -> Radio;

  SinkP.RadioSend        -> Radio;
  SinkP.RadioReceive     -> Radio.Receive;
  SinkP.RadioPacket      -> Radio;
  SinkP.CollectionPacket -> Radio;
  SinkP.PacketDelayMilli -> Radio;

  // dissemination
  components new OrinocoDisseminatorC(DdcForecastMsg);
  SinkP.ForecastUpdate -> OrinocoDisseminatorC.Update;
  SinkP.ForecastValue  -> OrinocoDisseminatorC.Value;

  //Receive Packages via Serial Connection
  components SerialActiveMessageC as AM;
  SinkP.SerialControl -> AM;
  SinkP.SerialReceive -> AM.Receive[AM_DDC_FORECAST_MSG];
  SinkP.AMSend 	      -> AM.AMSend[AM_SINKACK];
  SinkP.SerialPacket  -> AM;
  //Leds
  components LedsC;
  SinkP.Leds -> LedsC;


  components OrinocoStatsReportingJobC;
  OrinocoStatsReportingJobC.Packet -> Radio;
  SinkP.OrinocoStatsReporting   -> OrinocoStatsReportingJobC;

  #ifdef ORINOCO_DEBUG_STATISTICS
  components OrinocoDebugReportingJobC;
  OrinocoDebugReportingJobC.Packet -> Radio;
  SinkP.OrinocoDebugReporting   -> OrinocoDebugReportingJobC;
  #endif

  
  components LocalTimeMilliC;
  SinkP.LocalTime -> LocalTimeMilliC;
}
