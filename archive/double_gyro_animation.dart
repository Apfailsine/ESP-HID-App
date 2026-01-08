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

//     return {
//       'pitch': pitch,
//       'roll': roll,
//       'pitchRAD': pitchRAD,
//       'rollRAD': rollRAD,
//     };
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<BleCubit, BleState>(builder: (context, state) {
//       if (state is BleStateSubscribed) {
//         return Column(
//           children: [
//             DoubleTiltedBarWidget(
//               angle1: calculateTiltAngles(state.latestWearableData?.gyro_2[0] ?? 0, state.latestWearableData?.gyro_2[1] ?? 0,
//                       state.latestWearableData?.gyro_2[2] ?? 0)['pitchRAD'] ??
//                   0,
//               angle2: calculateTiltAngles(state.latestWearableData?.gyro_3[0] ?? 0, state.latestWearableData?.gyro_3[1] ?? 0,
//                       state.latestWearableData?.gyro_3[2] ?? 0)['pitchRAD'] ??
//                   0,
//             ),
//             TiltedBarWidget(
//               angle: calculateTiltAngles(state.latestWearableData?.gyro_3[0] ?? 0, state.latestWearableData?.gyro_3[1] ?? 0,
//                       state.latestWearableData?.gyro_3[2] ?? 0)['pitchRAD'] ??
//                   0,
//             ),
//           ],
//         );
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

// // class DoubleTiltedBarPainter extends CustomPainter {
// //   final double angle1; // Winkel des ersten Balkens
// //   final double angle2; // Winkel des zweiten Balkens

// //   DoubleTiltedBarPainter({required this.angle1, required this.angle2});

// //   @override
// //   void paint(Canvas canvas, Size size) {
// //     Paint paint = Paint()
// //       ..color = Colors.blue
// //       ..style = PaintingStyle.fill;
// //     Paint paint2 = Paint()
// //       ..color = Colors.red
// //       ..style = PaintingStyle.fill;

// //     // Größenangaben
// //     double barWidth = 20;
// //     double barHeight = 150;

// //     // Ursprung: Drehpunkt des ersten Balkens (unten)
// //     double pivotX = size.width / 2;
// //     double pivotY = size.height / 2 + barHeight / 2;

// //     // Ursprung verschieben auf den Drehpunkt des ersten Balkens
// //     canvas.translate(pivotX, pivotY);

// //     // Winkelberechnung für den ersten Balken
// //     double rotationAngle1 = angle1;

// //     // Rotation für den ersten Balken
// //     canvas.rotate(rotationAngle1);

// //     // Erster Balken zeichnen
// //     Rect barRect1 = Rect.fromLTWH(-barWidth / 2, -barHeight, barWidth, barHeight);
// //     canvas.drawRect(barRect1, paint);

// //     // Drehpunkt für den zweiten Balken setzen (oberes Ende des ersten Balkens)
// //     canvas.translate(0, -barHeight);

// //     // Winkelberechnung für den zweiten Balken
// //     double rotationAngle2 = angle2;

// //     // Rotation für den zweiten Balken
// //     canvas.rotate(rotationAngle2);

// //     // Zweiter Balken zeichnen
// //     Rect barRect2 = Rect.fromLTWH(-barWidth / 2, -barHeight / 2, barWidth, barHeight / 2);
// //     canvas.drawRect(barRect2, paint2);
// //   }

// //   @override
// //   bool shouldRepaint(covariant CustomPainter oldDelegate) {
// //     return true;
// //   }
// // }

// class DoubleTiltedBarPainter extends CustomPainter {
//   final double angle1; // Winkel des blauen Balkens
//   final double angle2; // Eigenständiger Winkel des roten Balkens

//   DoubleTiltedBarPainter({
//     required this.angle1,
//     required this.angle2,
//   });

//   @override
//   void paint(Canvas canvas, Size size) {
//     // Farben für die Balken
//     final paintBlue = Paint()..color = Colors.blue;
//     final paintRed = Paint()..color = Colors.red;

//     // Balkengröße
//     final double barWidth = 20;
//     final double barHeight = 150;

//     // Pivot für den blauen Balken (unten in der Mitte)
//     final double pivotX = size.width / 2;
//     final double pivotY = size.height / 2 + barHeight / 2;

//     // 1) Blauen Balken zeichnen
//     canvas.save();

//     // Koordinatensystem an Pivot verschieben
//     canvas.translate(pivotX, pivotY);

//     // Um angle1 drehen
//     canvas.rotate(angle1);

//     // Blauen Balken nach oben zeichnen
//     final Rect blueRect = Rect.fromLTWH(
//       -barWidth / 2, // Mittig um die X-Achse
//       -barHeight, // nach oben
//       barWidth,
//       barHeight,
//     );
//     canvas.drawRect(blueRect, paintBlue);

//     canvas.restore();
//     // => Zurück im globalen Koordinatensystem,
//     //    d. h. Rotation von angle1 wird NICHT mehr weitergereicht.

//     // 2) Globale Position der Balken-Oberkante berechnen
//     //    In lokaler (blau gedrehter) Koordinate wäre das (0, -barHeight).
//     //    Um das in globale Koordinaten zu überführen:
//     final double topX = pivotX + barHeight * sin(angle1);
//     final double topY = pivotY - barHeight * cos(angle1);

//     // 3) Roten Balken an diese globale Position setzen und NUR um angle2 drehen
//     canvas.save();

//     canvas.translate(topX, topY);
//     canvas.rotate(angle2);

//     // Roten Balken zeichnen (z.B. halb so lang)
//     final double redBarHeight = barHeight / 2;
//     final Rect redRect = Rect.fromLTWH(
//       -barWidth / 2, // wieder zentriert
//       -redBarHeight, // nach oben
//       barWidth,
//       redBarHeight,
//     );
//     canvas.drawRect(redRect, paintRed);

//     canvas.restore();
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }
