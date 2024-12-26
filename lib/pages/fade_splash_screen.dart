import 'dart:async';
import 'package:flutter/material.dart';
import 'login_register_page.dart'; // Import the updated login_register_page.dart

class FadeSplashScreen extends StatefulWidget {
  const FadeSplashScreen({super.key});

  @override
  State<FadeSplashScreen> createState() => _FadeSplashScreenState();
}

class _FadeSplashScreenState extends State<FadeSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Define the fade animation
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    // Start the fade animation
    _controller.forward();

    // Navigate to the login/register page after 3 seconds
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const LoginRegisterPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(seconds: 2), // Fade transition duration
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF1A1A1D), // Dark gray
                  Color(0xFF3B1C32), // Deep purple
                  Color(0xFF6A1E55), // Vibrant purple
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Splash screen ball centered
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation, // Apply fade animation to the splash image
              child: Image.asset(
                'assets/splash_screen_ball.png',
                height: 200, // Size consistent with login_register_page.dart
                width: 200,  // Size consistent with login_register_page.dart
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
