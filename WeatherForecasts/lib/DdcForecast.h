enum {
  DDC_VALUES_MAX        = 72,
  DDC_VALUE_ABS_SIZE    =  4,  // size of absolute values (in bits)
  DDC_VALUE_REL_MAXSIZE =  3,
  DDC_VALUE_UNKNOWN     = -1,
  //
  DDC_CODE_EQ           =  0,
  DDC_CODE_INC          =  1,
  DDC_CODE_DEC          =  2,
  DDC_CODE_ABS          =  3,
};



typedef struct ddc_forecast_s {
  uint32_t  creationTime;  // creation time (in local ms)
  uint8_t   resolution;    // time resolution of the forecast (in hours)
  uint8_t   numValues;     // number of forecast values (<= DDC_VALUES_MAX)
  uint8_t   sunrise;
  uint8_t   sunset;
  uint8_t   values[DDC_VALUES_MAX];
} ddc_forecast_t; 

