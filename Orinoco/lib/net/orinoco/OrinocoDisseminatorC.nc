generic configuration OrinocoDisseminatorC(typedef T) {
  provides {
    interface DisseminationUpdate<T> as Update;
    interface DisseminationValue<T>  as Value;
    interface DisseminationDelay     as Delay;
  }
}
implementation {
  components new OrinocoDisseminatorP(T);
  Update = OrinocoDisseminatorP.Update;
  Value  = OrinocoDisseminatorP.Value;
  Delay  = OrinocoDisseminatorP.Delay;
  
  components OrinocoDisseminationLayerC;
  OrinocoDisseminatorP.Dissemination -> OrinocoDisseminationLayerC;
  
  components LocalTimeMilliC;
  OrinocoDisseminatorP.LocalTimeMilli -> LocalTimeMilliC;
}