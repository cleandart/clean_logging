import 'package:clean_logging/logger.dart';
import 'package:clean_logging/server_logger.dart';

main() {

  getMetaData() =>
    {
     "data":"random data",
     "time": new DateTime.now().millisecondsSinceEpoch
    };

  Logger logger = new Logger('logger1', getMetaData: getMetaData);
  String connectionString = "mongodb://0.0.0.0:27017/logger";
  MongoLogger mongoLogger;
  MongoLogger.bind("127.0.0.1", 8080, connectionString)
    .then((mL) => mongoLogger = mL).then((_) => print('Mongo Logger initialized'));

}