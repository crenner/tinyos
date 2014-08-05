configuration SolarCurrentC {
  provides {
    interface Read<fp_t> as Read;
  }
}
implementation {
  components GenericFileSensorP as Sensor;
  Read = Sensor.Read;

  components MainC;
  MainC.SoftwareInit -> Sensor.Init;
  
  components LocalTimeMilliC;
  Sensor.Clock -> LocalTimeMilliC;
}
