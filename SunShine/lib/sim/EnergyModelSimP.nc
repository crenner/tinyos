#include "FixPointMath.h"

module EnergyModelSimP {
  provides {
    interface Read<fp_t> as CapVoltage;
  }
  uses {
    interface Boot;
    interface EnergyLoad;
    interface SensorValueUpdate<fp_t> as SolarCurrentUpdate;
    interface GetSet<const supply_config_t *> as SupplyConfig;
    interface GetSet<const capcontrol_config_t *> as CapConfig;
    interface LocalTime<TMilli> as Clock;
    interface Timer<TMilli> as AutoUpdateTimer;
  }
}
implementation {
  // internal state
  double    Vc_             = 0;   // cap voltage
  uint32_t  lastUpdate_     = 0;   // time of last update
  double    curConsumption_ = 0;   // node consumption current
  double    curHarvest_     = 0;   // harvested solar current

  // TODO check
  double Ccap_;   // Ccap_ Ccap_acity
  double eta_;    // regulator efficiency
  double Vnode_;  // node supply voltage
  double Vmax_;   // max Ccap_ voltage (?=  => TODO const

  #define BREAKDOWN_VOLTAGE 0.5  // move
  // TODO how about min switch-on voltage?

  
  /*** helpers *********************************************************/
  
  // get hardware config
  void pullConfig()
  {
    const supply_config_t     * sc = call SupplyConfig.get();
    const capcontrol_config_t * cc = call CapConfig.get();

    Vmax_  = FP_FLOAT(cc->maxVoltage);
    Ccap_  = FP_FLOAT(cc->capacity);
    eta_   = sc->efficiency / 100.0;
    Vnode_ = FP_FLOAT(sc->outputVoltage);
    
    dbg("EnergyModelSim", "Vmax = %g, Ccap = %g, eta = %g, Vnode = %g\n", Vmax_, Ccap_, eta_, Vnode_);
  }
  
  
  double f(double Vc, double Is, double In)
  {
    return (Is - ((In * Vnode_) / (eta_ * Vc))) / Ccap_;
  }

  //Calculates a new Cap Voltage for the given parameters
  //dt timespan in which the in and outputs remain unchanged
  //Vc old CapVoltage
  //Is Input adds to Ccap_
  //In Output subs from Ccap_
  inline double simulate(double dt, double Vc, double Is, double In)
  {
    if (dt <= 0) {
      return Vc;
    }

    if (In == 0 || Vc < BREAKDOWN_VOLTAGE) {
      Vc += (Is * dt) / Ccap_;
    } else {
      double t = 0;
      double h = 0.001;
      while(t < dt) {
        double k1 = h * f(Vc,Is,In);
        double k2 = h * f(Vc+k1/2,Is,In);
        double k3 = h * f(Vc+k2/2,Is,In);
        double k4 = h * f(Vc+k3,Is,In);
        Vc = Vc + (1/6.0)*(k1+2*k2+2*k3+k4);

        // work-around for small Vc (FIXME still needed?)
        if (Vc < 0.01) {
          Vc = 0.0001; 
        }
        t = t + h;
      }
    }
    
    // Vc cannot exceed Vmax_
    return Vc < Vmax_ ? Vc : Vmax_;
  }
  
  
  inline void update()
  {
    uint32_t  curTime;
    double    dt;
    
    //pullConfig();  // FIXME why do that over and over again, we won't change anything really ... do we?
    
    curTime = call Clock.get();
    dt      = (curTime - lastUpdate_) / 1024.0;
    
    // update Ccap_ voltage
    if (dt > 0) {
      Vc_ = simulate(dt, Vc_, curHarvest_, curConsumption_);
      
      dbg("EnergyModelSim", "energy update %u\t%g\t%g\t%g\t%g\n",
          curTime, Vc_, dt, curConsumption_, curHarvest_);
    
      lastUpdate_ = curTime;
    }
  }
  
  
  /*** Boot ************************************************************/
  
  event void Boot.booted()
  {
    pullConfig();
  
    call AutoUpdateTimer.startPeriodic(60*1024);  // TODO make this configurable
  }

  
  /*** EnergyLoad ******************************************************/

  // changed consumption
  event void EnergyLoad.loadChanged(load_t newConsumption)
  {
    dbg("EnergyModelSim", "consumption changed: %u\n", newConsumption);
  
    // update state  (order is important)
    update();
    curConsumption_ = newConsumption * 1e-6;  // uA -> A
  }
  
  
  // solar current has changed
  event void SolarCurrentUpdate.update(fp_t newHarvest)
  {
    dbg("EnergyModelSim", "harvest changed: %g\n", FP_FLOAT(newHarvest));
  
    // update state  (order is important)
    update();
    curHarvest_ = FP_FLOAT(newHarvest) * 1e-3;  // mA -> A
  }

  
  /*** AutoUpdateTimer *************************************************/
  // TODO
  
  event void AutoUpdateTimer.fired()
  {
    dbg("EnergyModelSim", "auto update\n");
  
    // update state  (order is important)
    update();
  }



  /*** CapVoltage ******************************************************/
  
  // signal successful sensor reading
  void task Ccap_ReadDone()
  {
    signal CapVoltage.readDone(SUCCESS, FP_UNFLOAT(Vc_));
  }

  
  // trigger Ccap_ voltage reading
  command error_t CapVoltage.read()
  {
    post Ccap_ReadDone();
    return SUCCESS;
  }

  default event void CapVoltage.readDone(error_t, fp_t)
  {
  }
}
