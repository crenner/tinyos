#include "scale.h"

/**
 * Simulation version of MeasureClockC for the mica platform. See 
 * tos/platforms/mica/MeasureClockC.nc for more details.
 *
 * @author Phil Levis
 */

module MeasureClockC {
  /* This code MUST be called from PlatformP only, hence the exactlyonce */
  provides interface Init @exactlyonce();

  provides {
interface Atm128Calibrate;
/*
    async command uint16_t cyclesPerJiffy();
    async command uint32_t calibrateMicro(uint32_t n);
    async command uint8_t adcPrescaler();
    async command uint16_t baudrateRegister(uint32_t baudrate);
    async command uint32_t actualMicro(uint32_t n);
*/
  }
}
implementation 
{
  command error_t Init.init() {
    return SUCCESS;
  }

  async command uint16_t Atm128Calibrate.cyclesPerJiffy() {
    return (1 << 8);
  }

  async command uint32_t Atm128Calibrate.calibrateMicro(uint32_t n) {
    return scale32(n + 122, 244, (1 << 32));
  }

  async command uint8_t Atm128Calibrate.adcPrescaler() {
    return ATM128_ADC_PRESCALE_64;  // assuming cycles = 1<<8 as in cyclesPerJiffy
  }

//
  async command uint16_t Atm128Calibrate.baudrateRegister(uint32_t baudrate) {
    // value is (cycles*32768) / (8*baudrate) - 1
    return ((uint32_t)(1 << 8) << 12) / baudrate - 1;
  }

  async command uint32_t Atm128Calibrate.actualMicro(uint32_t n) {
    // TODO verify, assuming 8 Mhz
    return scale32(n, 488 / (16 / 8), 1<<8);
  }
}
