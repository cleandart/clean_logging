library clean_logging.print_handler;
import 'package:clean_logging/logger.dart' as cL;
import 'package:logging/logging.dart' as l;

class PrintHandler {
  handleData(data) => print('$data');
}

class LogsHandler {

  cL.Logger logger;

  LogsHandler(this.logger);

  handleLog(l.LogRecord log) =>
      logger.log(log.level.value, log.message, error:log.error, stackTrace:log.stackTrace);
}

class MongoLogsHandler {

  l.Logger logger;

  MongoLogsHandler(this.logger);

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

  handleLog(Map log) => logger.log(_getLogLevel(log['level']), log.toString(),
      log['error'],log['stackTrace']);
}