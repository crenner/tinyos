#include "FixPointMath.h"

module TempSensorConverterP {
  uses {
    interface GetSet<const temp_converter_config_t *> as Config @exactlyonce();
  }
  provides {
    interface SensorValueConverter<sfp_t>;
  }
}

implementation {
  command sfp_t SensorValueConverter.convert (uint16_t val) {
    sfp_t  temp = 0;

    // T(r) = ( A + B * ln(r) )^-1
    // T(r) = X + Y * ln(r)
    //   with r = Rc / R
    //   where Rc is the resistance of the NTC and R is
    //   a constant series resistor
    //   Since the ADC value is the voltage V over R,
    //   we find Rc = R * (Vref - V) / V
    //   For V = ADC / 1024 * Vref:
    //   r = Rc / R
    //     = R * (Vref - V) / V / R
    //     = (Vref - V) / V
    //     = (Vref - ADC / 1024 * Vref) / (ADC / 1024 * Vref)
    //     = (1024 - ADC) / 1024 * 1024 / ADC
    //     = (1024 - ADC) / ADC

    // the integer part of fp_t has 8 bits, so that we must ensure
    //     (1024 - val) / val < 256
    // ==> val >= 4
    if (val >= 4) {
      const temp_converter_config_t * conf = call Config.get();
      fp_t  x;
      x = fpDiv((1024 - val), val);
      temp = fpLog(x);
      temp = conf->constGain + fpSMlt(temp, conf->linGain + fpSMlt(temp, conf->sqrGain));
    } else {
      //res  = FAIL;
      temp = FP_NaN;
    }
    return temp;
  }
}
