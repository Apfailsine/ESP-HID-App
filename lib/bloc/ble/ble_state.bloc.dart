part of 'ble_cubit.bloc.dart';

@immutable
sealed class BleState extends Equatable {}

class BleStateDisconnected extends BleState {
  @override
  List<Object?> get props => [];
}

// state while scanning for ble device (as of now it has a preset device name)
class BleStateScanning extends BleState {
  final List<String> foundDevices;
  BleStateScanning(this.foundDevices);

  @override
  List<Object?> get props => [foundDevices];
}

// state only for connection process, almost not relevant as it is super fast or an error occurs
class BleStateConnecting extends BleState {
  BleStateConnecting();

  @override
  List<Object?> get props => [];
}

// wearable device connected, no active subscription on characteristic
class BleStateConnected extends BleState {
  BleStateConnected();

  @override
  List<Object?> get props => [];
}

// wearable device connceted, active subscription on characteristic
class BleStateSubscribed extends BleState {
  final double? minRes1;
  final double? maxRes1;
  final double? minRes2;
  final double? maxRes2;
  final String? deviceInfo;
  final int? akkuLevel;
  BleStateSubscribed(this.minRes1, this.maxRes1, this.minRes2, this.maxRes2, this.deviceInfo, this.akkuLevel);

  @override
  List<Object?> get props => [minRes1, maxRes1, minRes2, maxRes2, deviceInfo, akkuLevel];
}

// state in case any error occurs (while connecting, subscribing, during active connection/subscription)
// idea -> any error means no data is received -> ui cant show data, reconnecting device needs to be done (autmatically or manually)
// this is the reason to combine different error states from ble_service (char-errors & device-connection-erros inside one errorState in cubit (relevant for app logic and ui)
// in development/ for debugging purposes error messages and data can be stored in this state to understand which kind of error occured

class BleStateErrorInterface extends BleState {
  final String errorMessage;
  BleStateErrorInterface(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

class BleStateError extends BleStateErrorInterface {
  BleStateError(super.errorMessage);
}

class BleStateErrorWritingToIotDevice extends BleStateErrorInterface {
  BleStateErrorWritingToIotDevice(super.errorMessage);
}
