// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:lasercat_db/screens/authenticate/play_page.dart';
// import 'package:lasercat_db/services/auth.dart';
//
// class SignIn extends StatefulWidget {
//   @override
//   _SignInState createState() => _SignInState();
// }
//
// class _SignInState extends State<SignIn> {
//
//   final AuthService _auth = AuthService();
//
//   @override
//   Widget build(BuildContext context) {
//    return Scaffold(
//       backgroundColor: Colors.brown[100],
//      appBar: AppBar(
//        backgroundColor: Colors.brown[400],
//        elevation: 0.0,
//        title: Text('Sign in to Laser Cat'),
//      ),
//      body: Container(
//        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
//        child: RaisedButton(
//          child: Text('Sign in anonymously'),
//          onPressed: () async{
//            dynamic user = await _auth.signInAnon();
//            if (user == null){
//              print('error signing in');
//            }else{
//              print("sucsessfuly signed in");
//              print(user);
//              return CameraPage();
//            }
//          },
//        ),
//      ),
//    );
//   }
// }
