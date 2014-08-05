#include "SunshineJobConfig.h"

module AmbientSamplingJobConfigC {
	provides {
		interface EAPeriodicJobConfig as JobConfig;
	}
}
implementation {
	async command uint32_t JobConfig.getPeriod() {
		return JC_AMBIENT_SAMPLING_PERIOD;
	}
}
