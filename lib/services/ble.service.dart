import 'dart:typed_data';
import 'package:gamerch_shinyhunter/data/models/connection_state.model.dart';
import 'package:gamerch_shinyhunter/data/models/controller_input.model.dart';
import 'package:gamerch_shinyhunter/services/ble.abstract.service.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';

//TODO: for all methods: check state before execution, handle wrong state

//TODO: find device without device name know (first time use, pairing ...) via service UUID

class BleService implements BleServiceInterface {
  // init flutter_reactive_ble package
  final FlutterReactiveBle _flutterReactiveBle = FlutterReactiveBle();

  // runtime variables for ble connection
  BleConnectionStatus _bleConnectionStatus = BleConnectionStatus.deviceDisconnected;
  String _statusMessage = 'no message';
  StreamSubscription<DiscoveredDevice>? _scanStream;
  DiscoveredDevice? _bleDevice;
  List<DiscoveredDevice> _discoveredDevicesList = [];
  StreamSubscription? _connectionStream;
  DeviceConnectionState _currentConnectionState = DeviceConnectionState.disconnected;
  StreamSubscription? _postureDataStream;
  StreamSubscription? _akkuDataStream;
  QualifiedCharacteristic? _charAppSetter;
  bool _isSendingController = false;

  //TODO check if this place is best to store this data (const environment variables in seperate file?)
  // final String myDeviceName = 'StraightUp';
  final Uuid _serviceUuid = Uuid.parse('12345678-1234-5678-1234-56789abcdef0');
  // primary IO characteristics: app -> device input, device -> app feedback (e.g., rumble)
  final Uuid _charUuidAppSetter = Uuid.parse('12345678-1234-5678-1234-56789abcdef1');
  final Uuid _charUuidRumble = Uuid.parse('12345678-1234-5678-1234-56789abcdef2');
  // legacy/posture characteristic placeholders kept for now

  //TODO: implement the package status stream (bt on? permissions ok?)
  // Stream<BleStatus> get bleStatusUpdates => _flutterReactiveBle.statusStream;

  // updating and publishing ble connection status
  //TODO: evaluate use of .broadcast (perma updates are a problem buit maybe multiple listeners needed)
  final StreamController<ConnectionState> _bleConnectionStatusController = StreamController<ConnectionState>.broadcast();
  @override
  Stream<ConnectionState> get bleConnectionStatusStream => _bleConnectionStatusController.stream;
  void _updateBleConnectionStatusStream(BleConnectionStatus updatedBleConnectionStatus, String? updatedStatusMessage) async {
    _statusMessage = updatedStatusMessage ?? _statusMessage;
    if (_bleConnectionStatus != updatedBleConnectionStatus) {
      _bleConnectionStatus = updatedBleConnectionStatus;
      _bleConnectionStatusController.add(
        ConnectionState(
          statusBleConnection: _bleConnectionStatus,
          statusMessage: _statusMessage,
        ),
      );
      _statusMessage = 'no message';
    } else {
      print('Status did not change. Update denied.');
    }
  }

  //TODO when to call dispose?
  void disposeBleConnectionStatusStream() {
    _bleConnectionStatusController.close();
  }

  // publishing found devices
  final StreamController<String> _foundDevicesStreamController = StreamController<String>.broadcast();
  @override
  Stream<String> get foundDevicesStream => _foundDevicesStreamController.stream;
  //TODO when to call dispose?
  void disposeFoundDevicesStream() {
    _foundDevicesStreamController.close();
  }

  // publishing ble received data
  final StreamController<List<double>> _receiveMeasurementDataStreamController = StreamController<List<double>>.broadcast();
  @override
  Stream<List<double>> get receiveMeasurementDataStream => _receiveMeasurementDataStreamController.stream;
  //TODO when to call dispose?
  void disposeReceiveMeasurementData1Stream() {
    _receiveMeasurementDataStreamController.close();
  }

  // publishing akku level data (care!: _akkuDataStream vs. akkuDataStream)
  final StreamController<int> _akkuDataStreamController = StreamController<int>.broadcast();
  @override
  Stream<int> get akkuDataStream => _akkuDataStreamController.stream;
  //TODO when to call dispose?
  void disposeAkkuDataStream() {
    _akkuDataStreamController.close();
  }

  @override
  List<double> convertIntArrayToDouble(List<int> intData) {
    List<double> data = intData.asMap().entries.map((entry) {
      int index = entry.key;
      int value = entry.value;
      if (index >= 2 && index <= 10) {
        // transform acceleration values with /1000 and to double
        return value / 1000.0;
      } else {
        // transform remaining values only to double
        return value.toDouble();
      }
    }).toList();
    return data;
  }

