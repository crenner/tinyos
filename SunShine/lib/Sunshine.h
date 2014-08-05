#ifndef SUNSHINE_H
#define SUNSHINE_H

/* currently not used due to problems with subsequent ADC readings */
//enum {
//  /* solar cell */
//  SOLAR_AVG_NUM_SAMPLES     =  4,
//  /* cap */
//  CAPVOLT_AVG_NUM_SAMPLES   =  2
//};

/**
 * global definitions
 */
#define CONFDFLT_SUPPLY_VOLTAGE    692 /* node supply voltage, 2.7 V (fp_t) */
#define CONFDFLT_SUPPLY_CUTOFF     128 /* minimum regulator input voltage, 0.5 V (fp_t) */
#define CONFDFLT_SUPPLY_EFFICIENCY  85 /* average node supply efficiency, (percent) */
typedef struct {
  fp_t     outputVoltage;
  fp_t     cutoffVoltage;
  uint8_t  efficiency;
} supply_config_t;
#define CONFDFLT_SUPPLY (supply_config_t) {          \
  CONFDFLT_SUPPLY_VOLTAGE,                           \
  CONFDFLT_SUPPLY_CUTOFF,                            \
  CONFDFLT_SUPPLY_EFFICIENCY                         \
}


/**
 * Temperatur conversion setup for Vishay 2381 640 66683
 * 
 * T(x) = A + B * x + C * x^2
 *   x    = log(R / Rref)
 *   Rref = reference resistance at 25 degree
 *   The following values are only valid for a 100k
 *   series resistor
 */
typedef struct {
  sfp_t  constGain;
  sfp_t  linGain;
  sfp_t  sqrGain;
} temp_converter_config_t;
#define CONFDFLT_TEMP_CONVERTER (temp_converter_config_t) {     \
   6400  /*  25.0  */,  /* degree celsius, (sfp_t) */           \
  -5599  /* -21.871*/,  /* degree celsius, (sfp_t) */           \
    333  /*   1.302*/   /* degree celsius, (sfp_t) */           \
}

/**
 * TODO CURRENTLY a placeholder
 * Light conversion
 * 
 * L(x) = A + B * x + C * x^2
 *   x    = log(R / Rref)
 *   Rref = reference resistance at 25 degree
 *   The following values are only valid for a 100k
 *   series resistor
 */
typedef struct {
  uint8_t  dummy;
} light_converter_config_t;
#define CONFDFLT_LIGHT_CONVERTER (light_converter_config_t) {     \
  1                                                               \
}


/**
 * configuration to convert adc values 'x' to solar current
 * see converter implementation for details
 */
typedef struct {
  uint8_t   offset;
  fp_t      linGain;
  fp_t      invGain;
} solar_converter_config_t;

/* default values */
#define CONF_OFFSET_ADAPT_DELAY  10  /* only decrease offset, if N consecutive samples below current value */
#define CONFDFLT_SOLAR_CONVERTER (solar_converter_config_t) {       \
  255,  /* (raw adc value) */                                       \
  (CONFDFLT_SUPPLY_VOLTAGE * 15 + 512) / 1024,   /* mA per adc step (fp_t),  Vcc / 1024 * 15mA/V */  \
   71   /* ... (fp_t) non-linearity sensor value compensation */  \
}

/* SunshineP: if the light reading is not above CONF_NOSOLAR_LIGHT_THRESH,
 * we assume zero solar current and discard the actual solar current
 * sensor reading */
#define CONF_NOSOLAR_LIGHT_THRESH  10


/**
 * configuration data
 * - maxVoltage
 * - cap capacity
 * - resistance value (discharge)
 */
typedef struct {
  bool      calibrated;     /* flag, whether cap has been calibrated */
  uint32_t  timestamp;      /* timestamp of last update */
  fp_t      maxVoltage;     /* maximum cap voltage */
  fp_t      capacity;       /* supercap capacity (farad) */
  fp_t      resistance;     /* resistance of discharger (ohm) */
} capcontrol_config_t;

#ifdef CAP_NOMINAL_SIZE
  #define FPTCAP FP_UNFLOAT(CAP_NOMINAL_SIZE)
#else
  /*25.0*/ /* lower bound (Farad, fp_t) */
  #define FPTCAP 6400 
#endif

/* default values */
#define CONFDFLT_CAPCONTROL (capcontrol_config_t) {                      \
  FALSE,                                                                 \
      0  /* boot time */,                                                \
    691  /* 2.7*/,     /* maximum cap voltage (Volt, fp_t) */            \
 FPTCAP, /* capacity (Farad, fp_t) */                                    \
  10394  /*39.0+1.6*/  /* resistor+mosfet resistance for cap calibration (Ohm, fp_t) */     \
}

enum {
  CAPLIBRATE_VDROP         = FP_CONV(0,15),   // target voltage delta for calibration
  CAPLIBRATE_VMIN          = FP_CONV(2, 0),   // min. voltage required to start calibration
  CAPLIBRATE_VMAX          = FP_CONV(2,50),   // max. voltage allowed to start calibration
};


enum {
  SUNSHINE_CAPVOLT_FILTER  = 128   // filter coeff for cap voltage EWMA smoothing
};

#endif
