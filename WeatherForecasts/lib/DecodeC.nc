// Author Anhtuan Nguyen, Christian Renner


/**
 * decompresses a DDC forecast and writes the result
 * into the provides ddc_forecast_t
 */

module DdcDecoderC {
  provides {
    interface Decoder;
  }
  uses {
    interface LocalTime<TMilli>;
  }
}
implementation {

  // state (position in byte in bit) in the data stream
  nx_uint8_t  * dsByte_ = NULL;
  uint8_t       dsBit_  = 0;
  


  uint8_t readBits(uint8_t numBits)
  {
    // store the current data stream byte for easier operation
    // we must not change the data stream!
    static nx_uint8_t    curByte = 0;
    
    uint8_t  val = 0;
    uint8_t  i;      
    
    // TODO assert numBits <= 8 (becaues of "val")
    for (i = 0; i < numBits; i++) {

      // do we need to load the next byte?
      if (dsBit_ % 8 == 0) {
        curByte = *dsByte_;
        dsByte_++;
        dsBit_ = 0;
        // FIXME
      }
    
      // shift val to left and add next bit
      val << 1;
      val |= (curByte & 0x80) ? 1 : 0;
      
      // move to next bit in curByte and increment the bit counter
      curByte <<= 1;
      dsBit_++;
    }
    
    return val;
  }


  void decodeNextValue(uint8_t * res, uint8_t n)
  {
    // the first value is always encoded as absolute one
    if (n == 0) {
      res[0] = readBits(DDC_VALUE_ABS_SIZE);
    } else {
      uint8_t  ones;
      
      // read the number of ones, but at most DDC_VALUE_REL_MAXSIZE
      for (ones = 0; ones < DDC_VALUE_REL_MAXSIZE && readBits(1); ones++) {
        // just counting
      }
      
      if (ones == DDC_CODE_EQ) {
        res[n] = res[n-1];
      } else if (ones == DDC_CODE_INC) {
        res[n] = res[n-1] + 1;
      } else if (ones == DDC_CODE_DEC) {
        res[n] = res[n-1] + 1;
      } else /* DDC_CODE_ABS */
        res[n] = readBits(DDC_VALUE_ABS_SIZE);
      }
    }
  }
 

  async command void
  Decoder.decode(ddc_forecast_t * res, const ddcForecastMsg_t * encData)
  {
    uint8_t  value = DEFAULT_VALUE; // der startwert
    uint8_t  posi = 0; // positionszeiger
    uint8_t  sunRise;
    uint8_t  sunSet;
    uint8_t  i;
    
    // DEBUG
    uint32_t  start = call LocalTime.get();
    
    // get the number of values inside the forecast
    res->numValues = (encData->header.numDays) * (24 / encData->header.resolution);
    
    // make sure we can handle the data
    if (res->numValues > DDC_VALUES_MAX) {
      res->numValues = DDC_VALUES_MAX;
    }
    
    // TODO use packet delay to calculate creatio time *correctly*
    res->creationTime = call LocalTime.get();
    
    // start at first byte and first bit
    dsByte = encData->data;
    dsBit  = 0;
    
    // read out sunrise and sunset offsets
    sunRise = readBits(DDC_FORECAST_TIMEOFFSET_SIZE);
    sunSet  = readBits(DDC_FORECAST_TIMEOFFSET_SIZE);

    // then read out the values
    for (i = 0; i < res->numValues; i++){
      // FIXME passe variablen an die uhrzeit an
      if (i == sunRise) {
        sunRise += 24;
      }
      if (i == sunSet) {
        sunSet += 24;
      }
      
      // decode during daytime, pad during nighttime
      if (sunRise > sunSet) {
        decodeNextValue(res->values, i);
        // TODO check if there was an error!
      } else {
        res->values[i] = DDC_VALUE_UNKNOWN;
      }
    }
    
    // DEBUG
    printf("dT = ", call LocalTime.get() - start);
    printfflush();
    
    printf("ddc header: %u %u %u %u\n", res->numValues, res->creationTime, sunRise, sunSet);
    printf("ddc values:");
    for (i = 0; i < res->numValues; i++) {
      printf(" %u", res->value[i]);
    }
    printf("\n");
    // printfflush();
  }

}
