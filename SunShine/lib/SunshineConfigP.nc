module SunshineConfigP {
  provides {
    interface ParameterInit<supply_config_t *>           as SupplyConfigInit;
    interface ParameterInit<capcontrol_config_t *>       as CapControlConfigInit;
    interface ParameterInit<solar_converter_config_t *>  as SolarConverterConfigInit;
    interface ParameterInit<temp_converter_config_t *>   as TempConverterConfigInit;
    interface ParameterInit<light_converter_config_t *>  as LightConverterConfigInit;
  }
}
implementation {
  /* SupplyConfigInit ****************************************************/
  command error_t SupplyConfigInit.init(supply_config_t * conf) {
    *conf = CONFDFLT_SUPPLY;
    return SUCCESS;
  }

  /* CapControlConfigInit ************************************************/
  command error_t CapControlConfigInit.init(capcontrol_config_t * conf) {
    *conf = CONFDFLT_CAPCONTROL;
    return SUCCESS;
  }

  /* SolarConverterConfigInit ********************************************/
  command error_t SolarConverterConfigInit.init(solar_converter_config_t * conf) {
    *conf = CONFDFLT_SOLAR_CONVERTER;
    return SUCCESS;
  }

  /* TempConverterConfigInit *********************************************/
  command error_t TempConverterConfigInit.init(temp_converter_config_t * conf) {
    *conf = CONFDFLT_TEMP_CONVERTER;
    return SUCCESS;
  }

  /* LightConverterConfigInit ********************************************/
  command error_t LightConverterConfigInit.init(light_converter_config_t * conf) {
    *conf = CONFDFLT_LIGHT_CONVERTER;
    return SUCCESS;
  }
}
