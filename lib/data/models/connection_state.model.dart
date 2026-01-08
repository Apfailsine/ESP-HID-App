enum BleConnectionStatus { deviceDisconnected, scanning, connecting, deviceConnected, subscribed, error }

class ConnectionState {
  final BleConnectionStatus statusBleConnection;
  final String statusMessage;

  ConnectionState({
    required this.statusBleConnection,
    required this.statusMessage,
  });

  @override
  String toString() {
    return 'status: $statusBleConnection, statusMessage: $statusMessage';
  }
}
