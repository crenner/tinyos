#include "Timer.h"
#include "Statistics.h"


/**
 * static slotting for energy-harvest prediction
 * @param NUM_SLOTS   number of slots per cycle
 * @param BASE_INTVL  base interval
 * @param CYCLE_LEN   length of a cycle as multiple of BASE_INTVL
 * @param ALPHA       smoothing factor for slot value
 *
 * NOTE CYCLE_LEN must be a multiple of NUM_SLOTS!
 */
generic module SlottedHarvestModelStaticP(uint8_t NUM_SLOTS, uint16_t BASE_INTVL, uint16_t CYCLE_LEN, uint8_t ALPHA) {
  provides {
    interface Init @exactlyonce();
    interface Slotter;
    interface SlotValue<fp_t>;
    interface EAPeriodicJobConfig as JobConfig;
  }
  uses {
    interface AveragingSensor<fp_t> @exactlyonce();
    interface EAJob;
  }
}
implementation {
  uint8_t   curSlot_;          // current slot (0 <= curSlot_ < NUM_SLOTS)
  bool      firstCycle_;       // marker whether this is the first cycle
  uint16_t  mean_[NUM_SLOTS];  // mean slot values

  enum {
    SLOT_LENGTH = CYCLE_LEN / NUM_SLOTS  // fixed slot length
  };

  /**
   * Calculate moving average.
   *
   * @param oldVal Old average
   * @param newVal New value
   * @param ratio Averaging ratio * 128. 128 = 1.0.
   *
   * @return oldVal*ratio+newVal*(1-ratio)
   */
  // TODO use ewma filter from Statistics
//   static fp_t movingAVG(fp_t oldVal, fp_t newVal, uint8_t ratio) {
//     return (((uint32_t)oldVal) * ratio + ((uint32_t)newVal) * (128-ratio) + 64) >> 7;
//   }


  /*** Init **************************************************************/
  command error_t
  Init.init() {
    uint8_t i;
    for (i = 0; i < NUM_SLOTS; i++)  {
      mean_[i] = 0;
    }
    curSlot_    = 0;
    firstCycle_ = TRUE;

    return SUCCESS;
  }
  
  
  
  /*** SlotValue *********************************************************/
  command fp_t SlotValue.get(uint8_t slot) {
    if (slot < NUM_SLOTS) {
      return mean_[slot];
    } else {
      return 0;//FP_NaN;
    }
  }

    
  
  /*** Slotter ***********************************************************/
  command uint32_t
  Slotter.getSlotDuration(uint8_t slot) {
    return call Slotter.getSlotLength(slot) * (uint32_t)BASE_INTVL;
  }
  
  
  command uint8_t
  Slotter.getSlotLength(uint8_t slot) {
    if (slot < NUM_SLOTS) {
      return SLOT_LENGTH;
    } else {
      return 0;
    }
  }

  command uint8_t
  Slotter.getCurSlot() {
    return curSlot_;
  }

//   command uint16_t Slotter.getBaseIntvl() {
//     return BASE_INTVL;
//   }

  command uint8_t
  Slotter.getNumSlots() {
    return NUM_SLOTS;
  }

  /*** EAJob *************************************************************/
  event void
  EAJob.run() {
    uint8_t lastSlot = curSlot_;
    fp_t    slotVal  = call AveragingSensor.get(TRUE);  // get average sensor value and clear it
      
      
    // TODO make this an extra component
      
    // get smoothing or use current value (if first cycle)
    if (firstCycle_) {
      mean_[curSlot_] = slotVal;
    } else {
      //mean_[curSlot_] = movingAVG(mean_[curSlot_], slotVal, ALPHA);
      mean_[curSlot_] = ewmaFilter16(mean_[curSlot_], slotVal, ALPHA);
    }

    // advance slot
    if (++curSlot_ == NUM_SLOTS) {
      curSlot_ = 0;
      firstCycle_ = FALSE;
    }

    signal Slotter.slotEnded(lastSlot);
    if (curSlot_ == 0) {
      signal Slotter.cycleEnded();
    }

    // and we're done
    call EAJob.done();
  }


  /*** JobConfig *********************************************************/
  async command uint32_t
  JobConfig.getPeriod() {
    return (1024UL * BASE_INTVL) * SLOT_LENGTH;
  }
}
