generic module OrinocoDisseminatorP(typedef T) {
  provides {
    interface DisseminationUpdate<T> as Update;
    interface DisseminationValue<T>  as Value;
    interface DisseminationDelay     as Delay;
  }
  uses {
    interface OrinocoDissemination as Dissemination;
    interface LocalTime<TMilli>    as LocalTimeMilli;
  }
}
implementation {
  uint8_t   version_ = 0;
  uint32_t  creationTime_;
  typedef struct piggy_data_s {
    uint16_t  age;
    T         data;
  } piggy_data_t;
  piggy_data_t  piggyData_;
  
  
  // inform upper layer about value updates inside a task
  // to keep processing time during packet/beacon reception low
  // we might break orinoco timings otherwise!
  task void valueChangedTask() {
    signal Value.changed();
  }
  

  /*** Update ************************************************************/
  command void
  Update.change(T * ONE newVal) {
    // FIXME check size
    memcpy(&piggyData_.data, newVal, sizeof(T));
    piggyData_.age = 0;
    version_++;
    creationTime_ = call LocalTimeMilli.get();
  }
  
  
  /*** Value *************************************************************/
  command const T *
  Value.get() {
    return &piggyData_.data;
  }

  /* NOTE only use to set default value */
  command void
  Value.set(const T * init) {
    piggyData_.data = *init;
    piggyData_.age  = 0;
    creationTime_ = call LocalTimeMilli.get();
  }

  default event void
  Value.changed() {
  }
  
  
  /*** Delay *************************************************************/
  command uint16_t
  Delay.delay() {
    return piggyData_.age;
  }
  
  
  /*** OrinocoDissemination **********************************************/
  event uint8_t
  Dissemination.version() {
    return version_;
  }

  event const uint8_t * 
  Dissemination.data(uint8_t * size) {
    // update age
    piggyData_.age = (call LocalTimeMilli.get() - creationTime_ + 512) / 1024;
    
    // provide data and size
    *size = sizeof(piggyData_);
    return (uint8_t *)&piggyData_;
  }
  
  event void
  Dissemination.update(uint8_t rversion, const uint8_t * rdata, uint8_t size) {
    // FIXME check size
    memcpy(&piggyData_, rdata, size);
    version_      = rversion;
    creationTime_ = call LocalTimeMilli.get() - piggyData_.age * 1024;
    post valueChangedTask();
  }
}
