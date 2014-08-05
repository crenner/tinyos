configuration CapControlC {
  provides {
    interface StdControl;
  }
}
implementation
{
  /* implemented in CapControlP */
  components CapControlP;
  StdControl = CapControlP;

  /* init */
  components PlatformC;
  CapControlP.Init <- PlatformC.SubInit;

  /* setup pin for discharging switch */
  components MicaBusC;
  CapControlP.DischargeSwitch -> MicaBusC.PW2;
}
