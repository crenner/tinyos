#include <FixPointMath.h>
#include <Statistics.h>

module SunshineP {
  provides {
    interface Get<fp_t>   as SolarCurrent;
    interface Get<fp_t>   as CapVoltage;
    interface Get<fp_t>   as RefCapVoltage;
    interface Get<sfp_t>  as Temperature;
    interface Get<fp_t>   as LightIntensity;

    // signal updates of sensor values
    interface SensorValueUpdate<fp_t>  as SolarCurrentUpdate;
    interface SensorValueUpdate<fp_t>  as CapVoltageUpdate;
    interface SensorValueUpdate<fp_t>  as RefCapVoltageUpdate;
    interface SensorValueUpdate<sfp_t> as TempUpdate;
    interface SensorValueUpdate<uint16_t>  as LightUpdate;
  }
  uses {
    // control solar cell and cap discharge
    interface StdControl  as CapControl;
    interface StdControl  as SolarControl;

    // sensor interfaces (actual reading of sensors)
    interface SensorValueUpdate<fp_t>  as SubSolarCurrentUpdate;
    interface SensorValueUpdate<fp_t>  as SubCapVoltageUpdate;
#ifdef USE_REFCAP
    interface SensorValueUpdate<fp_t>  as SubRefCapVoltageUpdate;
#endif
    interface SensorValueUpdate<sfp_t> as SubTempUpdate;
    interface SensorValueUpdate<uint16_t>  as SubLightUpdate;

    // debug
    interface Leds;
  }
}
implementation {
  // current sensor readings
  typedef struct {
    fp_t  Vc;
#ifdef USE_REFCAP
    fp_t  refVc;
#endif
    fp_t  Is;
    sfp_t Temp;
    uint16_t  Light;
  } SensorValues_t;
  SensorValues_t  sVal = { 0 };

  // state variables for caplibrate
  struct {
    // TODO
  } caplibrate;

  /* SOLAR CURRENT *******************************************************/
  command fp_t SolarCurrent.get() {
    return sVal.Is;
  }

  event void SubSolarCurrentUpdate.update(fp_t val) {
    sVal.Is = val;
    signal SolarCurrentUpdate.update(val);
  }

  default event void SolarCurrentUpdate.update(fp_t) {
    // nothing
  }


  /* CAP VOLTAGE *********************************************************/
  command fp_t CapVoltage.get() {
    return sVal.Vc;
  }

  event void SubCapVoltageUpdate.update(fp_t val) {
    sVal.Vc = val;
    //sVal.Vc = ewmaFilter16(sVal.Vc, val, SUNSHINE_CAPVOLT_FILTER);
    signal CapVoltageUpdate.update(val);
  }

  default event void CapVoltageUpdate.update(fp_t) {
    // nothing
  }

  
  /* REFCAP VOLTAGE *********************************************************/
  command fp_t RefCapVoltage.get() {
#ifdef USE_REFCAP
    return sVal.refVc;
#else
    return 0;
#endif
  }

#ifdef USE_REFCAP
  event void SubRefCapVoltageUpdate.update(fp_t val) {
    sVal.refVc = val;
    signal RefCapVoltageUpdate.update(val);
  }

  default event void RefCapVoltageUpdate.update(fp_t) {
    // nothing
  }
#endif


  /* TEMPERATURE SENSOR **************************************************/
  command sfp_t Temperature.get() {
    return sVal.Temp;
  }

  event void SubTempUpdate.update(sfp_t val) {
    sVal.Temp = val;
    signal TempUpdate.update(val);
  }

  default event void TempUpdate.update(sfp_t) {
    // nothing
  }


  /* LIGHT SENSOR ********************************************************/
  command fp_t LightIntensity.get() {
    return sVal.Light;
  }

  event void SubLightUpdate.update(uint16_t val) {
    sVal.Light = val;
    signal LightUpdate.update(val);
  }

  default event void LightUpdate.update(uint16_t) {
    // nothing
  }
}
