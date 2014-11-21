library clean_logging.basic_handler;
import 'package:clean_logging/logger.dart' as cL;
import 'package:logging/logging.dart' as l;

class PrintHandler {
  static handleData(data) => print('$data');
}

class JsonHandler {
  static handleData(data) => print("${cL.logToJson(data)}, ");
}

/**
 * Compatibility class for Logger in package logging. Logs from the other Logger
 * are logged by this logger.
 */
class LoggingToClean {

  cL.Logger logger;

  LoggingToClean(this.logger);

  /// Logs every log from Logger in package logging by this Logger
  handleLog(l.LogRecord log) =>
      logger.log(new cL.Level(log.level.name,log.level.value), log.message,
          error:log.error, stackTrace:log.stackTrace);
}

/**
 * Compatibility class for Logger in package logging. Logs from this logger
 * are logged by the Logger in package logging
 */
class CleanToLogging {

  l.Logger logger;

  CleanToLogging(this.logger);

  l.Level _getLogLevel(int level) {
    switch (level) {
      case 300: return new l.Level("FINEST", 300);
      case 400: return new l.Level("FINER", 400);
      case 500: return new l.Level("FINE", 500);
      case 700: return new l.Level("CONFIG",700);
      case 800: return new l.Level("INFO", 800);
      case 900: return new l.Level("WARNING", 900);
      case 1000: return new l.Level("SEVERE", 1000);
      case 1200: return new l.Level("SHOUT", 1200);
      default: return new l.Level("CUSTOM", level);
    }
  }

  handleLog(Map log) => logger.log(new l.Level(log['level'].name,log['level'].value), log.toString(),
      log['error'],log['stackTrace']);
}
