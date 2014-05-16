library clean_logging.server_handlers;

import 'package:clean_logging/logger.dart';
import 'dart:async';
import 'dart:io';
import 'package:clean_sync/server.dart';
import 'dart:convert';

class ClientRequestHandler {

  Function send;
  Function encode;

  _sendToUrlFactory(url) {
    HttpClient client = new HttpClient();
    return (String data) {
      client.postUrl(Uri.parse(url)).then((request) {
          request.write(data);
          request.close();
      });
    };

  ClientRequestHandler(url) : this.config(logToJson, _sendToUrlFactory(url));

  ClientRequestHandler.config(String this.encode(Map), Future this.send(String));

  handleData(data) => send(encode(data));

}

class MongoLogger {
  HttpServer httpServer;
  MongoDatabase mongodb;
  Function encode;
  Future init;
  String collectionName = 'logs';

  _createIndexes(List<String> keys) =>
    mongodb.createIndex(collectionName, new Map.fromIterable(keys, value: (v) => 1));

  MongoLogger.config(this.httpServer, this.mongodb, Map this.encode(Map), this.collectionName);

  MongoLogger.bind(host, port, connectionString) {
    mongodb = new MongoDatabase(connectionString);
    init = Future.wait(mongodb.init)
      .then((_) => _createIndexes(['event','timestamp','level','name']))
      .then((_) => HttpServer.bind(host,port)
      .then((server) => httpServer = server)
      .then((_) => httpServer.listen((request) {
        var json = [];
        request.listen((buffer) => json.addAll(buffer),
            onDone: () {
              Map log = JSON.decode(new String.fromCharCodes(json));
              mongodb.collection(collectionName).add(log, log["source"]);
            });
      })));

  }

}
