library main;

import 'package:clean_logging/mongo_logger.dart';

void main() {
  MongoLogger.bind("127.0.0.1", 8080, "mongodb://127.0.0.1:27017/logs");
}