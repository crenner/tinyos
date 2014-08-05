#include "FixPointMath.h"
#include "Sunshine.h"

interface Caplibrate {
  /**
   * initiates a cap calibration, which is either started immediately
   * or at any later point in time, when Vcap exceeds the minimum
   * required voltage for calibration
   * @return SUCCESS  the calibration will be started and an event
   *                  calibrateCapDone will be eventually signaled
   *         FAIL     calibration is not possible
   *         EALREADY a calibration is already pending or active
   */
  command error_t calibrateCap();
  
  /**
   * Notification about a completed (or canceled) calibration
   * The parameter capacity is only valid, if res == SUCESS
   */
  event void calibrateCapDone(fp_t capacity, error_t res);

  // command fp_t getMinVoltage();  // should be configured in SunShineConfigC
  // command error_t cancel();

  // command bool capacityMeasured();
  // command uint16_t getCapacity();
}
