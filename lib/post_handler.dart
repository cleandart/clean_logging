library clean_logging.post_handler.dart;

import 'dart:io';
import 'logger.dart';
import 'dart:async';
import 'package:clean_logging/http_handler.dart';

class ClientRequestHandler extends HttpHandler {

  static _sendToUrlFactory(url) {
    HttpClient client = new HttpClient();
    return (String data) {
      return client.postUrl(Uri.parse(url)).then((request) {
          var ctype = new ContentType('application', 'json', charset: 'utf-8');
          request.headers.contentType = ctype;
          request.write(data);
          request.close();
        }, onError: (e,s) => print("Error occured: ${e}, ${s}")
      );
    };
  }
  ClientRequestHandler(url):this.config(logToJson, _sendToUrlFactory(url));

  ClientRequestHandler.config(String encode(Map), Future send(String)): super.config(encode, send);
}
