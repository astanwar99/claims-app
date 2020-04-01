import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //Return Future with firebase user if exists
  Future<FirebaseUser> getUser() {
    return _auth.currentUser();
  }

  //Wrapping firebase calls
  Future<void> logout() async {
    var result = await FirebaseAuth.instance.signOut();
    notifyListeners();
    return result;
  }

  Future createUser(
      {String firstName,
      String lastName,
      String email,
      String password}) async {
    var result = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
    var user = result.user;
    UserUpdateInfo info = UserUpdateInfo();
    info.displayName = '$firstName $lastName';
    return user.updateProfile(info);
  }

  Future loginUser({String email, String password}) async {
    try {
      var result = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      notifyListeners();
      return result.user;
    } catch (e) {
      throw new AuthException(e.code, e.message);
    }
  }
}
