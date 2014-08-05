/* FIXME
 * this is not used at the moment
 */

module CapCalibrationJobP {
  uses {
    interface EAJob;
//    interface SensorValueUpdate<fp_t> as SensorValueUpdate;
    interface Leds;
//    interface Read<fp_t> as SolarCurrentSensor;
//    interface SplitControl as AMControl;
    interface CapControl;
//    interface SolarControl;
  }
}
implementation {
  uint8_t  preState_;        // hardware state upon 
  fp_t     capVoltageRef_;
  uint32_t refTime_;

  /* ... *****************************************************************/
  void check() {
    // retrieving the voltage could either be periodical (with same period as before)
    // or triggered by an adapted check interval (needed)
    // however, we still need to figure out when it would be best to perform
    // a recalibration
    // and how large the influence of other tasks would be!

    // expected knowns
    // - capVoltage_
    
    if (capVoltageRef_ - capVoltage_ >= conf_.capVoltageDrop) {
      fp_t  temp;
      /**
       * i = -C*dV ,  V = R * i
       * => dt = -RC * dV/V  =>   int_0^T dt = -RC int_V0^V dV/V
       * => T = RC ln(V0 / V)
       * => V = T / R / ln (V0 / V)
       */
      temp = fpDiv(capVoltageRef_, capVoltage);
      temp = fpLog(temp);
      temp = fpMlt(temp, fpConv((dect_t) call CapControl.getResistance(), 0));
      temp = fpDiv(FP_ONE, temp);
      capacity_ = fpDect((time_ / 1024) * logPart);

      // signal newly estimated value
      
      // restore old system state
      // radio, sensors, solar charging

      // we're done, thanks folks
    }
  }

  /* EAJob ***************************************************************/
  event void EAJob.run() {
// hier muesste wohl doch ein Timer verwendet werden, um periodisch zu pruefen,
// wann die Spannung ausreichend klein ist: ODER
// AUSSERDEM:
// Duerfen Jobs unterbrochen werden? Im aktuellen Konzept ist das moeglich!

    // constraints
    // - solar charging must be off!
    // - radio must be off
    // - mcu must be sleeping (standby)
    // - enable discharging
    capVoltageRef_ = FP_NaN;
    refTime_       = 0;

    call Leds.led2On();
    call EAJob.done();
  }
}

