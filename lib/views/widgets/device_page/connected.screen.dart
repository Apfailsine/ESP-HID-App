import 'package:flutter/material.dart';
import 'package:gamerch_shinyhunter/bloc/ble/ble_cubit.bloc.dart';
import 'package:gamerch_shinyhunter/views/constants/colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConnectedScreen extends StatefulWidget {
  const ConnectedScreen({
    super.key,
  });

  @override
  State<ConnectedScreen> createState() => _ConnectedScreenState();
}

class _ConnectedScreenState extends State<ConnectedScreen> {
  Color _containerColor = CustomColors.secondary;
  Color _textColor = CustomColors.secondary;
  double _containerWidth = 150;
  double _containerHeight = 40;

  void _animateContainer() async {
    await Future.delayed(const Duration(milliseconds: 10));
    if (!mounted) return;
    setState(() {
      _containerWidth = 180;
      _containerHeight = 60;
    });

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() {
      _containerColor = CustomColors.success;
      _textColor = CustomColors.onSuccess;
      _containerWidth = 150;
      _containerHeight = 40;
    });
  }

  @override
  void initState() {
    super.initState();
    _animateContainer();
  }

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
                        child: Image.asset(
                          'assets/0000.jpg',
                          width: double.infinity,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: 250,
                        height: 60,
                        child: Center(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 800),
                            curve: Curves.fastOutSlowIn,
                            height: _containerHeight,
                            width: _containerWidth,
                            decoration: BoxDecoration(
                              color: _containerColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: Icon(
                                    color: _textColor,
                                    Icons.bluetooth_connected,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Connected',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: _textColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      context.read<BleCubit>().disconnect();
                    },
                    child: const Text('Disconnect'),
                  )
                ],
              ),
            ])),
      );
    });
  }
}
