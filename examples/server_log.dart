import 'package:clean_logging/logger.dart';
import 'package:clean_logging/server_logger.dart';

main() {

  getMetaData() =>
    {
     "data":"random data",
     "time": new DateTime.now().millisecondsSinceEpoch.toString()
    };

  Logger logger = new Logger('logger1', getMetaData: getMetaData);
  logger.onRecord.listen(new ClientRequestHandler("http://127.0.0.1:8080").handleData);

  for (int i = 0; i < 10; i++) {
    logger.log(Logger.INFO, "event number: $i", data: {"number": i});
  }
  print('Finished');
}