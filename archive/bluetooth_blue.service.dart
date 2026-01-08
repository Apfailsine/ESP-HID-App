import 'dart:io';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleCommunicationBlue {
  static BluetoothDevice? globalDevice;

  beforeBleUsage() async {
    if (await FlutterBluePlus.isSupported == false) {
      print('Bluetooth not supported by this device');
      return;
    }
    var subscription = FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
      print(state);
      if (state == BluetoothAdapterState.on) {
      } else {
        print('Error in Bluetooth adapter state');
      }
    });
    if (Platform.isAndroid) {
      await FlutterBluePlus.turnOn();
    }
    subscription.cancel();
  }

  static scan() async {
    var subscription = FlutterBluePlus.onScanResults.listen(
      (results) {
        if (results.isNotEmpty) {
          ScanResult r = results.last;
          print('${r.device.remoteId}: "${r.advertisementData.advName}" found!');
          // connect(r.device);
          if (r.advertisementData.advName == 'StraightUp') {
            connect(r.device);
          }
        }
      },
      onError: (e) => print(e),
    );
    FlutterBluePlus.cancelWhenScanComplete(subscription);
    await FlutterBluePlus.adapterState.where((val) => val == BluetoothAdapterState.on).first;

    await FlutterBluePlus.startScan(
        // withServices: [Guid("180D")],
        withNames: ['StraightUp'],
        timeout: const Duration(seconds: 15));

    await FlutterBluePlus.isScanning.where((val) => val == false).first;
  }

  static connect(BluetoothDevice device) async {
    globalDevice = device;
    await device.connect();
    var subscription = device.connectionState.listen((BluetoothConnectionState state) async {
      if (state == BluetoothConnectionState.disconnected) {
        print('Disconnected!');
        //TODO:
        // 1. typically, start a periodic timer that tries to
        //    reconnect, or just call connect() again right now
        // 2. you must always re-discover services after disconnection!
      }
      if (state == BluetoothConnectionState.connected) {
        print('Connected!');
      }
    });

    device.cancelWhenDisconnected(subscription, delayed: true, next: true);
  }

  static disconnect() async {
    if (globalDevice != null) {
      await globalDevice!.disconnect();
    }
  }

  static readData() async {
    //TODO: use if (_bleDevice != null && _bleConnectionStatus == 'Connected') { as in other service
    // Note: You must call discoverServices after every re-connection!
    List<BluetoothService> services = await globalDevice!.discoverServices();
    services.forEach((service) async {
      // print('service: $service');
      print('service: ${service.serviceUuid}');
      var characteristics = service.characteristics;
      for (BluetoothCharacteristic c in characteristics) {
        print('chars: ${c.characteristicUuid}');
        print((c.characteristicUuid == Guid('fe4edf94-4a29-4819-95ad-7b7e92989510')));
        if (c.characteristicUuid == Guid('fe4edf94-4a29-4819-95ad-7b7e92989510')) {
          await c.setNotifyValue(true);
          print('in if');
          final subscription = c.onValueReceived.listen((value) {
            print('value: $value');
          });
        }
      }
    });

// cleanup: cancel subscription when disconnected
    // globalDevice!.cancelWhenDisconnected(subscription);

// subscribe
// Note: If a characteristic supports both **notifications** and **indications**,
// it will default to **notifications**. This matches how CoreBluetooth works on iOS.
  }
}
