library clean_logging.logger;

import 'dart:async';
import 'dart:convert';

/**
 * Recursively encodes the object to JSON - if some object does not implement .toJson(),
 * .toString() is used.
 */
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

/**
 * Log level used to determine the granularity of a log.
 */
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

/**
 * Class for logging objects. Similar to logger in package logging, but instead of logging
 * only String messages, [Logger] allows to log any data. Logging hierarchy can be expressed
 * while constructing a logger with name separated by '.', which then corresponds to a path from names
 * in hierachy tree.
 *
 * Every logger has it's logLevel, which decides whether to log the given log or not.
 * If a level is not specified, parent's level is considered.
 *
 * If data is to be logged, it is appended some additional data and pushed to a static stream.
 * If there is any action to be taken after data is logged, there's only needed to listen on this
 * static stream.
 */
class Logger {

  /// Full name of the Logger (with hierarchy)
  final fullSource;
  /// Name of the Logger (without hierarchy)
  final source;
  /// Filters out logs with smaller level
  Level logLevel = null;
  Logger _parent;

  /// Static stream, where every log is pushed
  static StreamController _streamController =
      new StreamController.broadcast(sync: true);

  /// Based on [logLevel], decides whether a log with [level] should be logged
  shouldLog(level) => logLevel == null ? _parent.shouldLog(level) : logLevel <= level;

  /**
   * If it should log the given [level], it pushes a Map with given data to the static stream
   * [onRecord]. Additionally, it adds a timestamp and if static [getMetaData] is specified,
   * it adds the result of this funciton (it may be some data that has to be recalculated for every log,
   * e.g. number of logs).
   */
  log(Level level, String event, {dynamic data, error, stackTrace}) {
    if (shouldLog(level)) {
      var logRec = {'level':level,
                    'fullSource': fullSource,
                    'source':source,
                    'event':event,
                    'meta':getMetaData != null ? getMetaData() : null,
                    'timestamp': new DateTime.now().millisecondsSinceEpoch,
                    'data':data,
                    'error':error,
                    'stackTrace':stackTrace
                  };
      if (_locked) {
        print('Error: Someone is trying to log during logging. Log record:\n'
              '${logRec.toString()}');
      } else {
        _locked = true;
        _streamController.add(logRec);
        _locked = false;
      }
    }
  }

  /// Logs data with Level.INFO - compatibility with Logger in package logging
  info(String event, {dynamic data, error, stackTrace})
    => log(Level.INFO, event, data:data, error:error, stackTrace:stackTrace);

  /// Logs data with Level.WARNING - compatibility with Logger in package logging
  warning(String event, {dynamic data, error, stackTrace})
    => log(Level.WARNING, event, data:data, error:error, stackTrace:stackTrace);

  /// Logs data with Level.SEVERE - compatibility with Logger in package logging
  severe(String event, {dynamic data, error, stackTrace})
    => log(Level.SEVERE, event, data:data, error:error, stackTrace:stackTrace);

  /// Logs data with Level.SHOUT - compatibility with Logger in package logging
  shout(String event, {dynamic data, error, stackTrace})
    => log(Level.SHOUT, event, data:data, error:error, stackTrace:stackTrace);

  /// Logs data with Level.CONFIG - compatibility with Logger in package logging
  config(String event, {dynamic data, error, stackTrace})
    => log(Level.CONFIG, event, data:data, error:error, stackTrace:stackTrace);

  /// Logs data with Level.FINE - compatibility with Logger in package logging
  fine(String event, {dynamic data, error, stackTrace})
    => log(Level.FINE, event, data:data, error:error, stackTrace:stackTrace);

  /// Logs data with Level.FINER - compatibility with Logger in package logging
  finer(String event, {dynamic data, error, stackTrace})
    => log(Level.FINER, event, data:data, error:error, stackTrace:stackTrace);

  /// Logs data with Level.FINEST - compatibility with Logger in package logging
  finest(String event, {dynamic data, error, stackTrace})
    => log(Level.FINEST, event, data:data, error:error, stackTrace:stackTrace);

  /**
   * All logs are pushed into this stream, every element in this stream is in
   * the following form:
   *
   * {
   *   'level': Level,
   *   'fullSource': String,
   *   'source': String,
   *   'event': String,
   *   'meta': dynamic,
   *   'timestamp': int,
   *   'data': dynamic,
   *   'error': dynamic,
   *   'stackTrace': dynamic,
   * }
   */
  static Stream<Map> get onRecord => _streamController.stream;

  static bool _locked = false;

  /**
   * This function is recalculated with every log, and it's result is pushed into
   * the stream. The function should not take any arguments.
   */
  static Function getMetaData;

  /**
   * All [Logger]s in the system.
   */
  static final Map<String, Logger> _loggers = {};

  static _createRootLogger() =>
    new Logger._internal("", "", null)..logLevel = Level.WARNING;

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
    return new Logger._internal(source, thisName, parent);
  }

  Logger._internal(this.fullSource, this.source, this._parent);

}
