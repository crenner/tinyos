COMPONENT=SinkC

CC2420POWER=31
#CC2420POWER=15
#CC2420POWER=7

BUILD_EXTRA_DEPS = SinkAck.class
CLEAN_EXTRA = SinkAck.class SinkAck.java

SinkAck.class: SinkAck.java
	javac SinkAck.java

SinkAck.java: SinkAck.h
	mig java -target=$(PLATFORM) $(CFLAGS) -java-classname=SinkAck SinkAck.h SinkAck -o $@


include $(MAKERULES)
include ../Makefile.radioconfig

CFLAGS += -DORINOCO_DEBUG_STATISTICS
#CFLAGS += -DORINOCO_DEBUG_PRINTF
CFLAGS += -DDISABLE_SYNCED_MICRO
CFLAGS += -DORINOCO_QUEUE_SIZE=1

#CFLAGS += -DUSE_PRINTF
#CFLAGS += -DWISEBED

CFLAGS += \
	-I . \
	-I ../../../Orinoco/interfaces \
	-I ../../../Orinoco/lib/net/orinoco \
	-I ../../../Orinoco/lib/rfxlink/layers \
	-I ../../../Orinoco/LocalTimeSyncedMicro/lib \
	-I ../../../EAJobs/interfaces \
	-I ../../../EAJobs/lib \
	-I ../../../Tools \
	-I ../../../Reporting \
	-I ../../lib \
	-I $(TOSDIR)/lib/net \
	-I $(TOSDIR)/lib/printf \

ifeq ($(findstring $(PLATFORM),iris), iris)
CFLAGS += \
	-I ../../../Orinoco/chips/rf230  \
	-I ../../../Orinoco/platforms/iris \
	-I ../../../LocalTimeSyncedMicro/chips/atm1281 \
	-I ../../../LocalTimeSyncedMicro/chips/atm1281/timer
else ifeq ($(findstring $(PLATFORM),telosb), telosb)
CFLAGS += \
	-I ../../../Orinoco/chips/cc2420  \
	-I ../../../Orinoco/platforms/telosb \
	-I ../../../LocalTimeSyncedMicro/chips/msp430 \
	-I ../../../LocalTimeSyncedMicro/chips/msp430/timer
else ifeq ($(PLATFORM),)
	# No target, no worries.
else
$(error Platform "$(PLATFORM)" is not supported)
endif

LDFLAGS += ../../../Tools/Statistics.c
