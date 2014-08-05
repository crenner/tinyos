// NOTE do not use at the moment
// this implementation causes *severe* trouble with ADCs:
// if tasks trigger ADC conversion (using different channels)
// at the same time, wrong readDone instances are called (for
// a completely unknown reason)
// MAYBE the read() call inside readDone() messes up the ADC
// configuration, so that channels are not / or falsely changed

generic module SmoothAdcC (uint8_t NUM_SAMPLES) {
  provides {
    interface Read<uint16_t> as SmoothRead;
  }
  uses {
    interface Read<uint16_t> as SingleRead;
  }
}
implementation {
  // members
  uint16_t  sumSampling_;
  uint16_t  numSamples_;
  bool      busy_ = FALSE;

  command error_t SmoothRead.read()
  {
    error_t  res;

    // do not start multiple conversions
    if (busy_) {
      return EBUSY;
    } else {
      busy_        = TRUE;
      numSamples_  = 0;
      sumSampling_ = 0;
    }
		
    res = call SingleRead.read();
    if (res != SUCCESS) {
      busy_        = FALSE;
    }
    return res;
  }

  event void SingleRead.readDone(error_t res, uint16_t val)
  {
    if (res != SUCCESS || busy_ == FALSE) {
      busy_ = FALSE;
      signal SmoothRead.readDone(res, val);
      return;
    }
		
    sumSampling_ += val;
    if (++numSamples_ < NUM_SAMPLES) {
      res = call SingleRead.read();
      if (res != SUCCESS) {
        // signal error
        busy_ = FALSE;
        signal SmoothRead.readDone(res, val);
      }
    } else {
      // get average with rounding capability
      val = (sumSampling_ + NUM_SAMPLES / 2) / NUM_SAMPLES;

      // signal result
      busy_ = FALSE;
      signal SmoothRead.readDone(res, val);
    }
  }
}
