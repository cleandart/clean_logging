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
            print('TYPE: ${body.type}');
            print('BODY: ${body.body}');
            if (body.type != "json") {
              request.response.statusCode = HttpStatus.BAD_REQUEST;
              request.response.close();
            } else {
              Map log = body.body;
              mongodb.collection(collectionName).insert(log);
              request.response.statusCode = HttpStatus.OK;
              request.response.write({"result":"OK"});
              request.response.close();
            }
          });
          request.response.headers.add("Access-Control-Allow-Origin", "*");
          request.response.headers.add("Access-Control-Allow-Methods", "POST");

        });
        return new MongoLogger.config(server, mongodb, logToJson);
    });
  }
}
