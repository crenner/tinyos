interface HarvestFactorForecast {
  /**
   * get (average) harvest factor for future time [from,from+dt)
   * @return harvest factor as fp_t in range [0,1]
   */
  command fp_t getHarvestFactor(uint32_t from, uint32_t dt);
}
