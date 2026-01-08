import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gamerch_shinyhunter/bloc/ble/ble_cubit.bloc.dart';
import 'package:gamerch_shinyhunter/views/constants/colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math';

class ChartIMU extends StatefulWidget {
  const ChartIMU({
    super.key,
  });

  @override
  State<ChartIMU> createState() => _ChartIMUState();
}

class _ChartIMUState extends State<ChartIMU> with SingleTickerProviderStateMixin {
  final dataPointsChart1 = <FlSpot>[const FlSpot(0, 0)];
  final dataPointsChart2 = <FlSpot>[const FlSpot(0, 0)];
  final dataPointsChart3 = <FlSpot>[const FlSpot(0, 0)];
  final dataPointsChart11 = <FlSpot>[const FlSpot(0, 0)];
  final dataPointsChart22 = <FlSpot>[const FlSpot(0, 0)];
  final dataPointsChart33 = <FlSpot>[const FlSpot(0, 0)];

  List<FlSpot> calculateDatapoints(List<FlSpot> dataPoints, double newDataPoint) {
    if (dataPoints.length == 200) {
      dataPoints.removeAt(0);
    }
    dataPoints.add(FlSpot(dataPoints.length.toDouble(), newDataPoint));
    for (int i = 0; i < dataPoints.length; i++) {
      dataPoints[i] = FlSpot(i.toDouble(), dataPoints[i].y);
    }
    return dataPoints;
  }

  LineChartBarData chartLine(List<FlSpot> points, Color color) {
    return LineChartBarData(
      spots: points,
      dotData: const FlDotData(
        show: false,
      ),
      barWidth: 4,
      isCurved: true,
      color: color,
      preventCurveOverShooting: true,
    );
  }

  LineChartData chartDataChart1(double newDatapoint, double minY, double maxY) {
    return LineChartData(
      minY: minY,
      maxY: maxY,
      minX: 0,
      maxX: 200,
      lineTouchData: const LineTouchData(enabled: false),
      gridData: const FlGridData(
        show: false,
      ),
      lineBarsData: [
        chartLine(calculateDatapoints(dataPointsChart1, newDatapoint), CustomColors.primary),
      ],
      titlesData: const FlTitlesData(
        show: false,
      ),
    );
  }

  LineChartData chartDataChart2(double newDatapoint, double minY, double maxY) {
    return LineChartData(
      minY: minY,
      maxY: maxY,
      minX: 0,
      maxX: 200,
      lineTouchData: const LineTouchData(enabled: false),
      gridData: const FlGridData(
        show: false,
      ),
      lineBarsData: [
        chartLine(calculateDatapoints(dataPointsChart2, newDatapoint), CustomColors.accentSalmon),
      ],
      titlesData: const FlTitlesData(
        show: false,
      ),
    );
  }

  LineChartData chartDataChart3(double newDatapoint, double minY, double maxY) {
    return LineChartData(
      minY: minY,
      maxY: maxY,
      minX: 0,
      maxX: 200,
      lineTouchData: const LineTouchData(enabled: false),
      gridData: const FlGridData(
        show: false,
      ),
      lineBarsData: [
        chartLine(calculateDatapoints(dataPointsChart3, newDatapoint), CustomColors.tertiary),
      ],
      titlesData: const FlTitlesData(
        show: false,
      ),
    );
  }

  LineChartData chartDataChart11(double newDatapoint, double minY, double maxY) {
    return LineChartData(
      minY: minY,
      maxY: maxY,
      minX: 0,
      maxX: 200,
      lineTouchData: const LineTouchData(enabled: false),
      gridData: const FlGridData(
        show: false,
      ),
      lineBarsData: [
        chartLine(calculateDatapoints(dataPointsChart11, newDatapoint), CustomColors.primary),
      ],
      titlesData: const FlTitlesData(
        show: false,
      ),
    );
  }

  LineChartData chartDataChart22(double newDatapoint, double minY, double maxY) {
    return LineChartData(
      minY: minY,
      maxY: maxY,
      minX: 0,
      maxX: 200,
      lineTouchData: const LineTouchData(enabled: false),
      gridData: const FlGridData(
        show: false,
      ),
      lineBarsData: [
        chartLine(calculateDatapoints(dataPointsChart22, newDatapoint), CustomColors.accentSalmon),
      ],
      titlesData: const FlTitlesData(
        show: false,
      ),
    );
  }

  LineChartData chartDataChart33(double newDatapoint, double minY, double maxY) {
    return LineChartData(
      minY: minY,
      maxY: maxY,
      minX: 0,
      maxX: 200,
      lineTouchData: const LineTouchData(enabled: false),
      gridData: const FlGridData(
        show: false,
      ),
      lineBarsData: [
        chartLine(calculateDatapoints(dataPointsChart33, newDatapoint), CustomColors.tertiary),
      ],
      titlesData: const FlTitlesData(
        show: false,
      ),
    );
  }

