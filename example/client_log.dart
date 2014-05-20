import 'package:clean_logging/logger.dart';
import 'package:clean_logging/ajax_handler.dart';
import 'package:clean_logging/print_handler.dart';

main() {
  getMetaData() =>
    {
     "data":"random data",
     "time": new DateTime.now().millisecondsSinceEpoch.toString()
    };

  var url = "http://127.0.0.1:8080";

  Logger logger = new Logger('logger1', getMetaData: getMetaData);
  Logger.onRecord.listen(new AjaxHandler(url).handleData);
  Logger.onRecord.listen(PrintHandler.handleData);

  for (int i = 0; i < 16; i++) {
    logger.warning("event number: ${i*100}", data: {"number": i});
  }
}