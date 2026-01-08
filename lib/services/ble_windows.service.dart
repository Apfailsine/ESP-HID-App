import 'dart:typed_data';

import 'package:gamerch_shinyhunter/data/models/controller_input.model.dart';
import 'package:gamerch_shinyhunter/services/ble.abstract.service.dart';
import 'package:win_ble/win_ble.dart';
import 'package:win_ble/win_file.dart';
import 'dart:async';
import 'package:gamerch_shinyhunter/data/models/connection_state.model.dart';

class BleWindowsService implements BleServiceInterface {
  // init windows ble package
  BleWindowsService() {
    _initPackage();
  }
  // runtime variables for ble connection
  // The 2 Attributes of ConnectionState Dataclass
  BleConnectionStatus _bleConnectionStatus = BleConnectionStatus.deviceDisconnected;
  String _statusMessage = 'no message';

  StreamSubscription? _scanStream;
  BleDevice? _bleDevice;
  List<BleDevice> _discoveredDevicesList = [];
  StreamSubscription? _connectionStream;
  bool _isSendingController = false;

  //TODO check if this place is best to store this data (const environment variables in seperate file?)

  // final String myDeviceName = 'StraightUp';
  final String _serviceUuid = '12345678-1234-5678-1234-56789abcdef0';
  final String _charUuidAppSetter = '12345678-1234-5678-1234-56789abcdef1';
  // Placeholder for future notify/indicate feedback (e.g., rumble)
  // ignore: unused_field
  final String _charUuidRumble = '12345678-1234-5678-1234-56789abcdef2';

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

  void _initPackage() async {
    //TODO: check bluetooth status of device or do it before scan?
    await WinBle.initialize(
      serverPath: await WinServer.path(),
      // enableLog: true,
    );
    _updateBleConnectionStatusStream(BleConnectionStatus.deviceDisconnected, null);
  }

  void disposePackage() async {
    WinBle.dispose();
    _connectionStream?.cancel();
    _scanStream?.cancel();
    await WinBle.disconnect(_bleDevice!.address);
    _updateBleConnectionStatusStream(BleConnectionStatus.deviceDisconnected, null);
  }

  @override
  void scanForDevices() async {
    if (_bleConnectionStatus != BleConnectionStatus.deviceDisconnected) {
      disconnect();
      scanForDevices();
    } else {
      _discoveredDevicesList = [];
      _updateBleConnectionStatusStream(BleConnectionStatus.scanning, null);
      WinBle.startScanning();
      _scanStream = WinBle.scanStream.listen((event) async {
        // print('name: ${event.name}, address: ${event.address}');
        if (event.name.isNotEmpty) {
          _foundDevicesStreamController.add(event.name);
          _discoveredDevicesList.add(event);
        }
      });
    }
  }

  @override
  void connectToDevice(String selectedDevice) async {
    // pick ui-selected device from device list stored here in service
    _bleDevice = _discoveredDevicesList.firstWhere((device) => device.name == selectedDevice);
    print(_bleDevice!.name);
    print(_bleDevice!.address);
    _updateBleConnectionStatusStream(BleConnectionStatus.connecting, null);
    _scanStream?.cancel();

    await WinBle.connect(_bleDevice!.address);
    _updateBleConnectionStatusStream(BleConnectionStatus.deviceConnected, null);
    _connectionStream = WinBle.connectionStreamOf(_bleDevice!.address).listen(
      (event) {
        print('Windows Connection event: $event');
        switch (event) {
          case false:
            _updateBleConnectionStatusStream(BleConnectionStatus.deviceDisconnected, null);
            break;
          case true:
            _updateBleConnectionStatusStream(BleConnectionStatus.deviceConnected, null);
            break;
        }
      },
      onError: (dynamic error) {
        _updateBleConnectionStatusStream(BleConnectionStatus.error, 'Error connecting to device');
      },
    );
  }

// base read char method
  //TODO: consider type checking of characterisitc parameter, cant be assigned to type as different types in win/mobile packages but method defined in interface
  @override
  Future<String?> readChar(characteristicUUID) async {
    String? result;
    if (_bleDevice != null) {
      List<int> data = await WinBle.read(address: _bleDevice!.address, serviceId: _serviceUuid, characteristicId: characteristicUUID);
      result = String.fromCharCodes(data);
      print(result);
    }
    return result;
  }

  // void _subscribeToAkkuDataStream() async {
  //   // cancel old subscription if existing (added timer needed)
  //   await _akkuDataStream?.cancel();
  //   //TODO: no best practice solution yet
  //   await Future.delayed(const Duration(milliseconds: 100));
  //   if (_bleDevice != null && (_bleConnectionStatus == BleConnectionStatus.deviceConnected || _bleConnectionStatus == BleConnectionStatus.subscribed)) {
  //     await WinBle.subscribeToCharacteristic(address: _bleDevice!.address, serviceId: _serviceUuid, characteristicId: _charUuidAkkuLevel);
  //     // _updateBleConnectionStatusStream(BleConnectionStatus.subscribed, null);
  //     _akkuDataStream = WinBle.characteristicValueStream.listen(
  //       (event) {
  //         // print(event['value']);
  //         // print(event['value'][0]);
  //         _akkuDataStreamController.add(event['value'][0]);
  //       },
  //       onError: (dynamic error) {
  //         _updateBleConnectionStatusStream(BleConnectionStatus.error, 'Error reading data from subscription: $error');
  //       },
  //     );
  //   } else {
  //     _updateBleConnectionStatusStream(BleConnectionStatus.error, 'Error subscribing to char Akku(Connection)');
  //   }
  // }


  @override
  void stopScan() async {
    if (_bleConnectionStatus == BleConnectionStatus.scanning) {
      _updateBleConnectionStatusStream(BleConnectionStatus.deviceDisconnected, null);
      WinBle.stopScanning();
      _scanStream?.cancel();
    }
  }

  @override
  void disconnect() async {
    try {
      await WinBle.disconnect(_bleDevice!.address);
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
        await WinBle.write(
            address: _bleDevice!.address, service: _serviceUuid, characteristic: _charUuidAppSetter, data: dataTransformed, writeWithResponse: true);
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
      await WinBle.write(
        address: _bleDevice!.address,
        service: _serviceUuid,
        characteristic: _charUuidAppSetter,
        data: input.toBytes(),
        writeWithResponse: true,
      );
    } catch (e) {
      print('error writing controller payload: $e');
      _updateBleConnectionStatusStream(BleConnectionStatus.error, 'Error writing controller payload: $e');
    } finally {
      _isSendingController = false;
    }
  }
}
