// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:gamerch_shinyhunter/bloc/ble/ble_cubit.bloc.dart';
// import 'package:gamerch_shinyhunter/bloc/wearable_settings/wearable_settings_cubit.bloc.dart';
// import 'package:gamerch_shinyhunter/views/constants/colors.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// //TODO: can this be a stateless widget?
// class SMADemo extends StatefulWidget {
//   const SMADemo({
//     super.key,
//   });

//   @override
//   State<SMADemo> createState() => _SMADemoState();
// }

// class _SMADemoState extends State<SMADemo> {
//   final dataPointsChart1 = <FlSpot>[const FlSpot(0, 0)];
//   final dataPointsChart2 = <FlSpot>[const FlSpot(0, 0)];

//   bool disableThresholdButtons = false;
//   bool showButtons = true;

//   // helper method to prevent data points from exceeding the chart boundaries
//   //TODO: check if this is best option
//   double clampValue(double value, double min, double max) {
//     return value.clamp(min, max).toDouble();
//   }

//   List<FlSpot> calculateDatapoints(List<FlSpot> dataPoints, double newDataPoint, double minY, double maxY) {
//     if (dataPoints.length == 200) {
//       dataPoints.removeAt(0);
//     }
//     dataPoints.add(FlSpot(dataPoints.length.toDouble(), clampValue(newDataPoint, minY, maxY)));
//     for (int i = 0; i < dataPoints.length; i++) {
//       dataPoints[i] = FlSpot(i.toDouble(), clampValue(dataPoints[i].y, minY, maxY));
//     }
//     return dataPoints;
//   }

//   // old method to calculate data points before clamping was implemented
//   // List<FlSpot> calculateDatapoints(List<FlSpot> dataPoints, double newDataPoint) {
//   //   if (dataPoints.length == 200) {
//   //     dataPoints.removeAt(0);
//   //   }
//   //   dataPoints.add(FlSpot(dataPoints.length.toDouble(), newDataPoint));
//   //   for (int i = 0; i < dataPoints.length; i++) {
//   //     dataPoints[i] = FlSpot(i.toDouble(), dataPoints[i].y);
//   //   }
//   //   return dataPoints;
//   // }

//   LineChartBarData chartLine(List<FlSpot> points, Color color) {
//     return LineChartBarData(
//       spots: points,
//       dotData: const FlDotData(
//         show: false,
//       ),
//       barWidth: 4,
//       isCurved: true,
//       color: color,
//       preventCurveOverShooting: true,
//     );
//   }

//   LineChartData chartDataChart1(double newDatapoint, double minY, double maxY, double threshold) {
//     return LineChartData(
//       minY: minY,
//       maxY: maxY,
//       minX: 0,
//       maxX: 200,
//       lineTouchData: const LineTouchData(enabled: false),
//       gridData: const FlGridData(
//         show: false,
//       ),
//       extraLinesData: ExtraLinesData(
//         horizontalLines: [
//           HorizontalLine(
//             y: threshold,
//             color: CustomColors.primary,
//             strokeWidth: 2,
//             dashArray: [10, 5], // Für gestrichelte Linien
//             label: HorizontalLineLabel(
//               show: true,
//               labelResolver: (line) => '${line.y}',
//               style: TextStyle(color: CustomColors.primary, fontSize: 12),
//               alignment: Alignment.topRight,
//             ),
//           ),
//         ],
//       ),
//       lineBarsData: [
//         chartLine(calculateDatapoints(dataPointsChart1, newDatapoint, minY, maxY), CustomColors.primary),
//       ],
//       titlesData: const FlTitlesData(
//         show: false,
//       ),
//     );
//   }

