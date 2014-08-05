module AmbientSamplingJobP {
  provides {
    interface SensorValueUpdate<sfp_t> as TempValueUpdate;
    interface SensorValueUpdate<fp_t>  as LightValueUpdate;
  }
  uses {
    interface EAJob;
    interface Leds;
    interface Read<sfp_t> as TempSensor;
    interface Read<fp_t>  as LightSensor;
  }
}
implementation {
  uint8_t  nSense;

  void checkDone() {
    if (nSense == 0) {
      call Leds.led0Off();
      call EAJob.done();
    }
  }

  // temp sensor update
  event void TempSensor.readDone(error_t res, sfp_t val) {
    if (res == SUCCESS) {
      signal TempValueUpdate.update(val);
    }
    atomic nSense--;
    checkDone();
  }

  // light sensor update
  event void LightSensor.readDone(error_t res, fp_t val) {
    if (res == SUCCESS) {
      signal LightValueUpdate.update(val);
    }
    atomic nSense--;
    checkDone();
  }

  // run job
  event void EAJob.run()
  {
    call Leds.led0On();
    nSense = 2;
    if (SUCCESS != call TempSensor.read())  atomic nSense--;
    if (SUCCESS != call LightSensor.read()) atomic nSense--;
    checkDone();
  }
}

