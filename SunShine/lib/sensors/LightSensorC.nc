configuration LightSensorC {
  provides {
    interface Read<uint16_t> as Read;
  }
}

implementation {
  // pass through read interface
  components new SwitchedSensorP(uint16_t) as LightSensorP;
  Read    = LightSensorP.Read;

  // converter
  //components LightSensorConverterP as LightSensorConverter;
  components DummySensorConverterP as LightSensorConverter;
  LightSensorP.Converter -> LightSensorConverter;

  //components SunshineConfigC;
  //LightSensorConverterP -> SunshineConfigC.GetSetLightConverterConfig;

  // initialization
  // NOTE use SubInit, since it's invoked *after* Init, which
  // manipulates GPIO registers!
  components PlatformC;
  LightSensorP.Init <- PlatformC.SubInit;

  // switch for temp sensor
  components MicaBusC;
  LightSensorP.SensorSwitch -> MicaBusC.PW4;

  // ADC reading and config
  components new AdcReadClientC() as ReadClient;
  LightSensorP.SubRead -> ReadClient;

  components LightSensorAdcConfigC;
  ReadClient.Atm128AdcConfig -> LightSensorAdcConfigC.AdcConfig;
}
