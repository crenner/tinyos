module EnergyPredictorC {
  provides {
    interface EnergyBudget;
  }
  uses {
    interface EnergyModel;
    interface SlottedForecast as SlottedHarvestForecast;
    interface EnergyPolicy<fp_t>;
    interface Get<fp_t> as CapVoltage;
  }
}
implementation {
#define ABS(x) ((x)>0?(x):-(x))

  double    maxIn;   // upper bound on consumption
  double    minIn;   // lower bound

  uint8_t   curSlot;
  double    startVc;

  double    In;

  double    Vc;

  bool calculationRunning = FALSE;

  void initBinaryStep() {
    In      = (maxIn + minIn) / 2.0;
    Vc      = startVc;
    curSlot = 0;
  }

  task void nextSlot() {
    //double   Ih   = (FP_FLOAT(call SlottedHarvestForecast.getSlotValue(curSlot))/1000.0);
    double  Ih = (FP_FLOAT(call SlottedHarvestForecast.getSlotValue(curSlot))/1000.0);
    calculationRunning = TRUE;
    call EnergyModel.calculate(call SlottedHarvestForecast.getSlotDuration(curSlot), Vc, Ih, In);
  }

  event void EnergyModel.calculationDone(double voltage) {
    policy_verdict_t  verdict;

    if (! calculationRunning) {
      return;
    }

    calculationRunning = FALSE;
    Vc = voltage;

    // feed intermediate result to policy
    verdict = call EnergyPolicy.feed(FP_UNFLOAT(voltage));

    curSlot++;
    if (curSlot < call SlottedHarvestForecast.getNumSlots() && verdict == POLICY_VERDICT_UNDECIDED) {
      post nextSlot();
    } else {
      // update search boundaries
      if (call EnergyPolicy.verdict() == POLICY_VERDICT_ACCEPT) {
        minIn = In;
      } else {
        maxIn = In;
      }

      dbg("Energy", "------------------------------\n");
      if (ABS(maxIn-minIn) > 10/(1000.0*1000.0)) {  // TODO config
        initBinaryStep();
        post nextSlot();
      }
      else {
        fp_t result = FP_UNFLOAT(minIn*1000);  // make mA from Ampere
        signal EnergyBudget.budgetUpdated(result);
      }
    }
  }

  event void SlottedHarvestForecast.slotEnded() {
    fp_t  capVolt = call CapVoltage.get();
    if (call EnergyPolicy.checkInitialState(capVolt) == POLICY_VERDICT_REJECT) {
      signal EnergyBudget.budgetUpdated(0);  // TODO config
      return;
    }

    startVc = FP_FLOAT(capVolt);

    maxIn = 20/1000.0;  // upper bound on consumption  // TODO config
    minIn = 0;          // lower bound                 // TODO config

    initBinaryStep();
    post nextSlot();
  }

  event void SlottedHarvestForecast.cycleEnded() {
  }
}
