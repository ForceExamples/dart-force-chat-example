library chat_example_force;

import 'dart:async';
import 'dart:io';
import 'package:logging/logging.dart' show Logger, Level, LogRecord;
import 'package:force/force_serverside.dart';

final Logger log = new Logger('ChatApp');

void main() {
  // Set up logger.
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });
  
  var portEnv = Platform.environment['PORT'];
  var port = portEnv == null ? 9223 : int.parse(portEnv);
  
  ForceServer fs = new ForceServer(host: InternetAddress.ANY_IP_V4, port: port, startPage: "forcechat.html" );
  
  fs.on('text', (e, sendable) {  
    var json = e.json;
    sendable.send('text', { 'line': json['line'], 'name': json['name'] });
  });
  
  // Profile shizzle
  List<String> chatNames = new List<String>();
  fs.onProfileChanged.listen((e) {
    String name = e.profileInfo['name'];
    if (e.type == ForceProfileType.New) {
      chatNames.add(name);
      
      fs.send('entered', { 'name' : name });
    }
    if (e.type == ForceProfileType.Removed) {
      chatNames.remove(name);
      
      fs.send('leaved', { 'name' : name });
    }
  });
  
  fs.on('list', (e, sendable) { 
    print("ask list!?");
    sendable.sendTo(e.wsId, 'list', chatNames);
  });
  
  fs.start().then((_) {
    fs.serve("/client.dart").listen((request) { 
      fs.serveFile("../web/client.dart", request);
    });
  });
}
