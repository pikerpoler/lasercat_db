import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'dart:convert';
// Import the firebase_core plugin
import 'package:firebase_core/firebase_core.dart';
import 'package:floating_action_bubble/floating_action_bubble.dart';
import 'package:lasercat_db/models/user.dart';
import 'package:lasercat_db/screens/view_camera.dart';

import 'package:lasercat_db/services/messeges.dart';



class CameraPage extends StatefulWidget {
  CameraPage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CameraPageState();
}

const String RANDOM ="SQUARE", CIRCLE = "CIRCLE", STAR = "STAR"; // change "SQUARE" to "RANDOM"
const int D_TIME=5;

class _CameraPageState extends State<CameraPage> with SingleTickerProviderStateMixin{
  // initialized for widget
  Animation<double> _animation;
  AnimationController _animationController;
  List<bool> isSelected = [false, false, true, false, false];
  String _playShape = RANDOM;
  int _playTime = 10;




  @override
  void initState(){

    // initialized for widget
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 260),
    );

    // initialized for widget
    final curvedAnimation = CurvedAnimation(curve: Curves.easeInOut, parent: _animationController);
    _animation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);

    // initialized for web-rct (for the video stream)

    //@Todo
    //get from the firestore the configutation for connection
    //set a connection
    //set the stream
    /// the next function is from other project. We can use some of it.
    // _createPeerConnection().then((pc) {
    //   _peerConnection = pc;
    // });

    super.initState();

  }


  void cameraHandler(bool isOn)async {
    if (isOn){
      //turnOf
      sendMessage("OFFER", 'dummy_offer', _playTime);
      Message message = await reciveMessage();
      print("message type is");
      print(message.message_type);
      print("message is");
      print(message.message);
    }else{
      // _createOffer();
    }
  }


  bool loopActive = false;

  void gameHandler(index) async{
    if (isSelected[index]){
      isSelected[4] = true;//disable food button

      if (_playTime == D_TIME){
        if (loopActive) return; //check if loop is active
        loopActive = true;
        while (isSelected[index]){
          sendMessage("SHAPE", _playShape, _playTime);
          await Future.delayed(Duration(milliseconds: 1000)); // wait a second
        }
        loopActive = false;
        isSelected[4] = false;//reable food button
        setState(() {});
      }
      else{
        sendMessage("SHAPE", _playShape, _playTime);
        Future.delayed(Duration(seconds: _playTime), () {
          isSelected[index] = false;
          isSelected[4] = false; //reable food button
          setState(() {});
        });
      }
    }//isOn
    else{
      //
    }
  }

  void foodHandler(int index){
      sendMessage("FOOD", "yunmmy", _playTime);
      Future.delayed(Duration(milliseconds: 250), () {
        isSelected[index] = false; //reable food button
        setState(() {});
      });
  }

  void shapeHandler(){
    RenderBox box = key.currentContext.findRenderObject();
    Offset position = box.localToGlobal(Offset.zero); //this is global position
    _showPopupMenuShape(position);
  }

  _showPopupMenuShape(offset) async {
    double left = offset.dx;
    double top = offset.dy;
    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(left, top, left+1, top+1),
      items: [
        PopupMenuItem(
          child: Row(children: [Icon(Icons.circle), Text("  Circle"),],),
          value: 0,
        ),
        PopupMenuItem(
          child: Row(children: [Icon(Icons.star), Text("  Star")],),
          value: 1,
        ),
        PopupMenuItem(
          child: Row(children: [Icon(Icons.device_unknown_sharp), Text("  Random"),],),
          value: 2,
        ),

      ],
      elevation: 8.0,

    ).then((value){
      if(value!=null)
        if (value == 0) _playShape=CIRCLE;
        else if (value == 1) _playShape=STAR;
        else if (value == 2) _playShape=RANDOM;
    });
  }

  void TimeHandler(){
      RenderBox box = key.currentContext.findRenderObject();
      Offset position = box.localToGlobal(Offset.zero); //this is global position
      _showPopupMenuTime(position);
  }

  _showPopupMenuTime(offset) async {
    double left = offset.dx;
    double top = offset.dy;
    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(left, top, left+1, top+1),
      items: [
        PopupMenuItem(
          child: Text("10 Sec"),
          value: 10,
        ),
        PopupMenuItem(
          child: Text("20 Sec"),
          value: 20,
        ),
        PopupMenuItem(
          child: Text("30 Sec"),
          value: 30,
        ),
        PopupMenuItem(
          child: Text("Forever"),
          value: D_TIME,
        ),
      ],
      elevation: 8.0,

    ).then((value){
      if(value!=null)
        _playTime=value;
    });
  }



  GlobalKey key = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final snackBar = SnackBar(
      content: Text('You are on timed mode- wait for program to end'),
    action: SnackBarAction(
      label: 'OK',
      onPressed: () {
        //ScaffoldMessenger.of(context).hideCurrentSnackBar();
      },
    ),
  );
  final snackBar2 = SnackBar(
    content: Text('You are on play mode- end the program first'),
    action: SnackBarAction(
      label: 'OK',
      onPressed: () {
        //ScaffoldMessenger.of(context).hideCurrentSnackBar();
      },
    ),
  );

  //main bulder - the app screen (UI)
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    return Scaffold(
      key: _scaffoldKey,
        appBar: AppBar(
          title: Text("Laser Cat"),
        ),

        body: Center(
          child: Column(
            children: <Widget>[
              // Expanded(
              //   child: Container(
              //     child: camera_widget()// videoRenderers(), CallSample() //
              //   ),
              // ),
              ToggleButtons(
                key: key,
                children: <Widget>[
                  Icon(Icons.timer),
                  Icon(Icons.workspaces_filled),
                  Icon(Icons.camera),
                  Icon(Icons.play_arrow),
                  Icon(Icons.fastfood),
                ],
                onPressed: (int index) {
                  setState(() {});
                  //isSelected[index] = !isSelected[index];
                  if (index == 0) TimeHandler();
                  else if (index == 1) shapeHandler();
                  else if (index == 2) {
                    isSelected[index] = !isSelected[index];
                    cameraHandler(isSelected[index]);
                  }
                  else if (index == 3) {
                    if (isSelected[index] && _playTime !=D_TIME){//if we are on timed and the button is pushed
                      _scaffoldKey.currentState.showSnackBar(snackBar);
                    }
                    else{
                      isSelected[index] = !isSelected[index];
                      gameHandler(index); //also turn food button off
                    }
                  }
                  else {
                    if (!isSelected[index]) {//if the button is on false
                      isSelected[index] = true;
                      foodHandler(index);
                    }
                    else{
                      if (_playTime==D_TIME) _scaffoldKey.currentState.showSnackBar(snackBar);
                      else _scaffoldKey.currentState.showSnackBar(snackBar2);
                    }

                  }
                },
                isSelected: isSelected,
                borderColor: Colors.lightBlueAccent,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ],
          ),
        ),
    );
  }
}

