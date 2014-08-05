generic module SensorP (typedef SensorValue_t)
{
  provides {
    interface Read<SensorValue_t> as Read;
  }
  uses {
    interface SensorValueConverter<SensorValue_t> as Converter;
    interface Read<uint16_t> as SubRead;
  }
}

implementation
{
  /* READ **********************************************************/
  command error_t Read.read() {
    return call SubRead.read();       // request conversion
  }

  default event void Read.readDone(error_t, SensorValue_t) {
    // nothing (dummy)
  }

  /* SUBREAD *******************************************************/
  event void SubRead.readDone(error_t res, uint16_t val) {
    SensorValue_t  v;
    if (res == SUCCESS) {
      v = call Converter.convert(val);
    }
    signal Read.readDone(res, v); 
  }
}
