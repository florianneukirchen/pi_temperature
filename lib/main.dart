/*
MIT License

Copyright (c) 2024 Florian Neukirchen

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
 */

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'live_line_chart.dart';

const BLE_NAME = 'Thermometer';
const SERVICE_UUID = '00000001-710e-4a5b-8d75-3e5b444bc3cf';
const CHARACTERIST_UUID = '00000002-710e-4a5b-8d75-3e5b444bc3cf';

void main() {
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const apptitle = 'Pi Temperature';

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // Manage State with provider
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: apptitle,
        theme: ThemeData(
          // This is the theme of your application.
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
          useMaterial3: true,
        ),
        home: const MyHomePage(title: apptitle),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  // Constructor to init appstate with waypoints and position
  MyAppState(){
    try {
      startScan();
    } catch (e) {
      // Do nothing
    }
  }


  final _ble = FlutterReactiveBle();

  StreamSubscription<DiscoveredDevice>? _scanSub;
  StreamSubscription<ConnectionStateUpdate>? _connectSub;
  StreamSubscription<List<int>>? _notifySub;

  var _found = false;
  var connected = false;
  var _value = '';
  var _unit = '';
  var maxValue = 45.0;

  void startScan() async {
    // Android requires location permission to use bluetooth
    final permission = Permission.location;

    if (await permission.isDenied) {
      await [permission,
        Permission.bluetoothScan,
        Permission.bluetoothAdvertise,
        Permission.bluetoothConnect
      ].request();
    }
    _scanSub = _ble.scanForDevices(withServices: []).listen(_onScanUpdate);
  }

  @override
  void dispose() {
    connected = false;
    _notifySub?.cancel();
    _connectSub?.cancel();
    _scanSub?.cancel();
    super.dispose();
  }

  void _onScanUpdate(DiscoveredDevice d) {
    if (d.name == BLE_NAME && !_found) {
      _scanSub?.cancel(); // Stop Scan
      _found = true;
      _connectSub = _ble.connectToDevice(id: d.id).listen((update) {
        if (update.connectionState == DeviceConnectionState.connected) {
          connected = true;
          _onConnected(d.id);
        }
      });
    }
  }

  void _onConnected(String deviceId) {
    final characteristic = QualifiedCharacteristic(
        deviceId: deviceId,
        serviceId: Uuid.parse(SERVICE_UUID),
        characteristicId: Uuid.parse('00000002-710e-4a5b-8d75-3e5b444bc3cf'));

    _notifySub = _ble.subscribeToCharacteristic(characteristic).listen((bytes) {
      // print(_value);
      _value = const Utf8Decoder().convert(bytes);
      notifyListeners();
    });
  }

  double getValue() {
    double v = 0.0;
    var splitted = _value.split(" ");
    if (splitted.length == 2) {
      v = double.parse(splitted[0]);
    }
    return v;
  }

  String getUnit() {
    if (_unit != "") {
      return _unit;
    } else {
      var splitted = _value.split(" ");
      if (splitted.length == 2) {
        return splitted[1];
      }
      return "";
    }
  }

} // AppState


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {


  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        title: Text(widget.title),
      ),
      body: Center(
          child: !appState.connected
              ? const CircularProgressIndicator()
          //: Text("${appState.getValue()} °C", style: Theme.of(context).textTheme.titleLarge)),
              : LiveLineChart()),
    );
  }
}
