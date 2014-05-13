import 'package:clean_logging/logger.dart';
import 'dart:async';
import 'dart:html' as html;
import 'dart:io';

class ClientRequestHandler {

  Function send;
  Function encode;

  _sendToUrlFactory(url) =>
      (String data) =>
        html.HttpRequest.request(url, method:'POST', sendData: data);

  ClientRequestHandler(url) {
    encode = logToJson;
    send = _sendToUrlFactory(url);
  }

  ClientRequestHandler.config(String this.encode(Map), Future this.send(String));
}

class MongoLogger {
  HttpServer httpServer;
  Db mongodb;

  MongoLogger.config(this.httpServer, this.mongodb, Map encode(Map));

  static bind(host, connectionString) {}
}