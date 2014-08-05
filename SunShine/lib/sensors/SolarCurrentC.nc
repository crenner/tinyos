configuration SolarCurrentC {
  provides {
    interface Read<fp_t> as Read;
  }
}
implementation {
  // pass through read interface
  components new SensorP(fp_t) as SensorP;
  Read = SensorP.Read;

  // converter
  components SolarCurrentConverterP;
  SensorP.Converter -> SolarCurrentConverterP;

  components MainC;
  SolarCurrentConverterP.Boot -> MainC;  // TODO should be removed

  components SunshineConfigC;
  SolarCurrentConverterP  -> SunshineConfigC.GetSetSolarConverterConfig;

  components SunshineC;
  SolarCurrentConverterP.LightValueUpdate -> SunshineC.LightUpdate;
  
  // ADC reading and config
/*
  components new SmoothAdcC(SOLAR_AVG_NUM_SAMPLES);
  SensorP.SubRead -> SmoothAdcC.SmoothRead;
  
  components new AdcReadClientC() as ReadClient;
  SmoothAdcC.SingleRead -> ReadClient;
*/
  
  /**
   * if the above is not working, use:
   */
  components new AdcReadClientC() as ReadClient;
  SensorP.SubRead -> ReadClient;
  /*
   */
  
  components SolarCurrentAdcConfigC;
  ReadClient.Atm128AdcConfig -> SolarCurrentAdcConfigC.AdcConfig;
}
