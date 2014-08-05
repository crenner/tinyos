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
  // members
  consumption_t  Q_     = 0;       // initial energy / energy delta
  fp_t           Vcap0_ = FP_NaN;  // initial voltage
  fp_t           Vcap_;            // final voltage
  uint32_t       time_;            // starting time / time delta

  enum {
    CAPLIBRATE_OFF,
    CAPLIBRATE_INIT,
    CAPLIBRATE_RUNNING,
    CAPLIBRATE_DONE
  };
  uint8_t  state_ = CAPLIBRATE_OFF;
 
  // calibration task
  task void caplibrateTask() {
    float  rp, e, e0, cap, r;
    const supply_config_t  * s = call SupplyConfig.get();
    capcontrol_config_t  cc;

    // calculate energy expenditure (Q_ is uAs)
    r  = FP_FLOAT((call CapConfig.get())->resistance);
    rp = (Q_ / (1024.0*time_)) * r * FP_FLOAT(s->outputVoltage) * (100.0 / s->efficiency);
    e  = FP_FLOAT(fpMlt(Vcap_,  Vcap_))  + rp;
    e0 = FP_FLOAT(fpMlt(Vcap0_, Vcap0_)) + rp;

    // NOTE time_ will be (way) less than an hour and is in ms, so range is fine here
    cap = time_ / (512.0 * log(e0 / e) * r);

    // reset voltage to re-enable calibration
    state_ = CAPLIBRATE_OFF;

    // save config
    cc = *(call CapConfig.get());
    cc.capacity   = FP_UNFLOAT(cap);
    cc.calibrated = TRUE;
    cc.timestamp  = call LocalTime.get();
    call CapConfig.set(&cc);

    // signal result
    signal Caplibrate.calibrateCapDone(cc.capacity, SUCCESS);
/*
    // old and crappy fix-point implementation
    fp_t  p, e, e0, cap, r;
    const supply_config_t  * s = call SupplyConfig.get();
    capcontrol_config_t  cc;

    // formula
    // C = (2*dt / R) / (log(V0^2 + R*P) - log(Vc^2 + R*P))

    // calculate energy expenditure (Q_ is uAs)
    r  = (call CapConfig.get())->resistance;
    p  = (fp_t)(((Q_ >> 10) * ((100 * (twicefp_t)fpMlt(r, s->supplyVoltage)) / s->supplyEfficiency)) / time_);
    e  = fpMlt(Vcap_, Vcap_)   + p;
    e0 = fpMlt(Vcap0_, Vcap0_) + p;

    cap = fpLog(e0) - fpLog(e);
    cap = fpMlt(cap, r);
    // NOTE time_ will be (way) less than an hour and is in ms, so range is fine here
    cap = (fp_t)((time_ << 7) / cap);

    // reset voltage to re-enable calibration
    state_ = CAPLIBRATE_OFF;

    x.Q  = Q_;
    x.V0 = Vcap0_;
    x.V  = Vcap_;
    x.dt = time_;
    x.C  = cap;

    // save config
    cc = *(call CapConfig.get());
    cc.capacity = cap;
    call CapConfig.set(&cc);

    // signal result
    signal Caplibrate.calibrateCapDone(&x, SUCCESS);
    //signal Caplibrate.calibrateCapDone(cap, SUCCESS);
*/
  }


  /* Caplibrate **********************************************************/
  command error_t Caplibrate.calibrateCap() {
    // a measurement has already been started
    if (state_ != CAPLIBRATE_OFF) {
      return EALREADY;
    }

    state_ = CAPLIBRATE_INIT;
    return SUCCESS;
  }


  default event void Caplibrate.calibrateCapDone(fp_t, error_t) {
    // nothing
  }


  /* CapVoltageUpdate ****************************************************/
  event void CapVoltageUpdate.update(fp_t val) {
    if (state_ == CAPLIBRATE_OFF) {
      return;

    } else if (state_ == CAPLIBRATE_RUNNING) {
      // is voltage delta large enough?
      if (val <= Vcap0_ - CAPLIBRATE_VDROP) {
        // get deltas
        Vcap_  = val;
        time_  = call LocalTime.get() - time_;
        Q_     = call EnergyConsumption.getTotalConsumption() - Q_;

        // switch on solar charging, disable discharger
        call SolarControl.start();
        call CapControl.stop();

        state_ = CAPLIBRATE_DONE;
        post caplibrateTask();
      }

    } else if (state_ == CAPLIBRATE_INIT) {
      if (val >= CAPLIBRATE_VMIN && val <= CAPLIBRATE_VMAX) {
        // init values
        Vcap0_ = val;
        time_  = call LocalTime.get();
        Q_     = call EnergyConsumption.getTotalConsumption();

        // disable solar cell and enable discharger
        call SolarControl.stop();
        call CapControl.start();

        state_ = CAPLIBRATE_RUNNING;
      }
    }
  }

}  
