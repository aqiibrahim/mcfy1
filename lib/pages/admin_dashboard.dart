import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mcfy1/pages/search_mc.dart';
import 'profile_page.dart';
import 'settings_page.dart';
import 'report_list_view.dart';
import 'login_register_page.dart';
import 'admin_user_list.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String username = 'Admin';
  bool isLoading = true;
  int totalLecturers = 0;
  int totalReports = 0;
  int totalMedicalCertificates = 0;
  int totalClinicStaff = 0;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
    _fetchTotalLecturers();
    _fetchTotalReports();
    _fetchTotalMedicalCertificates();
    _fetchTotalClinicStaff();
  }

  Future<void> _checkAuthentication() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _redirectToLogin();
        return;
      }
      await _fetchUsername(user.uid);
    } catch (e) {
      debugPrint('Error: $e');
      _redirectToLogin();
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchUsername(String userId) async {
    try {
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(userId).get();

      if (userDoc.exists) {
        setState(() {
          username = userDoc.data()?['username'] ?? 'Admin';
        });
      } else {
        username = 'Admin';
      }
    } catch (e) {
      debugPrint('Failed to fetch username: $e');
      username = 'Admin';
    }
  }

  Future<void> _fetchTotalLecturers() async {
    try {
      final lecturersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'Lecturer')
          .get();
      setState(() {
        totalLecturers = lecturersSnapshot.docs.length;
      });
    } catch (e) {
      debugPrint('Failed to fetch total lecturers: $e');
      setState(() {
        totalLecturers = 0;
      });
    }
  }

  Future<void> _fetchTotalReports() async {
    try {
      final reportsSnapshot = await FirebaseFirestore.instance.collection('reports').get();
      setState(() {
        totalReports = reportsSnapshot.docs.length;
      });
    } catch (e) {
      debugPrint('Failed to fetch total reports: $e');
      setState(() {
        totalReports = 0;
      });
    }
  }

  Future<void> _fetchTotalMedicalCertificates() async {
    try {
      final mcSnapshot =
          await FirebaseFirestore.instance.collection('medical_certificates').get();
      setState(() {
        totalMedicalCertificates = mcSnapshot.docs.length;
      });
    } catch (e) {
      debugPrint('Failed to fetch total medical certificates: $e');
      setState(() {
        totalMedicalCertificates = 0;
      });
    }
  }

  Future<void> _fetchTotalClinicStaff() async {
    try {
      final clinicStaffSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'IIUM Clinic Staff')
          .get();
      setState(() {
        totalClinicStaff = clinicStaffSnapshot.docs.length;
      });
    } catch (e) {
      debugPrint('Failed to fetch total clinic staff: $e');
      setState(() {
        totalClinicStaff = 0;
      });
    }
  }

  void _redirectToLogin() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginRegisterPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: Column(
          children: [
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Welcome back,",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
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
            Expanded(
              child: GridView.count(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  _buildCard(
                    'Medical Certificates',
                    totalMedicalCertificates.toString(),
                    Icons.medical_services,
                    Colors.purple,
                  ),
                  _buildCard(
                    'Lecturers',
                    totalLecturers.toString(),
                    Icons.school,
                    Colors.blue,
                  ),
                  _buildCard(
                    'Reports',
                    totalReports.toString(),
                    Icons.report,
                    Colors.orange,
                  ),
                  _buildCard(
                    'Clinic Staff',
                    totalClinicStaff.toString(),
                    Icons.person,
                    Colors.green,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, -4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavButton(
              context,
              icon: Icons.report,
              label: 'Reports',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ReportListView()),
                );
              },
            ),
            _buildNavButton(
              context,
              icon: Icons.group,
              label: 'User List',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminUserList()),
                );
              },
            ),
            _buildNavButton(
              context,
              icon: Icons.qr_code_scanner,
              label: 'MC List',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchMCPage()),
                );
              },
            ),
            _buildNavButton(
              context,
              icon: Icons.settings,
              label: 'Settings',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SettingsPage(role: 'Admin')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String title, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
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
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(BuildContext context,
      {required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF6A1E55), size: 30),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(color: Color(0xFF6A1E55), fontSize: 12),
          ),
        ],
      ),
    );
  }
}
