interface Decoder{
  command error_t decode(ddc_forecast_t * res, const ddcForecastMsg * encData);
}
