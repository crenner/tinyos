#ifndef DDC_FORECAST_H
#define DDC_FORECAST_H


enum {
  // TODO part of these could be used as variables for a generic implementation of the decoder!
  DDC_VALUE_MAX_NUM     = 144,  // maximum number of values
  DDC_VALUE_MAX         =  8,  // maximum value
  DDC_VALUE_ABS_SIZE    =  4,  // size of absolute values (in bits)
  DDC_VALUE_REL_MAXSIZE =  3,
  DDC_VALUE_UNKNOWN     = /*-1*/ 9,
  DDC_VALUE_DEFAULT     =  5,
  //
  DDC_CODE_EQ           =  0, // uses same codes as encoder but with leading ones only leaving out all zeroes
  DDC_CODE_INC          =  1, // e.q binarty code is 10, without 0 it's only 1
  DDC_CODE_DEC          =  2,
  DDC_CODE_ABS          =  3,
  AM_DDCFORECAST        = 188
};



typedef struct ddc_forecast_s {
  uint32_t  creationTime;  // creation time (in local ms)
  uint8_t   resolution;    // time resolution of the forecast (in hours)
  uint8_t   numValues;     // number of forecast values (<= DDC_VALUES_MAX)
  uint8_t   sunrise;
  uint8_t   sunset;
  uint8_t   values[DDC_VALUE_MAX_NUM];
} ddc_forecast_t;

ddc_forecast_t decodedData;



#endif
