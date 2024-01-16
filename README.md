# PiTemperature

Flutter app to plot Raspberry Pi CPU temperature on Android via [Bluetooth Low Energy](https://learn.adafruit.com/introduction-to-bluetooth-low-energy).

You have sensors connected to a Raspberry Pi, no internet connection while measuring, but still want to plot live
data on an Android phone? What about connecting with Bluetooth Low Energy? This project helps you to get started.

© 2024 Florian Neukirchen, under [MIT License](https://github.com/florianneukirchen/pi_temperature/blob/main/LICENSE)

## Set up the Raspberry Pi

I am using [CPUTemp](https://github.com/Douglas6/cputemp) by Douglas Otwell for the raspberry side.
This is an "Python GATT server example for the Raspberry Pi", i.e. a relative simple example of how to get
BLE working on the Rasperry Pi and to stream the CPU temperature. It would be easy to change the python code to be used with other sensors.

Clone this repository on your Pi. Change into the directory and start the GATT server with `python3 cputemp.py`.

For the CPU temperature example, the only thing I changed in the code is the time step at which the 
temperature value is updated: 
for testing purpuses I changed it from 5 s to 40 ms by changing:

```python
NOTIFY_TIMEOUT = 5000
```

to: 
```python
NOTIFY_TIMEOUT = 40
```

## Flutter App

The current version searches for Bluetooth device "Temperature" and subscribes using the UUIDs
specified in `cputemp.py`.

The app uses [provider](https://docs.flutter.dev/data-and-backend/state-mgmt/simple) to manage app state, [fl_chart](https://pub.dev/packages/fl_chart) for plotting
and [flutter_reactive_ble](https://pub.dev/packages/flutter_reactive_ble) for the bluetooth connection.

### Start to develop
The bluetooth connection details are set in `main.dart`:
- name of the bluetooth device
- UUID of Service and Characteristic

If you adapt the code for another sensor, you'll want to use another name and other UUIDs. There are 
<<<<<<< HEAD
many websites to generate UUIDs for free, just make sure you do not conflict with reserved UUIDs, see
[reference](https://novelbits.io/uuid-for-custom-services-and-characteristics/).

The sample rate in milliseconds (e.g. 40 ms) is set in `live_line_chart.dart`.

## Useful Resources
- [Get Started with Bluetooth Low Energy using Flutter & Arduino](https://medium.com/@danielwolf.dev/get-started-with-bluetooth-low-energy-using-flutter-arduino-bdf5d790edc)
- [Bluetooth Low Energy in Flutter – An Overview](https://leancode.co/blog/bluetooth-low-energy-in-flutter)
- [Introduction to Bluetooth Low Energy](https://learn.adafruit.com/introduction-to-bluetooth-low-energy)
