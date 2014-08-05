module SolarSamplingJobP {
  provides {
    interface SensorValueUpdate<fp_t> as SensorValueUpdate;
  }
  uses {
    interface EAJob;
    interface Leds;
    interface Read<fp_t> as SolarCurrentSensor;
  }
}
implementation {
  // sensor update
  event void SolarCurrentSensor.readDone(error_t res, fp_t val) {
    call Leds.led2Off();
    if (res == SUCCESS) {
      signal SensorValueUpdate.update(val);
    }
    call EAJob.done();
  }

  // run job
  event void EAJob.run() {
    call Leds.led2On();
    if (SUCCESS != call SolarCurrentSensor.read()) {
      call EAJob.done();
    }
  }
}

