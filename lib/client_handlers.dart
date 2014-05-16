library clean_logging.client_handlers;

import 'package:clean_logging/logger.dart';
import 'dart:async';
import 'dart:html';

class PrintHandler {
  handleData(data) => print('$data');
}

class AjaxHandler {

  final Function send;
  final Function encode;

  static _sendToUrlFactory(url) =>
      (String data) =>
        HttpRequest.request(url, method:'POST', sendData: data);

  AjaxHandler(url) : this.config(logToJson, _sendToUrlFactory(url));

  AjaxHandler.config(String this.encode(Map), Future this.send(String));

  handleData(data) => send(encode(data));
}