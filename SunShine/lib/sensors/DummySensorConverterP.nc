module DummySensorConverterP {
  //uses {
  //  interface GetSet<const light_converter_config_t *> as Config @exactlyonce();
  //}
  provides {
    interface SensorValueConverter<uint16_t>;
  }
}
implementation {
  command uint16_t SensorValueConverter.convert (uint16_t val) {
    return val;
  }
}
