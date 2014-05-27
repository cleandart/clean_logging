library clean_logging.ajax_handler;

import 'package:clean_logging/logger.dart';
import 'dart:async';
import 'dart:html';
import 'package:clean_logging/http_handler.dart';

class AjaxHandler extends HttpHandler {

  static _sendToUrlFactory(url) =>
      (String data) => HttpRequest.request(url, method:"POST",
            requestHeaders:{"Content-Type":"application/json"}, sendData:data)
            .catchError((e,s) => print("Error occured ${e}, ${s}"));


  AjaxHandler(url) : this.config(logToJson, _sendToUrlFactory(url));

  AjaxHandler.config(String encode(Map), Future send(String)):super.config(encode,send);
}
