import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mcfy1/pages/generate_mc_page.dart';
import 'package:mcfy1/pages/profile_page.dart';
import 'package:mcfy1/pages/settings_page.dart';
import 'package:mcfy1/pages/mc_display_page.dart';
import 'package:mcfy1/pages/search_page.dart';
import 'package:mcfy1/pages/all_qr_codes_page.dart';

class ClinicStaffDashboard extends StatelessWidget {
  const ClinicStaffDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Prevent navigation back
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9F9), // Light background
        body: SafeArea(
          child: Column(
            children: [
              // Gradient Header with Greeting
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF6A1E55),
                      Color(0xFF3B1C32),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF6A1E55),
                                Color(0xFF3B1C32),
                              ],
                            ),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: const CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.person,
                              color: Color(0xFF6A1E55),
                              size: 30,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Welcome back,",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                fontFamily: "Montserrat",
                                color: Colors.white70,
                              ),
                            ),
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
                                  return Text(
                                    username,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  );
                                } else {
                                  return const Text(
                                    'User',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.white),
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/loginRegister', (route) => false);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Search Bar
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SearchPage()),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "Search patients by name or matric number...",
                        style: TextStyle(
                          color: Color(0xFF9DA3B4),
                        ),
                      ),
                      Icon(Icons.search, color: Color(0xFF6A1E55)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Recent Activity Section
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Recent Activity',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF22215B),
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
                                  style: TextStyle(color: Color(0xFF9DA3B4)),
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
                                final documentId = docs[index].id;

                                return Container(
                                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF6A1E55),
                                        Color(0xFF3B1C32),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(16),
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
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => MCDisplayPage(
                                            documentId: documentId,
                                          ),
                                        ),
                                      );
                                    },
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
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.search, color: Color(0xFF4E85FF)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SearchPage()),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.account_circle, color: Color(0xFF34C759)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfilePage(role: 'ClinicStaff'),
                    ),
                  );
                },
              ),
              SizedBox(
                width: 60,
                height: 60,
                child: FloatingActionButton(
                  backgroundColor: const Color(0xFF4E85FF),
                  child: const Icon(Icons.add, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const GenerateMCPage()),
                    );
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.folder, color: Color(0xFFFFCC00)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AllQRCodesPage(),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings, color: Color(0xFFFF9500)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsPage(role: 'ClinicStaff'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
