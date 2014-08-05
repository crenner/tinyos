configuration SolarCurrentAdcConfigC {
  provides {
    interface Atm128AdcConfig as AdcConfig;
  }
}
implementation {
  components SolarCurrentAdcConfigP;
  components MicaBusC;

  AdcConfig = SolarCurrentAdcConfigP.AdcConfig;
  SolarCurrentAdcConfigP.Adc -> MicaBusC.Adc5;
}
