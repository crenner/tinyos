module CapSamplingJobP {
  provides {
    interface SensorValueUpdate<fp_t> as SensorValueUpdate;
  }
  uses {
    interface EAJob;
    interface Leds;
    interface Read<fp_t> as CapVoltageSensor;
  }
}
implementation {
  // sensor update
  event void CapVoltageSensor.readDone(error_t res, fp_t val) {
    call Leds.led1Off();
    if (res == SUCCESS) {
      signal SensorValueUpdate.update(val);
    }
    call EAJob.done();
  }

  // run job
  event void EAJob.run()
  {
    call Leds.led1On();
    if (SUCCESS != call CapVoltageSensor.read()) {
      call EAJob.done();
    }
  }
}

