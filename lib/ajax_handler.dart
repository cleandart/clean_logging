library clean_logging.ajax_handler;

import 'package:clean_logging/logger.dart';
import 'dart:async';
import 'dart:html';

class AjaxHandler {

  final Function _send;
  final Function _encode;

  static _sendToUrlFactory(url) =>
      (String data) {
          HttpRequest req = new HttpRequest();
          req.open("POST", url);
          req.setRequestHeader('Content-Type', 'application/json');
          req.setRequestHeader('User-Agent', 'random');
          req.send(data);
      };

  AjaxHandler(url) : this.config(logToJson, _sendToUrlFactory(url));

  AjaxHandler.config(String this._encode(Map), Future this._send(String));

  handleData(data) => _send(_encode(data));
}