#include <FixPointMath.h>
#include <Sunshine.h>

extern uint32_t epWasteTime;  // in EnergyProfiler

module TestC {
  uses {
    interface Boot;
//    interface Leds;
    interface Timer<TMilli> as RadioTimer;
    interface Timer<TMilli> as RadioOffTimer;
//    interface Timer<TMilli> as RadioOffTimer;
//    interface Timer<TMilli> as SampleTimer;
    interface Packet;
    interface AMPacket;
    interface AMSend;
    interface SplitControl as AMControl;
    interface PacketAcknowledgements as Ack;
//    interface CapControl;
//    interface SolarControl;
    interface Get<fp_t>    as SolarCurrent;
    interface Get<fp_t>    as CapVoltage;
//     interface Get<fp_t>    as RefCapVoltage;
    interface Get<sfp_t>   as TempSensor;
    interface Get<fp_t>    as LightSensor;

    interface SensorValueUpdate<fp_t>    as SolarCurrentUpdate;
    interface SensorValueUpdate<fp_t>    as CapVoltageUpdate;
//     interface SensorValueUpdate<fp_t>    as RefCapVoltageUpdate;
    interface SensorValueUpdate<sfp_t>   as TempSensorUpdate;
    interface SensorValueUpdate<fp_t>    as LightSensorUpdate;

    interface EnergyConsumption;

    interface GetSet<const solar_converter_config_t *> as GetSetSolarConverterConfig;
  }
}
implementation {

  typedef nx_struct SampleMsg {
    nx_uint16_t  cnt;
    nx_uint16_t  Vc;
    nx_uint16_t  Is;
    nx_uint16_t  light;
    nx_uint16_t  temp;
    nx_uint16_t  refVc;
    nx_uint32_t  conMCU;
    nx_uint32_t  conRadio;
    nx_uint32_t  conLeds;
    nx_uint32_t  epWaste;
    nx_uint8_t   level;
  } SampleMsg;
  message_t msg;
  uint16_t  cnt;
  uint16_t  nVolt, nRefVolt, nCur, nTemp, nLight;
  uint32_t  sVolt, sRefVolt, sCur, sLight;
  int32_t   sTemp;

  //uint32_t RADIO_DC[] = { 256, 512, 1024, 2048, 4096, 6144, 8192, 10240, 15360, 20480, 25600 };
  uint32_t RADIO_DC[] = { 64, 512, 1024, 2048, 4096, 6144, 8192, 10240, 15360, 20480, 25600 }; // FIXME TEST
  #define LEVEL_NUM  (sizeof(RADIO_DC)/sizeof(RADIO_DC[0]))
  #define VOLT_HIGH   fpConv(2,00)
  #define VOLT_LOW    fpConv(1,50)
  uint8_t level = 0;

  task void sendTask() {
    SampleMsg * p = (SampleMsg *)call Packet.getPayload(&msg, sizeof(SampleMsg));

    // init packet
    call Packet.clear(&msg);
    //call Ack.requestAck(&msg);
    p->cnt   = cnt++;
    atomic {
//      p->Vc    = (nVolt  > 0) ? (sVolt  / nVolt)  : call CapVoltage.get();
      p->Vc    = call CapVoltage.get();
      p->refVc = (nRefVolt > 0) ? (sRefVolt  / nRefVolt)  : call RefCapVoltage.get();
      p->Is    = (nCur   > 0) ? (sCur   / nCur)   : call SolarCurrent.get();
      p->light = (nLight > 0) ? (sLight / nLight) : call LightSensor.get();
      p->temp  = (nTemp  > 0) ? (sTemp  / nTemp)  : call TempSensor.get();
      nVolt  = sVolt  = 0;
      nRefVolt  = sRefVolt  = 0;
      nCur   = sCur   = 0;
      nLight = sLight = 0;
      nTemp  = sTemp  = 0;
    }
    p->conMCU   = call EnergyConsumption.getConsumption(EPC_MCU);
    p->conRadio = call EnergyConsumption.getConsumption(EPC_RADIO);
    p->conLeds  = call EnergyConsumption.getConsumption(EPC_LED0) +
                  call EnergyConsumption.getConsumption(EPC_LED1) +
                  call EnergyConsumption.getConsumption(EPC_LED2);
    //p->epWaste  = epWasteTime; /* time "wasted" by energy tracking */
    p->epWaste  = (call GetSetSolarConverterConfig.get())->offset;
    p->level    = level;

    // send data
    call AMSend.send(0, &msg, sizeof(SampleMsg));
  }

  event void Boot.booted() {
    //* (volatile uint8_t *) 39U |= 0xF0;
    cnt = 0;
//    call RadioTimer.startPeriodic(30720);
    call RadioTimer.startPeriodic(15360);
  }

  event void RadioTimer.fired() {
    // adjust radio duty cycle
    if (call CapVoltage.get() > VOLT_HIGH) {
      if (level < LEVEL_NUM - 1) level++;
    } else if (call CapVoltage.get() < VOLT_LOW) {
      if (level > 0) level--;
    }
    // DEBUG
    level = 0;  // FIXME TEST
    call RadioOffTimer.startOneShot(RADIO_DC[level]);

    // start radio
    if (call AMControl.start() == EALREADY) {
      //FIXME post sendTask();
    }
  }

  event void RadioOffTimer.fired() {
    call AMSend.cancel(&msg);
    call AMControl.stop();
  }

  event void AMControl.startDone(error_t res) {
    if (res == SUCCESS) {
      post sendTask();
    } else {
      //FIXME call AMControl.start();
    }
  }

  event void AMControl.stopDone(error_t res) {
    //FIXME if (res != SUCCESS) call AMControl.stop();
  }

  event void AMSend.sendDone(message_t * rmsg, error_t res) {
  }

  event void SolarCurrentUpdate.update(fp_t val) {
    atomic {
      sCur += val;
      nCur++;
    }
  }

  event void CapVoltageUpdate.update(fp_t val) {
    atomic {
      sVolt += val;
      nVolt++;
    }
  }

  event void RefCapVoltageUpdate.update(fp_t val) {
    atomic {
      sRefVolt += val;
      nRefVolt++;
    }
  }


  event void TempSensorUpdate.update(sfp_t val) {
    atomic {
      sTemp += val;
      nTemp++;
    }
  }

  event void LightSensorUpdate.update(fp_t val) {
    atomic {
      sLight += val;
      nLight++;
    }
  }
}
