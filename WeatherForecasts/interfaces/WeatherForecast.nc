interface WeatherForecast {

  /* returns whether there is any valid forecast available; all other
   * commands may only be used when there is a valid forecast */
  command bool valid();
  
  /* returns the local time (in ms) of the current forecast's creation */
  command uint32_t creationTime();

  /* returns the (raw) value of the I'th forecast; if that value does
   * not exist, the command returns DDC_VALUE_UNKNOWN */
  command uint8_t value(uint8_t i);
  
  /* returns the length (in binary ms) of the I'th forecast; if that 
   * forecast does not exist, the command returns 0 */
  command uint32_t length(uint8_t i);
  
  /* returns the number of forecast values */
  command uint8_t numValues();
  
  // TODO the following commands assume that we always know the data
  /* returns the time of the most recent (past) sunrise */
  command uint32_t prevSunrise();
  
  /* returns the time of the most recent (past) sunrise */
  command uint32_t nextSunrise();
  
  /* returns the time of the most recent (past) sunset */
  command uint32_t prevSunset();
  
  /* returns the time of the next sunset */
  command uint32_t nextSunset();