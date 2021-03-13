import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

Future sleep1() {
  return new Future.delayed(const Duration(seconds: 2), () => "1");
}


FirebaseFirestore _firestore = FirebaseFirestore.instance;

int MAX_ITERATIONS = 50;
String DEVICE_NAME = "";
DocumentReference docRef = FirebaseFirestore.instance.collection("users").doc(DEVICE_NAME);


class Message{
  String message_type;
  String message;
  int play_time;
  Message({this.message_type, this.message, this.play_time});
}

Future <void> setDeviceName(String uid,String device_name, ){
  FirebaseFirestore.instance.collection("uid to device name").doc(uid)
      .set({"device name": device_name})
      .catchError((error) => print("Failed to add user: $error"));
}

Future <void> getDeviceName(String uid)async{
  if (uid == ''){
    print("no user found. setting device to None");
    DEVICE_NAME = '';
    return;
  }
  DEVICE_NAME = (await FirebaseFirestore.instance.collection("uid to device name").doc(uid).get()).data()["device name"];
  print("setting device name to $DEVICE_NAME");
}

Future <String> getIP()async{
  if(DEVICE_NAME == ''){
    print("no device found");
    //return Message();
  }
  var docsnap = await docRef.get();
  var data = docsnap.data();
  return data["ip"];
}

void sendMessage(String message_type, String message, int play_time ) async {
  if(DEVICE_NAME == ''){
    print("no device found");
    return;
  }
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
  if(DEVICE_NAME == ''){
    print("no device found");
    //return Message();
  }
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






