configuration CapVoltageC {
  provides {
    interface Read<fp_t> as Read;
  }
}
implementation {
  components EnergyModelSimC;
  Read = EnergyModelSimC.CapVoltage;
}
