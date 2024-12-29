import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mcfy1/pages/generate_mc_page.dart';
import 'package:mcfy1/pages/profile_page.dart';
import 'package:mcfy1/pages/settings_page.dart';
import 'package:mcfy1/pages/mc_display_page.dart';
import 'package:mcfy1/pages/search_page.dart';

class ClinicStaffDashboard extends StatelessWidget {
  const ClinicStaffDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false; // Prevent navigation back
      },
      child: Scaffold(
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
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Welcome Section with Dynamic Username
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

                          return Row(
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.purple,
                                child: const Icon(Icons.person, color: Colors.white, size: 40),
                              ),
                              const SizedBox(width: 15),
                              Column(
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
                              ),
                            ],
                          );
                        } else if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
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
                    const SizedBox(height: 20),

                    // Recent Activity Section
                    const Text(
                      'Recent Activity',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('medical_certificates')
                            .where('generatedBy',
                                isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                            .orderBy('timestamp', descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final docs = snapshot.data!.docs;
                          if (docs.isEmpty) {
                            return const Center(
                              child: Text(
                                'No recent activity.',
                                style: TextStyle(color: Colors.white70),
                              ),
                            );
                          }

                          return ListView.builder(
                            itemCount: docs.length,
                            itemBuilder: (context, index) {
                              final activity = docs[index].data() as Map<String, dynamic>;
                              final name = activity['name'] ?? 'Unknown';
                              final matricNumber = activity['matricNumber'] ?? 'Unknown';
                              final stayOffDays = activity['stayOffDays'] ?? 'Unknown';
                              final documentId = docs[index].id; // Fetch the document ID for navigation

                              return GestureDetector(
                                onTap: () {
                                  // Navigate to MCDisplayPage with the selected document ID
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MCDisplayPage(
                                        documentId: documentId, // Pass the Firestore document ID
                                      ),
                                    ),
                                  );
                                },
                                child: Card(
                                  color: Colors.white.withOpacity(0.1),
                                  child: ListTile(
                                    title: Text(
                                      'Patient: $name',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Matric Number: $matricNumber',
                                          style: const TextStyle(color: Colors.white70),
                                        ),
                                        Text(
                                          'Stay-Off Days: $stayOffDays',
                                          style: const TextStyle(color: Colors.white70),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          color: const Color(0xFF3B1C32),
          shape: const CircularNotchedRectangle(),
          notchMargin: 8.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.blue),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SearchPage(), // Navigate to SearchPage
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.account_circle, color: Colors.green),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfilePage(role: 'ClinicStaff'),
                    ),
                  );
                },
              ),
              const SizedBox(width: 50), // Space for the middle button
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.orange),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsPage(role: 'ClinicStaff'),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.red),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/loginRegister', (route) => false);
                },
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.orange,
          child: const Icon(Icons.medical_services, size: 32),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const GenerateMCPage()),
            );
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }
}
