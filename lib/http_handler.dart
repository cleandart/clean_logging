library clean_logging.http_handler.dart;

import 'dart:async';

/**
 * Class supporting batch sending, all other handler which send the data elsewhere
 * extend this class.
 */
abstract class HttpHandler {

  final Function send;
  final Function encode;
  bool _running = false;
  final _queue = [];

  HttpHandler.config(String this.encode(Map m), Future this.send(String s));

  handleData(data) {
    _queue.add(data);
    _batchSend();
  }

  _batchSend() {
    // There shall be only one _batchSend function running at a time per handler instance
    if (_running) return;
    if (_queue.isEmpty) return;
    _running = true;
    send(encode(_queue)).then((_) {
      _running = false;
      // Keep performing until the queue is empty
      _batchSend();
    });
    _queue.clear();
  }
}
