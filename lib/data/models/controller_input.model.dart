import 'dart:typed_data';

/// Represents the full input snapshot of the virtual controller.
class ControllerInput {
  final double lx;
  final double ly;
  final double rx;
  final double ry;
  final double l2;
  final double r2;
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
  final bool zl;
  final bool zr;
  final bool l3;
  final bool r3;
  final bool minus;
  final bool plus;
  final bool home;
  final bool capture;

  const ControllerInput({
    required this.lx,
    required this.ly,
    required this.rx,
    required this.ry,
    required this.l2,
    required this.r2,
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
    required this.zl,
    required this.zr,
    required this.l3,
    required this.r3,
    required this.minus,
    required this.plus,
    required this.home,
    required this.capture,
  });

  factory ControllerInput.initial() {
    return const ControllerInput(
      lx: 0,
      ly: 0,
      rx: 0,
      ry: 0,
      l2: 0,
      r2: 0,
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
      zl: false,
      zr: false,
      l3: false,
      r3: false,
      minus: false,
      plus: false,
      home: false,
      capture: false,
    );
  }

  ControllerInput copyWith({
    double? lx,
    double? ly,
    double? rx,
    double? ry,
    double? l2,
    double? r2,
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
    bool? zl,
    bool? zr,
    bool? l3,
    bool? r3,
    bool? minus,
    bool? plus,
    bool? home,
    bool? capture,
  }) {
    return ControllerInput(
      lx: lx ?? this.lx,
      ly: ly ?? this.ly,
      rx: rx ?? this.rx,
      ry: ry ?? this.ry,
      l2: l2 ?? this.l2,
      r2: r2 ?? this.r2,
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
      zl: zl ?? this.zl,
      zr: zr ?? this.zr,
      l3: l3 ?? this.l3,
      r3: r3 ?? this.r3,
      minus: minus ?? this.minus,
      plus: plus ?? this.plus,
      home: home ?? this.home,
      capture: capture ?? this.capture,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lx': lx,
      'ly': ly,
      'rx': rx,
      'ry': ry,
      'l2': l2,
      'r2': r2,
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
      'zl': zl,
      'zr': zr,
      'l3': l3,
      'r3': r3,
      'minus': minus,
      'plus': plus,
      'home': home,
      'capture': capture,
    };
  }

  String toLogString() {
    return toJson().entries.map((e) => '${e.key}:${e.value}').join(', ');
  }

  Uint8List toBytes() {
    // encode axes as int16 little-endian, triggers as uint16, buttons as bitmask (uint32)
    final byteData = ByteData(16); // 4 axes *2 + 2 triggers *2 + 4 bytes buttons = 16 bytes

    int axis(double v) {
      final clamped = v.clamp(-1.0, 1.0);
      return (clamped * 32767).toInt();
    }

    byteData.setInt16(0, axis(lx), Endian.little);
    byteData.setInt16(2, axis(ly), Endian.little);
    byteData.setInt16(4, axis(rx), Endian.little);
    byteData.setInt16(6, axis(ry), Endian.little);

    int trigger(double v) {
      final clamped = v.clamp(0.0, 1.0);
      return (clamped * 65535).toInt();
    }

    byteData.setUint16(8, trigger(l2), Endian.little);
    byteData.setUint16(10, trigger(r2), Endian.little);

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
    setBit(6, zl);
    setBit(7, zr);
    setBit(8, l3);
    setBit(9, r3);
    setBit(10, dpadUp);
    setBit(11, dpadDown);
    setBit(12, dpadLeft);
    setBit(13, dpadRight);
    setBit(14, home);
    setBit(15, capture);
    setBit(16, plus);
    setBit(17, minus);

    byteData.setUint32(12, buttons, Endian.little);

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
          other.l2 == l2 &&
          other.r2 == r2 &&
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
          other.zl == zl &&
          other.zr == zr &&
          other.l3 == l3 &&
          other.r3 == r3 &&
          other.minus == minus &&
          other.plus == plus &&
          other.home == home &&
          other.capture == capture;
  }

  @override
  int get hashCode => Object.hashAll([
        lx,
        ly,
        rx,
        ry,
        l2,
        r2,
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
        zl,
        zr,
        l3,
        r3,
        minus,
        plus,
        home,
        capture,
      ]);
}
