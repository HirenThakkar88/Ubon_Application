import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:ubon_application/screens/wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Initialize the bindings
  await Firebase.initializeApp(); // Initialize Firebase (if you're using it)
  runApp(MyApp()); // Start the app
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login Page',
      theme: ThemeData(
        fontFamily: 'lora',
        primarySwatch: Colors.yellow,
      ),
      home: const Wrapper(),
    );
  }
}
