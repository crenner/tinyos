COMPONENT=TestDisseminationAppC



#CC2420POWER=31
CC2420POWER=15
#CC2420POWER=7

include $(MAKERULES)
include ../Makefile.radioconfig

#CFLAGS += -DDISABLE_SYNCED_MICRO
#CFLAGS += -DORINOCO_DEBUG_STATISTICS
#CFLAGS += -DORINOCO_DEBUG_PRINTF

# use lpl
CFLAGS += -DLOW_POWER_LISTENING
CFLAGS += -DLPL_DEF_LOCAL_WAKEUP=768
CFLAGS += -DLPL_DEF_REMOTE_WAKEUP=768
CFLAGS += -DDELAY_AFTER_RECEIVE=20

# use this flag (constant) to disable dissemination
#CFLAGS += -DNO_DISSEMINATION

# enable printf
#CFLAGS += -DUSE_PRINTF -I $(TOSDIR)/lib/printf

### For CTP:
CFLAGS += -I$(TOSDIR)/lib/net -I%T/lib/net/ctp -I%T/lib/net/le

### For Drip:
CFLAGS += -I$(TOSDIR)/lib/net -I%T/lib/net/drip

### For DIP:
#CFLAGS += -I$(TOSDIR)/lib/net -I%T/lib/net/dip -I%T/lib/net/dip/interfaces

### For Dhv
#CFLAGS += -I$(TOSDIR)/lib/net -I%T/lib/net/dhv -I%T/lib/net/dhv/interfaces
