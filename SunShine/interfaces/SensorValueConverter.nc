interface SensorValueConverter<SensorValue_t> {
	// convert a value from uint16 (raw ADC reading) to SensorValue_t
	command SensorValue_t convert(uint16_t);
}
