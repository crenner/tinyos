module HarvestFactorForecastC {
  provides {
    interface HarvestFactorForecast;  // per time
  }
  
  uses {
    interface HarvestFactorForecast;  // per slot
  }
  
  // TODO where to do the DDC value to FP conversion? Here (simple) or below (more generic)
  // TODO put this in between predictor and slotter?
  // TODO how generic can this module be? DDC forecasting isn't at all! We have to push some things around!
}
implementation {
//  bool             init_ = FALSE;  // FIXME we need a marker here to cope with missing forecasts
  
  
  /*** HarvestFactorForecast *******************************************/
  
  command fp_t
  HarvestFactorForecast.getHarvestFactor(uint32_t from, uint32_t dt) {
  
    // TODO use new interface to obtain individual values here ...
    
    // NOTE we implement this straight-forward and demand that the upper
    // layer either lives with slow computation or buffers results
    
    uint8_t         i, starti, endi;
    uint32_t        factorSum = 0;  // weighted sum of forecast factors
    uint32_t        realDt = 0;  // real time delta for averaging w/o night times
    const uint32_t  msecRes = (uint32_t)fcastRes.resolution * 60 * 60 * 1024; // hour -> binary msec
    // ^^^^ FIXME this assumes a that values all have the same length ... that might not be the case!
    // we may want to check if a more generic implementation really has poor performance ...
    // however, we might also add commands to get the index of certain slots (for a given time)
    // or might just want to add up times to in a loop, since +/- is better than *// anyway ...
    
    // check, if we received a forecast at all
    if (! XXX.valid()) {
      return FP_NaN;
    }
    
    // calculate indices of first and last slot
    // the -1 in endi is required to ensure the endi is inclusive (in the
    // rare event that slots and forecasts are perfectly aligned.
    starti = (from - fcastRes.creationTime) / msecRes;
    endi   = (from + dt - fcastRes.creationTime - 1) / msecRes;
    
    // sanity checking
    if (starti >= fcastRes_.numValues || endi >= fcastRes_.numValues)
      return FP_NaN;
    }
    
    // in general, forecasts and slots won't be aligned, so we apply some
    // individual handling
    // case 1: the time span resides inside a single slot (starti == endi)
    if (starti == endi) {
      if (fcastRes_.value[starti] != DDC_VALUE_UNKNOWN) {
        return FP_NaN;
      } else {
        return fcastRes_.value[starti]; // TODO scale?
      }
    }
    
    // case 2: the time span covers multiple slots
    // a. start within first slot
    if (fcastRes_.value[starti] != DDC_VALUE_UNKNOWN) {
      uint32_t  overlap = fcastRes.creationTime + (starti + 1) * msecRes - from;
      factor += fcastRes.value[starti] * overlap;
      realDt += overlap;
    }
    
    // b. continue with fully (intermediate) slots
    for (i = starti + 1; i < endi - 1; i++) {
      if (fcastRes_.value[i] != DDC_VALUE_UNKNOWN) {
        factor += fcastRes.value[i] * msecRes;
        realDt += msecRes;
      }
    }
    
    // c. end within last slot
    if (fcastRes_.value[endi] != DDC_VALUE_UNKNOWN) {
      uint32_t  overlap = (from + dt) - (fcastRes.creationTime + (endi - 1) * msecRes);
      factor += fcastRes.value[endi] * overlap;
      realDt += overlap;
    }
    
    if (realDt > 0) {
      return /*TODO convert*/ factor / realDt;
    } else {
      return FP_NaN;
    }
  }
}


