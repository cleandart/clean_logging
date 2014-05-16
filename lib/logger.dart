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

  Function info, warning, severe, shout, config, fine, finer, finest;

  final source;
  Function getMetaData;
  static StreamController _streamController = new StreamController.broadcast();

  Logger(this.source, {Map this.getMetaData()}) {
    info = _logByLevel(INFO);
    warning = _logByLevel(WARNING);
    severe = _logByLevel(SEVERE);
    shout = _logByLevel(SHOUT);
    config = _logByLevel(CONFIG);
    fine = _logByLevel(FINE);
    finer = _logByLevel(FINER);
    finest = _logByLevel(FINEST);
  }

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

  _logByLevel(int level) => (String event, {dynamic data, error, stackTrace})
      => log(level, event, data:data, error:error, stackTrace:stackTrace);

  /**
   * {
   *   'level':, 'source':, 'event':, 'meta': , 'timestamp':, 'data':, 'error':, 'stackTrace':
   * }
   */
  static Stream<Map> get onRecord => _streamController.stream;
}
