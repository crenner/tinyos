// Author Anhtuan Nguyen, Christian Renner


/**
 * decompresses a DDC forecast and writes the result
 * into the provides ddc_forecast_t
 */

module DdcDecoderP {
  provides {
    interface WeatherForecastDecoder<ddc_forecast_t, DdcForecastMsg> as Decoder;
  }
  uses {
    interface LocalTime<TMilli>;
  }
}
implementation {

  // state (position in byte in bit) in the data stream
  const nx_uint8_t  * dsLastByte_ = NULL;
  const nx_uint8_t  * dsByte_ = NULL;
  uint8_t             dsBit_  = 0;


  uint8_t readBits(uint8_t numBits)
  {
    // store the current data stream byte for easier operation
    // we must not change the data stream!
    static uint8_t    curByte = 0;
    
    uint8_t  val = 0;
    uint8_t  i;      
    
    // TODO assert numBits <= 8 (because of "val")
    for (i = 0; i < numBits; i++) {

      // do we need to load the next byte?
      if (dsBit_ % 8 == 0) {
        curByte = *dsByte_;
        dsByte_++;
        dsBit_ = 0;
        
        // sanity check
        if (dsByte_ > dsLastByte_) {
          return FAIL;
        }
      }
    
      // shift val to left and add next bit
      val <<= 1;
      val |= (curByte & 0x80) ? 1 : 0;
      
      // move to next bit in curByte and increment the bit counter
      curByte <<= 1;
      dsBit_++;
    }
    
    return val;
  }


  void decodeNextValue(uint8_t * res, uint8_t n, uint8_t defaultPredecessor)
  {
    uint8_t predecessor;
    uint8_t  ones;
    // define relative predecessor
    if (defaultPredecessor){ // if last value was Unknown
      predecessor = DDC_VALUE_DEFAULT;
    } 
    else {
      predecessor = res[n-1];
    }
    // predecessor of first value is default value
    if (n == 0) {
        predecessor = DDC_VALUE_DEFAULT;
    } 

      
      // read the number of ones, but at most DDC_VALUE_REL_MAXSIZE
      for (ones = 0; ones < DDC_VALUE_REL_MAXSIZE && readBits(1); ones++) {
        // just counting
      }
      
      if (ones == DDC_CODE_EQ) {
        res[n] = predecessor;
      } else if (ones == DDC_CODE_INC) {
        res[n] = predecessor + 1;
      } else if (ones == DDC_CODE_DEC) {
        res[n] = predecessor - 1;

      } else /* DDC_CODE_ABS */ {
        res[n] = readBits(DDC_VALUE_ABS_SIZE);
      }
    
  }
 

  command error_t
  Decoder.decode(ddc_forecast_t * res, const DdcForecastMsg * encData)
  {
    uint8_t  i;
    uint8_t  sunrise, sunset;
    uint8_t  defaultPredecessor;
    
    // get the number of values inside the forecast
    res->numValues = (encData->header.numDays+1) * (24 / (encData->header.resolution+1));
    // make sure we can handle the data
    if (res->numValues > DDC_VALUE_MAX_NUM) {
      res->numValues = DDC_VALUE_MAX_NUM;
    }
    
    // TODO use packet delay to calculate creatio time *correctly*
    res->creationTime = call LocalTime.get();
    // BIS HIER KORRIGIERT
    // INIT: start at first byte and first bit
    dsByte_     = encData->data;
    dsLastByte_ = dsByte_ + DDC_FORECAST_MAX_DATALEN - 1;
    dsBit_      = 0;

    
    // read out sunrise and sunset offsets
    res->sunrise = encData->header.sunrise;
    res->sunset  = encData->header.sunset;
    // then read out the values
    sunrise = res->sunrise;
    sunset  = res->sunset;

    for (i = 0; i < res->numValues; i++){
      // at sunrise/sunset, move to next occurance
      	defaultPredecessor = 0; // false
      	if (i == sunrise) {
        	sunrise += 24;
        	defaultPredecessor = 1;
      	} else if (i == sunset) {
        	sunset += 24;
      	}
   
      // decode during daytime, pad during nighttime
      	if (sunrise > sunset) { 
        	decodeNextValue(res->values, i,defaultPredecessor);

        // check if there was an error!
        	if (dsByte_ > dsLastByte_) {
          	return FAIL;
        	}

      	} else {
        	res->values[i] = DDC_VALUE_UNKNOWN;
      	}
    }
    return SUCCESS;
  }

}
