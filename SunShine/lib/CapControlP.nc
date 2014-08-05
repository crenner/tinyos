module CapControlP {
  provides {
    interface Init;
    interface StdControl as DischargeControl;
  }
  uses {
    interface GeneralIO as DischargeSwitch;
  }
}
implementation {
  // helper functions
  inline bool isDischarging() {
    return call DischargeSwitch.get();
  }

  /* Init ****************************************************************/
  command error_t Init.init() {
    // configure the pin and disable discharging initially
    call DischargeSwitch.makeOutput();
    call DischargeSwitch.clr();

    return SUCCESS;
  }

  /* DischargeControl ****************************************************/
  command error_t DischargeControl.start() {
    if (isDischarging()) {
      return EALREADY;
    }
    call DischargeSwitch.set();
    return SUCCESS;
  }

  command error_t DischargeControl.stop() {
    if (! isDischarging()) {
      return EALREADY;
    }
    call DischargeSwitch.clr();
    return SUCCESS;
  }
}
