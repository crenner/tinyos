module TempSensorAdcConfigP {
  provides {
    interface Atm128AdcConfig as AdcConfig;
  }
  uses {
    interface MicaBusAdc as Adc;
  }
}
implementation {
  async command uint8_t AdcConfig.getChannel() {
    return call Adc.getChannel();
  }

  async command uint8_t AdcConfig.getRefVoltage() {
    return ATM128_ADC_VREF_OFF;
  }

  async command uint8_t AdcConfig.getPrescaler() {
    return ATM128_ADC_PRESCALE;
  }
}
