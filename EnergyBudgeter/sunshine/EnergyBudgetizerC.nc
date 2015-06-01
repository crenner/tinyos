configuration EnergyBudgetizerC {
  provides {
    interface EnergyBudget;
    interface Slotter;
    interface SlotValue<fp_t> as HarvestModelValue;
    //interface SlotValue<fp_t> as HarvestForecastValue;
  }
}
implementation {
  components EnergyBudgetizerP;
  EnergyBudget         = EnergyBudgetizerP;
  Slotter              = EnergyBudgetizerP;
  HarvestModelValue    = EnergyBudgetizerP; 
  //HarvestForecastValue = EnergyBudgetizerP;

  components SunshineC;
  EnergyBudgetizerP.CapVoltage  -> SunshineC.CapVoltage;
  EnergyBudgetizerP.Harvest     -> SunshineC.SolarCurrentUpdate;

  components EnergyModelSunshineC;
  EnergyBudgetizerP.EnergyModel -> EnergyModelSunshineC;

  components SunshineConfigC;
  EnergyModelSunshineC.CapConfig    -> SunshineConfigC;
  EnergyModelSunshineC.SupplyConfig -> SunshineConfigC;
}