  Map<String, double> calculateTiltAngles(double ax, double ay, double az) {
    double roll = double.parse((atan2(ax, sqrt(ay * ay + az * az)) * (180 / pi)).toStringAsFixed(0));
    double rollRad = double.parse((atan2(ax, sqrt(ay * ay + az * az))).toStringAsFixed(4));
    double pitch = double.parse((atan2(az, sqrt(ax * ax + ay * ay)) * (180 / pi)).toStringAsFixed(0));
    double pitchRad = double.parse((atan2(az, sqrt(ax * ax + ay * ay))).toStringAsFixed(4));

    return {
      'pitch': pitch,
      'roll': roll,
      'pitch_rad': pitchRad,
      'roll_rad': rollRad,
    };
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BleCubit, BleState>(
      builder: (context, state) {
        if (state is BleStateSubscribed) {
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    children: [
                      Text('L/R: ${state.latestWearableData?.gyro_1[0]}'),
                      const SizedBox(width: 10),
                      Container(
                        width: 20,
                        height: 5,
                        color: CustomColors.primary,
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Row(
                    children: [
                      Text('Bend: ${state.latestWearableData?.gyro_1[1]}'),
                      const SizedBox(width: 10),
                      Container(
                        width: 20,
                        height: 5,
                        color: CustomColors.accentSalmon,
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Row(
                    children: [
                      Text('Third: ${state.latestWearableData?.gyro_1[2]}'),
                      const SizedBox(width: 10),
                      Container(
                        width: 20,
                        height: 5,
                        color: CustomColors.tertiary,
                      ),
                    ],
                  )
                ],
              ),
              Stack(
                children: [
                  SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 0.0, right: 0.0),
                      child: LineChart(chartDataChart1(state.latestWearableData?.gyro_1[0] ?? 0, -20, 20)),
                    ),
                  ),
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 0.0, right: 0.0),
                      child: LineChart(chartDataChart2(state.latestWearableData?.gyro_1[1] ?? 0, -20, 20)),
                    ),
                  ),
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 0.0, right: 0.0),
                      child: LineChart(chartDataChart3(state.latestWearableData?.gyro_1[2] ?? 0, -20, 20)),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    children: [
                      Text('L/R: ${state.latestWearableData?.gyro_2[0]}'),
                      const SizedBox(width: 10),
                      Container(
                        width: 20,
                        height: 5,
                        color: CustomColors.primary,
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Row(
                    children: [
                      Text('Bend: ${state.latestWearableData?.gyro_2[1]}'),
                      const SizedBox(width: 10),
                      Container(
                        width: 20,
                        height: 5,
                        color: CustomColors.accentSalmon,
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Row(
                    children: [
                      Text('Third: ${state.latestWearableData?.gyro_2[2]}'),
                      const SizedBox(width: 10),
                      Container(
                        width: 20,
                        height: 5,
                        color: CustomColors.tertiary,
                      ),
                    ],
                  )
                ],
              ),
              Stack(
                children: [
                  SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 0.0, right: 0.0),
                      child: LineChart(chartDataChart11(state.latestWearableData?.gyro_2[0] ?? 0, -14000, 14000)),
                    ),
                  ),
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 0.0, right: 0.0),
                      child: LineChart(chartDataChart22(state.latestWearableData?.gyro_2[1] ?? 0, -14000, 14000)),
                    ),
                  ),
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 0.0, right: 0.0),
                      child: LineChart(chartDataChart33(state.latestWearableData?.gyro_2[2] ?? 0, -14000, 14000)),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Column(
                    children: [
                      Text('x: ${state.latestWearableData?.gyro_1[0] ?? 0}'),
                      Text('y: ${state.latestWearableData?.gyro_1[1] ?? 0}'),
                      Text('z: ${state.latestWearableData?.gyro_1[2] ?? 0}'),
                      Text('x_g: ${state.latestWearableData?.gyro_1[3] ?? 0}'),
                      Text('y_g: ${state.latestWearableData?.gyro_1[4] ?? 0}'),
                      Text('z_g: ${state.latestWearableData?.gyro_1[5] ?? 0}'),
                      Text(
                          "Pitch: ${calculateTiltAngles(state.latestWearableData?.gyro_1[0] ?? 0, state.latestWearableData?.gyro_1[1] ?? 0, state.latestWearableData?.gyro_1[2] ?? 0)['pitch']}"),
                      Text(
                          "Roll: ${calculateTiltAngles(state.latestWearableData?.gyro_1[0] ?? 0, state.latestWearableData?.gyro_1[1] ?? 0, state.latestWearableData?.gyro_1[2] ?? 0)['roll']}"),
                    ],
                  ),
                  Column(
                    children: [
                      Text('x_g: ${state.latestWearableData?.gyro_2[0] ?? 0}'),
                      Text('y_g: ${state.latestWearableData?.gyro_2[1] ?? 0}'),
                      Text('z_g: ${state.latestWearableData?.gyro_2[2] ?? 0}'),
                      Text('x_gyro: ${state.latestWearableData?.gyro_2[3] ?? 0}'),
                      Text('y_gyro: ${state.latestWearableData?.gyro_2[4] ?? 0}'),
                      Text('z_gyro: ${state.latestWearableData?.gyro_2[5] ?? 0}'),
                      Text(
                          "Pitch: ${calculateTiltAngles(-(state.latestWearableData?.gyro_2[1] ?? 0), state.latestWearableData?.gyro_2[0] ?? 0, state.latestWearableData?.gyro_2[2] ?? 0)['pitch']}"),
                      Text(
                          "Roll: ${calculateTiltAngles(-(state.latestWearableData?.gyro_2[1] ?? 0), state.latestWearableData?.gyro_2[0] ?? 0, state.latestWearableData?.gyro_2[2] ?? 0)['roll']}"),
                    ],
                  ),
                ],
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
