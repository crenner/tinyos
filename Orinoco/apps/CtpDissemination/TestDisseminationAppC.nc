
#include "TestDissemination.h"

configuration TestDisseminationAppC {}
implementation {
  components TestDisseminationC;
  components PrintfC, SerialStartC;

  components MainC;
  TestDisseminationC.Boot -> MainC;

  components ActiveMessageC;
  TestDisseminationC.RadioControl -> ActiveMessageC;
  TestDisseminationC.LowPowerListening -> ActiveMessageC;
  
  components CollectionC as Collector;
  components new CollectionSenderC(AM_PERIODIC_PACKET) as DataSender;
  components new CollectionSenderC(AM_CMD_CONF) as ConfSender;
  TestDisseminationC.CollControl -> Collector;
  TestDisseminationC.SendData -> DataSender;
  TestDisseminationC.SendConf -> ConfSender;
  TestDisseminationC.RootControl -> Collector;
  TestDisseminationC.ReceiveData -> Collector.Receive[AM_PERIODIC_PACKET];
  TestDisseminationC.ReceiveConf -> Collector.Receive[AM_CMD_CONF];
  TestDisseminationC.CtpPacket -> Collector;

  components DisseminationC;
  TestDisseminationC.DissControl -> DisseminationC;

  components new DisseminatorC(orinoco_routing_t, 0x1234) as ObjectC;
  TestDisseminationC.DissValue  -> ObjectC;
  TestDisseminationC.DissUpdate -> ObjectC;

  components new TimerMilliC();
  TestDisseminationC.Timer -> TimerMilliC;
  
  components new TimerMilliC() as BootTimer;
  TestDisseminationC.BootTimer -> BootTimer;
  
  components LocalTimeMilliC;
  TestDisseminationC.LocalTime -> LocalTimeMilliC;
  
  components RandomC;
  TestDisseminationC.Random -> RandomC;
}

