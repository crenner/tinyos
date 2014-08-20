#include "printf.h"

#include "TestDissemination.h"

// TODO
// how to integrate CTP? or some other data collection?


module TestDisseminationC {
  uses interface Boot;
  
  uses interface Timer<TMilli> as BootTimer;
  uses interface Timer<TMilli> as Timer;
  
  uses interface SplitControl as RadioControl;

  // collection
  uses interface RootControl;
  uses interface StdControl as CollControl;
  uses interface Send as SendData;
  uses interface Send as SendConf;
  uses interface Receive as ReceiveData;
  uses interface Receive as ReceiveConf;
  uses interface CtpPacket;

  // dissemination
  uses interface StdControl as DissControl;
  uses interface DisseminationValue<orinoco_routing_t>  as DissValue;
  uses interface DisseminationUpdate<orinoco_routing_t> as DissUpdate;
  
  // other stuff
  uses interface LocalTime<TMilli>;
  uses interface Random;
  
  uses interface LowPowerListening;
}
implementation {
  uint32_t   cnt       = 0;
  orinoco_routing_t dissValue;
  message_t  myMsg, myConfMsg;

  
  
  /*** Boot *************************************************************/
  event void Boot.booted() {
    //call DissValue.set( &dissValue );
    
    // setup root 
    if (TOS_NODE_ID == SINK_ID) {
      call RootControl.setRoot();
    } else {
      call RootControl.unsetRoot();
    }
    
    // setup LPL
    if (call RootControl.isRoot()) {
      call LowPowerListening.setLocalWakeupInterval(SINK_WAKEUP_INTVL);
    } /*else {
      call LowPowerListening.setLocalWakeupInterval(SRC_WAKEUP_INTVL);
    }*/
    
    // switch on radio and enable routing
    call RadioControl.start();
    call DissControl.start();
    call CollControl.start();
    
    printf("%lu: %u boot\n", call LocalTime.get(), TOS_NODE_ID);
    printfflush();

    // boot sync
    call BootTimer.startOneShot(1024);

    // start our packet/update timer
    if (call RootControl.isRoot()) {
      dissValue.cmd = 0;
      call Timer.startOneShot(UPDATE_INTVL);      
    } else {
      call Timer.startOneShot(1 + (call Random.rand32() % DATA_PERIOD));
    }
  }
  
  
  
  /*** BootTimer ********************************************************/
  event void BootTimer.fired() {
    // we need to delay this because printf is only set up at Boot.booted() and we cannot influence the order of event signalling
    printf("%lu: %u reset\n", call LocalTime.get(), TOS_NODE_ID);
    printfflush();
  }
  
  
  
  /*** Timer ************************************************************/
  event void Timer.fired() {
    if (call RootControl.isRoot()) {
      dissValue.cmd++;
      call DissUpdate.change( &dissValue );
      
      //dbg("TestDisseminationC", "TestDisseminationC: Timer fired.\n");
      printf("%lu: %u bf-inc %u\n", call LocalTime.get(), TOS_NODE_ID, dissValue);
      printfflush();
    
      call Timer.startOneShot(UPDATE_INTVL);
    } else {
      uint8_t  msgCnt;
      error_t  result;

      for (msgCnt = 0; msgCnt < MSG_BURST_LEN; msgCnt++) {
        nx_uint16_t *d = call SendData.getPayload(&myMsg, sizeof(*d));
        //call Send.clear(&myMsg);
        *d = cnt++;
        //call LowPowerListening.setRemoteWakeupInterval(&myMsg, SRC_WAKEUP_INTVL);
        result = call SendData.send(&myMsg, sizeof(*d));
	if (SUCCESS == result) {
	  printf("%lu: %u data-tx %u\n", call LocalTime.get(), TOS_NODE_ID, *d);
	  printfflush();
	} else {
	  printf("%lu: %u data-fail %u\n", call LocalTime.get(), TOS_NODE_ID, *d);
	  printfflush();
	}
      }

      call Timer.startOneShot(DATA_PERIOD);
    }
  }

  
  /*** RadioControl *****************************************************/
  event void RadioControl.startDone(error_t error) { }

  event void RadioControl.stopDone(error_t error) { }
  

  /*** DissValue ********************************************************/
  void sendConfirmation(uint8_t cmd, uint16_t version, error_t status) {
    OrinocoCommandAckMsg* payload = (OrinocoCommandAckMsg*) call SendConf.getPayload(&myConfMsg, sizeof(OrinocoCommandAckMsg));
    payload->cmd = cmd;
    payload->version = version;
    payload->result = status;

    printf("%lu: %u bf-tx-conf %u %u %u\n", call LocalTime.get(), TOS_NODE_ID, cmd, version, status);
    printfflush();

    //call LowPowerListening.setRemoteWakeupInterval(&myConfMsg, SRC_WAKEUP_INTVL);
    call SendConf.send(&myConfMsg, sizeof(OrinocoCommandAckMsg));
    // TBD: Do we need to care about return status (worst case: cmd is resent in next BF)
  }
  
  event void DissValue.changed() {
    orinoco_routing_t dv = *(call DissValue.get());
    const uint16_t rxVal = dv.cmd;
    
    // nothing to do for sink/root
    if (call RootControl.isRoot()) {
      return;
    }

    //dbg("TestDisseminationC", "Received new correct 32-bit value @ %s.\n", sim_time_string());
    printf("%lu: %u bf-rx %u %u\n", call LocalTime.get(), TOS_NODE_ID, dissValue.cmd, rxVal);
    printfflush();
    
    dissValue = dv;
    
    // then send confirmation
    sendConfirmation(0, rxVal, SUCCESS);
  }


  
  /*** SendData *********************************************************/
  event void SendData.sendDone(message_t * msg, error_t err) {
    // TODO
  }
  
  
  /*** SendConf *********************************************************/
  event void SendConf.sendDone(message_t * msg, error_t err) {
    // TODO
  }
  
  
  /*** ReceiveData ******************************************************/
  event message_t * ReceiveData.receive(message_t * msg, void * payload, uint8_t len) {
    printf("%lu: %u data-rx %u %u %u %u\n", call LocalTime.get(), TOS_NODE_ID, call CtpPacket.getOrigin(msg), call CtpPacket.getType(msg), *((nx_uint16_t *)payload), call CtpPacket.getThl(msg));
    printfflush();
    return msg;
  }
  
  
  /*** ReceiveConf ******************************************************/
  event message_t * ReceiveConf.receive(message_t * msg, void * payload, uint8_t len) {
    OrinocoCommandAckMsg * p = (OrinocoCommandAckMsg *)payload;
    printf("%lu: %u bf-rx-conf %u %u %u %u\n", call LocalTime.get(), TOS_NODE_ID, call CtpPacket.getOrigin(msg), call CtpPacket.getType(msg), call CtpPacket.getThl(msg), p->version);
    printfflush();
    return msg;
  }
}
