generic module SlottedHarvestPredictionDummyC(uint8_t FORECAST_HORIZON) {
  provides {
    interface SlottedForecast as SlottedHarvestPrediction;
  }
  uses {
    interface Slotter as SlottedHarvestModel;
    interface SlotValue<fp_t> as SlottedHarvestModelValue;
    interface SlotValue<fp_t> as SlottedHarvestFactorValue;
    interface HarvestFactorForecast;
  }
}
implementation {
  /*
  uint8_t   latestSlot_      = 0;  // marker for the ... TODO
  uint16_t  latestSlotBegin_ = 0;  // 
  */
  
  bool  dirty_ = TRUE;
  fp_t  cache_[FORECAST_HORIZON];  // cache of forecast values for 

  
  /*** helpers *********************************************************/
  void
  buildCache() {
    uint8_t   slot, i;
    uint32_t  from, dt;
    fp_t      modelVal, avgFactor, predFactor;
    
    // fill the gap of cache entries
    from = 0;
    for (i = 0; i < FORECAST_HORIZON; i++) {
      // calculate the slot index of the underlying layer
      slot = (call SlottedHarvestModel.getCurSlot() + i) % call SlottedHarvestModel.getNumSlots();
      
      // slot duration
      dt = call SlottedHarvestModel.getSlotDuration(slot);
      
      // get required values for prediction
      modelVal   = call SlottedHarvestModelValue.get(slot);
      avgFactor  = call SlottedHarvestFactorValue.get(slot);
      predFactor = call HarvestFactorForecast.getHarvestFactor(from, dt);
      
      // FIXME if (HarvestFactorForecast.valid() && predFactor != FP_NaN) {
      if (predFactor != FP_NaN) {
        cache_[i] = fpMlt(modelVal, fpDiv(predFactor, avgFactor));
      } else {
        cache_[i] = modelVal;
      }
      
      from += dt;
    }

    dirty_ = FALSE;
  }
  
  
  /*** SlottedHarvestPrediction ****************************************/
  
  command uint8_t
  SlottedHarvestPrediction.getNumSlots() {
    return FORECAST_HORIZON;
  }

  
  command uint32_t
  SlottedHarvestPrediction.getSlotDuration(uint8_t slot) {
    return call SlottedHarvestModel.getSlotDuration(slot);
  }
  
  
  command fp_t
  SlottedHarvestPrediction.getSlotValue(uint8_t slot) {
    // at the moment, we do only support up to FORECAST_HORIZON
    if (slot >= FORECAST_HORIZON) {
      return FP_NaN;
    }
  
    if (dirty_) {
      buildCache();
    }
    
    return cache_[slot];
  }

  
  /*
  command fp_t SlottedHarvestPrediction.getSlotValue(uint8_t slot) {
    uint32_t  from, dt;
    
    // NOTE in general, we only expect 'slot' to either increase for
    // adjacent calls or go back to zero. We hence update the prediction
    // only for these cases efficiently
    if (slot < latestSlot_) {
      latestSlot_      = 0;
      latestSlotBegin_ = 0;
    }
    
    // update slot beginning time (go into future)
    for (; slot > latestSlot_; latestSlot_++) {
      latestSlotBegin_ += call SlottedHarvestModel.getSlotLength(latestSlot_);
    }
  
    // FIXME
    // this is a very poor implementation (performance-wise), as the harvest factors will be recomputed
    // over and over again (instead of cacheing their values). However, recomputation is only needed,
    // a) upon reception of a new forecast
    // b) change of slot aligments
    // c) slots must be shifted (by means of the pointer to the first slot in a ring buffer) upon slot end
    
    // FIXME
    // at the moment, we're missing the integration of the forecast value into the slotted value
    // looks like this should be done with a second slotter (if different length)
  
    // next, convert slot length base units / intervals into ms-time
    from = (uint32_t)latestSlotBegin_                             * call SlottedHarvestModel.getBaseIntvl();
    dt   = (uint32_t)call SlottedHarvestModel.getSlotLength(slot) * call SlottedHarvestModel.getBaseIntvl();
    
    // and finally obtain the forecast by multiplying the slot value with the harvest factor
    return fpMlt(call SlottedHarvestModel.getSlotValue(slot), call HarvestFactorForecast.getHarvestFactor(from, dt));
  }*/


  /*** SlottedHarvestModel *********************************************/
  
  event void
  SlottedHarvestModel.slotEnded(uint8_t slot) { 
    signal SlottedHarvestPrediction.slotEnded();
  }

  
  event void
  SlottedHarvestModel.cycleEnded() {
    signal SlottedHarvestPrediction.cycleEnded();
  }
  
  
//   event void
//   SlottedHarvestModel.realigned() {
//     updateCache();
//   
//   // TODO TODO TODO TODO
//     signal SlottedHarvestPrediction.realigned();
//   }
  
  
  /*** SlottedHarvestModel *********************************************/
//   event void
//   ??? {
//     updateCache();
//   }
}


/* eof */







