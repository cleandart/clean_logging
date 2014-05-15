library clean_logging.logger;

import 'dart:async';
import 'dart:convert';

String logToJson(Map log) => JSON.encode(log,
    toEncodable: (dynamic o){
      var res;
      try {
        res = o.toJson();
      } catch(e) {
        res = o.toString();
      }
      return res;
    });

class Logger {
  static final String INFO = 'info';
  static final String WARNING = 'warning';
  static final String FINE = 'fine';
  static final String FINER = 'finer';
  static final String FINEST = 'finest';

  var source;
  Function getMetaData;
  StreamController streamController;

  Logger(source, {Map this.getMetaData()}) {
    streamController = new StreamController();
  }
  log(String level, String event, {dynamic data, error, stackTrace}) {
    streamController.add({
      'level':level,
      'source':source,
      'event':event,
      'meta':getMetaData(),
      'timestamp': new DateTime.now().millisecondsSinceEpoch,
      'data':data,
      'error':error,
      'stackTrace':stackTrace
    });
  }

  /**
   * {
   *   'level':, 'source':, 'event':, 'meta': , 'timestamp':, 'data':, 'error':, 'stackTrace':
   * }
   */
  Stream<Map> get onRecord => streamController.stream;
}
