module SolarControlP {
  provides {
    interface Init;
    interface StdControl;
    interface Get<bool>;
  }
  uses {
    interface GeneralIO as ChargeSwitch;
  }
}
implementation {
  bool on = TRUE;

  /* Init ****************************************************************/
  command error_t Init.init()
  {
    call StdControl.start();      // allow charging
    return SUCCESS;
  }

  command bool Get.get() {
    return on;
  }
 
  /* Init ****************************************************************/
  command error_t StdControl.start()
  {
    on = TRUE;
    return SUCCESS;
  }

  command error_t StdControl.stop()
  {
    on = FALSE;
    return SUCCESS;
  }
}
