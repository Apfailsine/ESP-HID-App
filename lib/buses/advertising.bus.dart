import 'dart:async';

class Advertising {
  Advertising();

  //TODO: specify the type of the stream
  final _streamController = StreamController<dynamic>();

  Stream<dynamic> get stream => _streamController.stream; //getter for external acces on stream

  void publish(dynamic event) => _streamController.add(event);

  //DEV: when to use dispose
  void disposeStream() {
    _streamController.close();
  }
}
