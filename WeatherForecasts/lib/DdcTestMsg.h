#ifndef DDC_TEST_MSG_H
#define DDC_TEST_MSG_H


enum {
  AM_DDCTESTMSG         = 123,
  DDC_TEST_MAX_VALUE     = 72  // 7*24 values
};


typedef nx_struct DdcTestMsg {
  nx_uint32_t  decodingTime;  // creation time (in local ms)
  nx_uint8_t   numValues;     // number of forecast values (<= DDC_VALUES_MAX)
  nx_uint8_t   sunrise;
  nx_uint8_t   sunset;
  nx_uint8_t   values[DDC_TEST_MAX_VALUE];
} DdcTestMsg;

#endif
