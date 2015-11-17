configuration TestAppC {
}
implementation {
  components MainC;
  components TestC;
//  components LedsC;
  components SunshineC;
  components ActiveMessageC;
  components new AMSenderC(17);
  components new TimerMilliC() as RadioTimer;
  components new TimerMilliC() as RadioOffTimer;

  // generic stuff
  TestC.Boot           -> MainC.Boot;
//  TestC.Leds           -> LedsC;
  // sampling
  // getter
  TestC.SolarCurrent   -> SunshineC.SolarCurrent;
  TestC.CapVoltage     -> SunshineC.CapVoltage;
  TestC.RefCapVoltage     -> SunshineC.RefCapVoltage;
  TestC.TempSensor     -> SunshineC.TempSensor;
  TestC.LightSensor    -> SunshineC.LightSensor;
  // updater
  TestC.SolarCurrentUpdate -> SunshineC.SolarCurrentUpdate;
  TestC.RefCapVoltageUpdate   -> SunshineC.RefCapVoltageUpdate;
  TestC.TempSensorUpdate   -> SunshineC.TempUpdate;
  TestC.LightSensorUpdate  -> SunshineC.LightUpdate;
  // radio
  TestC.Packet         -> AMSenderC;
  TestC.AMPacket       -> AMSenderC;
  TestC.AMControl      -> ActiveMessageC;
  TestC.Ack            -> AMSenderC;
  TestC.AMSend         -> AMSenderC;
  // timers
  TestC.RadioTimer     -> RadioTimer;
  TestC.RadioOffTimer  -> RadioOffTimer;
  //TestC.RadioOnTimer   -> RadioOnTimer;

  // EnergyProfiler
  components EnergyTrackerC;
  TestC.EnergyConsumption -> EnergyTrackerC;

  // test
  components SunshineConfigC;
  TestC.GetSetSolarConverterConfig -> SunshineConfigC;
}
