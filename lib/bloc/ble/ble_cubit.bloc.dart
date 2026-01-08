import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gamerch_shinyhunter/data/models/connection_state.model.dart';
import 'package:gamerch_shinyhunter/data/models/controller_input.model.dart';
import 'package:gamerch_shinyhunter/services/ble.abstract.service.dart';
import 'package:meta/meta.dart';

part 'ble_state.bloc.dart';

class BleCubit extends Cubit<BleState> {
  final BleServiceInterface _bleService;
  StreamSubscription<ConnectionState>? _bleStatusSubscription;
  StreamSubscription<String>? _foundDevicesSubscripion;
  BleCubit(this._bleService) : super(BleStateDisconnected()) {
    _listenToBleServiceStatus();
  }

  void scanForDevices() {
    if (state is BleStateScanning) {
      _bleService.stopScan();
    }
    _bleService.scanForDevices();
  }

  void stopScanning() {
    _stopListeningToFoundDevices();
    _bleService.stopScan();
  }

  void connectToDevice(String selectedDevice) {
    _bleService.connectToDevice(selectedDevice);
  }

  void disconnect() {
    _bleService.disconnect();
  }

  void _listenToFoundDevices() {
    _foundDevicesSubscripion?.cancel();
    _foundDevicesSubscripion = _bleService.foundDevicesStream.listen(
      (device) {
        switch (state) {
          case BleStateScanning state:
            if (!state.foundDevices.contains(device)) {
              final updatedDevicesList = [...state.foundDevices, device];
              emit(BleStateScanning(updatedDevicesList));
            }
            break;
          default:
            print('Expected Scanning State, instead in: ${state.runtimeType}');
            break;
        }
      },
    );
  }

  void _stopListeningToFoundDevices() {
    _foundDevicesSubscripion?.cancel();
    emit(BleStateScanning(const []));
  }

  // listen to a stream of status updates implemented in the ble_service
  void _listenToBleServiceStatus() {
    _bleStatusSubscription?.cancel();
    _bleStatusSubscription = _bleService.bleConnectionStatusStream.listen(
      (status) {
        print('status: $status');
        // catch all potential states from ble_service and emit states accordingly
        _convertServiceStatusToState(status);
      },
    );
  }

  // helper method used in _listenToBleServiceStatus
  void _convertServiceStatusToState(ConnectionState status) async {
    switch (status.statusBleConnection) {
      case BleConnectionStatus.deviceDisconnected:
        emit(BleStateDisconnected());
        break;
      case BleConnectionStatus.scanning:
        emit(BleStateScanning(const []));
        _listenToFoundDevices();
        break;
      case BleConnectionStatus.connecting:
        _stopListeningToFoundDevices();
        emit(BleStateConnecting());
        break;
      case BleConnectionStatus.deviceConnected:
        emit(BleStateConnected());
        break;
      case BleConnectionStatus.error:
        emit(BleStateError(status.statusMessage));
        print(status.statusMessage);
        break;
      case BleConnectionStatus.subscribed:
        emit(BleStateSubscribed(null, null, null, null, null, null));
        break;
    }
  }

  void sendControllerInput(ControllerInput input) {
    switch (state) {
      case BleStateConnected _:
      case BleStateSubscribed _:
        _bleService.sendControllerInput(input);
        break;
      default:
        // ignore sends when not connected/subscribed
        break;
    }
  }

}
