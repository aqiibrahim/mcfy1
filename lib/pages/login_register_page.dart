import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mcfy1/pages/clinic_staff_dashboard.dart';
import 'package:mcfy1/pages/lecturer_dashboard.dart';
import 'package:mcfy1/pages/admin_dashboard.dart';



class LoginRegisterPage extends StatefulWidget {
  const LoginRegisterPage({super.key});

  @override
  State<LoginRegisterPage> createState() => _LoginRegisterPageState();
}

class _LoginRegisterPageState extends State<LoginRegisterPage> {
  bool isLogin = true; // Toggle between Login and Register
  String selectedRole = 'Admin'; // Default role
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Controllers for input fields
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController idNumberController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // Form validation key

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

          // Background Image (splash_screen_ball.png)
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: Image.asset(
                'assets/splash_screen_ball.png',
                height: 250,
                width: 250,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // Content on top of the background
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.9), // Slight dark overlay
                      borderRadius: BorderRadius.circular(20),
                    ),
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Title
                        const Text(
                          'McFy',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 5),

                        // Subtitle
                        const Text(
                          'Fast and Easy Verification',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Login/Register Tabs
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  isLogin = true;
                                });
                              },
                              child: Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isLogin ? Colors.orange : Colors.white,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  isLogin = false;
                                });
                              },
                              child: Text(
                                'Register',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: !isLogin ? Colors.orange : Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Login/Register Form
                        isLogin ? _buildLoginForm() : _buildRegisterForm(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

Widget _buildLoginForm() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      // Role Dropdown
      DropdownButtonFormField<String>(
        value: selectedRole,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          hintText: 'Role',
          hintStyle: const TextStyle(color: Colors.white70),
          prefixIcon: const Icon(Icons.person, color: Colors.white70),
        ),
        items: ['Admin', 'Lecturer', 'IIUM Clinic Staff']
            .map((role) => DropdownMenuItem<String>(
                  value: role,
                  child: Text(role),
                ))
            .toList(),
        onChanged: (value) {
          setState(() {
            selectedRole = value!;
          });
        },
      ),
      const SizedBox(height: 20),

      // Email TextField
      TextField(
        controller: emailController,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          hintText: 'Email',
          hintStyle: const TextStyle(color: Colors.white70),
          prefixIcon: const Icon(Icons.email, color: Colors.white70),
        ),
      ),
      const SizedBox(height: 20),

      // Password TextField
      TextField(
        controller: passwordController,
        obscureText: true,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          hintText: 'Password',
          hintStyle: const TextStyle(color: Colors.white70),
          prefixIcon: const Icon(Icons.lock, color: Colors.white70),
        ),
      ),
      const SizedBox(height: 20),

      // Login Button
      ElevatedButton(
        onPressed: _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text(
          'Login',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    ],
  );
}



  Widget _buildRegisterForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Role Dropdown
        DropdownButtonFormField<String>(
          value: selectedRole,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            hintText: 'Role',
            hintStyle: const TextStyle(color: Colors.white70),
            prefixIcon: const Icon(Icons.person, color: Colors.white70),
          ),
          items: ['Admin', 'Lecturer', 'IIUM Clinic Staff']
              .map((role) => DropdownMenuItem<String>(
                    value: role,
                    child: Text(role),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() {
              selectedRole = value!;
            });
          },
        ),
        const SizedBox(height: 20),

        // ID Number
        TextField(
          controller: idNumberController,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            hintText: 'Staff ID',
            hintStyle: const TextStyle(color: Colors.white70),
            prefixIcon: const Icon(Icons.badge, color: Colors.white70),
          ),
        ),
        const SizedBox(height: 20),

        // Username
        TextField(
          controller: usernameController,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            hintText: 'Username',
            hintStyle: const TextStyle(color: Colors.white70),
            prefixIcon: const Icon(Icons.person, color: Colors.white70),
          ),
        ),
        const SizedBox(height: 20),

        // Email
        TextField(
          controller: emailController,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            hintText: 'Email',
            hintStyle: const TextStyle(color: Colors.white70),
            prefixIcon: const Icon(Icons.email, color: Colors.white70),
          ),
        ),
        const SizedBox(height: 20),

        // Password
        TextFormField(
          controller: passwordController,
          obscureText: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            hintText: 'Password',
            hintStyle: const TextStyle(color: Colors.white70),
            prefixIcon: const Icon(Icons.lock, color: Colors.white70),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Password is required';
            }
            if (!RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}$')
                .hasMatch(value)) {
              return 'Invalid password';
            }
            return null;
          },
        ),
        const SizedBox(height: 10),

        // Password Requirements
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Password must include:',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ),
        const SizedBox(height: 5),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '- At least 8 characters\n- At least one uppercase letter\n- At least one number\n- At least one special character (!@#\$&*~)',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ),
        const SizedBox(height: 20),

        // Confirm Password
        TextFormField(
          controller: confirmPasswordController,
          obscureText: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            hintText: 'Confirm Password',
            hintStyle: const TextStyle(color: Colors.white70),
            prefixIcon: const Icon(Icons.lock, color: Colors.white70),
          ),
          validator: (value) {
            if (value != passwordController.text) {
              return 'Passwords do not match.';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),

        // Register Button
        ElevatedButton(
          onPressed: _register,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            'Register',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      ],
    );
  }

Future<void> _login() async {
  try {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    final userDoc = await _firestore
        .collection('users')
        .doc(userCredential.user!.uid)
        .get();

    if (userDoc.exists) {
      final storedRole = userDoc['role'];

      if (storedRole == selectedRole) {
        await _logLoginActivity(userCredential.user!.uid);

        if (storedRole == 'IIUM Clinic Staff' && mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ClinicStaffDashboard(),
            ),
          );
        } else if (storedRole == 'Lecturer' && mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LecturerDashboard(),
            ),
          );
        } else if (storedRole == 'Admin' && mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AdminDashboard(),
            ),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Dashboard for this role is not ready yet.')),
          );
        }
      } else {
        await _auth.signOut();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Incorrect role selected.')),
          );
        }
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not found.')),
      );
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login Failed: $e')),
      );
    }
  }
}

Future<void> _logLoginActivity(String userId) async {
  try {
    final existingActivityQuery = await _firestore
        .collection('loginHistory')
        .where('userId', isEqualTo: userId)
        .get();

    if (existingActivityQuery.docs.isNotEmpty) {
      // Update the latest document for the userId
      final docId = existingActivityQuery.docs.first.id;
      await _firestore.collection('loginHistory').doc(docId).update({
        'timestamp': FieldValue.serverTimestamp(),
      });
    } else {
      // Add a new document if none exists
      await _firestore.collection('loginHistory').add({
        'userId': userId,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  } catch (e) {
    print('Error logging login activity: $e');
  }
}


Future<void> _register() async {
  if (!_formKey.currentState!.validate()) return;

  try {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    await _firestore.collection('users').doc(userCredential.user!.uid).set({
      'idNumber': idNumberController.text.trim(),
      'username': usernameController.text.trim(),
      'email': emailController.text.trim(),
      'role': selectedRole,
      'createdAt': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Registration Successful')),
    );

    if (selectedRole == 'IIUM Clinic Staff' && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ClinicStaffDashboard(),
        ),
      );
    } else if (selectedRole == 'Lecturer' && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LecturerDashboard(),
        ),
      );
    } else if (selectedRole == 'Admin' && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const AdminDashboard(),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dashboard for this role is not ready yet.')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Registration Failed: $e')),
    );
  }
}

}
