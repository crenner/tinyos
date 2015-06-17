COMPONENT=DecoderTestC
BUILD_EXTRA_DEPS = DdcForecastMsg.class
CLEAN_EXTRA = DdcForecastMsg.class DdcForecastMsg.java

DdcForecastMsg.class: DdcForecastMsg.java
	javac DdcForecastMsg.java

DdcForecastMsg.java: ../../lib/DdcForecastMsg.h
	mig java -target=$(PLATFORM) $(CFLAGS) -java-classname=DdcForecastMsg ../../lib/DdcForecastMsg.h DdcForecastMsg -o $@
include $(MAKERULES)

########## Maximum data length (for buffer allocation)
PACKETLENGTH=80


########## Maximum printf length (for buffer allocation)
PRINTF_MSG_LENGTH=80
PRINTF_BUFFER_SIZE=400

CFLAGS += -DUSE_PRINTF -I $(TOSDIR)/lib/printf

CFLAGS += \
	-I . \
	-I ../../interfaces \
	-I ../../lib/ \

