COMPONENT=DecoderTestC
BUILD_EXTRA_DEPS = DdcForecastMsg.class DdcTestMsg.class
CLEAN_EXTRA = DdcForecastMsg.class DdcForecastMsg.java DdcTestMsg.class DdcTestMsg.java

DdcForecastMsg.class: DdcForecastMsg.java
	javac DdcForecastMsg.java

DdcTestMsg.class: DdcTestMsg.java
	javac DdcTestMsg.java


DdcForecastMsg.java: ../../lib/DdcForecastMsg.h
	mig java -target=$(PLATFORM) $(CFLAGS) -java-classname=DdcForecastMsg ../../lib/DdcForecastMsg.h DdcForecastMsg -o $@

DdcTestMsg.java: ../../lib/DdcTestMsg.h
	mig java -target=$(PLATFORM) $(CFLAGS) -java-classname=DdcTestMsg ../../lib/DdcTestMsg.h DdcTestMsg -o $@

include $(MAKERULES)
include ../Makefile.radioconfig

########## Maximum data length (for buffer allocation)
##PACKETLENGTH=80


<<<<<<< HEAD
########## Maximum data length (for buffer allocation)
PACKETLENGTH=80

########## Maximum printf length (for buffer allocation)
PRINTF_MSG_LENGTH=80
PRINTF_BUFFER_SIZE=400

# enable printf
CFLAGS += -DUSE_PRINTF -I $(TOSDIR)/lib/printf
=======
########## Maximum printf length (for buffer allocation)
##PRINTF_MSG_LENGTH=80
##PRINTF_BUFFER_SIZE=400
>>>>>>> 231a6d65ab2788e7643eeffc10f31de565a93c42

##CFLAGS += -DUSE_PRINTF -I $(TOSDIR)/lib/printf
CFLAGS += -I$(TOSDIR)/lib/T2Hack
CFLAGS += \
	-I . \
	-I ../../interfaces \
	-I ../../lib/ \

