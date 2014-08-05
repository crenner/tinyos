configuration SolarControlC {
  provides {
    interface StdControl;
  }
}
implementation {
  /* wired in SolarControlP */
  components SolarControlP;
  StdControl = SolarControlP;

  /* init */
  components PlatformC;
  SolarControlP.Init <- PlatformC.SubInit;

  /* setup pin for enabling/disabling charge process */
  components MicaBusC;
  SolarControlP.ChargeSwitch -> MicaBusC.PW0;
}
