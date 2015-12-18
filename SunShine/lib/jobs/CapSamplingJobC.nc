configuration CapSamplingJobC {
  provides {
    interface SensorValueUpdate<fp_t> as SensorValueUpdate;
  }
}
implementation {
  components CapSamplingJobP;

  // job implementation
  components new EAJobC() as Job;
  CapSamplingJobP -> Job.Job;

  // job configuration
  components new EAPeriodicJobConfigC();
  Job.JobConfig -> EAPeriodicJobConfigC;

  components CapSamplingJobConfigC;
  EAPeriodicJobConfigC.SubJobConfig -> CapSamplingJobConfigC;

  // job's internal wirings
  components NoLedsC as LedsC;
  //components LedsC as LedsC;
  CapSamplingJobP.Leds -> LedsC;

  components CapVoltageC;
  CapSamplingJobP.CapVoltageSensor -> CapVoltageC;

  // external wirings
  SensorValueUpdate = CapSamplingJobP;
}