  @override
  void scanForDevices() async {
    // check bluetooth status of device before starting scan
    //TODO: maybe integrate in an init method of service?
    while (_flutterReactiveBle.status == BleStatus.unauthorized) {
      await Permission.location.request();
    }
    // only scan if in disconnected state, otherwise disconnect to reset any connections
    if (_bleConnectionStatus != BleConnectionStatus.deviceDisconnected) {
      disconnect();
      scanForDevices();
    } else {
      _discoveredDevicesList = [];
      if (_flutterReactiveBle.status == BleStatus.ready) {
        _updateBleConnectionStatusStream(BleConnectionStatus.scanning, null);
        //TODO: specifying service here not works from esp side (use ESP32 NimBLE isntead of other esp ble pacakge?)
        _scanStream = _flutterReactiveBle.scanForDevices(withServices: []).listen(
          // _scanStream = _flutterReactiveBle.scanForDevices(withServices: [_serviceUuid]).listen(
          (event) {
            if (event.name.isNotEmpty) {
              // TODO: Maybe work with event.connectable
              // print('name: ${event.name}, id: ${event.id}');
              _foundDevicesStreamController.add(event.name);
              _discoveredDevicesList.add(event);
            }
          },
        );
      } else {
        _updateBleConnectionStatusStream(BleConnectionStatus.error, 'Ble device status not ready');
      }
    }
  }

  @override
  void connectToDevice(String selectedDevice) {
    // pick ui-selected device from device list stored here in service
    _bleDevice = _discoveredDevicesList.firstWhere((device) => device.name == selectedDevice);
    _updateBleConnectionStatusStream(BleConnectionStatus.connecting, null);
    _scanStream?.cancel();
    // service needs to be listed in withServices/servicesWithCharacteristicsToDiscover to interact (read and write data)
    _connectionStream = _flutterReactiveBle.connectToDevice(
      id: _bleDevice!.id,
      servicesWithCharacteristicsToDiscover: {
        _serviceUuid: [_charUuidAppSetter, _charUuidRumble],
      },
    ).listen(
      (event) async {
        _currentConnectionState = event.connectionState;
        switch (event.connectionState) {
          case DeviceConnectionState.connecting:
            Timer(const Duration(seconds: 10), () {
              // Überprüfe, ob das Gerät noch versucht zu verbinden
              if (_currentConnectionState == DeviceConnectionState.connecting) {
                _updateBleConnectionStatusStream(BleConnectionStatus.error, 'Timeout while connecting to device');
                _connectionStream?.cancel();
              }
            });
          case DeviceConnectionState.connected:
            {
              // ONLY USE CLEAR GATT CACHE IN DEVELOPMENT AS IT IS ON GREY LIST OF ANDROID OS (IN IOS NEVER USE IT)
              // await _flutterReactiveBle.clearGattCache(_bleDevice!.id);
              _charAppSetter = QualifiedCharacteristic(serviceId: _serviceUuid, characteristicId: _charUuidAppSetter, deviceId: event.deviceId);
              // TEST MTU SIZE
              final mtu = await _flutterReactiveBle.requestMtu(deviceId: _bleDevice!.id, mtu: 250);
              print('MTU Size: $mtu');
              _updateBleConnectionStatusStream(BleConnectionStatus.deviceConnected, null);
              break;
            }
          case DeviceConnectionState.disconnected:
            {
              _updateBleConnectionStatusStream(BleConnectionStatus.deviceDisconnected, null);
              break;
            }
          default:
        }
      },
      onError: (dynamic error) {
        _updateBleConnectionStatusStream(BleConnectionStatus.error, 'Error connecting to device and/or to characteristic');
      },
    );
  }


  // base read char method
  //TODO: consider type checking of characterisitc parameter, cant be assigned to type as different types in win/mobile packages but method defined in interface
  @override
  Future<String?> readChar(characteristic) async {
    String? result;
    if (_bleDevice != null && (_bleConnectionStatus == BleConnectionStatus.subscribed || _bleConnectionStatus == BleConnectionStatus.deviceConnected)) {
      try {
        final response = await _flutterReactiveBle.readCharacteristic(characteristic!);
        result = String.fromCharCodes(response);
      } catch (e) {
        print('error reading char: $e');
        _updateBleConnectionStatusStream(BleConnectionStatus.error, 'Error reading from characteristic: $e');
      }
    } else {
      _updateBleConnectionStatusStream(BleConnectionStatus.error, 'Error reading from characteristic (Connection)');
    }

    return result;
  }

