library chat_example_force;

import 'dart:async';
import 'package:logging/logging.dart' show Logger, Level, LogRecord;


import 'package:force/force_server.dart';
import 'package:force/force_common.dart';

final Logger log = new Logger('ChatApp');

void main() {
  // Set up logger.
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });

  ForceServer vs = new ForceServer(wsPath: "/ws", port: 9223 );
  
  vs.on('text', (e, sendable) { 
    var json = e.json;
    var line = json['line'];
    sendable.send('text', { 'line': line });
  });
  
  vs.start().then((_) {
    vs.serve("/client.dart").listen((request) { 
      vs.serveFile("../web/client.dart", request);
    });
  });
}
