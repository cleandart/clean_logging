library clean_logging.post_handler.dart;

import 'dart:io';
import 'logger.dart';
import 'dart:async';

class ClientRequestHandler {

  final Function send;
  final Function encode;

  static _sendToUrlFactory(url) {
    HttpClient client = new HttpClient();
    return (String data) {
      client.postUrl(Uri.parse(url)).then((request) {
          request.headers.contentType = new ContentType('application', 'json', charset: 'utf-8');
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
