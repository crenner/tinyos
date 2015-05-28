interface HarvestFactorForecast {
  /**
   * get (average) harvest factor for future time [from,from+dt)
   * if there is no harvest factor available, the command must
   * return FP_NaN.
   * @return harvest factor as fp_t in range [0,1] or FP_NaN
   */
  command fp_t getHarvestFactor(uint32_t from, uint32_t dt);
  
  // signal a forecast update
  event void update();
}
