import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Authservice {
  final _auth = FirebaseAuth.instance;
  Future<User?> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return cred.user;
    } catch (e) {
      //print("something went wrong");
      log("Something went wrong");
    }
    return null;
  }

  Future<User?> LoginUserWithEmailAndPassword(
      String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return cred.user;
    } catch (e) {
      //print("something went wrong");
      log("Something went wrong");
    }
    return null;
  }

  Future<void> signout() async {
    try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
      await _auth.signOut();
    } catch (e) {
      log("Something went wrong");
    }
  }
}
