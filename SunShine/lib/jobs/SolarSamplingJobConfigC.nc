#include "SunshineJobConfig.h"

module SolarSamplingJobConfigC {
	provides {
		interface EAPeriodicJobConfig as JobConfig;
	}
}
implementation {
	async command uint32_t JobConfig.getPeriod() {
		return JC_SOLAR_SAMPLING_PERIOD;
	}
}
