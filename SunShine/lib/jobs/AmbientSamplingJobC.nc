configuration AmbientSamplingJobC {
  provides {
    interface SensorValueUpdate<sfp_t> as TempValueUpdate;
    interface SensorValueUpdate<fp_t>  as LightValueUpdate;
  }
}
implementation {
  components AmbientSamplingJobP;

  // job implementation
  components new EAJobC() as Job;
  AmbientSamplingJobP -> Job.Job;

  // job configuration
  components new EAPeriodicJobConfigC();
  Job.JobConfig -> EAPeriodicJobConfigC;

  components AmbientSamplingJobConfigC;
  EAPeriodicJobConfigC.SubJobConfig -> AmbientSamplingJobConfigC;

  // job's internal wirings
  components NoLedsC as LedsC;
  AmbientSamplingJobP.Leds -> LedsC;

  components TempSensorC, LightSensorC;
  AmbientSamplingJobP.TempSensor  -> TempSensorC;
  AmbientSamplingJobP.LightSensor -> LightSensorC;

  // external wirings
  TempValueUpdate  = AmbientSamplingJobP.TempValueUpdate;
  LightValueUpdate = AmbientSamplingJobP.LightValueUpdate;
}

