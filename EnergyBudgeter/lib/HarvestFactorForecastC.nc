module HarvestFactorForecastC {
  provides {
    interface HarvestFactorForecast;
  }
  
  // TODO receive forecast message from somewhere
}
implementation {

  command fp_t HarvestFactorForecast.getHarvestFactor(uint32_t from, uint32_t dt) {
    return FP_ONE;
  }
}


// TODO TODO TODO
// SCHACHT
//
//
// uint8_t cloudcover[NUM_FC_VAL], sunshine[NUM_FC_VAL];
// 	uint32_t cc_creation, ss_creation;
// 
// 	//Worst Case initialization for both cloudcover- and sunshine-duration- forecasts
// 	command error_t Init.init() {
// 		int i;
// 		for(i=0;i<NUM_FC_VAL;i++){
// 			cloudcover[i]=8;
// 			sunshine[i]=0;
// 		}
// 		dbg("Forecast","Forecast: Initialisiert.\n");
// 		return SUCCESS;
// 	}
// 
// 	//Receives forecast updates over the motes radio.
// 	event message_t* ReceivesForecast.receive(message_t* bufPtr, void* payload, uint8_t len) {
// 		//Is it a message we are waiting for?
// 		if(len==sizeof(ForecastMessage)){
// 			int i;
// 			bool legit=TRUE;
// 			//Create a pointer to the data of the message.
// 			ForecastMessage* data=(ForecastMessage*)payload;
// 
// 			//Cloudcover- or Sunshine-Update?
// 			if(data->fc_type==0){
// 				//Are the values legit?
// 				for (i=0;i<NUM_FC_VAL;i++)
// 					if(legit)
// 						legit=(data->values[i]>=0&&data->values[i]<=8);
// 
// 				//Do a Cloudcoverupdate if they are.
// 				if(legit) {
// 					dbg("Forecast","Forecast:Legitimes Cloudcoverupdate.\n");
// 					cc_creation=data->fc_creation;
// 					for(i=0;i<NUM_FC_VAL;i++)
// 						cloudcover[i]=data->values[i];
// 				}
// 			} else if(data->fc_type==1){
// 				//Are the values legit?
// 				for (i=0;i<NUM_FC_VAL;i++)
// 					if(legit)
// 						legit=(data->values[i]>=0&&data->values[i]<=60);
// 
// 				//Do a Sunshineupdate if they are.
// 				if(legit) {
// 					dbg("Forecast","Forecast:Legitimes Sunshineupdate.\n");
// 					ss_creation=data->fc_creation;
// 					for(i=0;i<NUM_FC_VAL;i++)
// 						sunshine[i]=data->values[i];
// 				}
// 			} else {
// 				//Ignore message. (Contains unknown type of update.)
// 			}
// 		}
// 		return bufPtr;
// 	}
// 
// 
// 	//Returns the Cloudcover-Forecast for the designated timeperiod.
// 	command fp_t ForecastSink.getCloudcoverForecast(uint32_t period_begins, uint32_t period_length) {
// 		int i;
// 		fp_t cloudcover_forecast;
// 		uint32_t i_period_begins, i_period_ends, cloudtime;
// 
// 		//Beginning of calculation period
// 		i_period_begins=(period_begins<cc_creation)?cc_creation:period_begins;
// 		//Ending of calculation period
// 		i_period_ends=(cc_creation+(NUM_FC_VAL*DUR_FC_VAL)<period_begins+period_length)?cc_creation+(NUM_FC_VAL*DUR_FC_VAL):period_begins+period_length;
// 
// 		//Whole timeperiod in one slot?
// 		if((i_period_begins-cc_creation)/DUR_FC_VAL==(i_period_ends-cc_creation)/DUR_FC_VAL) {
// 			//duration*active slot
// 			cloudtime=(i_period_ends-i_period_begins)*cloudcover[(i_period_begins-cc_creation)/DUR_FC_VAL];
// 		} else {
// 			//First forecastslot (may be only parts of it)
// 			cloudtime=DUR_FC_VAL-((i_period_begins-cc_creation)%DUR_FC_VAL)*cloudcover[(i_period_begins-cc_creation)/DUR_FC_VAL];
// 			//Whole slots in between (may be none)
// 			for(i=(i_period_begins-cc_creation)/DUR_FC_VAL+1;i<(i_period_ends-cc_creation)/DUR_FC_VAL;i++){
// 				cloudtime+=DUR_FC_VAL*cloudcover[i];
// 			}
// 			//Last forecastslot (may be only parts of it)
// 			cloudtime+=((i_period_ends-cc_creation)%DUR_FC_VAL)*cloudcover[(i_period_ends-cc_creation)/DUR_FC_VAL];
// 		}
// 		//The mean cloudcover for the given period gets calculated and returned as a fp_t
// 		cloudcover_forecast=(fp_t)round((((float)cloudtime/((float)i_period_ends - (float) i_period_begins)) / 8.0 )*256.0);
// 		return cloudcover_forecast;
// 	}
// 
// 	//Returns the Sunshine-Forecast for the designated timeperiod.
// 	command fp_t ForecastSink.getSunShineForecast(uint32_t period_begins, uint32_t period_length) {
// 		fp_t sunshine_forecast;
// 		uint32_t i_period_begins, i_period_ends, suntime;
// 		int i;
// 		//Beginning of calculation period
// 		i_period_begins=(period_begins<ss_creation)?ss_creation:period_begins;
// 		//Ending of calculation period
// 		i_period_ends=(ss_creation+(NUM_FC_VAL*DUR_FC_VAL)<period_begins+period_length)?ss_creation+(NUM_FC_VAL*DUR_FC_VAL):period_begins+period_length;
// 
// 		//Whole timeperiod in one slot?
// 		if((i_period_begins-ss_creation)/DUR_FC_VAL==(i_period_ends-ss_creation)/DUR_FC_VAL) {
// 			//duration*active slot
// 			suntime=(i_period_ends-i_period_begins)*cloudcover[(i_period_begins-ss_creation)/DUR_FC_VAL];
// 		} else {
// 			//First forecastslot (may be only parts of it)
// 			suntime=DUR_FC_VAL-((i_period_begins-ss_creation)%DUR_FC_VAL)*cloudcover[(i_period_begins-ss_creation)/DUR_FC_VAL];
// 			//Whole slots in between (may be none)
// 			for(i=(i_period_begins-ss_creation)/DUR_FC_VAL+1;i<(i_period_ends-ss_creation)/DUR_FC_VAL;i++){
// 				suntime+=DUR_FC_VAL*cloudcover[i];
// 			}
// 			//Last forecastslot (may be only parts of it)
// 			suntime+=((i_period_ends-ss_creation)%DUR_FC_VAL)*cloudcover[(i_period_ends-ss_creation)/DUR_FC_VAL];
// 		}
// 		//The mean sunshine for the given period gets calculated and returned as a fp_t
// 		sunshine_forecast=(fp_t)round(((float)suntime/((float)i_period_ends - (float) i_period_begins))*256.0);
// 
// 		return sunshine_forecast;
// 	}