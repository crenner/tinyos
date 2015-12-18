COMPONENT=TestAppC

CFLAGS += -DRF230_DEF_CHANNEL=19
//CFLAGS += -DUSE_REFCAP
CFLAGS += -DTOSH_DATA_LENGTH=40
CFLAGS += -DDISABLE_SYNCED_MICRO

CFLAGS += \
	-I . \
	-I ../../../EnergyProfiler/lib \
	-I ../../../EnergyProfiler/interfaces \
	-I ../../../EAJobs/interfaces \
	-I ../../interfaces \
	-I ../../../EAJobs/lib \
	-I ../../../LocalTimeSyncedMicro/lib \
	-I ../../../LocalTimeSyncedMicro/chips/atm1281/timer \
	-I ../../lib \
	-I ../../lib/jobs \
	-I ../../lib/sensors \
	-I ../../lib/configurator \
	-I ../../lib/generic_crc \
	-I ../../chips/atm128/flash \
	-I ../../../Tools/
#        -I$(TOSDIR)/lib/printf
	
#LDFLAGS += ../../../Tools/FixPointMath.c

include $(MAKERULES)
