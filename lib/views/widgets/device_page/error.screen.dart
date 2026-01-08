import 'package:flutter/material.dart';
import 'package:gamerch_shinyhunter/bloc/ble/ble_cubit.bloc.dart';
import 'package:gamerch_shinyhunter/views/constants/colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({
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
            child: ListView(children: [
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
                            'assets/0000.png',
                            width: double.infinity,
                          ),
                          Center(
                            child: Icon(
                              Icons.sensors,
                              color: CustomColors.error.withValues(alpha: 0.6),
                              size: 150,
                            ),
                          ),
                        ]),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 40,
                        width: 100,
                        decoration: BoxDecoration(
                          color: CustomColors.error,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 20,
                              width: 20,
                              child: Icon(
                                Icons.error,
                                color: CustomColors.onError,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Error',
                              style: TextStyle(
                                fontSize: 15,
                                color: CustomColors.onError,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      context.read<BleCubit>().disconnect();
                    },
                    child: const Text('Reset Connection'),
                  )
                ],
              ),
            ])),
      );
    });
  }
}
