import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'pages/login_register_page.dart'; // Import the login/register page
import 'pages/lecturer_dashboard.dart'; // Import the lecturer dashboard
import 'pages/admin_dashboard.dart'; // Import the admin dashboard

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
        '/adminDashboard': (context) => const AdminDashboard(),
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
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading indicator while waiting for Firebase
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData) {
          // If a user is logged in, fetch their role and navigate accordingly
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(snapshot.data!.uid)
                .get(),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (roleSnapshot.hasData && roleSnapshot.data != null) {
                final role = roleSnapshot.data!['role'];

                // Navigate to the appropriate dashboard based on the user's role
                if (role == 'admin') {
                  return const AdminDashboard();
                } else if (role == 'lecturer') {
                  return const LecturerDashboard();
                } else {
                  return const LoginRegisterPage(); // Fallback to login if role is invalid
                }
              } else {
                // If there's an error fetching role or no role is found, log out the user
                FirebaseAuth.instance.signOut();
                return const LoginRegisterPage();
              }
            },
          );
        } else {
          // If no user is logged in, navigate to the login/register page
          return const LoginRegisterPage();
        }
      },
    );
  }
}
