#include "FixPointMath.h"
#include "Sunshine.h"


module CapVoltageConverterP {
  uses {
    interface GetSet<const supply_config_t *> as Config @exactlyonce();
  }
  provides {
    interface SensorValueConverter<fp_t>;
  }
}
implementation {
  command fp_t SensorValueConverter.convert (uint16_t val) {
    // - implicit conversion of ADC reading *val* by handling
    //   it as a fp_t value.
    // - multiplication with ADC reference voltage in fp_t
    // - closing the gap between implicit fp_t conversion
    //   and needed division by ADC max value by final shift
    //
    // V = (val / 1024 * Vcc) * F  (F for uint=>fp_t)
    //   = (val / F) * (Vcc * F) / (1024 / F)
    //      ^^^^^^^     ^^^^^^^     ^^^^^^^^
    //     fake fp_t      fp_t     reconversion
    return fpMlt((fp_t)val, (call Config.get())->outputVoltage) >> (10 - FP_FRACT_SIZE); 
  }
}
