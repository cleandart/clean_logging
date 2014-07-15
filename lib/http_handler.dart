library clean_logging.http_handler.dart;

import 'dart:async';

abstract class HttpHandler {

  final Function send;
  final Function encode;
  bool _running = false;
  final _queue = [];

  HttpHandler.config(String this.encode(Map), Future this.send(String));

  handleData(data) {
    _queue.add(data);
    print("Queue: $_queue");
    _batchSend();
  }

  _batchSend() {
    // There shall be only one _batchSend function running at a time per handler instance
    print("Running ? $_running");
    print("Is Empty ? ${_queue.isEmpty}");
    if (_running) return;
    if (_queue.isEmpty) return;
    _running = true;
    print("Queue before send: $_queue");
    var enc;
    try {
      enc = encode(_queue);
    } catch (e) {
      print("Error in encoding: $e");
    }
    print("Trying to send: ${enc}");
    send(enc).then((_) {
      print("Sent: $_queue");
      _running = false;
      // Keep performing until the queue is empty
      _batchSend();
    }).catchError((e,s) => print("ERROR: $e $s"));
    _queue.clear();
  }
}
