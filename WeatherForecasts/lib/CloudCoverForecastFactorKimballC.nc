#include "WeatherForecast.h"


module CloudCoverForecastFactorKimballC {
  provides {
    interface WeatherForecast<fp_t> as FactorForecast;
  }
  uses {
    interface WeatherForecast<uint8_t> as RawForecast;
  }
}
implementation {
  
  /*** FactorForecast **************************************************/
  
  command bool
  FactorForecast.valid() {
    return call RawForecast.valid();
  }
  
  
  command uint32_t
  FactorForecast.creationTime() {
    return call RawForecast.creationTime();
  }
  
  
  command uint32_t
  FactorForecast.horizon() {
    return call RawForecast.horizon();
  }
  
  
  command fp_t
  FactorForecast.value(uint8_t i) {
    uint8_t  raw = call RawForecast.value(i);
    
    if (raw == WEATHERFORECAST_VALUE_UNKNOWN) {
      return FP_NaN;
    }
    
    // TODO the conversion
    return (fp_t)( ( (CLOUDCOVER_MAX_VALUE - raw) * 256 + CLOUDCOVER_MAX_VALUE / 2) / CLOUDCOVER_MAX_VALUE );
  }
  
  
  command uint32_t
  FactorForecast.length(uint8_t i) {
    return call RawForecast.length(i);
  }
  
  
  command uint8_t
  FactorForecast.numValues() {
    return call RawForecast.numValues();
  }
  
  
  command uint32_t
  FactorForecast.prevSunrise() {
    return call RawForecast.prevSunrise();
  }
  
  
  command uint32_t
  FactorForecast.nextSunrise() {
    return call RawForecast.nextSunrise();
  }
  
  
  command uint32_t
  FactorForecast.prevSunset() {
    return call RawForecast.prevSunset();
  }
  
  
  command uint32_t
  FactorForecast.nextSunset() {
    return call RawForecast.nextSunset();
  }
}


