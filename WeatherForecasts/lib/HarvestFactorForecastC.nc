#include "DdcForecastMsg.h"

generic configuration HarvestFactorForecastC(uint8_t NUM_SLOTS, uint8_t ALPHA) {
  provides {
    //interface HarvestFactorForecast;  // per time
    interface HarvestFactorForecast;
    interface SlotValue<fp_t>;
  }
  uses {
    interface Slotter;
    interface DisseminationValue<DdcForecastMsg>  as DissValue;
    interface DisseminationDelay                  as DissDelay;
  }
}
implementation {
  HarvestFactorForecast = HarvestFactorForecastP;
  SlotValue             = HarvestFactorForecastP;
  Slotter               = HarvestFactorForecastP;
  
  components MainC;
  MainC -> HarvestFactorForecastP.Init;

  components new HarvestFactorForecastP(NUM_SLOTS, ALPHA);
  HarvestFactorForecastP.WeatherForecast -> ForecastFactorConverter;
  HarvestFactorForecastP.LocalTime       -> LocalTimeMilliC;

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


