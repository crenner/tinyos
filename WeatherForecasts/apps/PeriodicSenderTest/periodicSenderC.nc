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

#ifdef USE_PRINTF
  #define NEW_PRINTF_SEMANTICS
  #include "printf.h"
#endif
#include "DdcForecastMsg.h"
#include "DdcTestMsg.h"

configuration periodicSenderC {
}
implementation {
  components MainC;
  components periodicSenderP as TestC;
  components new TimerMilliC();
  components new TimerMilliC() as BootTimer;

  #ifdef PRINTF_H
  components PrintfC;
  components SerialStartC;
  components LocalTimeMilliC;
  TestC.LocalTime -> LocalTimeMilliC;
  #endif
  
  TestC.Boot              -> MainC.Boot;
  TestC.Timer             -> TimerMilliC;
  TestC.BootTimer         -> BootTimer;

  components OrinocoP as Radio;
  TestC.RootControl       -> Radio;
  TestC.RadioControl      -> Radio;
  TestC.ForwardingControl -> Radio;
  TestC.Send              -> Radio.Send;
  TestC.Packet            -> Radio;
  TestC.RadioReceive      -> Radio.Receive;
  TestC.CollectionPacket  -> Radio;
  TestC.OrinocoConfig     -> Radio;
  //TestC.OrinocoRouting    -> Radio;

//Receive Packages via Serial Connection


  // Orinoco internal reporting
  components OrinocoStatsReportingJobC;
  OrinocoStatsReportingJobC.Packet -> Radio;
  TestC.OrinocoStatsReporting   -> OrinocoStatsReportingJobC;

  //Decoder  
  components WeatherForecastC; 
  TestC.Weather -> WeatherForecastC.WeatherForecast;
  components new OrinocoDisseminatorC(DdcForecastMsg);
  components DdcDecoderC;
  components LocalTimeMilliC as WeatherTime;
  WeatherForecastC.DissValue ->OrinocoDisseminatorC.Value;
  WeatherForecastC.DissDelay ->OrinocoDisseminatorC.Delay;
  WeatherForecastC.Decoder ->DdcDecoderC.Decoder;
  WeatherForecastC.LocalTime -> WeatherTime;

components SerialActiveMessageC as AM;
  WeatherForecastC.AMControl 	  -> AM;
  WeatherForecastC.AMSend 	  -> AM.AMSend[AM_DDCTESTMSG];
  WeatherForecastC.AMPacket 	  -> AM;
components LedsC as LED;
  WeatherForecastC.Leds -> LED;


  components LedsC;
  TestC.Leds -> LedsC;
  
  components RandomC;
  TestC.Random -> RandomC;
 
  #ifdef ORINOCO_DEBUG_STATISTICS
  components OrinocoDebugReportingJobC;
  OrinocoDebugReportingJobC.Packet -> Radio;
  TestC.OrinocoDebugReporting   -> OrinocoDebugReportingJobC;
  #endif

}
