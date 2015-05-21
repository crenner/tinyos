
enum {
  DUMMY_FORECAST_MAX_DATALEN   = 20,  // max length of ddc forecasts in bytes
};


typedef uint16_t ddcForecastAge_t;

typedef struct ddcForecastMsg_t {
  uint8_t           version
  uint8_t           len;
  ddcForecastAge_t  age;                                 // message age (seconds)
  uint8_t           data[DUMMY_FORECAST_MAX_DATALEN];    // data, up 8 * DDC_FORECAST_MAX_DATALEN bits
} ddcForecastMsg_t;