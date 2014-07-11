library clean_logging.logger;

import 'dart:async';
import 'dart:convert';

String logToJson(log) => JSON.encode(log,
    toEncodable: (dynamic o){
      var res;
      try {
        res = o.toJson();
      } catch(e) {
        res = o.toString();
      }
      return res;
    });

class Level implements Comparable<Level> {

  final String name;

  /**
   * Unique value for this level. Used to order levels, so filtering can exclude
   * messages whose level is under certain value.
   */
  final int value;

  const Level(this.name, this.value);

  /** Special key to turn on logging for all levels ([value] = 0). */
  static const Level ALL = const Level('ALL', 0);

  /** Special key to turn off all logging ([value] = 2000). */
  static const Level OFF = const Level('OFF', 2000);

  /** Key for highly detailed tracing ([value] = 300). */
  static const Level FINEST = const Level('FINEST', 300);

  /** Key for fairly detailed tracing ([value] = 400). */
  static const Level FINER = const Level('FINER', 400);

  /** Key for tracing information ([value] = 500). */
  static const Level FINE = const Level('FINE', 500);

  /** Key for static configuration messages ([value] = 700). */
  static const Level CONFIG = const Level('CONFIG', 700);

  /** Key for informational messages ([value] = 800). */
  static const Level INFO = const Level('INFO', 800);

  /** Key for potential problems ([value] = 900). */
  static const Level WARNING = const Level('WARNING', 900);

  /** Key for serious failures ([value] = 1000). */
  static const Level SEVERE = const Level('SEVERE', 1000);

  /** Key for extra debugging loudness ([value] = 1200). */
  static const Level SHOUT = const Level('SHOUT', 1200);

  static const List<Level> LEVELS = const
      [ALL, FINEST, FINER, FINE, CONFIG, INFO, WARNING, SEVERE, SHOUT, OFF];

  bool operator ==(Object other) => other is Level && value == other.value;
  bool operator <(Level other) => value < other.value;
  bool operator <=(Level other) => value <= other.value;
  bool operator >(Level other) => value > other.value;
  bool operator >=(Level other) => value >= other.value;
  int compareTo(Level other) => value - other.value;
  int get hashCode => value;
  String toString() => name;
  toJson() => {"name":name, "value":value};

}

class Logger {

  final source;
  Level logLevel = null;
  Logger _parent;
  static StreamController _streamController =
      new StreamController.broadcast(sync: true);

  shouldLog(level) => logLevel == null ? _parent.shouldLog(level) : logLevel <= level;

  log(Level level, String event, {dynamic data, error, stackTrace}) {
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
    => log(Level.INFO, event, data:data, error:error, stackTrace:stackTrace);

  warning(String event, {dynamic data, error, stackTrace})
    => log(Level.WARNING, event, data:data, error:error, stackTrace:stackTrace);

  severe(String event, {dynamic data, error, stackTrace})
    => log(Level.SEVERE, event, data:data, error:error, stackTrace:stackTrace);

  shout(String event, {dynamic data, error, stackTrace})
    => log(Level.SHOUT, event, data:data, error:error, stackTrace:stackTrace);

  config(String event, {dynamic data, error, stackTrace})
    => log(Level.CONFIG, event, data:data, error:error, stackTrace:stackTrace);

  fine(String event, {dynamic data, error, stackTrace})
    => log(Level.FINE, event, data:data, error:error, stackTrace:stackTrace);

  finer(String event, {dynamic data, error, stackTrace})
    => log(Level.FINER, event, data:data, error:error, stackTrace:stackTrace);

  finest(String event, {dynamic data, error, stackTrace})
    => log(Level.FINEST, event, data:data, error:error, stackTrace:stackTrace);

  /**
   * {
   *   'level':, 'source':, 'event':, 'meta': , 'timestamp':, 'data':, 'error':, 'stackTrace':
   * }
   */
  static Stream<Map> get onRecord => _streamController.stream;

  static Function getMetaData;

  /**
   * All [Logger]s in the system.
   */
  static final Map<String, Logger> _loggers = {};

  static _createRootLogger() =>
    new Logger._internal("", null)..logLevel = Level.WARNING;

  /** Root logger. */
  static Logger get ROOT => new Logger('');
  /**
   * Singleton constructor. Calling `new Logger(name)` will return the same
   * actual instance whenever it is called with the same string name.
   * Creates root logger with logLevel set if not created.
   */
  factory Logger(String source) {
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
