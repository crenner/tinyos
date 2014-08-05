configuration CapVoltageC {
  provides {
    interface Read<fp_t> as Read;
  }
}
implementation {
  // pass through read interface
  components new SensorP(fp_t) as SensorP;
  Read = SensorP.Read;

  // converter
  components CapVoltageConverterP;
  SensorP.Converter -> CapVoltageConverterP;

  components SunshineConfigC;
  CapVoltageConverterP  -> SunshineConfigC.GetSetSupplyConfig;
  
  // ADC reading and config
/*
  components new SmoothAdcC(CAPVOLT_AVG_NUM_SAMPLES);
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
  
  components CapVoltageAdcConfigC;
  ReadClient.Atm128AdcConfig -> CapVoltageAdcConfigC.AdcConfig;
}
