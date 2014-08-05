configuration TempSensorC {
  provides {
    interface Read<sfp_t> as Read;
  }
}

implementation {
  // pass through read interface
  components new SwitchedSensorP(sfp_t) as TempSensorP;
  Read = TempSensorP.Read;

  // converter
  components TempSensorConverterP;
  TempSensorP.Converter -> TempSensorConverterP;

  components SunshineConfigC;
  TempSensorConverterP  -> SunshineConfigC.GetSetTempConverterConfig;
  
  // initialization
  // NOTE use SubInit, since it's invoked *after* Init, which
  // manipulates GPIO registers!
  components PlatformC;
  TempSensorP.Init <- PlatformC.SubInit;

  // switch for temp sensor
  components MicaBusC;
  TempSensorP.SensorSwitch -> MicaBusC.PW3;

  // ADC reading and config
  components new AdcReadClientC() as ReadClient;
  TempSensorP.SubRead -> ReadClient;

  components TempSensorAdcConfigC;
  ReadClient.Atm128AdcConfig -> TempSensorAdcConfigC.AdcConfig;
}
