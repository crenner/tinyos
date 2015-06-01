#include "EnergyBudgetizer.h"

configuration EnergyBudgetizerP {
  provides {
    interface EnergyBudget;
    interface Slotter;
    interface SlotValue<fp_t> as HarvestModelValue;
    //interface SlotValue<fp_t> as HarvestForecastValue;
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
  components new HARVEST_MODEL(HARVESTMODEL_NUM_SLOTS, HARVESTMODEL_BASE_INTVL, HARVESTMODEL_CYCLE_LEN, HARVESTMODEL_FILTER) as HarvestModelC;
  #else
  #  warning "Using *default* harvest model SlottedHarvestModelStaticC"
  components new SlottedHarvestModelStaticC(HARVESTMODEL_NUM_SLOTS, HARVESTMODEL_BASE_INTVL, HARVESTMODEL_CYCLE_LEN, HARVESTMODEL_FILTER) as HarvestModelC;
  #endif
  Slotter           = HarvestModelC;
  HarvestModelValue = HarvestModelC;
  HarvestModelC.AveragingSensor -> AveragingSensorC;
  
  // set up harvest prediction
  #ifdef HARVEST_PREDICTION
  #  warning "Using *custom* harvest predictor"
  components new HARVEST_PREDICTION(FORECAST_NUM_SLOTS) as HarvestPredictionC;
  #else
  #  warning "Using *default* harvest predictor"
  components new SlottedHarvestPredictionDummyC(FORECAST_NUM_SLOTS) as HarvestPredictionC;
  #endif
  
  HarvestPredictionC.SlottedHarvestModel       -> HarvestModelC;
  HarvestPredictionC.SlottedHarvestModelValue  -> HarvestModelC;
  
  // set up harvest factor forecast
  components new HarvestFactorForecastC(HARVESTMODEL_NUM_SLOTS, HARVESTMODEL_FILTER); // FIXME unclever implementation ?
  HarvestPredictionC.HarvestFactorForecast     -> HarvestFactorForecastC;
  HarvestPredictionC.SlottedHarvestFactorValue -> HarvestFactorForecastC;
  HarvestFactorForecastC.Slotter -> HarvestModelC;
//  HarvestForecastValue
  
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
