import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lasercat_db/models/user.dart';
import 'package:lasercat_db/screens/wrapper.dart';
import 'package:lasercat_db/services/auth.dart';
import 'package:provider/provider.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.


  @override
  Widget build(BuildContext context) {
    return StreamProvider<CatUser>.value(
      value: AuthService().user,
      child: MaterialApp(
        home: Wrapper(),
      ),
    );
  }
}
