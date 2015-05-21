// Author Anhtuan Nguyen, Christian Renner


/**
 * decompresses a DDC forecast and writes the result
 * into the provides ddc_forecast_t
 */

configuration DdcDecoderC {
  provides {
    interface Decoder;
  }
}
implementation {
  components DdcDecoderP;
  Decoder = DdcDecoderP;
  
  components LocalTimeMilliC;
  DdcDecoderP.LocalTime -> LocalTimeMilliC;
}
