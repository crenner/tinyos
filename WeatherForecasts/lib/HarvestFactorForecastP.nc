#include "Statistics.h"


generic module HarvestFactorForecastP(uint8_t NUM_SLOTS, uint8_t ALPHA) {
  provides {
    interface Init @exactlyonce();
    interface HarvestFactorForecast;
    interface SlotValue<fp_t>;
  }
  uses {
    interface Slotter;
    interface WeatherForecast<fp_t>;  // per slot
    interface LocalTime<TMilli>;
  }
}
implementation {
  
  fp_t  mean_[NUM_SLOTS];   // mean slot values
  
  
  
  /*** Init **************************************************************/
  
  command error_t
  Init.init() {
    uint8_t  i;
    for (i = 0; i < NUM_SLOTS; i++)  {
      mean_[i] = FP_ONE;
    }

    return SUCCESS;
  }
  
  
  
  /*** HarvestFactorForecast *******************************************/
  
  command fp_t
  HarvestFactorForecast.getHarvestFactor(uint32_t from, uint32_t dt) {
    
    // NOTE we implement this straight-forward and demand that the upper
    // layer either lives with slow computation or buffers results
    
    uint8_t   i;
    uint32_t  fstart, fend;
    uint32_t  factorSum = 0;  // weighted sum of forecast factors
    uint32_t  realDt = 0;  // real time delta for averaging w/o night times
    
    // check, if we received a forecast at all
    if (! call WeatherForecast.valid()) {
      return FP_NaN;
    }
    
    // NOTE in the following, we do all time considerations relative to the
    // creation time of the forecast (from is always later than forecast
    // creation) in order to prevent any time wrap-around issues.
    from -= call WeatherForecast.creationTime();
    
    // check if the required time span is in scope (forecast horizon)
    if (from + dt > call WeatherForecast.horizon()) {
      return FP_NaN;
    }

    
    // iterate over individual forecast factors and calculated a weighted sum
    fstart  = 0;
    for (i = 0; i < call WeatherForecast.numValues(); i++) {
      fend = fstart + call WeatherForecast.length(i);
      
      if (fstart >= from + dt) {  // forecast slot is behind requested interval
        break;
      } else if (fend > from) { // there is an overlap
        fp_t  value = call WeatherForecast.value(i);
        if (value != FP_NaN) {
          uint32_t  overlap;
          overlap =  ((from + dt < fend) ? (from + dt) : fend)  // min(from + dt, fend)
                   - ((from > fstart) ? from : fstart);         // max(from, fstart);
        
          factorSum += value * overlap;
          realDt    += overlap;
        }
      }
      
      fstart = fend;
    }
    
    
    if (realDt > 0) {
      return (factorSum + realDt / 2) / realDt;
    } else {
      return FP_NaN;
    }
  }
  
  
  /*
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
    // or might just want to add up times to in a loop, since +/- is better than
    
    
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
      return factor / realDt;   // TODO convert
    } else {
      return FP_NaN;
    }
  }
  */
  
  
  
  /*** SlotValue *********************************************************/
  
  command fp_t
  SlotValue.get(uint8_t slot) {
    if (slot < NUM_SLOTS) {
      return mean_[slot];
    } else {
      return FP_NaN;
    }
  }
  
  
  /*** Slotter ***********************************************************/
  
  event void
  Slotter.slotEnded(uint8_t slot) {
    uint32_t  from, dt;
    fp_t slotVal;
  
    if (slot >= NUM_SLOTS) {
      return;  // must not occur!
    }
    
    dt      = call Slotter.getSlotDuration(slot);
    from    = call LocalTime.get() - dt;
    slotVal = call HarvestFactorForecast.getHarvestFactor(from, dt); 
    mean_[slot] = ewmaFilter16(mean_[slot], slotVal, ALPHA);
  }
  
  
  event void
  Slotter.cycleEnded() {
  }
}


