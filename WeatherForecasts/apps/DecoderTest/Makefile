COMPONENT=DecoderTestC

include $(MAKERULES)

########## Maximum data length (for buffer allocation)
PACKETLENGTH=80

########## Maximum printf length (for buffer allocation)
PRINTF_MSG_LENGTH=80
PRINTF_BUFFER_SIZE=400

# enable printf
CFLAGS += -DUSE_PRINTF -I $(TOSDIR)/lib/printf

CFLAGS += \
	-I . \
	-I ../../interfaces \
	-I ../../lib/ \

