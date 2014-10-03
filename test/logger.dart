library clean_logging.test_logger;

import 'package:unittest/unittest.dart';
import 'package:clean_logging/logger.dart';

Logger l = new Logger('logger');

void main() {
  test('Logging inside logging does not end in infinite loop.', () {
    // given
    Logger.ROOT.logLevel = Level.ALL;
    Logger.onRecord.listen((_) => handleLog(_));
    l.info("Hello!");
  });
}

handleLog(lr) {
  try {
    throw new Exception("Exception");
  } catch (e) {
    l.shout("$e");
  }
}
