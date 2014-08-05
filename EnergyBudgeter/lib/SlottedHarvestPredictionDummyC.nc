module SlottedHarvestPredictionDummyC {
  provides {
    interface Slotter as SlottedHarvestPrediction;
  }
  uses {
    interface Slotter as SlottedHarvestModel;
    interface HarvestFactorForecast;
  }
}
implementation {

  uint8_t   latestSlot_      = 0;  // marker for the
  uint16_t  latestSlotBegin_ = 0;  // 

  
  /*** SlottedHarvestPrediction ****************************************/

  command uint8_t SlottedHarvestPrediction.getCurSlot() {
    return call SlottedHarvestModel.getCurSlot();
  }

  
  command uint8_t SlottedHarvestPrediction.getNumSlots() {
    return call SlottedHarvestModel.getNumSlots();
  }

  
  command uint8_t SlottedHarvestPrediction.getSlotLength(uint8_t slot) {
    return call SlottedHarvestModel.getSlotLength(slot);
  }

  
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
  
    // next, convert slot length base units / intervals into ms-time
    from = (uint32_t)latestSlotBegin_                             * call SlottedHarvestModel.getBaseIntvl();
    dt   = (uint32_t)call SlottedHarvestModel.getSlotLength(slot) * call SlottedHarvestModel.getBaseIntvl();
    
    // and finally obtain the forecast by multiplying the slot value with the harvest factor
    return fpMlt(call SlottedHarvestModel.getSlotValue(slot), call HarvestFactorForecast.getHarvestFactor(from, dt));
  }


  command uint16_t SlottedHarvestPrediction.getBaseIntvl() {
    return call SlottedHarvestModel.getBaseIntvl();
  }


  /*** SlottedHarvestModel *********************************************/
  
  event void SlottedHarvestModel.slotEnded(uint8_t slot) {
    signal SlottedHarvestPrediction.slotEnded(slot);
  }

  
  event void SlottedHarvestModel.cycleEnded() {
    signal SlottedHarvestPrediction.cycleEnded();
  }
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