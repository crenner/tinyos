//#include "FixPointMath.h"

/**
 * Perkin Elmer Photecell A 9060 14
 *
 * I(R) = 10 * log10( A (R - R0) )  (I [dB lux], R [kOhm])
 * I(v) = 10 * log10( A*Rs (v - R0/Rs) )
 *      = 10 * log10(-A*Rs) + 10 * log10(R0/Rs - v)
 *      = a + b * ln(R0/Rs - v)
 * with (I1, R1), (I2, R2):
 * - A  = (I2 - I1) / (R2 - R1)
 * - R0 = R1 - I1 / A
 * - a  = 10 * log10(-A*Rs)
 * - b  = 10 / ln(10)
 *
 * for (10 [=10 lux], 210k), (20 [=100 lux], 15k), Rs=5.1k
 * - a     =   3.717781
 * - b     =   4.342945
 * - R0/Rs =  45.424837
 */
#define LIGHT_COEFF_CONST (fp_t)(  952)
#define LIGHT_COEFF_LIN   (fp_t)( 1112)
#define LIGHT_LIN_SHIFT   (fp_t)(11629)
#define LIGHT_ZERO        (fp_t)(    0)  /* no light */

module LightSensorConverterP {
  uses {
    interface GetSet<const light_converter_config_t *> as Config @exactlyonce();
  }
  provides {
    interface SensorValueConverter<fp_t>;
  }
}
implementation {
  command fp_t SensorValueConverter.convert (uint16_t val) {
    fp_t  light = 0;
    //   The ADC value is the voltage V over R.
    //   For V = ADC / 1024 * Vref:
    //   r = Rc / R
    //     = R * (Vref - V) / V / R
    //     = (Vref - V) / V
    //     = (Vref - ADC / 1024 * Vref) / (ADC / 1024 * Vref)
    //     = (1024 - ADC) / 1024 * 1024 / ADC
    //     = (1024 - ADC) / ADC

    return val;
/*
    if (val > 0) {
      fp_t  v;
      // the integer part of fp_t has 8 bits, so that we must ensure
      //     (1024 - val) / val < 256
      // ==> val >= 4
      if (val >= 4) {
        v = fpDiv((1024 - val), val);
        if (v < LIGHT_LIN_SHIFT) {
          v = fpLog(LIGHT_LIN_SHIFT - v);
          light = LIGHT_COEFF_CONST + fpMlt(LIGHT_COEFF_LIN, v);
        } else {
          light = LIGHT_ZERO;
        }
      } else {
        light = LIGHT_ZERO;
      }
    } else {
      light = LIGHT_ZERO;
    }
    return light;
*/
  }
}
