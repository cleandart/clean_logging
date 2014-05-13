import 'package:logging/logging.dart';
import 'dart:async';
import 'dart:convert';

String logToJson(Map log) => JSON.encode(log,
    toEncodable: (dynamic o){
      var res;
      try {
        res = o.toJson();
      } catch(e) {
        res = o.toString();
      }
      return res;
    });

class Logger {
  var source;
  Function getMetaData;
  StreamController streamController;

  Logger(source, {Map this.getMetaData()}) {
    streamController = new StreamController();
  }
  log(Level level, String event, {dynamic data, error, stackTrace}) {
    streamController.add({
      'level':level,
      'event':event,
      'meta':getMetaData(),
      'timestamp': new DateTime.now().millisecondsSinceEpoch,
      'data':data,
      'error':error,
      'stackTrace':stackTrace
    });
  }

  /**
   * {
   *   'level':, 'source':, 'event':, 'meta': , 'timestamp':, 'data':, 'error':, 'stackTrace':
   * }
   */
  Stream<Map> get onRecord => streamController.stream;
}
