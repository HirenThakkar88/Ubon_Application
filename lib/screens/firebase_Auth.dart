import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ubon_application/main.dart';
import 'package:ubon_application/screens/home_screen.dart';

class Authservice {
  final _auth = FirebaseAuth.instance;

   Future<Map<String, String>?> signInWithGoogle() async {
  
  // goToHome(BuildContext context) => Navigator.of(context).pushReplacement(
  //             MaterialPageRoute(builder: (context) => HomeScreen()),
  //           );

    try {
      // Perform the Google sign-in
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        return null; // User aborted sign-in
      }

      // Retrieve Google Sign-In authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Ensure that accessToken and idToken are not null
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        throw Exception('Google sign-in authentication failed. Missing token.');
      }

      // Sign in to Firebase with the Google credentials
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase and retrieve user details
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = userCredential.user;

      // Ensure user is not null before proceeding
      if (user == null) {
        throw Exception('Google sign-in failed. No user information.');
      }

      final uid = user.uid;
      final email = user.email ?? 'No email';
      final displayName = user.displayName ?? 'No name';

      // Fetch user data from Firestore by email
      final firestore = FirebaseFirestore.instance;
      final querySnapshot = await firestore
          .collection('authentication')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userDoc = querySnapshot.docs.first;
        final password = userDoc['password'];

        if (userDoc['user_type'] == null) {
          await userDoc.reference.update({'user_type': 'basic user'});
        }

        // If the password is not null, sign in and go to Home screen
        if (password != null && password.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final BuildContext? currentContext =
                navigatorKey.currentState?.context;

            if (currentContext != null) {
              Navigator.of(currentContext).pushReplacement(
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            }
          });
        } else {
          // If the password is null, prompt user to recover password
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final BuildContext? currentContext =
                navigatorKey.currentState?.context;

            if (currentContext != null) {
              Navigator.of(currentContext).pushReplacement(
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            }
          });
        }
      } else {
        // If user doesn't exist in Firestore, create a new entry
        await firestore.collection('authentication').doc(uid).set({
          'auth_id': uid,
          'email': email,
          'name': displayName,
          'password': null, // Password initially set to null
          'user_type': 'basic user',
        });

        // Redirect to SetPassword screen
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final BuildContext? currentContext =
              navigatorKey.currentState?.context;

          if (currentContext != null) {
            Navigator.of(currentContext).pushReplacement(
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          }
        });
      }

      // Return user details as a map
      return {
        'uid': uid,
        'email': email,
      };
    } catch (e) {
      print('Error during Google sign-in: $e');
      return null;
    }
  }

  Future<UserCredential?> LoginWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      final googleAuth = await googleUser?.authentication;
      final cred = GoogleAuthProvider.credential(
          idToken: googleAuth?.idToken, accessToken: googleAuth?.accessToken);

      return await _auth.signInWithCredential(cred);
    } catch (e) {
      print(e.toString());
    }
    return null;
  }

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
