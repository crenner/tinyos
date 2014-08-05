#include "FixPointMath.h"
#include "Sunshine.h"

module SolarCurrentConverterP {
  uses {
    interface GetSet<const solar_converter_config_t *> as Config @exactlyonce();
    interface Boot;
    interface SensorValueUpdate<uint16_t> as LightValueUpdate;
  }
  provides {
    interface SensorValueConverter<fp_t>;
  }
}
implementation {
  bool      isDark_           = FALSE;
  //uint8_t   offsetAdaptDelay_ = 0;
  uint8_t   offsetSmooth_     = 0xFF;
  uint8_t   offsetAboveCnt_   = 0;
  uint8_t   offsetBelowCnt_   = 0;
  float     v                 = 0;                // conversion correction for non-linear part

  /* Internals ***********************************************************/
  void updateOffset(uint8_t newOffset) {
    // adapt offset value
    solar_converter_config_t  newConf = *(call Config.get());
    //newConf.offset = (newOffset + conf->offset + 1) / 2;
    //offsetSmooth_  = newConf.offset;
    newConf.offset = offsetSmooth_;
    //if (newConf.offset != conf->offset) {
    call Config.set(&newConf);
    //}

    // update non-linear conversion part
    v = FP_FLOAT(newConf.invGain) * FP_FLOAT(newConf.linGain) * newConf.offset;
  }

  /* Boot ****************************************************************/
  event void Boot.booted() {
    const solar_converter_config_t * conf = call Config.get();

//  OFFSET resetting code
//    solar_converter_config_t  nc;
//    nc = *conf;
//    nc.offset = 0xFF;
//    call Config.set(&nc);

    v = FP_FLOAT(conf->invGain) * FP_FLOAT(conf->linGain) * conf->offset;
  }

  /* LightValueUpdate ****************************************************/
  event void LightValueUpdate.update(uint16_t val) {
    // NOTE solar current readings are effect by temperature effects, which
    // result in massive errors during ~0 mA readings
    // for that purpose, we use the light reading (low light reading implies
    // 0 mA solar current) to alleviate this problem
    if (val <= CONF_NOSOLAR_LIGHT_THRESH) {
      isDark_ = TRUE;
    } else {
      isDark_ = FALSE;
    }
  }

  /* SensorValueConverter ************************************************/
  command fp_t SensorValueConverter.convert (uint16_t val) {
    const solar_converter_config_t * conf = call Config.get();

    // smooth value for offset detection: EWMA with 0.75 to avoid overfitting
    offsetSmooth_ = (uint8_t)((3 * (uint16_t)offsetSmooth_ + val + 3) / 4);
    
    // it's dark
    if (isDark_) {
      offsetBelowCnt_ = 0;  // reset lightness counter
      
      if (val >= conf->offset) {
        // the current value is larger than the offset.
        // this may occur, if the offset is shifted (e.g., due to temperature changes)
        // in this case, we should try to lift the offset value
        if (offsetAboveCnt_ >= CONF_OFFSET_ADAPT_DELAY) {
          if (offsetSmooth_ > conf->offset) {
            updateOffset(offsetSmooth_);
            offsetAboveCnt_ = 0;  // reset the delay counter
          }
        } else {
          offsetAboveCnt_++;  // only increment, if
        }
      } else {
        offsetAboveCnt_ = 0;  // reset above counter, if val is below offset
      }

      return 0;  // no solar energy during the night

    // it's light
    } else {
      fp_t      cur = 0;                // conversion result
      
      offsetAboveCnt_ = 0;
    
      // convert value
      if (val > conf->offset) {
        // CONVERSION MODEL
        // val0 = conf->offset
        // a    = conf->linGain
        // b    = conf->invGain
        // I = (val - val0) * (a + 1 / ( a*b*val0 * (val - val0 + b*val0) ))
        // I = a * (val-val0) - 1/(a * (val-val0) + a*b*val0) + 1/(a*b*val0)
        //     ^^^^^^^^^^^^^^     ^^^^^^^^^^^^^^^
        //          ds                  ds          ^^^^^^^^       ^^^^^^^^
        //                                              v              v
        // => I = ds - 1/(ds + v) + 1/v
        // => I = ds - v/(v*(ds+v)) + (ds+v)/(v*(ds+v)) = ds + ds / (v * (ds + v))
        cur = (val - conf->offset) * conf->linGain;

        // calculate current, prevent negative values (=overflows)
        // FIXME => possibly leads to NaN in fpInv, if v too small!
        // so we're currently using floating points
        if (v > 0) {
          // fp_t / float = fp_t
          cur += cur / (v * (cur + v));
        }

        // reset offset adaptation counter (val > val0)
        offsetBelowCnt_ = 0;
      } else {
        if (offsetBelowCnt_ >= CONF_OFFSET_ADAPT_DELAY) {
          if (offsetSmooth_ < conf->offset) {
            updateOffset(offsetSmooth_);
            offsetBelowCnt_ = 0;  // reset the delay counter
          }
        } else {
          offsetBelowCnt_++;  // only increment, if not at maximum
        }
      }
    
      return cur;
    }
  }
  
}
