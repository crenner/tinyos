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

    interface DisseminationValue<DdcForecastMsg> as Value;	
    interface DisseminationUpdate<DdcForecastMsg> as Update;
    
#ifdef ORINOCO_DEBUG_STATISTICS
    interface Get<const orinoco_dissemination_statistics_t *> as DisseminationStatistics;
#endif
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
    
#ifdef PRINTF_H
    interface LocalTime<TMilli>;
#endif
  }
}
implementation {
  bool     updateRequired_  = FALSE;
  DdcForecastMsg paket; // local Package
  // FIXME we might want to make sure that we send updates only
  // to intended receivers.
  //am_addr_t  updateRequester_ = AM_BROADCAST;
   
  // FIXME check how wise it is to put the version between
  // the actual data and the delay time field! (currently a lower layer)
  // this will surely mess up the weird time extraction at the current
  // sink implementation .. (if it's still there)
  
#ifdef ORINOCO_DEBUG_STATISTICS
  orinoco_dissemination_statistics_t  ds_ = {0};
#endif
  
   
  /*** tools *************************************************************/
  uint8_t * getDataFooter(message_t * msg) {
    // add dissemination data footer to the end of the packet (behind
    // regular payload) to avoid packet copying for, e.g., serial
    // transmission at the sink
    return (uint8_t *)
      (call DataSubPacket.getPayload(msg, call DataSubPacket.maxPayloadLength())
      + call DataPacket.payloadLength(msg));
  }
  
  
  // check if v1 is newer than v2
  // return true, if v1 newer than v2; false otherwise
  bool isNewer(uint8_t v1, uint8_t v2) {
    return (v1 > v2) || ((v2 - v1) >= DISSEMINATION_VERSION_MAX/2);
  }
   

  /*** BeaconSend ********************************************************/
  command error_t
  BeaconSend.send(am_addr_t dst, message_t * msg, uint8_t len) {
    // do we have to piggy-back data?
    if (updateRequired_) {
      uint8_t          v;
      uint8_t          dlen;
      uint8_t        * p = NULL;
      const uint8_t  * d = NULL;
      
      // get version, data and size
      v = signal Dissemination.version();
      d = signal Dissemination.data(&dlen);
      
      if (d != NULL && dlen > 0) {
        // get pointer behind upper layer payload
        p = call BeaconSubPacket.getPayload(msg, call BeaconSubPacket.maxPayloadLength())
            + len;
        // FIXME we should check len here (it *must* be sizeof(OrinocoBeaconMsg)
        
        // TODO check if data fits into packet!
        *p = v;  // TODO proper typecast to diss_version_t
        memcpy(p + DISSEMINATION_VERSION_SIZE, d, dlen);
        len += dlen + DISSEMINATION_VERSION_SIZE;
        
#ifdef ORINOCO_DEBUG_STATISTICS
        ds_.numTxDissBeacons++;
#endif

//       printf("%lu: %u diss-tx %u %u\n", call LocalTime.get(), TOS_NODE_ID, v, call AMPacket.destination(msg));
//       printfflush();
      }
    
      // we're sending out the data, so clear flag
      updateRequired_ = FALSE;
    }
    
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
    // FIXME
    return call BeaconSubPacket.payloadLength(msg);
    //return call DataSubPacket.payloadLength(msg) - DISSEMINATION_VERSION_SIZE;
  }

  command void BeaconPacket.setPayloadLength(message_t * msg, uint8_t len) {
    // FIXME at this point, we don't exactly know
    call BeaconSubPacket.setPayloadLength(msg, len);
    //call DataSubPacket.setPayloadLength(msg, len + DISSEMINATION_VERSION_SIZE);
  }

  command uint8_t BeaconPacket.maxPayloadLength() {
    // FIXME apply max. data size to be piggy-backed
    //return call BeaconSubPacket.maxPayloadLength() - DISSEMINATION_MAX_DATA_SIZE;
    return call BeaconSubPacket.maxPayloadLength();
  }

  command void * BeaconPacket.getPayload(message_t * msg, uint8_t len) {
    // FIXME apply max. data size to be piggy-backed
    //return call BeaconSubPacket.getPayload(msg, len + DISSEMINATION_MAX_DATA_SIZE);
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
  
  
  /*** Dissemination (dummy implementation) ******************************/
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
  Dissemination.update(uint8_t rversion, const uint8_t * rdata, uint8_t size) {
    // ignore
  }

// Kopiere übergebenen Wert auf das lokale Paket 
command void Update.change(DdcForecastMsg* CC){
}


// Liefere neue Werte ab
command const DdcForecastMsg* Value.get(){
return &paket;

}
// Setze standardwert
command void Value.set( const DdcForecastMsg* val){
paket = *val;


}
  
  
  /*** DisseminationStatistics *******************************************/
#ifdef ORINOCO_DEBUG_STATISTICS
  command const orinoco_dissemination_statistics_t *
  DisseminationStatistics.get() {
    return &ds_;
  }
#endif
  
  
  /*** BeaconSubSend *****************************************************/
  event void
  BeaconSubSend.sendDone(message_t * msg, error_t error) {
    signal BeaconSend.sendDone(msg, error);
  }
  
  
  /*** BeaconSubReceive **************************************************/
  event message_t * 
  BeaconSubReceive.receive(message_t * msg, void * payload, uint8_t len) {
    // is there any data attached?
    // NOTE this implementation relies on the fact that the remaining
    // packet payload is a fixed-size OrinocoBeaconMsg
    if (len > sizeof(OrinocoBeaconMsg)) {
      uint8_t    dlen = len - sizeof(OrinocoBeaconMsg) - DISSEMINATION_VERSION_SIZE;
      uint8_t  * d    = (uint8_t *)payload + sizeof(OrinocoBeaconMsg) + DISSEMINATION_VERSION_SIZE;
      uint8_t    v    = *((uint8_t *)payload + sizeof(OrinocoBeaconMsg));
      
      // provide update
      // TODO check if it's useful to do this here
      if (isNewer(v, signal Dissemination.version())) {
#ifdef ORINOCO_DEBUG_STATISTICS
        ds_.numRxDissBeacons++;
#endif
        signal Dissemination.update(v, d, dlen);
      } else {
#ifdef ORINOCO_DEBUG_STATISTICS
        ds_.numRxDissBeaconsNonNew++;
#endif
        //printf("%lu: %u diss-glitch %u %u %u\n", call LocalTime.get(), TOS_NODE_ID, signal Dissemination.version(), v, call AMPacket.source(msg));
        //printfflush();
      }
    }

    return signal BeaconReceive.receive(msg, payload, sizeof(OrinocoBeaconMsg));
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
    if (isNewer(vl, *vr)) {
      updateRequired_ = TRUE;
      
      //updateRequester_ = call AMPacket.source(msg);
      //printf("%lu: %u diss-trig %u %u %u\n", call LocalTime.get(), TOS_NODE_ID, vl, *vr, call AMPacket.source(msg));
      //printfflush();
    } else {
      updateRequired_  = FALSE;
      //updateRequester_ = AM_BROADCAST;
    }
    
    return signal DataReceive.receive(msg, payload, len);
  }
}
