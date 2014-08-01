configuration EnergyModelSimC {
  provides {
    interface Read<fp_t> as CapVoltage;
  }
  uses {
    interface EnergyLoad;
  }
}
implementation {

  components MainC;
  components SunshineC;
  components SunshineConfigC;
  components LocalTimeMilliC;
  components new TimerMilliC() as AutoUpdateTimer;
  
  components EnergyModelSimP;
  EnergyModelSimP.Boot               -> MainC;
  EnergyModelSimP.SolarCurrentUpdate -> SunshineC.SolarCurrentUpdate;
  EnergyModelSimP.CapConfig          -> SunshineConfigC;
  EnergyModelSimP.SupplyConfig       -> SunshineConfigC;
  EnergyModelSimP.Clock              -> LocalTimeMilliC;
  EnergyModelSimP.AutoUpdateTimer    -> AutoUpdateTimer;
  
  CapVoltage = EnergyModelSimP.CapVoltage;
  EnergyLoad = EnergyModelSimP.EnergyLoad;
}
