import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:ubon_application/firebase_options.dart';
import 'package:ubon_application/screens/login_screen.dart';
import 'package:ubon_application/screens/splash_screen.dart';
import 'package:ubon_application/screens/wrapper.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:loader_overlay/loader_overlay.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Initialize the bindings
  await Firebase.initializeApp( 
  options: DefaultFirebaseOptions.currentPlatform,
  );// Initialize Firebase (if you're using it)
  runApp(const MyApp()); // Start the app
}

class MyApp extends StatefulWidget {

  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
   return GlobalLoaderOverlay(
    child: MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Login Page',
      theme: ThemeData(
        fontFamily: 'lora',
        primarySwatch: Colors.yellow,
      ),
      home:SplashScreen(),
    ),
    );
  }
}
