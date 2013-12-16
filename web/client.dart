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
    forceClient = new ForceClient();
    forceClient.connect();
    
    inputElement.onChange.listen((e) {
      String value = inputElement.value;
      if (value.startsWith("private ")) {
        print("going private!");
        String subValue = value.substring(8);
        String sendName = subValue.substring(0, subValue.indexOf(" "));
        
        String sendValue = subValue.substring(sendName.length);
        
        print("name! $sendName");
        print("name! $sendValue");
        var request = {
                       'name': chatName,
                       'line': sendValue
        };
        forceClient.sendToProfile('name', sendName, 'private', request);
        
        addText("private to $sendName", sendValue);
      } else {
        var request = {
            'name': chatName,
            'line': inputElement.value
        };
        forceClient.send('text', request);
      }
      inputElement.value = '';
    });
    
    nameElement.onChange.listen((e) {
      chatName = nameElement.value;
      enterScreen.style.display = "none";
      chatScreen.style.display = "block";
      inputElement.focus();
      
      var profileInfo = { 'name' : chatName};
      forceClient.initProfileInfo(profileInfo);
    });
    
    nameElement.focus();
    
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
    
    forceClient.on("private", (e, sender) {
      addPrivate(e.json['name'], e.json['line']);
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
  
  void addPrivate(String name, String text) {
    print("coming private text in $text");
    var result = new DivElement();
    result.innerHtml = "private message from <b>$name</b> : $text";
    context.children.add(result);
  }
}

void main() {
  var client = new Client();
}
