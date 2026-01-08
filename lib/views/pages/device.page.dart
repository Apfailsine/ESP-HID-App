import 'package:flutter/material.dart';
import 'package:gamerch_shinyhunter/bloc/ble/ble_cubit.bloc.dart';
import 'package:gamerch_shinyhunter/views/widgets/device_page/_device_page_widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DevicePage extends StatefulWidget {
  const DevicePage({super.key});

  final String title = 'DevicePage';

  @override
  State<DevicePage> createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BleCubit, BleState>(
      builder: (context, state) {
        if (state is BleStateDisconnected) {
          return const DisconnectedScreen();
        }
        if (state is BleStateScanning) {
          return const ScanningScreen();
        }
        if (state is BleStateConnecting) {
          return const ConnectingScreen();
        }
        if (state is BleStateConnected || state is BleStateSubscribed || state is BleStateErrorWritingToIotDevice) {
          return const ConnectedScreen();
        }
        if (state is BleStateError) {
          return const ErrorScreen();
        } else {
          return Center(child: Text('Unknown state: $state'));
        }
      },
    );
  }
}
