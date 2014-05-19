library clean_logging.ajax_handler;

import 'package:clean_logging/logger.dart';
import 'dart:async';
import 'dart:html';

class AjaxHandler {

  final Function _send;
  final Function _encode;

  static _sendToUrlFactory(url) =>
      (String data) => HttpRequest.request(url, method:"POST",
            requestHeaders:{"Content-Type":"application/json"}, sendData:data);


  AjaxHandler(url) : this.config(logToJson, _sendToUrlFactory(url));

  AjaxHandler.config(String this._encode(Map), Future this._send(String));

  handleData(data) => _send(_encode(data));
}
