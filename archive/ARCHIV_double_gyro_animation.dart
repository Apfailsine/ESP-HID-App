// import 'package:flutter/material.dart';
// import 'dart:math';
// import 'package:gamerch_shinyhunter/bloc/ble/ble_cubit.bloc.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// class DoubleGyroAnimationWrapper extends StatefulWidget {
//   const DoubleGyroAnimationWrapper({
//     super.key,
//   });

//   @override
//   State<DoubleGyroAnimationWrapper> createState() => _DoubleGyroAnimationWrapperState();
// }

// class _DoubleGyroAnimationWrapperState extends State<DoubleGyroAnimationWrapper> {
//   Map<String, double> calculateTiltAngles(double ax, double ay, double az) {
//     double roll = double.parse((atan2(ax, sqrt(ay * ay + az * az)) * (180 / pi)).toStringAsFixed(0));
//     double rollRAD = double.parse((atan2(ax, sqrt(ay * ay + az * az))).toStringAsFixed(4));
//     double pitch = double.parse((atan2(az, sqrt(ax * ax + ay * ay)) * (180 / pi)).toStringAsFixed(0));
//     double pitchRAD = double.parse((atan2(az, sqrt(ax * ax + ay * ay))).toStringAsFixed(4));
//     if (ay < 0) {
//       pitch = 180 - pitch;
//       pitchRAD = pi - pitchRAD;
//     }
//     return {
//       'pitch': pitch,
//       'roll': roll,
//       'pitchRAD': pitchRAD,
//       'rollRAD': rollRAD,
//     };
//   }

//   double calculateSecondaryTiltAngle(angle1, angle2) {
//     return (angle2 - angle1).abs();
//     if (angle2 > 0) {
//       return (angle2 - angle1).abs();
//     } else {
//       return -(angle2 - angle1).abs();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<BleCubit, BleState>(builder: (context, state) {
//       if (state is BleStateSubscribed) {
//         print(calculateTiltAngles(
//                 state.latestWearableData?.gyro_2[0] ?? 0, state.latestWearableData?.gyro_2[1] ?? 0, state.latestWearableData?.gyro_2[2] ?? 0)['pitchRAD'] ??
//             0);
//         return Column(
//           children: [
//             Text(
//                 "pitch unten${calculateTiltAngles(state.latestWearableData?.gyro_2[0] ?? 0, state.latestWearableData?.gyro_2[1] ?? 0, state.latestWearableData?.gyro_2[2] ?? 0)['pitch'] ?? 0}"),
//             Text(
//                 "pitch unten rad${calculateTiltAngles(state.latestWearableData?.gyro_2[0] ?? 0, state.latestWearableData?.gyro_2[1] ?? 0, state.latestWearableData?.gyro_2[2] ?? 0)['pitchRAD'] ?? 0}"),
//             Text("y als ref${state.latestWearableData?.gyro_2[1] ?? 0}"),
//             Text("-------------------"),
//             Text(
//                 "pitch oben${calculateTiltAngles(state.latestWearableData?.gyro_3[0] ?? 0, state.latestWearableData?.gyro_3[1] ?? 0, state.latestWearableData?.gyro_3[2] ?? 0)['pitch'] ?? 0}"),
//             Text(
//                 "pitch oben rad${calculateTiltAngles(state.latestWearableData?.gyro_3[0] ?? 0, state.latestWearableData?.gyro_3[1] ?? 0, state.latestWearableData?.gyro_3[2] ?? 0)['pitchRAD'] ?? 0}"),
//             Text("y als ref${state.latestWearableData?.gyro_3[1] ?? 0}"),
//             Text("-------------------"),
//             Text(
//               "abs delta${calculateSecondaryTiltAngle(calculateTiltAngles(
//                     state.latestWearableData?.gyro_2[0] ?? 0,
//                     state.latestWearableData?.gyro_2[1] ?? 0,
//                     state.latestWearableData?.gyro_2[2] ?? 0,
//                   )['pitchRAD'] ?? 0, calculateTiltAngles(
//                     state.latestWearableData?.gyro_3[0] ?? 0,
//                     state.latestWearableData?.gyro_3[1] ?? 0,
//                     state.latestWearableData?.gyro_3[2] ?? 0,
//                   )['pitchRAD'] ?? 0)}",
//             ),
//             DoubleTiltedBarWidget(
//               angle1: calculateTiltAngles(state.latestWearableData?.gyro_2[0] ?? 0, state.latestWearableData?.gyro_2[1] ?? 0,
//                       state.latestWearableData?.gyro_2[2] ?? 0)['pitchRAD'] ??
//                   0,
//               angle2: calculateSecondaryTiltAngle(
//                   calculateTiltAngles(
//                         state.latestWearableData?.gyro_2[0] ?? 0,
//                         state.latestWearableData?.gyro_2[1] ?? 0,
//                         state.latestWearableData?.gyro_2[2] ?? 0,
//                       )['pitchRAD'] ??
//                       0,
//                   calculateTiltAngles(
//                         state.latestWearableData?.gyro_3[0] ?? 0,
//                         state.latestWearableData?.gyro_3[1] ?? 0,
//                         state.latestWearableData?.gyro_3[2] ?? 0,
//                       )['pitchRAD'] ??
//                       0),
//             ),
//           ],
//         );
//         // return TiltedBarWidget(
//         //   angle: calculateTiltAngles(state.latestWearableData?.gyro_2[0] ?? 0, state.latestWearableData?.gyro_2[1] ?? 0,
//         //           state.latestWearableData?.gyro_2[2] ?? 0)['pitchRAD'] ??
//         //       0,
//         // );
//       } else {
//         return Container();
//       }
//     });
//   }
// }

