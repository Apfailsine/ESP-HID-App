import 'dart:typed_data';

/// Represents the full input snapshot of the virtual controller.
class ControllerInput {
  final double lx;
  final double ly;
  final double rx;
  final double ry;
  final bool dpadUp;
  final bool dpadDown;
  final bool dpadLeft;
  final bool dpadRight;
  final bool a;
  final bool b;
  final bool x;
  final bool y;
  final bool l;
  final bool r;
  final bool minus;
  final bool plus;
  final bool home;

  const ControllerInput({
    required this.lx,
    required this.ly,
    required this.rx,
    required this.ry,
    required this.dpadUp,
    required this.dpadDown,
    required this.dpadLeft,
    required this.dpadRight,
    required this.a,
    required this.b,
    required this.x,
    required this.y,
    required this.l,
    required this.r,
    required this.minus,
    required this.plus,
    required this.home,
  });

  factory ControllerInput.initial() {
    return const ControllerInput(
      lx: 0,
      ly: 0,
      rx: 0,
      ry: 0,
      dpadUp: false,
      dpadDown: false,
      dpadLeft: false,
      dpadRight: false,
      a: false,
      b: false,
      x: false,
      y: false,
      l: false,
      r: false,
      minus: false,
      plus: false,
      home: false,
    );
  }

  ControllerInput copyWith({
    double? lx,
    double? ly,
    double? rx,
    double? ry,
    bool? dpadUp,
    bool? dpadDown,
    bool? dpadLeft,
    bool? dpadRight,
    bool? a,
    bool? b,
    bool? x,
    bool? y,
    bool? l,
    bool? r,
    bool? minus,
    bool? plus,
    bool? home,
  }) {
    return ControllerInput(
      lx: lx ?? this.lx,
      ly: ly ?? this.ly,
      rx: rx ?? this.rx,
      ry: ry ?? this.ry,
      dpadUp: dpadUp ?? this.dpadUp,
      dpadDown: dpadDown ?? this.dpadDown,
      dpadLeft: dpadLeft ?? this.dpadLeft,
      dpadRight: dpadRight ?? this.dpadRight,
      a: a ?? this.a,
      b: b ?? this.b,
      x: x ?? this.x,
      y: y ?? this.y,
      l: l ?? this.l,
      r: r ?? this.r,
      minus: minus ?? this.minus,
      plus: plus ?? this.plus,
      home: home ?? this.home,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lx': lx,
      'ly': ly,
      'rx': rx,
      'ry': ry,
      'dpadUp': dpadUp,
      'dpadDown': dpadDown,
      'dpadLeft': dpadLeft,
      'dpadRight': dpadRight,
      'a': a,
      'b': b,
      'x': x,
      'y': y,
      'l': l,
      'r': r,
      'minus': minus,
      'plus': plus,
      'home': home,
    };
  }

  String toLogString() {
    return toJson().entries.map((e) => '${e.key}:${e.value}').join(', ');
  }

  Uint8List toBytes() {
    // encode axes as int16 little-endian, buttons as bitmask (uint16)
    final byteData = ByteData(2 * 4 + 2); // 4 axes *2 bytes + 2 bytes buttons = 10 bytes

    int axis(double v) {
      final clamped = v.clamp(-1.0, 1.0);
      return (clamped * 32767).toInt();
    }

    byteData.setInt16(0, axis(lx), Endian.little);
    byteData.setInt16(2, axis(ly), Endian.little);
    byteData.setInt16(4, axis(rx), Endian.little);
    byteData.setInt16(6, axis(ry), Endian.little);

    int buttons = 0;
    void setBit(int bit, bool on) {
      if (on) buttons |= (1 << bit);
    }

    setBit(0, a);
    setBit(1, b);
    setBit(2, x);
    setBit(3, y);
    setBit(4, l);
    setBit(5, r);
    setBit(6, minus);
    setBit(7, plus);
    setBit(8, home);
    setBit(9, dpadUp);
    setBit(10, dpadDown);
    setBit(11, dpadLeft);
    setBit(12, dpadRight);

    byteData.setUint16(8, buttons, Endian.little);

    return byteData.buffer.asUint8List();
  }

  @override
  String toString() => toLogString();

  @override
  bool operator ==(Object other) {
    return other is ControllerInput &&
        other.lx == lx &&
        other.ly == ly &&
        other.rx == rx &&
        other.ry == ry &&
        other.dpadUp == dpadUp &&
        other.dpadDown == dpadDown &&
        other.dpadLeft == dpadLeft &&
        other.dpadRight == dpadRight &&
        other.a == a &&
        other.b == b &&
        other.x == x &&
        other.y == y &&
        other.l == l &&
        other.r == r &&
        other.minus == minus &&
        other.plus == plus &&
        other.home == home;
  }

  @override
  int get hashCode => Object.hashAll([
        lx,
        ly,
        rx,
        ry,
        dpadUp,
        dpadDown,
        dpadLeft,
        dpadRight,
        a,
        b,
        x,
        y,
        l,
        r,
        minus,
        plus,
        home,
      ]);
}
