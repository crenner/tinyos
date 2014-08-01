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
  double    Vc_         = 0;          // cap voltage
  uint64_t  lastTime_   = 0;     // TODO
  uint32_t  lastLoad_ = 0;
  double    lastSolarCurrent_  = 0;

  // TODO check
  double cap;   // cap capacity
  double eta;   // regulator efficiency
  double Vn;    // node supply voltage
  double Vmax;  // max cap voltage (?=  => TODO const

  #define BREAKDOWN_VOLTAGE 0.5  // move
  // TODO how about min switch-on voltage?

  
  /*** helpers *********************************************************/
  
  // get hardware config
  void pullConfig()
  {
    const supply_config_t     * sc = call SupplyConfig.get();
    const capcontrol_config_t * cc = call CapConfig.get();

    Vmax = FP_FLOAT(cc->maxVoltage);
    cap  = FP_FLOAT(cc->capacity);
    eta  = sc->efficiency / 100.0;
    Vn   = FP_FLOAT(sc->outputVoltage);
  }
  
  
  double f(double Vc, double Is, double In)
  {
    return (Is/1000.0 - ((In*Vn)/(eta*Vc)))/cap;
  }

  //Calculates a new Cap Voltage for the given parameters
  //dt timespan in which the in and outputs remain unchanged
  //Vc old CapVoltage
  //Is Input adds to cap
  //In Output subs from cap
  inline double simulate(double dt, double Vc, double Is, double In)
  {
    if (dt <= 0) {
      return Vc;
    }

    if (In == 0 || Vc < BREAKDOWN_VOLTAGE) {
      Vc += ((Is / 1000.0) * dt) / cap;
    } else {
      double t = 0;
      double h = 0.001;
      while(t < dt) {
        double k1 = h * f(Vc,Is,In);
        double k2 = h * f(Vc+k1/2,Is,In);
        double k3 = h * f(Vc+k2/2,Is,In);
        double k4 = h * f(Vc+k3,Is,In);
        Vc = Vc + (1/6.0)*(k1+2*k2+2*k3+k4);

        if (Vc < 0.01) {
          Vc = 0.0001; 
        }
        if (Vc > Vmax) { 
          Vc = Vmax;
        }
        t = t + h;
      }
    }
    return Vc;
  }
  
  
  /*** Boot ************************************************************/
  
  event void Boot.booted()
  {
    call AutoUpdateTimer.startPeriodic(1024*60);  // TODO make this configurable
  }

  
  /*** EnergyLoad ******************************************************/

  // changed consumption
  event void EnergyLoad.loadChanged(load_t newLoad)
  {
    uint32_t dt, curTime;
    
    dbg("capvoltageEvent_Energyload", "EnergyLoad: Geändert: %i\n",newLoad);
    
    pullConfig();  // FIXME why do that over and over again, we won't change anything really ...
    
    curTime = call Clock.get();
    dt = (curTime - lastTime_) / 1024.0;
    
    // update cap voltage
    Vc_ = simulate(dt, Vc_, lastSolarCurrent_, newLoad);
    
    // update state
    lastLoad_ = newLoad;
    lastTime_ = curTime;
    
    dbg("capvoltageEvent", "EnergyLoad: %i\n", newLoad);
  }
  
  
  // solar current has changed
  event void SolarCurrentUpdate.update(fp_t val)
  {
    uint32_t dt;
    uint32_t curTime;
    
    // TODO really move this to some function, this is redundant!
    
    //pull Configs
    pullConfig();
    //Get present time
    curTime = call Clock.get();
    //Get timedif to previous simulation
    dt = curTime/1024.0-lastTime_/1024.0;
    dbg("capvoltageEvent_Sensor", "SolarValueUpdate: Vc_ vorher:%f Zeit seit letzter Berechnung:%i sekunden\n",Vc_,dt);
    //Start the voltage in cap calculation
    Vc_ = simulate(dt,Vc_,FP_FLOAT(val),lastLoad_);
    dbg("capvoltageEvent_Sensor", "SolarValueUpdate: Vc_ danach:%f\n",Vc_);
    //set lastSolarCurrent_ newInput
    lastSolarCurrent_=FP_FLOAT(val);
    dbg("capvoltageEvent", "Sensor: %f\n", lastSolarCurrent_);		
    lastTime_ = curTime;
  }

  
  /*** AutoUpdateTimer *************************************************/
  // TODO
  
  event void AutoUpdateTimer.fired()
  {
    // TODO FIXME see above
    uint32_t dt;
    uint32_t presentTime;
    //Get present time
    presentTime = call Clock.get();
    //Get timedif to previous simulation
    dt = presentTime/1024.0-lastTime_/1024.0;
    //pull Configs
    pullConfig();
    dbg("capvoltageEvent_Timer", "One_Min_Timer: Vc_ vorher:%f Zeit seit letzter Berechnung:%i sekunden\n",Vc_,dt);
    //Start the voltage in cap calculation
    Vc_ = simulate(dt,Vc_,lastSolarCurrent_,lastLoad_);
    dbg("capvoltageEvent_Timer", "One_Min_Timer: Vc_ danach:%f\n",Vc_);
    lastTime_=presentTime;
  }



  /*** CapVoltage ******************************************************/
  
  // signal successful sensor reading
  void task capReadDone()
  {
    signal CapVoltage.readDone(SUCCESS, FP_UNFLOAT(Vc_));
  }

  
  // trigger cap voltage reading
  command error_t CapVoltage.read()
  {
    post capReadDone();
    return SUCCESS;
  }

  default event CapVoltage.readDone(error_t, fp_t)
  {
  }
}
