#include "DdcForecast.h"
#include "DdcForecastMsg.h"


module WeatherForecastC {
  provides {
    interface WeatherForecast<uint8_t>;
  }
  uses {
    interface DisseminationValue<DdcForecastMsg>  as DissValue;
    interface DisseminationDelay                  as DissDelay;
    
    interface WeatherForecastDecoder<ddc_forecast_t, DdcForecastMsg> as Decoder;
    
    interface LocalTime<TMilli>;


    interface SplitControl as AMControl;
    interface AMSend;
    interface Packet as AMPacket;
    interface Leds;
  }
}
implementation {
  bool init_ = FALSE;
  bool locked = FALSE;
  const DdcForecastMsg*   fcastMsg_;
  ddc_forecast_t   fcastRes_;
  message_t packet;
  bool temp2 = FALSE;
  
  //TODO Testen
  
  /*** helpers *********************************************************/
  
  void
  printForecast() {
  	uint8_t maxIndex;
  	uint8_t i;
	if (locked) {
     		 return;
  	}
	else {
		// Allocate Space for new Package sent
      		DdcTestMsg* rcm = (DdcTestMsg*)call AMPacket.getPayload(&packet, sizeof(DdcTestMsg));
      		if (rcm == NULL) {
			call Leds.led0On(); 
			return;
      		}
      		if (call AMPacket.maxPayloadLength() < sizeof(DdcTestMsg)) {
			return;
      		}
		// Copy header to package
      		rcm->decodingTime = TOS_NODE_ID;
      		rcm->numValues    = fcastRes_.numValues;
      		rcm->sunrise      = fcastRes_.sunrise;
      		rcm->sunset       = fcastRes_.sunset;
		// Decoded Values will be copied in such a way that each byte contains 2 values since each value takes 4 bits.
      		maxIndex          = fcastRes_.numValues >>1; // divided by 2
      		for(i = 0; i< maxIndex; i++){
			rcm->values[i] =(fcastRes_.values[2*i]<<4)+fcastRes_.values[2*i+1];
		}
		// Send package
     		if (call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(DdcTestMsg)) == SUCCESS) {
	    		if(!temp2){
				call Leds.led2On();
				temp2 = TRUE;
	    		}else {
	     			call Leds.led2Off();
				temp2 = FALSE;
	    		}
			locked = TRUE;
     		}
	}
//#ifdef PRINT_H
/*
    uint8_t  i;
//TODO printf kann menge der Daten nicht korrekt ausgeben. Daher per serielle schnittstell als Paket ?
    
   printf("%lu: %d fcast %lu %d %d %d %d [", call LocalTime.get(), TOS_NODE_ID, fcastRes_.creationTime, fcastRes_.resolution, fcastRes_.numValues, fcastRes_.sunrise, fcastRes_.sunset);
    for (i = 0; i < fcastRes_.numValues; i++) {
      printf("%d", fcastRes_.values[i]);
    }
    printf("]\n");
    printfflush();
*/
//#endif
  }
  
  
  
  /*** tasks ***********************************************************/
  
  task void
  decodeTask() {
    ddc_forecast_t  fcastTmp_;

    if (SUCCESS == call Decoder.decode(&fcastTmp_, fcastMsg_)) {
      fcastRes_ = fcastTmp_;
      init_ = TRUE; 
      printForecast();
    }
  }
  
  
  
  /*** WeatherForecast *************************************************/
  
  command bool
  WeatherForecast.valid() {
    return init_;
  }
  
  
  command uint32_t
  WeatherForecast.creationTime() {
    return fcastRes_.creationTime;
  }
  
  
  command uint32_t
  WeatherForecast.horizon() {
    return fcastRes_.numValues * (uint32_t)fcastRes_.resolution * 60 * 60 * 1024;  // hour --> binary ms
  }
  
  
  command uint8_t
  WeatherForecast.value(uint8_t i) {
    if (i < fcastRes_.numValues) {
      return fcastRes_.values[i];
    } else {
      return DDC_VALUE_UNKNOWN;  // TODO generic
    }
  }
  
  
  command uint32_t
  WeatherForecast.length(uint8_t i) {
    if (i < fcastRes_.numValues) {
      return (uint32_t)fcastRes_.resolution * 60 * 60 * 1024;  // hour --> binary ms
    } else {
      return 0;
    }
  }
  
  
  command uint8_t
  WeatherForecast.numValues() {
    return fcastRes_.numValues;
  }
  
  
  command uint32_t
  WeatherForecast.prevSunrise() {
    // TODO
    return 0;
  }
  
  
  command uint32_t
  WeatherForecast.nextSunrise() {
    // TODO
    return 0;
  }
  
  
  command uint32_t
  WeatherForecast.prevSunset() {
    // TODO
    return 0;
  }
  
  
  command uint32_t
  WeatherForecast.nextSunset() {
    // TODO
    return 0;
  }

  
  
  /*** DissValue *******************************************************/
  
  event void
  DissValue.changed() {
    // access packet delay directly to estimate time of forecast creation
    fcastRes_.creationTime = call LocalTime.get() - call DissDelay.delay();
    fcastMsg_              = call  DissValue.get();
    // put actual decoding into separate task
    post decodeTask();
  }


/*****TEST Output *****************************************************/
  event void
  AMControl.startDone(error_t error) {
  }
  
  
  event void
  AMControl.stopDone(error_t error) {
    call AMControl.start();  // restart
  }

  event void AMSend.sendDone(message_t* bufPtr, error_t error) {
      locked = FALSE;
  }
  
}





