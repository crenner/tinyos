#include "FixPointMath.h"

interface SlottedForecast {
  /**
   * get the number of slots (i.e., forecast horizon)
   * @return number of slots
   */
  command uint8_t getNumSlots();

  /**
   * get the length of slot
   * @param slot slot index (0 <= slot < getNumSlots())
   * @return length of slot as multiple of base interval (@see getBaseIntvl())
   */
  command uint32_t getSlotDuration(uint8_t slot);

  /**
   * obtain representative value of slot
   * @param slot slot index (0 <= slot < getNumSlots())
   * @return representativ slot value
   */
  command fp_t getSlotValue(uint8_t slot);

  /**
   * called when a slot is elapsed
   */
  event void slotEnded();

  /**
   * call upon end of a complete cycle (i.e., last slot has elapsed)
   */
  event void cycleEnded();
}
