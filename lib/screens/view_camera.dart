import 'dart:convert';

import 'package:flutter/material.dart';
// import 'package:flutter_webrtc/web/rtc_session_description.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:lasercat_db/services/messeges.dart';
import 'package:sdp_transform/sdp_transform.dart';


class camera_widget extends StatefulWidget {
  camera_widget({Key key}) : super(key: key);


  @override
  _camera_widgetState createState() => _camera_widgetState();
}

class _camera_widgetState extends State<camera_widget> {

  var _my_candidate;
  bool _offer = false;
  RTCPeerConnection _peerConnection;
  MediaStream _localStream;
  RTCVideoRenderer _localRenderer = new RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = new RTCVideoRenderer();

  final sdpController = TextEditingController();

  @override
  dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    sdpController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    print("init state");
    initRenderers();
    _createPeerConnection().then((pc) {
      _peerConnection = pc;
    });

    //connect_with_messegas();
    super.initState();
  }

  initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  void connect_with_messegas() async{
    // await _createPeerConnection().then((pc) {
    //   _peerConnection = pc;
    // });
    print("pc = ");
    print(_peerConnection);
    print("connecting with messages");
    RTCSessionDescription description =
    await _peerConnection.createOffer({'offerToReceiveVideo': 1});
    print("created offer, description =");
    print(description.sdp);

    print("set local desc");
    var session = parse(description.sdp).toString();
    print("session =");
    print(session);
    print("json session =");
    print(json.encode(session));
    _peerConnection.setLocalDescription(description);

    sendMessage("OFFER", description.sdp, 10);
    Message answer = await reciveMessage();
    if(answer.message_type != "ANSWER"){
      print("ERROR: message_type != ANSWER");
      return;
    }
    print("answer is:");
    dynamic sdp = answer.message;
    print(sdp);


    // RTCSessionDescription description =
    //     new RTCSessionDescription(session['sdp'], session['type']);
    RTCSessionDescription in_description =
    new RTCSessionDescription(sdp, 'answer');
    print(in_description.toMap());

    await _peerConnection.setRemoteDescription(in_description);
    print("should work now");
  }

  void _print_pressed() async{
    connect_with_messegas();
    print("pressed");
  }

  void _createOffer() async {
    RTCSessionDescription description =
    await _peerConnection.createOffer({'offerToReceiveVideo': 1});
    var session = parse(description.sdp);
    print(json.encode(session));
    _offer = true;

    // print(json.encode({
    //       'sdp': description.sdp.toString(),
    //       'type': description.type.toString(),
    //     }));

    _peerConnection.setLocalDescription(description);
  }

  void _createAnswer() async {
    RTCSessionDescription description =
    await _peerConnection.createAnswer({'offerToReceiveVideo': 1});

    var session = parse(description.sdp);
    print(json.encode(session));
    // print(json.encode({
    //       'sdp': description.sdp.toString(),
    //       'type': description.type.toString(),
    //     }));

    _peerConnection.setLocalDescription(description);
  }

  void _setRemoteDescription() async {
    String jsonString = sdpController.text;
    dynamic session = await jsonDecode('$jsonString');

    String sdp = write(session, null);

    // RTCSessionDescription description =
    //     new RTCSessionDescription(session['sdp'], session['type']);
    RTCSessionDescription description =
    new RTCSessionDescription(sdp, _offer ? 'answer' : 'offer');
    print(description.toMap());

    await _peerConnection.setRemoteDescription(description);
  }

  void _addCandidate() async {
    String jsonString = sdpController.text;
    dynamic session = await jsonDecode('$jsonString');
    print(session['candidate']);
    dynamic candidate =
    new RTCIceCandidate(session['candidate'], session['sdpMid'], session['sdpMlineIndex']);
    await _peerConnection.addCandidate(candidate);
  }

  _createPeerConnection() async {
    print("creating peer connections");
    Map<String, dynamic> configuration = {
      "iceServers": [
        //{"url": "stun:stun.l.google.com:19302"},
        {"url": "stun:eu-turn3.xirsys.com"},
      ]
    };

    final Map<String, dynamic> offerSdpConstraints = {
      "mandatory": {
        "OfferToReceiveAudio": true,
        "OfferToReceiveVideo": true,
      },
      "optional": [],
    };

    _localStream = await _getUserMedia();

    RTCPeerConnection pc = await createPeerConnection(configuration, offerSdpConstraints);
    if (pc != null) print(pc);
    pc.addStream(_localStream);

    pc.onIceCandidate = (e) {
      if (e.candidate != null) {
        _my_candidate =json.encode({
          'candidate': e.candidate.toString(),
          'sdpMid': e.sdpMid.toString(),
          'sdpMlineIndex': e.sdpMlineIndex,
        });


        print(json.encode({ // TODO remove
          'candidate': e.candidate.toString(),
          'sdpMid': e.sdpMid.toString(),
          'sdpMlineIndex': e.sdpMlineIndex,
        }));
      }
    };

    pc.onIceConnectionState = (e) {
      print(e);
    };

    pc.onAddStream = (stream) {
      print('addStream: ' + stream.id);
      _remoteRenderer.srcObject = stream;
    };

    return pc;
  }

  _getUserMedia() async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': false,
      'video': {
        'facingMode': 'user',
      },
    };

    MediaStream stream = await navigator.getUserMedia(mediaConstraints);

    // _localStream = stream;
    _localRenderer.srcObject = stream;
    // _localRenderer.mirror = true;

    // _peerConnection.addStream(stream);

    return stream;
  }

  SizedBox videoRenderers() => SizedBox(
      height: 200,
      child: Row(children: [
        // Flexible(
        //   child: new Container(
        //       key: new Key("local"),
        //       margin: new EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
        //       decoration: new BoxDecoration(color: Colors.black),
        //       child: new RTCVideoView(_localRenderer)
        //   ),
        // ),
        Flexible(
          child: new Container(
              key: new Key("remote"),
              margin: new EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
              decoration: new BoxDecoration(color: Colors.black),
              child: new RTCVideoView(_remoteRenderer)),
        )
      ]));

  Row offerAndAnswerButtons() =>
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: <Widget>[
        new RaisedButton(
          // onPressed: () {
          //   return showDialog(
          //       context: context,
          //       builder: (context) {
          //         return AlertDialog(
          //           content: Text(sdpController.text),
          //         );
          //       });
          // },
          onPressed: _print_pressed, // _createOffer,
          child: Text('Offer'),
          color: Colors.amber,
        ),
        RaisedButton(
          onPressed: _createOffer,
          child: Text('Answer'),
          color: Colors.amber,
        ),
      ]);

  Row sdpCandidateButtons() =>
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: <Widget>[
        RaisedButton(
          onPressed: _setRemoteDescription,
          child: Text('Set Remote Desc'),
          color: Colors.amber,
        ),
        RaisedButton(
          onPressed: _addCandidate,
          child: Text('Add Candidate'),
          color: Colors.amber,
        )
      ]);

  Padding sdpCandidatesTF() => Padding(
    padding: const EdgeInsets.all(4.0),
    child: TextField(
      controller: sdpController,
      keyboardType: TextInputType.multiline,
      maxLines: 4,
      maxLength: TextField.noMaxLength,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            child: Column(children: [
              videoRenderers(),
              offerAndAnswerButtons(),
              //sdpCandidatesTF(),
              //sdpCandidateButtons(),
            ])));
  }
}

int connect(){

  return 1;
}
