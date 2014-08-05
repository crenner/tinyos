#ifndef SUNSHINE_JOBCONFIG_H
#define SUNSHINE_JOBCONFIG_H

/* sampling period (ms) for ambient sensors (light, temperature) */
#ifndef JC_AMBIENT_SAMPLING_PERIOD
#define JC_AMBIENT_SAMPLING_PERIOD  30720UL
#endif

/* sampling period (ms) for cap voltage */
/* should be small enough (<1min) to keep voltage drop for CapLibrate low */
#ifndef JC_CAP_SAMPLING_PERIOD 
#define JC_CAP_SAMPLING_PERIOD  15360UL
#endif

/* sampling period (ms) for solar current */
/* allow for fine-grained values to obtain a valid and expressive mean over 30s */
#ifndef JC_SOLAR_SAMPLING_PERIOD 
#define JC_SOLAR_SAMPLING_PERIOD 3072UL
#endif


#endif
