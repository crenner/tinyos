generic module ConfigP(typedef conftype_t) {
  provides {
    interface Init;
    interface GetSet<const conftype_t *>;
  }
  uses {
    interface ParameterInit<conftype_t *>;
    interface Configurator;
    // Dirty
  }

  // TODO there is currently no possibility to store the config!
}
implementation {
  conftype_t  conf_;

  /* Init ****************************************************************/
  command error_t Init.init() {
    return call ParameterInit.init(&conf_);
  }

  /* GetSet **************************************************************/
  command const conftype_t * GetSet.get() {
    return &conf_;
  }

  command void GetSet.set(const conftype_t * newConf) {
    conf_ = *newConf;
    call Configurator.store();
  }

  /* Configurator ********************************************************/
  event void Configurator.requestLogin() {
    call Configurator.login(&conf_, sizeof(conf_));
  }

  event void Configurator.stored(error_t res) {
    // TODO howto handle errors?
  }

  event void Configurator.loaded(bool valid, void * data, uint8_t size, error_t res) {
    if (valid) {
      conf_ = *((conftype_t *)data);
    } else {
      // load defaults and store
      call ParameterInit.init(&conf_);
      call Configurator.store();
    }
  }
}
