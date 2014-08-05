#include "Sunshine.h"
#include <FixPointMath.h>

configuration SunshineC {
  provides {
    interface Caplibrate;

    // sensor value getters
    interface Get<fp_t>  as SolarCurrent;
    interface Get<fp_t>  as CapVoltage;
#ifdef USE_REFCAP
    interface Get<fp_t>  as RefCapVoltage;
#endif
    interface Get<sfp_t> as TempSensor;
    interface Get<fp_t>  as LightSensor;

    // signal updates of sensor values
    interface SensorValueUpdate<fp_t>  as SolarCurrentUpdate;
    interface SensorValueUpdate<fp_t>  as CapVoltageUpdate;
#ifdef USE_REFCAP
    interface SensorValueUpdate<fp_t>  as RefCapVoltageUpdate;
#endif
    interface SensorValueUpdate<sfp_t> as TempUpdate;
    interface SensorValueUpdate<uint16_t>  as LightUpdate;
  }
}
implementation {
  components SunshineP;

  /* CONFIGURATION *******************************************************/
//  components SunshineConfigC;  // NOTE not needed at the moment

  /* CAP/SOLAR CONTROLS **************************************************/
  components CapControlC, SolarControlC;
  SunshineP.CapControl   -> CapControlC;
  SunshineP.SolarControl -> SolarControlC;

  /* DEBUG ***************************************************************/
  components NoLedsC as LedsC;
  SunshineP.Leds -> LedsC;

  /* EXTERNAL SENSOR VALUE GETTER ACCESS *********************************/
  SolarCurrent  = SunshineP.SolarCurrent;
  CapVoltage    = SunshineP.CapVoltage;
#ifdef USE_REFCAP
  RefCapVoltage = SunshineP.RefCapVoltage;
#endif
  TempSensor    = SunshineP.Temperature;
  LightSensor   = SunshineP.LightIntensity;

  /* EXTERNAL SAMPLE UPDATES *********************************************/
  SolarCurrentUpdate  = SunshineP.SolarCurrentUpdate;
  CapVoltageUpdate    = SunshineP.CapVoltageUpdate;
#ifdef USE_REFCAP
  RefCapVoltageUpdate = SunshineP.RefCapVoltageUpdate;
#endif
  TempUpdate          = SunshineP.TempUpdate;
  LightUpdate         = SunshineP.LightUpdate;

  /* CAPLIBRATE **********************************************************/
  components CaplibrateC;
  Caplibrate = CaplibrateC;

  CaplibrateC.CapVoltageUpdate -> SunshineP.CapVoltageUpdate;

  /* SENSING JOBS ********************************************************/
  components CapSamplingJobC;
  SunshineP.SubCapVoltageUpdate -> CapSamplingJobC;

#ifdef USE_REFCAP
  components RefCapSamplingJobC;
  SunshineP.SubRefCapVoltageUpdate -> RefCapSamplingJobC;
#endif

  components SolarSamplingJobC;
  SunshineP.SubSolarCurrentUpdate -> SolarSamplingJobC;
  
  components AmbientSamplingJobC;
  SunshineP.SubTempUpdate  -> AmbientSamplingJobC.TempValueUpdate;
  SunshineP.SubLightUpdate -> AmbientSamplingJobC.LightValueUpdate;
}

