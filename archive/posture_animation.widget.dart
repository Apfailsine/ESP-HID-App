import 'package:flutter/material.dart';
import 'dart:math';

import 'package:gamerch_shinyhunter/bloc/ble/ble_cubit.bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PostureAnimationWrapper extends StatefulWidget {
  const PostureAnimationWrapper({
    super.key,
  });

  @override
  State<PostureAnimationWrapper> createState() => _PostureAnimationWrapperState();
}

class _PostureAnimationWrapperState extends State<PostureAnimationWrapper> {
  Map<String, double> calculateTiltAngles(double ax, double ay, double az) {
    double roll = double.parse((atan2(ax, sqrt(ay * ay + az * az)) * (180 / pi)).toStringAsFixed(0));
    double rollRAD = double.parse((atan2(ax, sqrt(ay * ay + az * az))).toStringAsFixed(4));
    double pitch = double.parse((atan2(az, sqrt(ax * ax + ay * ay)) * (180 / pi)).toStringAsFixed(0));
    double pitchRAD = double.parse((atan2(az, sqrt(ax * ax + ay * ay))).toStringAsFixed(4));

    return {
      'pitch': pitch,
      'roll': roll,
      'pitchRAD': pitchRAD,
      'rollRAD': rollRAD,
    };
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BleCubit, BleState>(builder: (context, state) {
      if (state is BleStateSubscribed) {
        return PostureAnimation(
            bodyAngle: calculateTiltAngles(
                    state.latestWearableData?.gyro_1[0] ?? 0, state.latestWearableData?.gyro_1[1] ?? 0, state.latestWearableData?.gyro_1[2] ?? 0)['rollRAD'] ??
                0,
            depthAngle: calculateTiltAngles(
                    state.latestWearableData?.gyro_1[0] ?? 0, state.latestWearableData?.gyro_1[1] ?? 0, state.latestWearableData?.gyro_1[2] ?? 0)['pitchRAD'] ??
                0);
      } else {
        return Container();
      }
    });
  }
}

class PostureAnimation extends StatelessWidget {
  final double bodyAngle;
  final double depthAngle; // Neuer Parameter für die Farbänderung

  const PostureAnimation({super.key, required this.bodyAngle, required this.depthAngle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CustomPaint(
        painter: FigurePainter(bodyAngle: bodyAngle, depthAngle: depthAngle),
        child: const SizedBox(
          width: 200,
          height: 400,
        ),
      ),
    );
  }
}

class FigurePainter extends CustomPainter {
  final double bodyAngle;
  final double depthAngle;

  FigurePainter({required this.bodyAngle, required this.depthAngle});

  @override
  void paint(Canvas canvas, Size size) {
    // Berechne die Farbe basierend auf dem depthAngle
    // Color color = Color.lerp(Colors.green, Colors.red, depthAngle.clamp(0, 1))!;
    Color color;
    if (depthAngle < -0.75) {
      // Bereich 1: Rot zu Orange (negative Werte)
      color = Color.lerp(Colors.red, Colors.orange, (depthAngle + 1.5) / 0.75)!;
    } else if (depthAngle < 0) {
      // Bereich 2: Orange zu Grün (negative bis 0)
      color = Color.lerp(Colors.orange, Colors.green, (depthAngle + 0.75) / 0.75)!;
    } else if (depthAngle <= 0.75) {
      // Bereich 3: Grün zu Orange (positive Werte bis 0.75)
      color = Color.lerp(Colors.green, Colors.orange, depthAngle / 0.75)!;
    } else {
      // Bereich 4: Orange zu Rot (positive Werte über 0.75 bis 1.5)
      color = Color.lerp(Colors.orange, Colors.red, (depthAngle - 0.75) / 0.75)!;
    }

    Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    double centerX = size.width / 2;
    double groundY = size.height - 20;

    // Körpergrößen
    double bodyLength = 120;
    double headRadius = 30;
    double armLength = 70;
    double legLength = 100;
    double bodyWidth = 50;

    // Beinparameter
    double legWidth = 20;
    double legCornerRadius = 10;

    // Beine zeichnen
    RRect leftLeg = RRect.fromRectAndRadius(
      Rect.fromLTWH(centerX - legWidth - 5, groundY - legLength, legWidth, legLength),
      Radius.circular(legCornerRadius),
    );
    canvas.drawRRect(leftLeg, paint);

    RRect rightLeg = RRect.fromRectAndRadius(
      Rect.fromLTWH(centerX + 5, groundY - legLength, legWidth, legLength),
      Radius.circular(legCornerRadius),
    );
    canvas.drawRRect(rightLeg, paint);

    // Ursprung für Rotation setzen (Hüfte)
    canvas.save();
    canvas.translate(centerX, groundY - legLength);

    // Körperrotation anwenden
    canvas.rotate(-bodyAngle);

    // Körper zeichnen
    double bodyCornerRadius = 20;
    RRect body = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        -bodyWidth / 2,
        -bodyLength,
        bodyWidth,
        bodyLength,
      ),
      Radius.circular(bodyCornerRadius),
    );
    canvas.drawRRect(body, paint);

    // Kopf zeichnen
    canvas.drawCircle(Offset(0, -bodyLength - headRadius), headRadius, paint);

    // Arme zeichnen
    double armWidth = 15;
    double armCornerRadius = 7.5;
    double armAngle = -pi / 3;

    // Linker Arm
    canvas.save();
    canvas.translate(-bodyWidth / 2, -bodyLength + armWidth);
    canvas.rotate(armAngle);
    RRect leftArm = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        -armLength,
        -armWidth / 2,
        armLength,
        armWidth,
      ),
      Radius.circular(armCornerRadius),
    );
    canvas.drawRRect(leftArm, paint);
    canvas.restore();

    // Rechter Arm
    canvas.save();
    canvas.translate(bodyWidth / 2, -bodyLength + armWidth);
    canvas.rotate(-armAngle);
    RRect rightArm = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        0,
        -armWidth / 2,
        armLength,
        armWidth,
      ),
      Radius.circular(armCornerRadius),
    );
    canvas.drawRRect(rightArm, paint);
    canvas.restore();

    canvas.restore(); // Rotation des Körpers zurücksetzen
  }

  @override
  bool shouldRepaint(covariant FigurePainter oldDelegate) {
    return oldDelegate.bodyAngle != bodyAngle || oldDelegate.depthAngle != depthAngle;
  }
}
