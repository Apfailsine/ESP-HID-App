import 'package:flutter/material.dart';
import 'package:gamerch_shinyhunter/bloc/ble/ble_cubit.bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WearableDemo extends StatefulWidget {
  const WearableDemo({
    super.key,
  });

  @override
  State<WearableDemo> createState() => _WearableDemoState();
}

class _WearableDemoState extends State<WearableDemo> {
  int? inputValue;
  int? inputValue2;
  int inputValueMax = 100;
  int inputValue2Max = 100;
  bool isIncreasing = false;
  bool showDefaultImage = false;

  List<Color> colors = const [
    Color.fromARGB(0, 234, 162, 65),
    Color.fromARGB(30, 234, 162, 65),
    Color.fromARGB(60, 234, 162, 65),
    Color.fromARGB(90, 234, 162, 65),
    Color.fromARGB(120, 234, 161, 65),
    Color.fromARGB(150, 234, 161, 65),
    Color.fromARGB(180, 234, 161, 65),
    Color.fromARGB(210, 234, 161, 65),
  ];

  Color getColor({required int id, required int value, required double start, required double end}) {
    int colorCount = colors.length;
    double range = end - start;
    double part = range / (colorCount - 1);
    if (part == 0) {
      part = 1;
    }
    int index = ((value - start) / part).floor();
    double localT = ((value - start) % part) / part;

    if (index >= (colorCount - 1)) {
      return colors.last;
    } else if (index < 0) {
      return colors.first;
    }

    // Interpolieren der Farbe
    return Color.lerp(colors[index], colors[index + 1], localT)!;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BleCubit, BleState>(
      builder: (context, state) {
        if (state is BleStateSubscribed) {
          return Stack(
            children: [
              Image.asset(
                'assets/Gurt_front_breit_HD_noShadow.png',
              ),
              ClipRect(
                child: Align(
                  alignment: Alignment.topLeft,
                  heightFactor: 0.4,
                  widthFactor: 0.4,
                  child: Image.asset(
                    'assets/Gurt_front_breit_HD_noShadow.png',
                    color: getColor(
                      id: 1,
                      value: state.latestWearableData?.resistance_1.toInt() ?? 0,
                      start: state.minRes1 ?? 0,
                      end: state.maxRes1 ?? 100,
                    ),
                  ),
                ),
              ),
              Transform.translate(
                offset: Offset(MediaQuery.of(context).size.width - MediaQuery.of(context).size.width * 0.46, 0.0),
                child: ClipRect(
                  child: Align(
                    alignment: Alignment.topRight,
                    heightFactor: 0.4,
                    widthFactor: 0.4,
                    child: Image.asset(
                      'assets/Gurt_front_breit_HD_noShadow.png',
                      color: getColor(
                        id: 2,
                        value: state.latestWearableData?.resistance_2.toInt() ?? 0,
                        start: state.minRes2 ?? 0,
                        end: state.maxRes2 ?? 100,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        } else {
          return Container();
        }
      },
    );
  }
}
