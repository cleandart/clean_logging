library clean_logging.server_handlers;

import 'package:clean_logging/logger.dart';
import 'dart:async';
import 'dart:io';
import 'package:clean_sync/server.dart';
import 'dart:convert';

class ClientRequestHandler {

  final Function send;
  final Function encode;

  static _sendToUrlFactory(url) {
    HttpClient client = new HttpClient();
    return (String data) {
      client.postUrl(Uri.parse(url)).then((request) {
          request.write(data);
          request.close();
        }
      );
    };
  }
  ClientRequestHandler(url):this.config(logToJson, _sendToUrlFactory(url));

  ClientRequestHandler.config(String this.encode(Map), Future this.send(String));

  handleData(data) => send(encode(data));

}

class MongoLogger {
  HttpServer httpServer;
  MongoDatabase mongodb;
  Function encode;
  static String collectionName = 'logs';

  static _createIndexes(db, List<String> keys) =>
    db.createIndex(collectionName, new Map.fromIterable(keys, value: (v) => 1));

  MongoLogger.config(this.httpServer, this.mongodb, String this.encode(Map));

  static Future<MongoLogger> bind(host, port, connectionString) {
    var mongodb = new MongoDatabase(connectionString);
    return Future.wait(mongodb.init)
      .then((_) => _createIndexes(mongodb, ['event','timestamp','level','name']))
      .then((_) => HttpServer.bind(host,port))
      .then((server) {
        server.listen((request) {
          var json = [];
          request.response.headers.add("Access-Control-Allow-Origin", "*");
          request.response.headers.add("Access-Control-Allow-Methods", "POST,GET,DELETE,PUT,OPTIONS");
          request.listen((buffer) => json.addAll(buffer),
              onDone: () {
                Map log = JSON.decode(new String.fromCharCodes(json));
                mongodb.collection(collectionName).add(log, log["source"]);
                request.response.statusCode = HttpStatus.OK;
                request.response.write({"result":"OK"});
                request.response.close();
              },
              onError: (e) {
                request.response.statusCode = HttpStatus.BAD_REQUEST;
                request.response.write({"error":"$e"});
                request.response.close();
              });
          }
        );
        return new MongoLogger.config(server, mongodb, logToJson);
      });

  }

}
