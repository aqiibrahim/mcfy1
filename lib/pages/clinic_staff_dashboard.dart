import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mcfy1/pages/generate_mc_page.dart';
import 'profile_page.dart';

class ClinicStaffDashboard extends StatelessWidget {
  const ClinicStaffDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient Background
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

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'McFy',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.account_circle, color: Color(0xFFFFD700)),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProfilePage(role: 'ClinicStaff'),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 10),
                          IconButton(
                            icon: const Icon(Icons.settings, color: Colors.white, size: 30),
                            onPressed: () {
                              // Settings action
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Welcome Section with Dynamic Username
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.purple,
                        child: const Icon(Icons.person, color: Colors.white, size: 40),
                      ),
                      const SizedBox(width: 15),
                      StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data != null) {
                            final userData =
                                snapshot.data!.data() as Map<String, dynamic>;
                            final username = userData['username'] ?? 'User';

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Hello',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white70,
                                  ),
                                ),
                                Text(
                                  username,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            );
                          } else if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else {
                            return const Text(
                              'Hello, User',
                              style: TextStyle(
                                fontSize: 22,
                                color: Colors.white,
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Dashboard Buttons
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 20,
                      children: [
                        _buildDashboardButton(
                          context: context, // Pass the context here
                          icon: Icons.medical_services,
                          title: 'Generate MC',
                          color: Colors.orange,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const GenerateMCPage()),
                            );
                          },
                        ),
                        _buildDashboardButton(
                          context: context, // Pass the context here
                          icon: Icons.assignment,
                          title: 'Activity',
                          color: Colors.purple,
                          onTap: () {
                            // Action for Activity
                          },
                        ),
                        _buildDashboardButton(
                          context: context, // Pass the context here
                          icon: Icons.search,
                          title: 'Find',
                          color: Colors.blue,
                          onTap: () {
                            // Action for Find
                          },
                        ),
                        _buildDashboardButton(
                          context: context, // Pass the context here
                          icon: Icons.file_present,
                          title: 'Documents',
                          color: Colors.green,
                          onTap: () {
                            // Action for Documents
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardButton({
    required BuildContext context, // Pass the context to use it for navigation
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
