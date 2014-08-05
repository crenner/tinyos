#include "Sunshine.h"

configuration SunshineConfigC {
  provides {
    interface GetSet<const supply_config_t *>          as GetSetSupplyConfig;
    interface GetSet<const capcontrol_config_t *>      as GetSetCapControlConfig;
    interface GetSet<const solar_converter_config_t *> as GetSetSolarConverterConfig;
    interface GetSet<const temp_converter_config_t *>  as GetSetTempConverterConfig;
    interface GetSet<const light_converter_config_t *> as GetSetLightConverterConfig;
  }
}
implementation {
  components SunshineConfigP;

  // configuration for Supply (DCDC)
  components new ConfigC(supply_config_t)
    as SupplyConfig;
  SupplyConfig               -> SunshineConfigP.SupplyConfigInit;
  GetSetSupplyConfig         =  SupplyConfig;

  // configuration for Cap Control
  components new ConfigC(capcontrol_config_t)
    as CapControlConfig;
  CapControlConfig           -> SunshineConfigP.CapControlConfigInit;
  GetSetCapControlConfig     =  CapControlConfig;

  // configuration for Solar Converter
  components new ConfigC(solar_converter_config_t)
    as SolarConverterConfig;
  SolarConverterConfig       -> SunshineConfigP.SolarConverterConfigInit;
  GetSetSolarConverterConfig = SolarConverterConfig;

  // configuration for Temperature Converter
  components new ConfigC(temp_converter_config_t)
    as TempConverterConfig;
  TempConverterConfig        -> SunshineConfigP.TempConverterConfigInit;
  GetSetTempConverterConfig  = TempConverterConfig;

  // configuration for Light Converter
  components new ConfigC(light_converter_config_t)
    as LightConverterConfig;
  LightConverterConfig       -> SunshineConfigP.LightConverterConfigInit;
  GetSetLightConverterConfig = LightConverterConfig;
}
