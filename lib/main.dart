import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'pages/fade_splash_screen.dart'; // Import the fade splash screen
import 'pages/login_register_page.dart'; // Import the login/register page
//import 'pages/profile_page.dart'; // Import the profile page
import 'pages/lecturer_dashboard.dart'; 
//import 'pages/settings_page.dart';// Import the lecturer dashboard

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'McFy',
      theme: ThemeData.dark(), // We use dark theme as base
      home: const FadeSplashScreen(), // Set the splash screen as the initial page
      routes: {
        '/loginRegister': (context) => const LoginRegisterPage(),
        //'/profile': (context) => const ProfilePage(),
        '/lecturerDashboard': (context) => const LecturerDashboard(),
        //'/settings': (context) => const SettingsPage(),
      },
    );
  }
}