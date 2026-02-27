import 'dart:typed_data';

import 'package:gamerch_shinyhunter/data/models/controller_input.model.dart';
import 'package:gamerch_shinyhunter/services/ble.abstract.service.dart';
import 'dart:async';
import 'package:gamerch_shinyhunter/data/models/connection_state.model.dart';
import 'dart:io';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

//TODO: check what has to be nullable, what not
class BleServiceBlue implements BleServiceInterface {
  // init mac ble blue plusnpackage
  BleServiceBlue() {
    _initPackage();
  }
  // runtime variables for ble connection
  // The 2 Attributes of ConnectionState Dataclass
  BleConnectionStatus _bleConnectionStatus = BleConnectionStatus.deviceDisconnected;
  String _statusMessage = 'no message';

  StreamSubscription? _scanStream;
  BluetoothDevice? _bleDevice;
  BluetoothService? _bleSerivce;
  List<BluetoothDevice> _discoveredDevicesList = [];
  List<BluetoothService> _discoveredServices = [];
  List<BluetoothCharacteristic> _discoveredCharacteristics = [];
  StreamSubscription? _connectionStream;
  StreamSubscription? _postureDataStream;
  StreamSubscription? _akkuDataStream;
  bool _isSendingController = false;

  //TODO check if this place is best to store this data (const environment variables in seperate file?)

  // final String myDeviceName = 'StraightUp';
  final String _serviceUuid = 'd12e0660-887f-4107-8b2c-a5c2036616aa';
  final String _charUuidAppSetter = '523bbab9-09b3-412d-82fd-9a690bc2c6c4';
  // Placeholder for future notify/indicate feedback (e.g., rumble)
  // ignore: unused_field
  final String _charUuidRumble = 'e7699040-939c-47d8-8264-b2df3198db0e';

  // updating and publishing ble connection status
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
      if (index < 2 || (index > 10 && index < 20)) {
        // scale back to double after it has been upscaled by 100 to send it as int
        return value / 100.0;
      }
      // if (index >= 2 && index <= 10) {
      //   // transform acceleration values with /1000 and to double
      //   return value / 1000.0;
      // }
      else {
        // transform remaining values only to double
        return value.toDouble();
      }
    }).toList();
    return data;
  }

  void _initPackage() async {
    FlutterBluePlus.setLogLevel(LogLevel.none, color: false);
    //TODO: check bluetooth status of device or do it before scan?
    if (await FlutterBluePlus.isSupported == false) {
      print('Bluetooth not supported by this device');
      return;
    }
    var subscription = FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
      print('BT Adapter state: $state');
      if (state == BluetoothAdapterState.on) {
        print('Bluetooth adapter is on');
      } else {
        print('Error in Bluetooth adapter state');
      }
    });
    if (Platform.isAndroid) {
      await FlutterBluePlus.turnOn();
    }
    subscription.cancel();

    _updateBleConnectionStatusStream(BleConnectionStatus.deviceDisconnected, null);
  }

  void disposePackage() async {
    //TODO: how to disconnect and dispose blue plus package
    _connectionStream?.cancel();
    _scanStream?.cancel();
    _postureDataStream?.cancel();
    _updateBleConnectionStatusStream(BleConnectionStatus.deviceDisconnected, null);
  }

  @override
  void scanForDevices() async {
    if (Platform.isAndroid) {
      await FlutterBluePlus.turnOn();
    }
    if (_bleConnectionStatus != BleConnectionStatus.deviceDisconnected) {
      disconnect();
      scanForDevices();
    } else {
      _discoveredDevicesList = [];
      _updateBleConnectionStatusStream(BleConnectionStatus.scanning, null);
      _scanStream = FlutterBluePlus.scanResults.listen(
        (results) {
          if (results.isNotEmpty) {
            if (results.last.advertisementData.advName.isNotEmpty) {
              _foundDevicesStreamController.add(results.last.device.advName);
              _discoveredDevicesList.add(results.last.device);
            }
          }
        },
        onError: (e) => print('error during scan stream: $e'),
      );
      if (_scanStream != null) {
        FlutterBluePlus.cancelWhenScanComplete(_scanStream!);
      }

      //TODO: should scan start code be in front of listening to scanresutl?
      await FlutterBluePlus.adapterState.where((val) => val == BluetoothAdapterState.on).first;

      await FlutterBluePlus.startScan(
          // withServices: [Guid("180D")],
          //TODO_consider timeout
          // timeout: const Duration(seconds: 15),
          androidUsesFineLocation: true);
//startScan(timeout: Duration(seconds: 4), androidUsesFineLocation: true);
      await FlutterBluePlus.isScanning.where((val) => val == false).first;
    }
  }

  @override
  void connectToDevice(String selectedDevice) async {
    // pick ui-selected device from device list stored here in service
    _bleDevice = _discoveredDevicesList.firstWhere((device) => device.advName == selectedDevice);
    print(_bleDevice!.advName);
    print(_bleDevice!.remoteId);
    _updateBleConnectionStatusStream(BleConnectionStatus.connecting, null);
    _scanStream?.cancel();

    await _bleDevice?.connect(autoConnect: false);
    // _updateBleConnectionStatusStream(BleConnectionStatus.deviceConnected, null);
    _connectionStream = _bleDevice?.connectionState.listen(
      (BluetoothConnectionState state) async {
        if (state == BluetoothConnectionState.disconnected) {
          _updateBleConnectionStatusStream(BleConnectionStatus.deviceDisconnected, null);
        }
        if (state == BluetoothConnectionState.connected) {
          _discoveredServices = await _bleDevice!.discoverServices();
          _bleSerivce = _discoveredServices.firstWhere(
            (element) => element.serviceUuid == Guid(_serviceUuid),
          );
          _discoveredCharacteristics = _bleSerivce?.characteristics ?? [];

          //TODO: is service discovery here best?
          //TODO: should here be checked of service is available?
          _updateBleConnectionStatusStream(BleConnectionStatus.deviceConnected, null);
        }
      },
      onError: (dynamic error) {
        _updateBleConnectionStatusStream(BleConnectionStatus.error, 'Error connecting to device');
      },
    );
    if (_connectionStream != null) {
      _bleDevice?.cancelWhenDisconnected(_connectionStream!, delayed: true, next: true);
    }
  }

