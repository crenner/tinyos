generic module SwitchedSensorP (typedef SensorValue_t)
{
  provides {
    interface Init;
    interface Read<SensorValue_t> as Read;
  }
  uses {
    interface GeneralIO as SensorSwitch;
    interface SensorValueConverter<SensorValue_t> as Converter;
    interface Read<uint16_t> as SubRead;
  }
}

implementation
{
  /* INIT **********************************************************/
  command error_t Init.init() {
    call SensorSwitch.makeOutput();  // configure output
    call SensorSwitch.clr();         // and switch of sensor
    return SUCCESS;
  }

  
  /* READ **********************************************************/
  command error_t Read.read() {
    error_t res;
    call SensorSwitch.set();         // switch on sensor
    res = call SubRead.read();       // and request conversion
    if (res != SUCCESS) {
      call SensorSwitch.clr(); // switch off sensor on failure
    }
    return res;
  }

  default event void Read.readDone(error_t, SensorValue_t) {
    // nothing (dummy)
  }

  /* SUBREAD *******************************************************/
  event void SubRead.readDone(error_t res, uint16_t val) {
    SensorValue_t  v;
    call SensorSwitch.clr(); // switch off sensor
    if (res == SUCCESS) {
      v = call Converter.convert(val);
    }
    signal Read.readDone(res, v); 
  }
}
