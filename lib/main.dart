import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'pages/fade_splash_screen.dart'; // Import the fade splash screen
import 'pages/login_register_page.dart'; // Import the login/register page
import 'pages/lecturer_dashboard.dart'; // Import the lecturer dashboard

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'McFy',
      theme: ThemeData.dark(), // We use a dark theme as base
      home: const AuthChecker(), // Initial page based on auth state
      routes: {
        '/loginRegister': (context) => const LoginRegisterPage(),
        '/lecturerDashboard': (context) => const LecturerDashboard(),
      },
    );
  }
}

/// AuthChecker determines the first page to display based on user's auth state.
class AuthChecker extends StatelessWidget {
  const AuthChecker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(), // Listen to auth state changes
      builder: (context, snapshot) {
        // Check if the user is authenticated
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading indicator while waiting for Firebase
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          // If a user is logged in, navigate to the lecturer dashboard
          return const LecturerDashboard();
        } else {
          // If no user is logged in, navigate to the login/register page
          return const LoginRegisterPage();
        }
      },
    );
  }
}
