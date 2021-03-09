// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:lasercat_db/models/user.dart';
//
//
// class AuthService {
//
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//
//   //create user obj based on firebase user
//
//   CatUser _userFromFrirebaseUser(User user){
//     return user != null ? CatUser(uid: user.uid) : null;
//   }
//
//   // sign in anonymously
//     Future signInAnon() async{
//       try {
//         UserCredential result = await _auth.signInAnonymously();
//         User user = result.user;
//         return _userFromFrirebaseUser(user);
//       } catch(e){
//         print('signin failed');
//         print(e.toString());
//         return null;
//       }
//     }
//
//   // sign in with email and password
//
//   // register
//
//   // sign out
//
// }