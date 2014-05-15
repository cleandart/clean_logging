import 'package:clean_logging/logger.dart';
import 'package:clean_logging/client_handlers.dart';

main() {
  getMetaData() =>
    {
     "data":"random data",
     "time": new DateTime.now().millisecondsSinceEpoch
    };

  var url = "http://127.0.0.1:8080";

  Logger logger = new Logger('logger1', getMetaData: getMetaData);
  logger.onRecord.listen(new AjaxHandler(url).handleData);
  logger.onRecord.listen(new PrintHandler().handleData);

  for (int i = 0; i < 10; i++) {
    logger.log(Logger.WARNING, "event number: ${i*100}", data: {"number": i});
  }
}