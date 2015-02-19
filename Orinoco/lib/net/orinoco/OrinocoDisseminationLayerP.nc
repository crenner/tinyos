// TODO move to header
#define DISSEMINATION_VERSION_SIZE  sizeof(uint8_t)
#define DISSEMINATION_VERSION_MAX   255


module OrinocoDisseminationLayerP {
  provides {
    // beacons
    interface Receive  as BeaconReceive;
    interface AMSend   as BeaconSend;
    interface Packet   as BeaconPacket;    
    
    // data
    interface Receive  as DataReceive;
    interface AMSend   as DataSend;
    interface Packet   as DataPacket;
    
    // dissemination
    interface OrinocoDissemination as Dissemination;
  }
  uses {
    // beacons
    interface AMSend   as BeaconSubSend;
    interface Receive  as BeaconSubReceive;
    interface Packet   as BeaconSubPacket;
    
    // data
    interface AMSend   as DataSubSend;
    interface Receive  as DataSubReceive;
    interface Packet   as DataSubPacket;

    // am ids
    interface AMPacket;
  }
}
implementation {
  bool     updateRequired_  = FALSE;
  // FIXME we might want to make sure that we send updates only
  // to intended receivers.
  //am_addr_t  updateRequester_ = AM_BROADCAST;
   
  // FIXME check how wise it is to put the version between
  // the actual data and the delay time field! (currently a lower layer)
  // this will surely mess up the weird time extraction at the current
  // sink implementation .. (if it's still there)
  
   
  /*** tools *************************************************************/
  uint8_t * getDataFooter(message_t * msg) {
    // add dissemination data footer to the end of the packet (behind
    // regular payload) to avoid packet copying for, e.g., serial
    // transmission at the sink
    return (uint8_t *)
      (call DataSubPacket.getPayload(msg, call DataSubPacket.maxPayloadLength())
      + call DataPacket.payloadLength(msg)); // FIXME is this the right call?
      // FIXME also check in PacketDelayLayerP!
  }
   

  /*** BeaconSend ********************************************************/
  command error_t
  BeaconSend.send(am_addr_t dst, message_t * msg, uint8_t len) {
    // TODO
    // - attach data, if required
    return call BeaconSubSend.send(dst, msg, len);
  }
  
  
  command void *
  BeaconSend.getPayload(message_t * msg, uint8_t len) {
    return call BeaconPacket.getPayload(msg, len);
  }
  
  
  command uint8_t
  BeaconSend.maxPayloadLength() {
     return call BeaconPacket.maxPayloadLength();
  }
  
  
  command error_t
  BeaconSend.cancel(message_t * msg) {
    call BeaconSubSend.cancel(msg);
  }
  
  
  /*** BeaconPacket ******************************************************/
  command void BeaconPacket.clear(message_t * msg) {
    return call BeaconSubPacket.clear(msg);
  }

  command uint8_t BeaconPacket.payloadLength(message_t * msg) {
    return call BeaconSubPacket.payloadLength(msg);
  }

  command void BeaconPacket.setPayloadLength(message_t * msg, uint8_t len) {
    call BeaconSubPacket.setPayloadLength(msg, len);
  }

  command uint8_t BeaconPacket.maxPayloadLength() {
    return call BeaconSubPacket.maxPayloadLength();
  }

  command void * BeaconPacket.getPayload(message_t * msg, uint8_t len) {
    return call BeaconSubPacket.getPayload(msg, len);
  }

  
  /*** DataSend **********************************************************/
  command error_t
  DataSend.send(am_addr_t dst, message_t * msg, uint8_t len) {
    // attach current version and increment length
    uint8_t *  v = getDataFooter(msg);
    *v = signal Dissemination.version();
    len += DISSEMINATION_VERSION_SIZE;
    
    return call DataSubSend.send(dst, msg, len);
  }
  
  
  command void *
  DataSend.getPayload(message_t * msg, uint8_t len) {
    return call DataPacket.getPayload(msg, len);
  }
  
  
  command uint8_t
  DataSend.maxPayloadLength() {
     return call DataPacket.maxPayloadLength();
  }
  
  
  command error_t
  DataSend.cancel(message_t * msg) {
    return call DataSubSend.cancel(msg);
  }
  
  
  /*** DataPacket ********************************************************/
  command void DataPacket.clear(message_t * msg) {
    return call DataSubPacket.clear(msg);
  }

  command uint8_t DataPacket.payloadLength(message_t * msg) {
    return call DataSubPacket.payloadLength(msg) - DISSEMINATION_VERSION_SIZE;
  }

  command void DataPacket.setPayloadLength(message_t * msg, uint8_t len) {
    call DataSubPacket.setPayloadLength(msg, len + DISSEMINATION_VERSION_SIZE);
  }

  command uint8_t DataPacket.maxPayloadLength() {
    return call DataSubPacket.maxPayloadLength() - DISSEMINATION_VERSION_SIZE;
  }

  command void * DataPacket.getPayload(message_t * msg, uint8_t len) {
    return call DataSubPacket.getPayload(msg, len + DISSEMINATION_VERSION_SIZE);
  }
  
  
  /*** Dissemination *****************************************************/
  default event uint8_t
  Dissemination.version() {
    return 0;
  }

  default event const uint8_t * 
  Dissemination.data(uint8_t * size) {
    *size = 0;
    return NULL;
  }
  
  default event void
  Dissemination.update(const uint8_t * d, uint8_t size) {
    // ignore
  }
  
  
  /*** BeaconSubSend *****************************************************/
  event void
  BeaconSubSend.sendDone(message_t * msg, error_t error) {
    signal BeaconSend.sendDone(msg, error);
  }
  
  
  /*** BeaconSubReceive **************************************************/
  event message_t * 
  BeaconSubReceive.receive(message_t * msg, void * payload, uint8_t len) {
    // TODO
    // - check if data attached (do we need an extra field or how do we do this?)
    // -> we could use another packet type?
    // - copy out data (if present)
    return signal BeaconReceive.receive(msg, payload, len);
  }
  
  
  /*** DataSubSend *******************************************************/
  event void
  DataSubSend.sendDone(message_t * msg, error_t error) {
    signal DataSend.sendDone(msg, error);
  }
  
  
  /*** DataSubReceive ****************************************************/
  event message_t * 
  DataSubReceive.receive(message_t * msg, void * payload, uint8_t len) {
    uint8_t *  vr = getDataFooter(msg);
    uint8_t    vl = signal Dissemination.version();
    
    // is the sender still up to date?
    if (*vr < vl || (*vr - vl) >= DISSEMINATION_VERSION_MAX/2) {
      updateRequired_  = TRUE;
      
      //updateRequester_ = call AMPacket.source(msg);
      printf("%u diss old %u %u %u\n", TOS_NODE_ID, vl, *vr, call AMPacket.source(msg));
      printfflush();
    } else {
      updateRequired_  = FALSE;
      //updateRequester_ = AM_BROADCAST;
    }
    
    return signal DataReceive.receive(msg, payload, len);
  }
}
