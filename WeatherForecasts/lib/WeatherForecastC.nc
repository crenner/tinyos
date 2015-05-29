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
  }
}
implementation {
  bool             init_ = FALSE;
  DdcForecastMsg   fcastMsg_;
  ddc_forecast_t   fcastRes_;
  
  
  
  /*** helpers *********************************************************/
  
  void
  printForecast() {
#ifdef PRINT_H
    uint8_t  i;
    
    printf("%lu: %u fcast %u %u %u %u %u [", call LocalTime.get(), TOS_NODE_ID, fcastRes_.creationTime, fcastRes_.resolution, fcastRes_.numValues, fcastRes_.sunrise, fcastRes_.sunset);
    for (i = 0; i < fcastRes_.numValues; i++) {
      printf(" %u", fcastRes_->values[i]);
    }
    printf("]\n");
    printfflush();
#endif
  }
  
  
  
  /*** tasks ***********************************************************/
  
  task void
  decodeTask() {
    ddc_forecast_t  fcastTmp_;
    
    if (SUCCESS != call Decoder.decode(&fcastTmp_, &fcastMsg_)) {
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
    
    // put actual decoding into separate task
    post decodeTask();
  }
}


