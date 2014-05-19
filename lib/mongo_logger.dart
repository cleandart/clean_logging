library clean_logging.mongo_logger;

import 'package:clean_logging/logger.dart';
import 'dart:async';
import 'dart:io';
import 'package:http_server/http_server.dart';
import 'package:mongo_dart/mongo_dart.dart';

class MongoLogger {
  HttpServer httpServer;
  Db mongodb;
  Function encode;
  static String collectionName = 'logs';

  static _createIndexes(db, List<String> keys) =>
    db.createIndex(collectionName, keys: new Map.fromIterable(keys, value: (v) => 1));

  MongoLogger.config(this.httpServer, this.mongodb, String this.encode(Map));

  static Future<MongoLogger> bind(host, port, connectionString) {
    var mongodb = new Db(connectionString);
    return mongodb.open()
      .then((_) => _createIndexes(mongodb, ['event','timestamp','level','name']))
      .then((_) => HttpServer.bind(host,port))
      .then((server) {
        server.listen((request) {
          HttpBodyHandler.processRequest(request).then((body) {
            request.response.headers.add("Access-Control-Allow-Origin", "*");
            request.response.headers.add("Access-Control-Allow-Methods", "POST, OPTIONS");
            if (body.request.method == "OPTIONS") {
              // For cross origin request
              request.response.headers.add("Access-Control-Allow-Headers", "Content-Type");
            } else if (body.type != "json") {
              request.response.statusCode = HttpStatus.BAD_REQUEST;
            } else {
              Map log = body.body;
              mongodb.collection(collectionName).insert(log);
              request.response.statusCode = HttpStatus.OK;
              request.response.write({"result":"OK"});
            }
            return request.response.close();
          });

        });
        return new MongoLogger.config(server, mongodb, logToJson);
    });
  }
}
