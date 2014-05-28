library clean_logging.mongo_logger;

import 'dart:async';
import 'dart:io';
import 'package:http_server/http_server.dart';
import 'package:mongo_dart/mongo_dart.dart';

class MongoLogger {
  HttpServer httpServer;
  Db mongodb;
  static const String COLLECTION_NAME = 'logs';

  static Future _createIndexes(Db mongodb) {
    var indexes = [
      {'level': 1, 'timestamp': 1},
      {'timestamp': 1},
      {'source': 1, 'timestamp':1},
      {'source': 1, 'level': 1},
      {'event': 1, 'timestamp': 1},
    ];
    return Future.wait(indexes.map((i) =>
        mongodb.ensureIndex(COLLECTION_NAME, keys: i)));
  }

  MongoLogger.config(this.httpServer, this.mongodb);

  _insertLogs(dynamic logs) => mongodb.collection(COLLECTION_NAME).insertAll(logs is List ? logs : [logs])
      .catchError((e,s) => print("Error occured while inserting to database: ${e}, ${s}"));

  _handleRequest(request) {
    HttpBodyHandler.processRequest(request).then((body) {
      request.response.headers.add("Access-Control-Allow-Origin", "*");
      request.response.headers.add("Access-Control-Allow-Methods", "POST, OPTIONS");
      if (body.request.method == "OPTIONS") {
        // For cross origin request
        request.response.headers.add("Access-Control-Allow-Headers", "Content-Type");
      } else if (body.type != "json") {
        request.response.statusCode = HttpStatus.BAD_REQUEST;
      } else {
        _insertLogs(body.body);
        request.response.statusCode = HttpStatus.OK;
        request.response.write({"result":"OK"});
      }
      request.response.close();
    });
  }

  start() =>
    httpServer.listen((request) => _handleRequest(request));

  static Future<MongoLogger> bind(host, port, connectionString) {
    var mongodb = new Db(connectionString);
    return mongodb.open()
      .then((_) => _createIndexes(mongodb))
      .then((_) => HttpServer.bind(host,port))
      .then((server) => new MongoLogger.config(server, mongodb)..start());
    }
}
