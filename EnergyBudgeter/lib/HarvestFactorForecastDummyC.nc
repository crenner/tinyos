module HarvestFactorForecastDummyC {
  provides {
    interface HarvestFactorForecast;
  }
}
implementation {

  command fp_t HarvestFactorForecast.getHarvestFactor(uint32_t from, uint32_t dt) {
    return FP_ONE;
  }
}
