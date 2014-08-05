configuration TempSensorAdcConfigC {
  provides {
    interface Atm128AdcConfig as AdcConfig;
  }
}
implementation {
  // pass through config
  components TempSensorAdcConfigP;
  AdcConfig = TempSensorAdcConfigP.AdcConfig;

  // wire correct ADC port
  components MicaBusC;
  TempSensorAdcConfigP.Adc -> MicaBusC.Adc4;
}