// class TiltedBarWidget extends StatelessWidget {
//   final double angle; // Neigungswinkel von -1.5 (rechts) bis 1.5 (links)

//   const TiltedBarWidget({super.key, required this.angle});

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: CustomPaint(
//         painter: TiltedBarPainter(angle: angle),
//         child: const SizedBox(
//           width: 200,
//           height: 200,
//         ),
//       ),
//     );
//   }
// }

// class TiltedBarPainter extends CustomPainter {
//   final double angle; // Neigungswinkel von -1.5 bis 1.5

//   TiltedBarPainter({required this.angle});

//   @override
//   void paint(Canvas canvas, Size size) {
//     Paint paint = Paint()
//       ..color = Colors.blue
//       ..style = PaintingStyle.fill;

//     // Ursprüngliche Breite und Höhe des Balkens
//     double barWidth = 20;
//     double barHeight = 150;

//     // Drehpunkt: Untere Mitte des Balkens
//     double pivotX = size.width / 2;
//     double pivotY = size.height / 2 + barHeight / 2;

//     // Ursprung auf den Drehpunkt verschieben
//     canvas.translate(pivotX, pivotY);

//     // Winkelberechnung: Skalierung des Eingabewerts (-1.5 bis 1.5) auf -π/4 bis π/4 (±45°)
//     double rotationAngle = angle;

//     // Rotation anwenden
//     canvas.rotate(rotationAngle);

//     // Balken zeichnen: Vom Drehpunkt ausgehend nach oben
//     Rect barRect = Rect.fromLTWH(-barWidth / 2, -barHeight, barWidth, barHeight);
//     canvas.drawRect(barRect, paint);
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     return true; // Der Painter wird immer neu gezeichnet, da das Widget Stateless ist
//   }
// }

// class DoubleTiltedBarWidget extends StatelessWidget {
//   final double angle1; // Winkel des ersten Balkens (unterer Balken)
//   final double angle2; // Winkel des zweiten Balkens (oberer Balken)

//   const DoubleTiltedBarWidget({
//     super.key,
//     required this.angle1,
//     required this.angle2,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: CustomPaint(
//         painter: DoubleTiltedBarPainter(angle1: angle1, angle2: angle2),
//         child: const SizedBox(
//           width: 400,
//           height: 400,
//         ),
//       ),
//     );
//   }
// }

// class DoubleTiltedBarPainter extends CustomPainter {
//   final double angle1; // Winkel des ersten Balkens
//   final double angle2; // Winkel des zweiten Balkens

//   DoubleTiltedBarPainter({required this.angle1, required this.angle2});

//   @override
//   void paint(Canvas canvas, Size size) {
//     Paint paint = Paint()
//       ..color = Colors.blue
//       ..style = PaintingStyle.fill;
//     Paint paint2 = Paint()
//       ..color = Colors.red
//       ..style = PaintingStyle.fill;

//     // Größenangaben
//     double barWidth = 20;
//     double barHeight = 150;

//     // Ursprung: Drehpunkt des ersten Balkens (unten)
//     double pivotX = size.width / 2;
//     double pivotY = size.height / 2 + barHeight / 2;

//     // Ursprung verschieben auf den Drehpunkt des ersten Balkens
//     canvas.translate(pivotX, pivotY);

//     // Winkelberechnung für den ersten Balken
//     double rotationAngle1 = angle1;

//     // Rotation für den ersten Balken
//     canvas.rotate(rotationAngle1);

//     // Erster Balken zeichnen
//     Rect barRect1 = Rect.fromLTWH(-barWidth / 2, -barHeight, barWidth, barHeight);
//     canvas.drawRect(barRect1, paint);

//     // Drehpunkt für den zweiten Balken setzen (oberes Ende des ersten Balkens)
//     canvas.translate(0, -barHeight);

//     // Winkelberechnung für den zweiten Balken
//     double rotationAngle2 = angle2;

//     // Rotation für den zweiten Balken
//     canvas.rotate(rotationAngle2);

//     // Zweiter Balken zeichnen
//     Rect barRect2 = Rect.fromLTWH(-barWidth / 2, -barHeight / 2, barWidth, barHeight / 2);
//     canvas.drawRect(barRect2, paint2);
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     return true; // Der Painter wird immer neu gezeichnet, da die Winkel sich ändern können
//   }
// }
