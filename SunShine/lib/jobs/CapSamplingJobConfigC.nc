#include "SunshineJobConfig.h"

module CapSamplingJobConfigC {
	provides {
		interface EAPeriodicJobConfig as JobConfig;
	}
}
implementation {
	async command uint32_t JobConfig.getPeriod() {
		return JC_CAP_SAMPLING_PERIOD;
	}
}
