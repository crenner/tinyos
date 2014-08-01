generic module ConfigP(typedef conftype_t) {
  provides {
    interface Init;
    interface GetSet<const conftype_t *>;
  }
  uses {
    interface ParameterInit<conftype_t *>;
  }
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
  }
}
