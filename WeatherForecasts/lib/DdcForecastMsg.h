
enum {
  DDC_FORECAST_MAX_DATALEN     = 20,  // max length of ddc forecasts in bytes
  //DDC_FORECAST_VERSION_SIZE    = 5,   // size of version number (bits)
  DDC_FORECAST_NUMDAYS_SIZE    = 3,   // size of the number of days field (bits)
  DDC_FORECAST_RESOLUTION_SIZE = 2,   // size of the resolution field (bits)
  DDC_FORECAST_TIMEOFFSET_SIZE = 5,   // size of time offsets (sunrise/sunset) (bits)
  //DDC_FORECAST_RESERVED_SIZE   = 4,   // unused bits (to next byte border)
  AM_DDC_FORECAST_MSG          = 200
};


typedef nx_uint16_t ddcForecastAge_t;

typedef nx_struct ddcForecastMsg {
  nx_struct {
//    nx_uint8_t  version    : DDC_FORECAST_VERSION_SIZE;     // version number, ring counter
    nx_uint8_t  numDays    : DDC_FORECAST_NUMDAYS_SIZE;     // forecast length - 1 in number of days
    nx_uint8_t  resolution : DDC_FORECAST_NUMDAYS_SIZE;     // resolution - 1 in hours
//    nx_uint8_t  sunrise    : DDC_FORECAST_TIMEOFFSET_SIZE;  // sunrise offset w.r.t. forecast creation or sunset
//    nx_uint8_t  sunset     : DDC_FORECAST_TIMEOFFSET_SIZE;  // sunset offset w.r.t. forecast creation or sunrise
//    nx_uint8_t  reserved   : DDC_FORECAST_RESERVED_SIZE;    // unused bits
  } header;
  ddcForecastAge_t  age;                                 // message age (seconds)
  nx_uint8_t        data[DDC_FORECAST_MAX_DATALEN];      // data, up 8 * DDC_FORECAST_MAX_DATALEN bits
} ddcForecastMsg;