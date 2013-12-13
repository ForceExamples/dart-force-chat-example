import 'dart:async';
import 'dart:html';

import 'package:force/force_browser.dart';

class Client {
  
  final DivElement log = new DivElement();
  DivElement statusElement = querySelector('#status');
 
  ForceClient forceClient;
  
  //Chat ??
  InputElement inputElement = querySelector("#speak");
  DivElement context = querySelector("#context");
  
  //name
  InputElement nameElement = querySelector("#name");
  
  //2 parts
  DivElement enterScreen = querySelector("#enter_screen");
  DivElement chatScreen = querySelector("#chat_screen");
  
  String chatName;
  
  Client() {
    inputElement.onChange.listen((e) {
      var request = {
          'name': chatName,
          'line': inputElement.value
      };
      forceClient.send('text', request);
      inputElement.value = '';
    });
    
    nameElement.onChange.listen((e) {
      chatName = nameElement.value;
      enterScreen.style.display = "none";
      chatScreen.style.display = "block";
      inputElement.focus();
    });
    
    forceClient = new ForceClient();
    forceClient.connect();
    
    forceClient.onConnecting.listen((e) {
      if (e.type=="connected") {
        onConnected();
      } else if (e.type=="disconnected") {
        onDisconnected();
      }
    });
    
    forceClient.on("text", (e, sender) {
      addText(e.json['name'], e.json['line']);
    });
  }

  void onConnected() {
    setStatus('');
    inputElement.disabled = false;
    
    forceClient.onMessage.listen((e) {
      onMessage(e.request, e.json);
    });
  }

  void onDisconnected() {
    setStatus('Disconnected - start \'bin/server.dart\' to continue');
    inputElement.disabled = true;
  }

  void setStatus(String status) {
    statusElement.innerHtml = status;
  }


  void onMessage(String request, dynamic json) {
     print("response on: '$request' with $json");
  }

  void addText(String name, String text) {
    print("coming text in $text");
    var result = new DivElement();
    result.innerHtml = "$name : $text";
    context.children.add(result);
  }
}

void main() {
  var client = new Client();
}
