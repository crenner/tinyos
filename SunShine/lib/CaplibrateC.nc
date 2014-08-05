configuration CaplibrateC {
  provides {
    interface Caplibrate;
  }
  uses {
    interface SensorValueUpdate<fp_t> as CapVoltageUpdate;
  }
}
implementation {
  components CaplibrateP;

  Caplibrate       = CaplibrateP;
  CapVoltageUpdate = CaplibrateP;

  components LocalTimeMilliC;
  CaplibrateP.LocalTime -> LocalTimeMilliC;

  components EnergyTrackerC;
  CaplibrateP.EnergyConsumption -> EnergyTrackerC;

  components CapControlC;
  CaplibrateP.CapControl -> CapControlC;
  
  components SolarControlC;
  CaplibrateP.SolarControl -> SolarControlC;

  components SunshineConfigC;
  CaplibrateP.SupplyConfig -> SunshineConfigC;
  CaplibrateP.CapConfig    -> SunshineConfigC;

}

