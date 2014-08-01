#include <FixPointMath.h>

module CaplibrateP {
  provides {
    interface Caplibrate;
  }
  uses {
    interface EnergyConsumption;
    interface StdControl as CapControl;
    interface StdControl as SolarControl;
    interface GetSet<const supply_config_t *>     as SupplyConfig;
    interface GetSet<const capcontrol_config_t *> as CapConfig;
    interface LocalTime<TMilli>       as LocalTime;
    interface SensorValueUpdate<fp_t> as CapVoltageUpdate;
  }
}
implementation {
  task void caplibrateTask() {
    capcontrol_config_t  cc;

    // save config
    cc = *(call CapConfig.get());
    //cc.capacity   = FP_UNFLOAT(CAP); is now in lib/Sunshine.h
    cc.calibrated = TRUE;
    cc.timestamp  = call LocalTime.get();
    call CapConfig.set(&cc);

    // signal result
    signal Caplibrate.calibrateCapDone(cc.capacity, SUCCESS);
  }


  /* Caplibrate **********************************************************/
  command error_t Caplibrate.calibrateCap() {
    post caplibrateTask();
    return SUCCESS;
  }


  default event void Caplibrate.calibrateCapDone(fp_t, error_t) {
    // nothing
  }


  /* CapVoltageUpdate ****************************************************/
  event void CapVoltageUpdate.update(fp_t val) {
  }
}  
