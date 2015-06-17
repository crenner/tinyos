/* $Id: $ */
/*
 * Copyright (c) 2015 Universität zu Lübeck (UzL).
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
 * Universität zu Lübeck OR ITS CONTRIBUTORS BE LIABLE
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
 */
 
#include "Serial.h"

#include "DdcForecast.h"
#include "DdcForecastMsg.h"
#include "printf.h"

module DecoderTestP @safe() {
  uses {
    interface Boot;
    interface WeatherForecastDecoder<ddc_forecast_t, DdcForecastMsg> as Decoder;
    interface LocalTime<TMicro>;
    
    interface SplitControl as AMControl;
    interface Receive;
    interface AMSend;
    interface Packet;

  }
}
implementation {

  DdcForecastMsg    fcastMsg;
  ddc_forecast_t    fcastRes;

  task void
  decoderTask() {
  uint8_t i;
  uint32_t startTime;
  startTime =call LocalTime.get();
    call Decoder.decode(&fcastRes, &fcastMsg);
  startTime =call LocalTime.get()-startTime;

    for(i = 0; i< fcastRes.numValues; i++)
	{
		printf("%u*",fcastRes.values[i]);
    		//printfflush(); 
	}

    printf("%lu\n",startTime);
    printfflush(); 
  }
  

  event void
  Boot.booted() {
    call AMControl.start();
  }
  
  
  event void
  AMControl.startDone(error_t error) {
  }
  
  
  event void
  AMControl.stopDone(error_t error) {
    call AMControl.start();  // restart
  }
  




  event message_t* Receive.receive(message_t* bufPtr, 
				   void* payload, uint8_t len) {

    memcpy(&fcastMsg, payload, len);   
    post decoderTask();
    return bufPtr;
  }

  event void AMSend.sendDone(message_t* bufPtr, error_t error) {
  }

}  
