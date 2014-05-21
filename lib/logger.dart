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

  static const int ALL = 0;
  static const int FINEST = 300;
  static const int FINER = 400;
  static const int FINE = 500;
  static const int CONFIG = 700;
  static const int INFO = 800;
  static const int WARNING = 900;
  static const int SEVERE = 1000;
  static const int SHOUT = 1200;
  static const int OFF = 2000;

  final source;
  Function getMetaData;
  int logLevel = null;
  Logger _parent;
  static StreamController _streamController = new StreamController.broadcast();

  shouldLog(level) => logLevel == null ? _parent.shouldLog(level) : logLevel <= level;

  log(int level, String event, {dynamic data, error, stackTrace}) {
    if (shouldLog(level)) {
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

  /**
   * All [Logger]s in the system.
   */
  static final Map<String, Logger> _loggers = {};

  static _createRootLogger() =>
    new Logger._internal("", null)..logLevel = Logger.WARNING;

  /** Root logger. */
  static Logger get ROOT => new Logger('');
  /**
   * Singleton constructor. Calling `new Logger(name)` will return the same
   * actual instance whenever it is called with the same string name.
   * Creates root logger with logLevel set if not created.
   */
  factory Logger(String source, {Map getMetaData()}) {
    return _loggers.putIfAbsent(source, source == "" ? _createRootLogger : () => new Logger._named(source));
  }

  factory Logger._named(String source) {
    if (source.startsWith('.')) {
      throw new ArgumentError("name shouldn't start with a '.'");
    }
    // Split hierarchical names (separated with '.').
    int dot = source.lastIndexOf('.');
    Logger parent = null;
    String thisName;
    if (dot == -1) {
      if (source != '') parent = new Logger('');
      thisName = source;
    } else {
      parent = new Logger(source.substring(0, dot));
      thisName = source.substring(dot + 1);
    }
    return new Logger._internal(thisName, parent);
  }

  Logger._internal(this.source, this._parent);

}
