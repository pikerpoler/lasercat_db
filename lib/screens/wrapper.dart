import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lasercat_db/models/user.dart';
import 'package:lasercat_db/screens/authenticate/authenticate.dart';
import 'file:///C:/Users/nadav/AndroidStudioProjects/lasercat_db/lib/screens/play_page.dart';
import 'package:provider/provider.dart';
import 'package:lasercat_db/services/auth.dart';


class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.landscapeLeft,
    //   DeviceOrientation.landscapeRight,
    // ]);
    var user = FirebaseAuth.instance.currentUser != null ? CatUser(uid: FirebaseAuth.instance.currentUser.uid) : null;
    user = Provider.of<CatUser>(context);
    // return either the Home or Authenticate widget
    print(user);
    return CameraPage();
    if (user == null){

      return Authenticate();
    } else {
      return CameraPage();
    }

  }
}