  Uint8List _doubleToBytes(List<double> dataList) {
    final byteData = ByteData(dataList.length * 8); // double = 8 bytes each

    for (int i = 0; i < dataList.length; i++) {
      byteData.setFloat64(i * 8, dataList[i], Endian.little);
    }

    return byteData.buffer.asUint8List();
  }

  @override
  void writeToChar(List<double> dataList) {
    Uint8List dataTransformed = _doubleToBytes(dataList);
    if (_bleDevice != null && (_bleConnectionStatus == BleConnectionStatus.deviceConnected || _bleConnectionStatus == BleConnectionStatus.subscribed)) {
      try {
        _flutterReactiveBle.writeCharacteristicWithResponse(
          _charAppSetter!,
          value: dataTransformed,
        );
      } catch (e) {
        print('error writing char: $e');
        _updateBleConnectionStatusStream(BleConnectionStatus.error, 'Error writing to characteristic: $e');
        //TODO: blestate has custom error class for writin errors, this is not used as not connected to this error  here -> option to not stop ui if only writing is not working as intended
      }
    } else {
      print('$_bleConnectionStatus');
      _updateBleConnectionStatusStream(BleConnectionStatus.error, 'Error writing to characteristic (Connection)');
      //TODO: blestate has custom error class for writin errors, this is not used as not connected to this error  here -> option to not stop ui if only writing is not working as intended
    }
  }

  @override
  void sendControllerInput(ControllerInput input) {
    if (_bleDevice == null || (_bleConnectionStatus != BleConnectionStatus.deviceConnected && _bleConnectionStatus != BleConnectionStatus.subscribed)) {
      return; // drop silently when not connected
    }
    if (_isSendingController) return; // drop frames instead of queuing

    _isSendingController = true;
    final payload = input.toBytes();
    _flutterReactiveBle
        .writeCharacteristicWithoutResponse(
          _charAppSetter!,
          value: payload,
        )
        .catchError((e) {
      print('error writing controller payload: $e');
    }).whenComplete(() => _isSendingController = false);
  }

  //TODO: check if subscription AND listening has to be closed at some point
  // void _subscribeToAkkuDataStream() async {
  //   // cancel old subscription if existing (added timer needed)
  //   await _akkuDataStream?.cancel();
  //   //TODO: no best practice solution yet
  //   await Future.delayed(const Duration(milliseconds: 100));
  //   if (_bleDevice != null &&
  //       (_bleConnectionStatus == BleConnectionStatus.deviceConnected || _bleConnectionStatus == BleConnectionStatus.subscribed) &&
  //       _currentConnectionState == DeviceConnectionState.connected) {
  //     try {
  //       _akkuDataStream = _flutterReactiveBle.subscribeToCharacteristic(_charAkkuLevel!).listen(
  //         (data) {
  //           _akkuDataStreamController.add(data[0]);
  //         },
  //         onError: (dynamic error) {
  //           _updateBleConnectionStatusStream(BleConnectionStatus.error, 'Error reading data from akku subscription: $error');
  //         },
  //       );
  //       // _updateBleConnectionStatusStream(BleConnectionStatus.subscribed, null);
  //     } catch (e) {
  //       _updateBleConnectionStatusStream(BleConnectionStatus.error, 'Error subscribing to char akku: $e');
  //     }
  //   } else {
  //     _updateBleConnectionStatusStream(BleConnectionStatus.error, 'Error subscribing to char akku (Connection)');
  //   }
  // }

  //TODO: check if subscription AND listening has to be closed at some point

  void _unSubscribeFromAllChars() async {
    if (_bleConnectionStatus == BleConnectionStatus.subscribed) {
      try {
        //TODO: check if this is the correct way to unsubscribe
        _postureDataStream?.cancel();
        _akkuDataStream?.cancel();
      } catch (e) {
        _updateBleConnectionStatusStream(BleConnectionStatus.error, 'Error when unsubscribing: $e');
      }
    } else {
      print('Did not unsubscribe as not in subscribed state');
    }
  }

  @override
  void stopScan() {
    //TODO: check if any method like _flutterReactiveBle.stopScanForDevices is needed
    if (_bleConnectionStatus == BleConnectionStatus.scanning) {
      _updateBleConnectionStatusStream(BleConnectionStatus.deviceDisconnected, null);
      _scanStream?.cancel();
    }
  }

  @override
  void disconnect() async {
    _unSubscribeFromAllChars();
    try {
      _connectionStream?.cancel();
      _updateBleConnectionStatusStream(BleConnectionStatus.deviceDisconnected, null);
    } catch (e) {
      _updateBleConnectionStatusStream(BleConnectionStatus.error, 'Error Disconnecting Device: $e');
    }
  }
}
