import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamerch_shinyhunter/bloc/ble/ble_cubit.bloc.dart';
import 'package:gamerch_shinyhunter/data/models/controller_input.model.dart';
import 'package:gamerch_shinyhunter/views/constants/colors.dart';

class ControllerPage extends StatefulWidget {
  const ControllerPage({super.key});

  @override
  State<ControllerPage> createState() => _ControllerPageState();
}

class _ControllerPageState extends State<ControllerPage> {
  ControllerInput _input = ControllerInput.initial();
  Timer? _sendTimer;

  // Tunable layout spacings
  final double columnTopPadding = 0;
  final double columnSpacing = 16;
  final double rowSpacing = 12;
  final double dpadHorizontalGap = 48;
  final double middleColumnWidth = 400;
  final Duration sendInterval = const Duration(milliseconds: 20); // debug: 1 Hz

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _sendTimer = Timer.periodic(sendInterval, (_) => _dispatchControllerState());
  }

  void _updateState(ControllerInput Function(ControllerInput) apply) {
    setState(() {
      _input = apply(_input);
    });
    // debugPrint('[controller] ${_input.toLogString()}');
  }

  void _setButton(String button, bool pressed) {
    switch (button) {
      case 'minus':
        _updateState((s) => s.copyWith(minus: pressed));
        break;
      case 'plus':
        _updateState((s) => s.copyWith(plus: pressed));
        break;
      case 'home':
        _updateState((s) => s.copyWith(home: pressed));
        break;
      case 'l':
        _updateState((s) => s.copyWith(l: pressed));
        break;
      case 'r':
        _updateState((s) => s.copyWith(r: pressed));
        break;
      case 'a':
        _updateState((s) => s.copyWith(a: pressed));
        break;
      case 'b':
        _updateState((s) => s.copyWith(b: pressed));
        break;
      case 'x':
        _updateState((s) => s.copyWith(x: pressed));
        break;
      case 'y':
        _updateState((s) => s.copyWith(y: pressed));
        break;
      case 'dpadUp':
        _updateState((s) => s.copyWith(dpadUp: pressed));
        break;
      case 'dpadDown':
        _updateState((s) => s.copyWith(dpadDown: pressed));
        break;
      case 'dpadLeft':
        _updateState((s) => s.copyWith(dpadLeft: pressed));
        break;
      case 'dpadRight':
        _updateState((s) => s.copyWith(dpadRight: pressed));
        break;
    }
  }

  void _onLeftStick(Offset offset) {
    _updateState((s) => s.copyWith(lx: offset.dx, ly: offset.dy));
  }

  void _onRightStick(Offset offset) {
    _updateState((s) => s.copyWith(rx: offset.dx, ry: offset.dy));
  }

  void _dispatchControllerState() {
    if (!mounted) return;
    final payload = _input.toBytes();
    debugPrint('[send-bytes] ${payload.toList()}');
    context.read<BleCubit>().sendControllerInput(_input);
  }

  @override
  void dispose() {
    _sendTimer?.cancel();
    // Restore broader orientation support when leaving controller view.
    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    return Scaffold(
      body: Padding(
        padding: isLandscape ? const EdgeInsets.all(16) : const EdgeInsets.fromLTRB(12, 12, 12, 24),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildLeftColumn()),
                const SizedBox(width: 12),
                SizedBox(width: middleColumnWidth, child: _buildCenterColumn()),
                const SizedBox(width: 12),
                Expanded(child: _buildRightColumn()),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLeftColumn() {
    return Padding(
      padding: EdgeInsets.only(top: columnTopPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ControllerButton(
            label: 'L',
            onChanged: (pressed) => _setButton('l', pressed),
            shape: BoxShape.rectangle,
            width: 140/2,
            height: 44/2,
          ),
          SizedBox(height: 56/2),
          JoystickPad(
            onChanged: _onLeftStick,
            baseColor: CustomColors.backgroundWhite,
            knobColor: CustomColors.secondary,
          ),
          SizedBox(height: 64/2),
          DPad(
            onUp: (p) => _setButton('dpadUp', p),
            onDown: (p) => _setButton('dpadDown', p),
            onLeft: (p) => _setButton('dpadLeft', p),
            onRight: (p) => _setButton('dpadRight', p),
            horizontalGap: dpadHorizontalGap/2,
          ),
        ],
      ),
    );
  }

  Widget _buildCenterColumn() {
    return Padding(
      padding: EdgeInsets.only(top: 128/2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ControllerButton(label: '-', onChanged: (p) => _setButton('minus', p), size: 52, shape: BoxShape.rectangle),
              SizedBox(width: 128),
              ControllerButton(label: '+', onChanged: (p) => _setButton('plus', p), size: 52, shape: BoxShape.rectangle),
            ],
          ),
          SizedBox(height: 64),
          ControllerButton(
            label: 'Home',
            onChanged: (pressed) => _setButton('home', pressed),
            width: 90,
            height: 52,
            shape: BoxShape.rectangle,
          ),
        ],
      ),
    );
  }

  Widget _buildRightColumn() {
    return Padding(
      padding: EdgeInsets.only(top: columnTopPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ControllerButton(
            label: 'R',
            onChanged: (p) => _setButton('r', p),
            shape: BoxShape.rectangle,
            width: 140,
            height: 44,
          ),
          SizedBox(height: 32),
          ControllerButton(label: 'X', onChanged: (p) => _setButton('x', p)),
          SizedBox(height: 0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ControllerButton(label: 'Y', onChanged: (p) => _setButton('y', p)),
              SizedBox(width: 64),
              ControllerButton(label: 'A', onChanged: (p) => _setButton('a', p)),
            ],
          ),
          SizedBox(height: 0),
          ControllerButton(label: 'B', onChanged: (p) => _setButton('b', p)),
          SizedBox(height: 64),
          JoystickPad(
            onChanged: _onRightStick,
            baseColor: CustomColors.backgroundWhite,
            knobColor: CustomColors.secondary,
          ),
        ],
      ),
    );
  }
}

