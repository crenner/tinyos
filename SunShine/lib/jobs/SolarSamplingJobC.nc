configuration SolarSamplingJobC {
  provides {
    interface SensorValueUpdate<fp_t> as SensorValueUpdate;
  }
}
implementation {
  components SolarSamplingJobP;

  // job implementation
  components new EAJobC() as Job;
  SolarSamplingJobP -> Job.Job;

  // job configuration
  components new EAPeriodicJobConfigC();
  Job.JobConfig -> EAPeriodicJobConfigC;

  components SolarSamplingJobConfigC;
  EAPeriodicJobConfigC.SubJobConfig -> SolarSamplingJobConfigC;

  // job's internal wirings
  components NoLedsC as LedsC;
  //components LedsC as LedsC;
  SolarSamplingJobP.Leds -> LedsC;

  components SolarCurrentC;
  SolarSamplingJobP.SolarCurrentSensor -> SolarCurrentC;

  // external wirings
  SensorValueUpdate = SolarSamplingJobP;
}

