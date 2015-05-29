#include "DdcForecastMsg.h"

configuration HarvestFactorForecastC {
  provides {
    interface HarvestFactorForecast;  // per time
  }
  uses {
    interface DisseminationValue<DdcForecastMsg>  as DissValue;
    interface DisseminationDelay                  as DissDelay;
  }
}
implementation {  
  // TODO
  
  HarvestFactorForecast = HarvestFactorForecastP;

  components HarvestFactorForecastP;
  HarvestFactorForecastP.WeatherForecast -> ForecastFactorConverter;

  components CloudCoverForecastFactorKimballC as ForecastFactorConverter; // TODO rename / generic
  ForecastFactorConverter.RawForecast -> WeatherForecastC;
  
  components WeatherForecastC;
  WeatherForecastC.DissValue  = DissValue;
  WeatherForecastC.DissDelay  = DissDelay;
  WeatherForecastC.LocalTime -> LocalTimeMilliC;
  WeatherForecastC.Decoder   -> DdcDecoderC;

  components LocalTimeMilliC;
  components DdcDecoderC;
}