class ControllerButton extends StatefulWidget {
  const ControllerButton({
    super.key,
    required this.label,
    required this.onChanged,
    this.size = 56,
    this.shape = BoxShape.circle,
    this.width,
    this.height,
  });

  final String label;
  final ValueChanged<bool> onChanged;
  final double size;
  final BoxShape shape;
  final double? width;
  final double? height;

  @override
  State<ControllerButton> createState() => _ControllerButtonState();
}

class _ControllerButtonState extends State<ControllerButton> {
  bool _pressed = false;

  void _update(bool pressed) {
    if (_pressed == pressed) return;
    setState(() {
      _pressed = pressed;
    });
    widget.onChanged(pressed);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _update(true),
      onTapUp: (_) => _update(false),
      onTapCancel: () => _update(false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: widget.width ?? widget.size,
        height: widget.height ?? widget.size,
        decoration: BoxDecoration(
          color: _pressed ? CustomColors.secondary : CustomColors.backgroundWhite,
          shape: widget.shape,
          borderRadius: widget.shape == BoxShape.rectangle ? BorderRadius.circular(8) : null,
          border: Border.all(color: CustomColors.onBackgroundWhite, width: 2),
          boxShadow: [
            BoxShadow(
              color: CustomColors.shadowColor,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          widget.label,
          style: TextStyle(
            color: CustomColors.onSecondary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class DPad extends StatelessWidget {
  const DPad({
    super.key,
    required this.onUp,
    required this.onDown,
    required this.onLeft,
    required this.onRight,
    this.horizontalGap = 32,
    this.buttonSize = 56,
  });

  final ValueChanged<bool> onUp;
  final ValueChanged<bool> onDown;
  final ValueChanged<bool> onLeft;
  final ValueChanged<bool> onRight;
  final double horizontalGap;
  final double buttonSize;

  @override
  Widget build(BuildContext context) {
    final double totalWidth = buttonSize * 2 + horizontalGap + 16; // small extra padding for balance
    return SizedBox(
      width: totalWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ControllerButton(label: '^', onChanged: onUp, size: buttonSize, shape: BoxShape.rectangle),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ControllerButton(label: '<', onChanged: onLeft, size: buttonSize, shape: BoxShape.rectangle),
              SizedBox(width: horizontalGap),
              ControllerButton(label: '>', onChanged: onRight, size: buttonSize, shape: BoxShape.rectangle),
            ],
          ),
          ControllerButton(label: 'v', onChanged: onDown, size: buttonSize, shape: BoxShape.rectangle),
        ],
      ),
    );
  }
}

class JoystickPad extends StatefulWidget {
  const JoystickPad({
    super.key,
    required this.onChanged,
    this.radius = 70,
    this.knobRadius = 26,
    this.baseColor = Colors.white,
    this.knobColor = Colors.grey,
  });

  final ValueChanged<Offset> onChanged;
  final double radius;
  final double knobRadius;
  final Color baseColor;
  final Color knobColor;

  @override
  State<JoystickPad> createState() => _JoystickPadState();
}

class _JoystickPadState extends State<JoystickPad> {
  Offset _offset = Offset.zero;

  void _updateOffset(Offset localPosition) {
    final center = Offset(widget.radius, widget.radius);
    final delta = localPosition - center;
    final distance = delta.distance;
    final maxDistance = widget.radius - widget.knobRadius;

    Offset clamped = delta;
    if (distance > maxDistance && distance != 0) {
      clamped = Offset(delta.dx / distance * maxDistance, delta.dy / distance * maxDistance);
    }

    final normalized = Offset(clamped.dx / maxDistance, clamped.dy / maxDistance);

    setState(() {
      _offset = clamped;
    });
    widget.onChanged(normalized);
  }

  void _reset() {
    setState(() {
      _offset = Offset.zero;
    });
    widget.onChanged(Offset.zero);
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.radius * 2;
    return GestureDetector(
      onPanStart: (details) => _updateOffset(details.localPosition),
      onPanUpdate: (details) => _updateOffset(details.localPosition),
      onPanEnd: (_) => _reset(),
      onPanCancel: _reset,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.baseColor,
                border: Border.all(color: CustomColors.onBackgroundWhite, width: 3),
              ),
            ),
            Positioned(
              left: widget.radius + _offset.dx - widget.knobRadius,
              top: widget.radius + _offset.dy - widget.knobRadius,
              child: Container(
                width: widget.knobRadius * 2,
                height: widget.knobRadius * 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.knobColor,
                  boxShadow: [
                    BoxShadow(
                      color: CustomColors.shadowColor,
                      blurRadius: 3,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

