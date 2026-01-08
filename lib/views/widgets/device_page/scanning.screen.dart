import 'package:flutter/material.dart';
import 'package:gamerch_shinyhunter/views/constants/colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamerch_shinyhunter/bloc/ble/ble_cubit.bloc.dart';

class ScanningScreen extends StatefulWidget {
  const ScanningScreen({
    super.key,
  });
  final String title = 'ScanningScreen';

  @override
  State<ScanningScreen> createState() => _ScanningScreenState();
}

class _ScanningScreenState extends State<ScanningScreen> {
  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    return BlocBuilder<BleCubit, BleState>(builder: (context, state) {
      if (state is BleStateScanning) {
        return Scaffold(
          appBar: (isLandscape)
              ? null
              : AppBar(
                  // title: Text(widget.title),
                  backgroundColor: CustomColors.primary,
                ),
          body: Container(
            color: CustomColors.primary,
            padding: const EdgeInsets.fromLTRB(10, 50, 10, 10),
            width: double.infinity,
            height: double.infinity,
            child: ListView(children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 50,
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          // border: Border.all(color: CustomColors.backgroundWhite),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.touch_app,
                              color: CustomColors.onPrimary,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Select GaMerch Device to Connect',
                              style: TextStyle(
                                color: CustomColors.backgroundWhite,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 250,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          // color: CustomColors.backgroundDirtyWhite,
                          color: CustomColors.backgroundWhite.withValues(alpha: 0.85),
                          boxShadow: [
                            BoxShadow(
                              // color: CustomColors.shadowColor,
                              color: CustomColors.shadowBlackTransparent,
                              spreadRadius: 2,
                              blurRadius: 3,
                              offset: const Offset(0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        child: ListView.builder(
                          itemCount: state.foundDevices.length,
                          itemBuilder: (context, index) {
                            final device = state.foundDevices[index];
                            return Column(
                              children: [
                                Material(
                                  color: Colors.transparent, // Make the background transparent
                                  child: InkWell(
                                    highlightColor: CustomColors.primaryHover,
                                    splashColor: CustomColors.primaryHover,
                                    borderRadius: BorderRadius.circular(10), // Match the shape with the ListTile's shape
                                    onTap: () {
                                      context.read<BleCubit>().connectToDevice(device);
                                    },
                                    child: ListTile(
                                      title: Text(device),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  ),
                                ),
                                if (index != state.foundDevices.length - 1)
                                  const Divider(
                                    indent: 10,
                                    endIndent: 10,
                                    height: 5,
                                    thickness: 0.5,
                                  ), // Add Divider except for the last item
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 40,
                        width: 150,
                        decoration: BoxDecoration(
                          color: CustomColors.secondary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: CustomColors.onBackgroundWhite,
                                strokeWidth: 2,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Scanning',
                              style: TextStyle(
                                fontSize: 15,
                                color: CustomColors.onSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      context.read<BleCubit>().stopScanning();
                    },
                    child: const Text('Stop Scanning'),
                  )
                ],
              ),
            ]),
          ),
        );
      } else {
        return Container();
      }
    });
  }
}
