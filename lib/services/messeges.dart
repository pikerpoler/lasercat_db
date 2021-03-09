import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

Future sleep1() {
  return new Future.delayed(const Duration(seconds: 2), () => "1");
}


FirebaseFirestore _firestore = FirebaseFirestore.instance;

int MAX_ITERATIONS = 50;
String DEVICE_NAME = "prototype";
DocumentReference docRef = FirebaseFirestore.instance.collection("users").doc(DEVICE_NAME);

class Message{
  String message_type;
  String message;
  int play_time;
  Message({this.message_type, this.message, this.play_time});
}

void sendMessage(String message_type, String message, int play_time ) async {
  for (int i = 0; i < MAX_ITERATIONS; i++) {
    var docsnap = await docRef.get();
    var data = docsnap.data();
    if (!data["device_unread"]) {
      docRef.update({ 'device_unread':true,
      'message_to_device_type': message_type,
      'message_to_device': message,
      'play_time' : play_time});

      // data['device_unread'] = true;
      // data['message_to_device_type'] = message_type;
      // data['message_to_device'] = message;
      // docRef.set(data);
      return;
    }
    sleep1();
  }
  print("error sending message. timed out");
}

Future<Message> reciveMessage()async{
  for (int i = 0; i < MAX_ITERATIONS; i++) {
    var docsnap = await docRef.get();
    var data = docsnap.data();
    if(data['app_unread']){
      docRef.update({'app_unread':false});
      return Message(message_type:data['message_to_app_type'], message: data['message_to_app'], play_time: 0);
    }
    print(i);
    sleep1();
  }
  print("error reciving message. timed out");


}

  //example for a document
  // {
  //   'app_unread': false,
  //   'device_unread': true,
  //   'message_to_device_type': "this is type",
  //   'message_to_device': " and this is message",
  //   'message_to_app': "this isn't important",
  //   'message_to_app_type': "also this is not"
  // };






