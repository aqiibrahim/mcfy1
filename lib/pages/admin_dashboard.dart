import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile_page.dart';
import 'settings_page.dart';
import 'find_user_page.dart';
import 'find_scanned_qr.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String username = 'Admin';

  @override
  void initState() {
    super.initState();
    _fetchUsername();
  }

  Future<void> _fetchUsername() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();
        if (userDoc.exists) {
          setState(() {
            username = userDoc['username'] ?? 'Admin';
          });
        }
      }
    } catch (e) {
      setState(() {
        username = 'Admin';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false; // Prevent back navigation
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color(0xFF2B2129),
          automaticallyImplyLeading: false,
          title: const Text(
            'McFy',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Color(0xFFE5D1B8),
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfilePage(role: 'Admin'),
                  ),
                );
              },
              icon: const Icon(Icons.account_circle, color: Color(0xFFE5D1B8)),
            ),
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.white, size: 30),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsPage(role: 'Admin'),
                  ),
                );
              },
            ),
          ],
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFDD8E58),
                Color(0xFF708A81),
                Color(0xFF2B2129),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  'Welcome Back,',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Color(0xFFE5D1B8),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  username,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 26,
                    color: Color(0xFF2B2129),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      context,
                      icon: Icons.person_search,
                      label: 'Find User',
                      color: const Color(0xFF708A81),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const FindUserPage()),
                        );
                      },
                    ),
                    _buildActionButton(
                      context,
                      icon: Icons.qr_code_scanner,
                      label: 'Find MC',
                      color: const Color(0xFFDD8E58),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const FindScannedQRPage()),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // View Report Button
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Add functionality for viewing reports
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2B2129),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 30),
                  ),
                  icon: const Icon(
                    Icons.report,
                    color: Color(0xFFE5D1B8),
                    size: 28,
                  ),
                  label: const Text(
                    'View Report',
                    style: TextStyle(color: Color(0xFFE5D1B8), fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: TextButton.icon(
          onPressed: onTap,
          icon: Icon(icon, color: const Color(0xFF2B2129), size: 28),
          label: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFFE5D1B8),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
