library chat_example_force;

import 'dart:io';
import 'package:force/force_serverside.dart';

void main() {
  // Setup what port to listen to 
  var portEnv = Platform.environment['PORT'];
  var port = portEnv == null ? 8080 : int.parse(portEnv);
  var serveClient = portEnv == null ? true : false;
  
  // Create a force server
  ForceServer fs = new ForceServer(port: port, 
                                   clientFiles: '../client/build/web/',
                                   clientServe: serveClient);
  
  // Setup logger
  fs.setupConsoleLog();
  
  // Setup handler for "/text"
  fs.on('text', (e, sendable) {  
    var json = e.json;
    sendable.send('text', { 'line': json['line'], 'name': json['name'] });
    
    if (json['line']=='close') {
      fs.close(e.wsId);
    }
  });
  
  // Profile shizzle
  List<String> chatNames = new List<String>();
  fs.onProfileChanged.listen((e) {
    String name = e.profileInfo['name'];
    if (e.type == ForceProfileType.New) {
      chatNames.add(name);
      
      fs.send('entered', { 'name' : name });
    }
    if (e.type == ForceProfileType.ChangedProperty) {
      chatNames.add(name);
      fs.send('entered', { 'name' : name });
      
      chatNames.remove(e.property.value);
      fs.send('leaved', { 'name' : e.property.value });
    }
    if (e.type == ForceProfileType.Removed) {
      chatNames.remove(name);
      
      fs.send('leaved', { 'name' : name });
    }
  });
  
  // Setup handler for "/list" 
  fs.on('list', (e, sendable) { 
    sendable.sendTo(e.wsId, 'list', chatNames);
  });
  
  // Start force server 
  fs.start();
}

