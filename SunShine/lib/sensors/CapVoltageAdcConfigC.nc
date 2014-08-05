configuration CapVoltageAdcConfigC {
  provides {
    interface Atm128AdcConfig as AdcConfig;
  }
}

implementation {
  components CapVoltageAdcConfigP;
  components MicaBusC;

  AdcConfig = CapVoltageAdcConfigP.AdcConfig;
  CapVoltageAdcConfigP.Adc -> MicaBusC.Adc7;
}
