#include "EnergyBudgetizer.h"

configuration EnergyBudgetizerP {
  provides {
    interface EnergyBudget;
    interface Slotter;
  }
  uses {
    interface EnergyModel;
    interface SensorValueUpdate<fp_t> as Harvest;
    interface Get<fp_t> as CapVoltage;
  }
}
implementation {
  components new AveragingSensorC();
  Harvest = AveragingSensorC.SensorValueUpdate;

  // set up slotter
  #ifdef HARVEST_MODEL
  #  warning "Using *custom* harvest model"
  components new HARVEST_MODEL(FORECAST_NUM_SLOTS, FORECAST_BASE_INTVL, FORECAST_CYCLE_LEN, FORECAST_FILTER) as HarvestModelC;
  #else
  #  warning "Using *default* harvest model SlottedHarvestModelStaticC"
  components new SlottedHarvestModelStaticC(FORECAST_NUM_SLOTS, FORECAST_BASE_INTVL, FORECAST_CYCLE_LEN, FORECAST_FILTER) as HarvestModelC;
  #endif
  Slotter = HarvestModelC;
  HarvestModelC.AveragingSensor -> AveragingSensorC;
  
  // set up harvest prediction
  #ifdef HARVEST_PREDICTION
  #  warning "Using *custom* harvest predictor"
  components HARVEST_PREDICTION as HarvestPredictionC;
  #else
  #  warning "Using *default* harvest predictor"
  components SlottedHarvestPredictionDummyC as HarvestPredictionC;
  #endif
  
  HarvestPredictionC.SlottedHarvestModel   -> HarvestModelC;
  HarvestPredictionC.HarvestFactorForecast -> HarvestFactorForecastC;
  
  // set up harvest factor forecast
  // FIXME
  components HarvestFactorForecastDummyC as HarvestFactorForecastC;
  
  // set up energy prediction
  components EnergyPredictorC;
  EnergyPredictorC.SlottedHarvestForecast -> HarvestPredictionC;
  EnergyPredictorC.EnergyBudget     = EnergyBudget;
  EnergyPredictorC.CapVoltage       = CapVoltage;
  EnergyPredictorC.EnergyModel      = EnergyModel;

  // set up policy
  #ifdef ENERGY_POLICY
  #  warning "Using custom energy policy"
  components ENERGY_POLICY as EnergyPolicy;
  #else
  #  warning "Using default energy policy EnergyPolicyDepletionSafeC"
  components EnergyPolicyDepletionSafeC as EnergyPolicy;
  #endif
  EnergyPredictorC.EnergyPolicy -> EnergyPolicy;
}
