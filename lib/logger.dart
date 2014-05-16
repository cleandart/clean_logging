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

  static const int FINEST = 300;
  static const int FINER = 400;
  static const int FINE = 500;
  static const int CONFIG = 700;
  static const int INFO = 800;
  static const int WARNING = 900;
  static const int SEVERE = 1000;
  static const int SHOUT = 1200;

  final source;
  Function getMetaData;
  static StreamController _streamController = new StreamController.broadcast();

  Logger(this.source, {Map this.getMetaData()});

  log(int level, String event, {dynamic data, error, stackTrace}) {
    _streamController.add({
      'level':level,
      'source':source,
      'event':event,
      'meta':getMetaData != null ? getMetaData() : null,
      'timestamp': new DateTime.now().millisecondsSinceEpoch,
      'data':data,
      'error':error,
      'stackTrace':stackTrace
    });
  }

  info(String event, {dynamic data, error, stackTrace})
    => log(INFO, event, data:data, error:error, stackTrace:stackTrace);

  warning(String event, {dynamic data, error, stackTrace})
    => log(WARNING, event, data:data, error:error, stackTrace:stackTrace);

  severe(String event, {dynamic data, error, stackTrace})
    => log(SEVERE, event, data:data, error:error, stackTrace:stackTrace);

  shout(String event, {dynamic data, error, stackTrace})
    => log(SHOUT, event, data:data, error:error, stackTrace:stackTrace);

  config(String event, {dynamic data, error, stackTrace})
    => log(CONFIG, event, data:data, error:error, stackTrace:stackTrace);

  fine(String event, {dynamic data, error, stackTrace})
    => log(FINE, event, data:data, error:error, stackTrace:stackTrace);

  finer(String event, {dynamic data, error, stackTrace})
    => log(FINER, event, data:data, error:error, stackTrace:stackTrace);

  finest(String event, {dynamic data, error, stackTrace})
    => log(FINEST, event, data:data, error:error, stackTrace:stackTrace);

  /**
   * {
   *   'level':, 'source':, 'event':, 'meta': , 'timestamp':, 'data':, 'error':, 'stackTrace':
   * }
   */
  static Stream<Map> get onRecord => _streamController.stream;
}
