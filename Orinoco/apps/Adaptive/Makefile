COMPONENT=TestAppC

ifneq ($(findstring sim,$(MAKECMDGOALS)),sim)
	LDFLAGS += ../../../Tools/FixPointMath.c
	LDFLAGS += ../../../Tools/Statistics.c
endif

ifeq ($(findstring iris,$(MAKECMDGOALS)),iris)
	include $(MAKERULES)
	include ../Makefile.radioconfig
endif


#CFLAGS += -DENERGY_POLICY=EnergyPolicyMaxPowerC
CFLAGS += -DENERGY_POLICY=EnergyPolicyDepletionSafeC

CFLAGS += -DORINOCO_DEBUG_STATISTICS
#CFLAGS += -DUSE_REFCAP


CFLAGS += \
        -I . \
        -I $(TOSDIR)/lib/net \
        -I ../../interfaces \
        -I ../../lib/net/orinoco \
        -I ../../../EAJobs/interfaces \
        -I ../../../EAJobs/lib \
        -I ../../../EnergyBudgeter/interfaces \
	-I ../../../EnergyBudgeter/lib \
	-I ../../../EnergyBudgeter/sunshine \
	-I ../../../EnergyProfiler/interfaces \
	-I ../../../EnergyProfiler/lib \
	-I ../../../LocalTimeSyncedMicro/lib \
	-I ../../../SunShine/interfaces \
	-I ../../../SunShine/lib \
	-I ../../../SunShine/lib/jobs \
	-I ../../../SunShine/lib/sensors \
	-I ../../../SunShine/lib/configurator \
	-I ../../../SunShine/lib/generic_crc \
	-I ../../../SunShine/chips/atm128/flash \
	-I ../../../SunShine/platforms/mica \
	-I ../../../Reporting \
	-I ../../../Tools \
	-I ../../../WeatherForecasts/interfaces \
	-I ../../../WeatherForecasts/lib

ifeq ($(findstring $(PLATFORM),iris), iris)
CFLAGS += \
	-I ../../chips/rf230  \
	-I ../../platforms/iris \
	-I ../../lib/rfxlink/layers \
	-I ../../../LocalTimeSyncedMicro/chips/atm1281 \
	-I ../../../LocalTimeSyncedMicro/chips/atm1281/timer
else ifeq ($(findstring $(PLATFORM),telosb), telosb)
CFLAGS += \
	-I ../../chips/cc2420  \
	-I ../../platforms/telosb \
	-I ../../../LocalTimeSyncedMicro/chips/msp430 \
	-I ../../../LocalTimeSyncedMicro/chips/msp430/timer
else ifeq ($(PLATFORM),)
	# No target, no worries.
else
$(error Platform "$(PLATFORM)" is not supported)
endif


CXXFLAGS+=-O2 -I/usr/include/python2.7/ -I$(TOSDIR)/lib/tossim/

.PHONY: simulation
simulation: ../../../Tools/FixPointMath.o ../../../Tools/Statistics.o
	make -e iris sim-etrack
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) simbuild/iris/tossim.o simbuild/iris/sim.o simbuild/iris/c-support.o ../../../Tools/FixPointMath.o ../../../Tools/Statistics.o TossimDriver.cpp -o simulate