// base read char method
  //TODO: consider type checking of characterisitc parameter, cant be assigned to type as different types in win/mobile packages but method defined in interface
  @override
  Future<String?> readChar(characteristicUUID) async {
    String? result;
    if (_bleDevice != null && (_bleConnectionStatus == BleConnectionStatus.subscribed || _bleConnectionStatus == BleConnectionStatus.deviceConnected)) {
      BluetoothCharacteristic localChar = _discoveredCharacteristics.firstWhere((element) => element.characteristicUuid == Guid(characteristicUUID));
      List<int> value = await localChar.read();
      // prints raw result in array field [0] is akku level readable
      print('READER: raw results read: $value');
      result = String.fromCharCodes(value);
      // prints string for example device info
      print('READER: formatted results (win service style) read: $result');
    }
    return result;
  }

  void _unSubscribeFromAllChars() async {
    if (_bleConnectionStatus == BleConnectionStatus.subscribed) {
      try {
        //TODO: check how to solve it with blue plus package
        // await WinBle.unSubscribeFromCharacteristic(address: _bleDevice!.address, serviceId: _serviceUuid, characteristicId: _charUuidPostureData);
        _postureDataStream?.cancel();
        // await WinBle.unSubscribeFromCharacteristic(address: _bleDevice!.address, serviceId: _serviceUuid, characteristicId: _charUuidAkkuLevel);
        _akkuDataStream?.cancel();
      } catch (e) {
        _updateBleConnectionStatusStream(BleConnectionStatus.error, 'Error when unsubscribing: $e');
      }
    } else {
      print('Did not unsubscribe as not in subscribed state');
    }
  }

  @override
  void stopScan() async {
    if (_bleConnectionStatus == BleConnectionStatus.scanning) {
      _updateBleConnectionStatusStream(BleConnectionStatus.deviceDisconnected, null);
      FlutterBluePlus.stopScan();
      _scanStream?.cancel();
    }
  }

  @override
  void disconnect() async {
    _unSubscribeFromAllChars();
    try {
      _bleDevice?.disconnect();
      _connectionStream?.cancel();
      _updateBleConnectionStatusStream(BleConnectionStatus.deviceDisconnected, null);
    } catch (e) {
      _updateBleConnectionStatusStream(BleConnectionStatus.error, 'Error Disconnecting Device: $e');
    }
  }

  Uint8List _doubleToBytes(List<double> dataList) {
    final byteData = ByteData(dataList.length * 8); // double = 8 bytes each

    for (int i = 0; i < dataList.length; i++) {
      byteData.setFloat64(i * 8, dataList[i], Endian.little);
    }

    return byteData.buffer.asUint8List();
  }

  @override
  void writeToChar(List<double> dataList) async {
    Uint8List dataTransformed = _doubleToBytes(dataList);
    if (_bleDevice != null && (_bleConnectionStatus == BleConnectionStatus.deviceConnected || _bleConnectionStatus == BleConnectionStatus.subscribed)) {
      try {
        BluetoothCharacteristic localChar = _discoveredCharacteristics.firstWhere((element) => element.characteristicUuid == Guid(_charUuidAppSetter));
        await localChar.write(dataTransformed);
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
  void sendControllerInput(ControllerInput input) async {
    if (_bleDevice == null || (_bleConnectionStatus != BleConnectionStatus.deviceConnected && _bleConnectionStatus != BleConnectionStatus.subscribed)) {
      return; // drop silently when not connected
    }
    if (_isSendingController) return; // drop frames instead of queuing

    _isSendingController = true;
    try {
      BluetoothCharacteristic localChar = _discoveredCharacteristics.firstWhere((element) => element.characteristicUuid == Guid(_charUuidAppSetter));
      await localChar.write(input.toBytes(), withoutResponse: true);
    } catch (e) {
      print('error writing controller payload: $e');
      _updateBleConnectionStatusStream(BleConnectionStatus.error, 'Error writing controller payload: $e');
    } finally {
      _isSendingController = false;
    }
  }

//@override
  void scanForAdvertisingDevice() {
    // listen ...
    // if found -> add to broadcast stream
    //TODO implement the listenable stream as a bus -> first test implementatio of new architecture
  }
}
