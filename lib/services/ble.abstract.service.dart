import 'package:gamerch_shinyhunter/data/models/connection_state.model.dart';
import 'package:gamerch_shinyhunter/data/models/controller_input.model.dart';
import 'dart:async';

abstract class BleServiceInterface {
  Stream<ConnectionState> get bleConnectionStatusStream;
  Stream<List<double>> get receiveMeasurementDataStream;
  Stream<String> get foundDevicesStream;
  Stream<int> get akkuDataStream;
  List<double> convertIntArrayToDouble(List<int> intData);
  void scanForDevices();
  void connectToDevice(String selectedDevice);
  void stopScan();
  void disconnect();
  void writeToChar(List<double> data);
  void sendControllerInput(ControllerInput input);
  Future<String?> readChar(characteristic);
}

//TODO: only implement methods that are used externally, others can be private with _methodName
