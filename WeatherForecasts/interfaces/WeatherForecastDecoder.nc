interface WeatherForecastDecoder<forecast_type, message_type> {
  command error_t decode(forecast_type * res, const message_type * encData);
}