//   LineChartData chartDataChart2(double newDatapoint, double minY, double maxY, double threshold) {
//     return LineChartData(
//       minY: minY,
//       maxY: maxY,
//       minX: 0,
//       maxX: 200,
//       lineTouchData: const LineTouchData(enabled: false),
//       gridData: const FlGridData(
//         show: false,
//       ),
//       lineBarsData: [
//         chartLine(calculateDatapoints(dataPointsChart2, newDatapoint, minY, maxY), CustomColors.accentSalmon),
//       ],
//       extraLinesData: ExtraLinesData(
//         horizontalLines: [
//           HorizontalLine(
//             y: threshold,
//             color: CustomColors.accentSalmon,
//             strokeWidth: 2,
//             dashArray: [10, 5], // Für gestrichelte Linien
//             label: HorizontalLineLabel(
//               show: true,
//               labelResolver: (line) => '${line.y}',
//               style: TextStyle(color: CustomColors.accentSalmon, fontSize: 12),
//               alignment: Alignment.topLeft,
//             ),
//           ),
//         ],
//       ),
//       titlesData: const FlTitlesData(
//         show: false,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<BleCubit, BleState>(
//       builder: (context, state) {
//         if (state is BleStateSubscribed) {
//           return BlocBuilder<WearableSettingsCubit, WearableSettingsState>(
//             builder: (wearableSettingsContext, wearableSettingsState) {
//               // Inner BlocBuilder for ThresholdCubit
//               return Container(
//                 padding: const EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                   color: CustomColors.primaryHover,
//                   borderRadius: BorderRadius.circular(5),
//                 ),
//                 child: Column(
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Row(
//                           children: [
//                             const Text('Right Shoulder:'),
//                             // Text('Left: ${state.latestWearableData?.resistance_1}'),
//                             const SizedBox(width: 10),
//                             Container(
//                               width: 40,
//                               height: 5,
//                               color: CustomColors.primary,
//                             ),
//                           ],
//                         ),
//                         const SizedBox(width: 20),
//                         Row(
//                           children: [
//                             const Text('Left Shoulder:'),
//                             // Text('Right: ${state.latestWearableData?.resistance_2}'),
//                             const SizedBox(width: 10),
//                             Container(
//                               width: 40,
//                               height: 5,
//                               color: CustomColors.accentSalmon,
//                             ),
//                           ],
//                         )
//                       ],
//                     ),
//                     const SizedBox(
//                       height: 5,
//                     ),
//                     showButtons
//                         ? Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Container(
//                                 padding: const EdgeInsets.all(3),
//                                 decoration: BoxDecoration(
//                                   color: CustomColors.primary,
//                                   borderRadius: BorderRadius.circular(5),
//                                 ),
//                                 child: Text(
//                                   state.latestWearableData?.resistance_1.toString() ?? '0',
//                                   style: TextStyle(
//                                     color: CustomColors.onPrimary,
//                                   ),
//                                 ),
//                               ),
//                               Container(
//                                 padding: const EdgeInsets.all(3),
//                                 decoration: BoxDecoration(
//                                   color: CustomColors.accentSalmon,
//                                   borderRadius: BorderRadius.circular(5),
//                                 ),
//                                 child: Text(
//                                   state.latestWearableData?.resistance_2.toString() ?? '0',
//                                   style: TextStyle(
//                                     color: CustomColors.onPrimary,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           )
//                         : Container(),
//                     const SizedBox(
//                       height: 5,
//                     ),
//                     Stack(
//                       children: [
//                         SizedBox(
//                           height: 150,
//                           width: double.infinity,
//                           child: Padding(
//                             padding: const EdgeInsets.only(left: 0.0, right: 0.0),
//                             child: LineChart(chartDataChart1(
//                               state.latestWearableData?.resistance_1.toDouble() ?? 0,
//                               state.minRes1 ?? 0.0,
//                               state.maxRes1 ?? 100.0,
//                               wearableSettingsState.smaResThresholdLeft.toDouble(),
//                             )),
//                           ),
//                         ),
//                         Positioned.fill(
//                           child: Padding(
//                             padding: const EdgeInsets.only(left: 0.0, right: 0.0),
//                             child: LineChart(chartDataChart2(
//                               state.latestWearableData?.resistance_2.toDouble() ?? 0,
//                               state.minRes2 ?? 0,
//                               state.maxRes2 ?? 100,
//                               wearableSettingsState.smaResThresholdRight.toDouble(),
//                             )),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 10),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       children: [
//                         GestureDetector(
//                           onTap: () => showButtons = !showButtons,
//                           child: Container(
//                             decoration: BoxDecoration(
//                               color: CustomColors.secondary,
//                               borderRadius: BorderRadius.circular(5),
//                             ),
//                             child: showButtons
//                                 ? Row(
//                                     children: [
//                                       Icon(
//                                         Icons.arrow_drop_down,
//                                         size: 40,
//                                         color: CustomColors.onSecondary,
//                                       ),
//                                       Text(
//                                         'Hide Buttons  ',
//                                         style: TextStyle(color: CustomColors.onSecondary),
//                                       )
//                                     ],
//                                   )
//                                 : Row(
//                                     children: [
//                                       Icon(
//                                         Icons.arrow_right,
//                                         size: 40,
//                                         color: CustomColors.onSecondary,
//                                       ),
//                                       Text(
//                                         'Show Buttons  ',
//                                         style: TextStyle(color: CustomColors.onSecondary),
//                                       )
//                                     ],
//                                   ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     showButtons
//                         ? Column(
//                             children: [
//                               SizedBox(
//                                 height: 5,
//                               ),
//                               TextButton(
//                                 style: ButtonStyle(
//                                   minimumSize: WidgetStateProperty.all<Size>(const Size(double.infinity, 40)),
//                                   textStyle: WidgetStateProperty.all<TextStyle>(const TextStyle(fontSize: 12)),
//                                 ),
//                                 onPressed: () {
//                                   context.read<BleCubit>().resetCalibration();
//                                   dataPointsChart1.clear();
//                                   dataPointsChart2.clear();
//                                 },
//                                 child: const Text('Reset Calibration'),
//                               ),
//                               const SizedBox(height: 10),
//                               SizedBox(
//                                 width: double.infinity,
//                                 child: Row(
//                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Expanded(
//                                       child: TextButton(
//                                         style: ButtonStyle(
//                                           textStyle: WidgetStateProperty.all<TextStyle>(const TextStyle(fontSize: 12)),
//                                         ),
//                                         onPressed: () {
//                                           if (disableThresholdButtons) {
//                                             wearableSettingsContext.read<WearableSettingsCubit>().setReminderMode(1);
//                                           } else {
//                                             wearableSettingsContext.read<WearableSettingsCubit>().setReminderMode(0);
//                                             wearableSettingsContext.read<WearableSettingsCubit>().setSmaResThresholdLeft(-1);
//                                             wearableSettingsContext.read<WearableSettingsCubit>().setSmaResThresholdRight(-1);
//                                           }
//                                           disableThresholdButtons = !disableThresholdButtons;
//                                         },
//                                         child: const Text('Threshold On/Off'),
//                                       ),
//                                     ),
//                                     const SizedBox(
//                                       width: 10,
//                                     ),
//                                     Expanded(
//                                       child: TextButton(
//                                         style: ButtonStyle(
//                                           textStyle: WidgetStateProperty.all<TextStyle>(
//                                             const TextStyle(fontSize: 12),
//                                           ),
//                                           foregroundColor: WidgetStateProperty.resolveWith<Color>(
//                                             (Set<WidgetState> states) {
//                                               if (states.contains(WidgetState.disabled)) {
//                                                 return CustomColors.shadowColor;
//                                               }
//                                               return CustomColors.onBackgroundWhite; // Standardfarbe
//                                             },
//                                           ),
//                                           backgroundColor: WidgetStateProperty.resolveWith<Color?>(
//                                             (Set<WidgetState> states) {
//                                               if (states.contains(WidgetState.disabled)) {
//                                                 return CustomColors.backgroundDirtyWhite;
//                                               }
//                                               return null;
//                                             },
//                                           ),
//                                         ),
//                                         onPressed: disableThresholdButtons
//                                             ? null
//                                             : () {
//                                                 if ((state.maxRes1 != null && state.minRes1 != null) && (state.maxRes2 != null && state.minRes2 != null)) {
//                                                   double autoThreshold = state.minRes1! + ((state.maxRes1! - state.minRes1!) * (1 / 4));
//                                                   double autoThreshold2 = state.minRes2! + ((state.maxRes2! - state.minRes2!) * (1 / 4));
//                                                   wearableSettingsContext.read<WearableSettingsCubit>().setBothResistanceThresholds(
//                                                         autoThreshold.toInt(),
//                                                         autoThreshold2.toInt(),
//                                                       );
//                                                   print(' auto set thresholds-- 1_${autoThreshold.toInt()} 2_${autoThreshold2.toInt()}');
//                                                 }
//                                               },
//                                         child: const Text('Auto set thresholds'),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               const SizedBox(height: 10),
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   TextButton(
//                                     onPressed: () {
//                                       wearableSettingsContext
//                                           .read<WearableSettingsCubit>()
//                                           .setSmaResThresholdLeft(wearableSettingsState.smaResThresholdLeft - 100);
//                                       print('- 100 on th');
//                                     },
//                                     style: ButtonStyle(
//                                       backgroundColor: WidgetStateProperty.all<Color>(CustomColors.primary),
//                                     ),
//                                     child: Text(
//                                       '- 100',
//                                       style: TextStyle(color: CustomColors.onPrimary),
//                                     ),
//                                   ),
//                                   TextButton(
//                                     onPressed: () {
//                                       wearableSettingsContext
//                                           .read<WearableSettingsCubit>()
//                                           .setSmaResThresholdLeft(wearableSettingsState.smaResThresholdLeft + 100);
//                                       print('+ 100 on th');
//                                     },
//                                     style: ButtonStyle(
//                                       backgroundColor: WidgetStateProperty.all<Color>(CustomColors.primary),
//                                     ),
//                                     child: Text(
//                                       '+ 100',
//                                       style: TextStyle(color: CustomColors.onPrimary),
//                                     ),
//                                   ),
//                                   TextButton(
//                                     onPressed: () {
//                                       wearableSettingsContext
//                                           .read<WearableSettingsCubit>()
//                                           .setSmaResThresholdRight(wearableSettingsState.smaResThresholdRight - 100);
//                                     },
//                                     style: ButtonStyle(
//                                       backgroundColor: WidgetStateProperty.all<Color>(CustomColors.accentSalmon),
//                                     ),
//                                     child: Text(
//                                       '- 100',
//                                       style: TextStyle(color: CustomColors.onSecondary),
//                                     ),
//                                   ),
//                                   TextButton(
//                                     onPressed: () {
//                                       wearableSettingsContext
//                                           .read<WearableSettingsCubit>()
//                                           .setSmaResThresholdRight(wearableSettingsState.smaResThresholdRight + 100);
//                                     },
//                                     style: ButtonStyle(
//                                       backgroundColor: WidgetStateProperty.all<Color>(CustomColors.accentSalmon),
//                                     ),
//                                     child: Text(
//                                       '+ 100',
//                                       style: TextStyle(color: CustomColors.onSecondary),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           )
//                         : Container(),
//                   ],
//                 ),
//               );
//             },
//           );
//         } else {
//           return Container();
//         }
//       },
//     );
//   }
// }
