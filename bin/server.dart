library chat_example_force;

import 'dart:async';
import 'package:logging/logging.dart' show Logger, Level, LogRecord;


import 'package:force/force_serverside.dart';

final Logger log = new Logger('ChatApp');

void main() {
  // Set up logger.
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });

  ForceServer fs = new ForceServer(wsPath: "/ws", port: 9223, startPage: "forcechat.html" );
  
  fs.on('text', (e, sendable) { 
    var json = e.json;
    sendable.send('text', { 'line': json['line'], 'name': json['name'] });
  });
  
  fs.start().then((_) {
    fs.serve("/client.dart").listen((request) { 
      fs.serveFile("../web/client.dart", request);
    });
  });
}
