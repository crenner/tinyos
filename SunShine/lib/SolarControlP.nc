module SolarControlP {
  provides {
    interface Init;
    interface StdControl;
  }
  uses {
    interface GeneralIO as ChargeSwitch;
  }
}
implementation {
  /* Init ****************************************************************/
  command error_t Init.init()
  {
    call StdControl.start();      // allow charging
    return SUCCESS;
  }
 
 
  /* Init ****************************************************************/
  command error_t StdControl.start()
  {
    /**
     * Charging is always enabled, when the pin
     * is serving as an input.
     */
    call ChargeSwitch.clr();
    call ChargeSwitch.makeInput();

    return SUCCESS;
  }

  command error_t StdControl.stop()
  {
    /**
     * To disable charging, we make the solar pin
     * an output and write a logical one. This
     * short-circuits the solar cell.
     * NOTE if writing a logical zero to the pin (if serving as
     * an output), overcharging of the cap may occur!
     */
    call ChargeSwitch.makeOutput();
    call ChargeSwitch.set();

    return SUCCESS;
  }
}
