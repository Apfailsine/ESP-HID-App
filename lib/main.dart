import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:gamerch_shinyhunter/bloc/ble/ble_cubit.bloc.dart';
import 'package:gamerch_shinyhunter/global_bloc_observer.dart';
import 'package:gamerch_shinyhunter/layout.dart';
import 'package:gamerch_shinyhunter/services/ble_blue.service.dart';
import 'package:gamerch_shinyhunter/services/ble_windows.service.dart';
import 'package:gamerch_shinyhunter/views/constants/theme_data.dart';

void main() async {
  // Initialize environment variables
  await dotenv.load(fileName: '.env');

  // Ensure flutter system and platform channels are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set Bloc observer for debugging
  Bloc.observer = const GlobalBlocObserver();

  // Determine platform and configure services
  final isWindows = Platform.isWindows;
  // final isMacOS = Platform.isMacOS;
  // final isAndroid = Platform.isAndroid;
  // final isIOs = Platform.isIOS;

  final bleService = isWindows ? BleWindowsService() : BleServiceBlue();
  // : BleService();


  final blocProviders = [
    BlocProvider<BleCubit>(
      lazy: false,
      create: (context) => BleCubit(bleService),
    ),
  ];

  runApp(
    MultiProvider(
      providers: blocProviders,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GaMerch Shiny Hunter',
      theme: themeData(),
      home: const Layout(),
      debugShowCheckedModeBanner: false,
    );
  }
}
