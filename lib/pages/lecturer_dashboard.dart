import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'qr_details_page.dart';
import 'find_scanned_qr.dart';
import 'scanqr_page.dart';
import 'profile_page.dart';
import 'settings_page.dart';

class LecturerDashboard extends StatefulWidget {
  const LecturerDashboard({Key? key}) : super(key: key);

  @override
  State<LecturerDashboard> createState() => _LecturerDashboardState();
}

class _LecturerDashboardState extends State<LecturerDashboard> {
  String username = 'Lecturer';

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
            username = userDoc['username'] ?? 'Lecturer';
          });
        }
      }
    } catch (e) {
      setState(() {
        username = 'Lecturer';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Prevent going back
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color(0xFF2B2129), // Dark brownish-black
          automaticallyImplyLeading: false, // Removes the back button
          title: const Text(
            'McFy',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Color(0xFFE5D1B8), // Light beige
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfilePage(role: 'Lecturer'),
                  ),
                );
              },
              icon: const Icon(Icons.account_circle, color: Color(0xFFE5D1B8)),
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
              icon: const Icon(Icons.settings, color: Color(0xFFE5D1B8)),
            ),
          ],
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFDD8E58), // Light orange
                Color(0xFF708A81), // Muted green
                Color(0xFF2B2129), // Dark brownish-black
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  'Welcome Back,',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Color(0xFFE5D1B8), // Light beige
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
                    color: Color(0xFF2B2129), // Dark brownish-black
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF2B2129),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser?.uid)
                      .collection('scanned_qrs')
                      .orderBy('scannedAt', descending: true)
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
                          style: TextStyle(
                            color: Color(0xFFE5D1B8),
                            fontSize: 16,
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data() as Map<String, dynamic>;
                        final name = data['name'] ?? 'Unknown';
                        final matricNumber = data['matricNumber'] ?? 'Unknown';
                        final stayOffDays = data['stayOffDays'] ?? 'Unknown';

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => QRDetailsPage(
                                  serialNumber: data['serialNumber'] ?? 'N/A',
                                  mcData: data,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE5D1B8).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Name: $name',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFFE5D1B8),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Matric Number: $matricNumber',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF2B2129),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Stay-Off Days: $stayOffDays',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF2B2129),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      context,
                      icon: Icons.qr_code_scanner,
                      label: 'Scan QR',
                      color: const Color(0xFF708A81), // Muted green
                    ),
                    _buildActionButton(
                      context,
                      icon: Icons.search,
                      label: 'Find',
                      color: const Color(0xFFDD8E58), // Light orange
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {},
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
                    'Report',
                    style: TextStyle(color: Color(0xFFE5D1B8), fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 20),
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
  }) {
    return Expanded(
  child: Container(
    margin: const EdgeInsets.symmetric(horizontal: 10),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(10),
    ),
    child: TextButton.icon(
      onPressed: () {
        if (icon == Icons.qr_code_scanner) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ScanQRPage()),
          );
        } else if (icon == Icons.search) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FindScannedQRPage()),
          );
        }
      },
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