// TODO TODO TODO TODO
// oder muss das nach HarvestFactorForecast (wohl schon)
// SCHACHT
//
//
// 	#include <FixPointMath.h>
// 	#include "EnergyBudgetizer.h"
// 	#include "Forecast.h"
// 	#include <math.h>
// 
// module HarvestPredictorP {
// 	provides {
// 		interface Slotter as OutputSlotter;
// 	}
// 	uses {
// 		interface Slotter as InputSlotter;
// 		interface ProvideForecast;
// 		interface LocalTime<TMilli> as Clock;
// 		
// 	}
// }
// 
// implementation{
// 	#define KIMBALL(x) (1-0.71*x)
// 	#define LAEVASTU(x) (1-0.6*pow(x,3))
// 	
//   enum {
//     SLOT_LENGTH_SECS = (FORECAST_CYCLE_LEN / FORECAST_NUM_SLOTS)*FORECAST_BASE_INTVL,  // fixed slot length in seconds
//   };
// 
// 	//Holds the last FORECAST_NUM_SLOTS slotValues to be able to calculate the next 12 slots
// 	uint16_t meanSlotValue[FORECAST_NUM_SLOTS];
// 	//Holds the present time
// 	uint32_t nowInSeconds;
// 	//Holds the values for the last slot
// 	fp_t lastCloudcover=0, lastSunshine=0;
// 	//Stores if still first Cycle of Calculations
// 	int firstCycle=1;
// 
// 	//Calculate moving average
//   static fp_t movingAVG(fp_t oldVal, fp_t newVal, uint8_t ratio) {
//     return (((uint32_t)oldVal) * ratio + ((uint32_t)newVal) * (128-ratio) + 64) >> 7;
//   }
// 
// 	command uint8_t OutputSlotter.getCurSlot(){
// 		return call InputSlotter.getCurSlot();
// 	}
// 
//   command uint8_t OutputSlotter.getNumSlots(){
// 		return call InputSlotter.getNumSlots();
// 	}
// 
//   command uint8_t OutputSlotter.getSlotLength(uint8_t slot){
// 		return call InputSlotter.getSlotLength(slot);
// 	}
// 
//   command fp_t OutputSlotter.getSlotValue(uint8_t slot){
// 		return call InputSlotter.getSlotValue(slot);
// 	}
// 
//   command uint16_t OutputSlotter.getBaseIntvl(){
// 		return call InputSlotter.getBaseIntvl();
// 	}
// 
//   command fp_t OutputSlotter.getSlotForecast(uint8_t slot){
// 		uint8_t curSlot;
// 		uint32_t startingtime;
// 		fp_t cc;
// 
// 		curSlot = call InputSlotter.getCurSlot();
// 
// 		//get present time
// 		nowInSeconds = call Clock.get()/1024;
// 
// 		//Calc starting time of slot that is called for
// 		//(now - how much into this slot)+Slotdifference*Slotlength in seconds
// 		startingtime=nowInSeconds-(nowInSeconds%SLOT_LENGTH_SECS)+((slot-curSlot)%FORECAST_NUM_SLOTS)*SLOT_LENGTH_SECS;
// 
// 		//get Forecast for this slot next day
// 		cc = call ProvideForecast.getCloudcoverForecast(startingtime,SLOT_LENGTH_SECS);
// 
// 		//return the calculated Value for that slot
// 		return meanSlotValue[slot]*KIMBALL(cc);
// 	}
// 
// 	/*
// 	//returns the calculated mean cloudcover as a fp_t value
// 	command fp_t getCloudcoverForecast(uint32_t period_begins, uint32_t period_length);
// 	//returns the calculated mean sun time as a fp_t value
// 	command fp_t getSunShineForecast(uint32_t period_begins, uint32_t period_length);
// 	*/
//   event void InputSlotter.slotEnded(uint8_t slot){
// 		uint32_t slotLengthSeconds;
// 		uint16_t slotValue;
// 
// 		dbg("HarvestPredictor","HarvestPredictor:\nSlotlänge ist %i sekunden\nSlotWert ist %f \n",
// 					SLOT_LENGTH_SECS,FP_FLOAT(meanSlotValue[slot%FORECAST_NUM_SLOTS]));
// 
// 		slotValue=call InputSlotter.getSlotValue(slot)/KIMBALL(lastCloudcover);
// 		if(firstCycle) {
// 			meanSlotValue[slot]=slotValue;
// 		} else {
// 			meanSlotValue[slot]=FP_FLOAT(movingAVG(FP_UNFLOAT(meanSlotValue[slot]),FP_UNFLOAT(slotValue), FORECAST_FILTER));
// 		}
// 		//save the Forecast of next Slot for next time this event happens
// 		nowInSeconds = call Clock.get()/1024;
// 		lastCloudcover = call ProvideForecast.getCloudcoverForecast(nowInSeconds,SLOT_LENGTH_SECS);
// 
// 		//Signal the EnergyPredictor.
// 		signal OutputSlotter.slotEnded(slot);
// 	}
// 		
//   event void InputSlotter.cycleEnded(){
// 		signal OutputSlotter.cycleEnded();
// 		firstCycle=0;
// 	}
// 
// }