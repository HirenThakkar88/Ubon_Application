
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ubon_application/screens/home_screen.dart';
import 'package:ubon_application/screens/login_screen.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  bool? isLoggedIn;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final loginStatus = prefs.getBool('isLoggedIn') ?? false;

    setState(() {
      isLoggedIn = loginStatus;
    });
  }

  Future<void> _updateLoginStatus(bool status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', status);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoggedIn == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text("Error occurred"),
            );
          } else {
            if (snapshot.data == null) {
              if (isLoggedIn == false) {
                return const LoginScreen();
              } else {
                _updateLoginStatus(false);
                return const LoginScreen();
              }
            } else {
              _updateLoginStatus(true);
              return  HomeScreen();
            }
          }
        },
      ),
    );
  }
}
