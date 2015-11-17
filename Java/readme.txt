The parseCloudcover Application has the main purpose of sending and receiving data from the sink node.
So far the only data sent are encoded Cloud Cover forecasts.
There are also several different modes for testing purposes.

1. Forecast mode:
Forecast mode can be started by starting the application with the parameter "weather".
The application will read periodically forecast data from the source http://www2.wetterspiegel.de
as well as the sunrise and sunset time from http://www.sunrise-and-sunset.com
to create an encoded forecast. The data will be then send to the sink node.
The source code can be found in WeatherTask.java

1.1 Parameter:
Certain parameter can be changed at runtime via the Parameter.txt file.
Frequency: Gives the period at where new forecasts will be generated in millisecond. By Default this parameter is one hour.
Number of Values: Forecasts have a horizon of 7 Days with a resolution of one hour. This means an encoded forecast will have 168 values.
The number of values parameter can be used to reduce the horizon and thereby reduce the number of values sent.
Resolution: starting at 0 for 1 hour and 1 for 2 hours and so on. The resolution give the length of a timeslot in a forecast.
The minimum value is 1 hour. The bigger the resolution the the more timeslots have to be merged by computing the average of their values.

1.2 Setting up the Sink
The Application cannot communicate directly with the sink node. Another tools is required: the "Serial Forwarder"
It can be executed by calling /opt/tinyos-2.1.2/support/sdk/cpp/sf/sf  in bash.
After that a console will open where we enter the command: 
start 9002 /dev/ttyUSB1/ 57600
9002 is the port for the Serialforwarder and is default.
/dev/ttyUSB1 is the assumed Port of the sink node
57600 is the Baudrate.
All data sent from the parseCloudCover application will be sent to the Serial Forwarder, which forwards the data to the sink and vice versa

2. Test Mode1
In this mode forecast datasets are read from a given test file. These datasets are encoded and
sent via Serialforwarder to the sink node. This mode allows sending a greater amount of different data
in a short amount of time. It is important to set the time between each dataset sent to at least 2 seconds
as shorter intervals may cause package losses at the serial forwarder side.
The source Code for this mode can be found in TestCoding.java

2.1 Parameter
Test1 mode can be started by starting the application with the parameter "test".
The second parameter is the location of the test forecast data. By default there is a cloudcover2.dat file
with about 10000 test datasets in the application folder.
The third parameter is the time parameter. This parameter determines the amount of waiting time between each
dataset sent in milliseconds.

3. Test Mode2


