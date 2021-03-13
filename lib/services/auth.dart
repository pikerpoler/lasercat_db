import 'package:firebase_auth/firebase_auth.dart';
import 'package:lasercat_db/models/user.dart';


class AuthService {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  //create user obj based on firebase user

  CatUser _userFromFirebaseUser(User user){
    return user != null ? CatUser(uid: user.uid) : null;
  }

  CatUser getCurrentUser(){
    return _userFromFirebaseUser(_auth.currentUser);
  }

  // auth change user stream
  Stream<CatUser> get user {

    return FirebaseAuth.instance.authStateChanges().map((firebaseUser) => _userFromFirebaseUser(firebaseUser));


    //     .listen((firebaseUser)
    //
    // // {
    // //   // do whatever you want based on the firebaseUser state
    // //   print("user changed!!");
    // //   // print(firebaseUser);
    // //   // print(_userFromFirebaseUser(firebaseUser));
    // //   return _userFromFirebaseUser(firebaseUser);
    // // });
    //
    // // return _auth.authStateChanges()
    // //   //.map((FirebaseUser user) => _userFromFirebaseUser(user));
    // //   .map(_userFromFirebaseUser);
  }

  // sign in anonymously
    Future signInAnon() async{
      try {
        UserCredential result = await _auth.signInAnonymously();
        User user = result.user;
        return _userFromFirebaseUser(user);
      } catch(e){
        print('signin failed');
        print(e.toString());
        return null;
      }
    }

  // sign in with email and password
  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User user = result.user;
      return user;
    } catch (error) {
      print(error.toString());
      return null;
    }
  }

  // register with email and password
  Future registerWithEmailAndPassword(String email, String password) async {
    try {
      print("trying to creaye user");
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      print("created, result:");
      print(result);
      User user = result.user;
      print("user:");
      print(user);
      // create a new document for the user with the uid
      //await DatabaseService(uid: user.uid).updateUserData('0','new crew member', 100);


      return _userFromFirebaseUser(user);
    } catch (error) {
      print(error.toString());
      return null;
    }
  }

  // sign out
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (error) {
      print(error.toString());
      return null;
    }
  }

}