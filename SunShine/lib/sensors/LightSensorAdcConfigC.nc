configuration LightSensorAdcConfigC {
  provides {
    interface Atm128AdcConfig as AdcConfig;
  }
}
implementation {
  components LightSensorAdcConfigP;
  AdcConfig = LightSensorAdcConfigP.AdcConfig;

  components MicaBusC;
  LightSensorAdcConfigP.Adc -> MicaBusC.Adc3;
}
