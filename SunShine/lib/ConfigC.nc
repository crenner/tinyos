generic configuration ConfigC(typedef conftype_t) {
  provides {
    interface GetSet<const conftype_t *>;
  }
  uses {
    interface ParameterInit<conftype_t *>;
  }
}
implementation {
  components new ConfigP(conftype_t);
  ParameterInit = ConfigP.ParameterInit;
  GetSet        = ConfigP.GetSet;

  components MainC;
  ConfigP.Init <- MainC;

  components new ConfiguratorC();
  ConfigP.Configurator -> ConfiguratorC;
}
