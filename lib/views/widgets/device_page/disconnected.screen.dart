import 'package:flutter/material.dart';
import 'package:gamerch_shinyhunter/bloc/ble/ble_cubit.bloc.dart';
import 'package:gamerch_shinyhunter/views/constants/colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DisconnectedScreen extends StatelessWidget {
  const DisconnectedScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    return BlocBuilder<BleCubit, BleState>(builder: (context, state) {
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
            child: ListView(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 300,
                          width: double.infinity,
                          child: Stack(children: [
                            Image.asset(
                              'assets/0000.jpg',
                              width: double.infinity,
                            ),
                            Center(
                              child: Icon(
                                Icons.block,
                                color: CustomColors.backgroundWhite.withValues(alpha: 0.3),
                                size: 130,
                              ),
                            ),
                          ]),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          // this container
                          height: 40,
                          // width: 220,
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.8,
                          ),
                          decoration: BoxDecoration(
                            color: CustomColors.secondary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(width: 5),
                              const SizedBox(
                                height: 20,
                                width: 20,
                                child: Icon(
                                  Icons.bluetooth_disabled,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'No Device Connected',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: CustomColors.onSecondary,
                                ),
                              ),
                              SizedBox(width: 10),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        context.read<BleCubit>().scanForDevices();
                      },
                      child: const Text('Start Scanning for Devices'),
                    )
                  ],
                ),
              ],
            )),
      );
    });
  }
}
