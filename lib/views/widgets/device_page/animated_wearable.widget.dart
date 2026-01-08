import 'package:flutter/material.dart';

/// Static wearable illustration; previously animated through a frame sequence.
class AnimatedWearable extends StatelessWidget {
  const AnimatedWearable({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/0000.png',
      width: double.infinity,
    );
  }
}
