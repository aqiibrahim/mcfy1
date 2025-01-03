import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mcfy1/pages/generate_mc_page.dart';
import 'package:mcfy1/pages/profile_page.dart';
import 'package:mcfy1/pages/settings_page.dart';
import 'package:mcfy1/pages/mc_display_page.dart';
import 'package:mcfy1/pages/all_qr_codes_page.dart';
import 'search_page.dart';

class ClinicStaffDashboard extends StatefulWidget {
  const ClinicStaffDashboard({Key? key}) : super(key: key);

  @override
  State<ClinicStaffDashboard> createState() => _ClinicStaffDashboardState();
}

class _ClinicStaffDashboardState extends State<ClinicStaffDashboard> {
  final TextEditingController _searchController = TextEditingController();
  List<QueryDocumentSnapshot> _filteredDocs = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _fetchRecentActivity();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchRecentActivity() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('medical_certificates')
          .where('generatedBy', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();

      setState(() {
        _filteredDocs = querySnapshot.docs;
      });
    }
  }

  void _onSearchChanged() {
    _filterResults(_searchController.text.trim());
  }

  void _filterResults(String query) {
    if (query.isEmpty) {
      _fetchRecentActivity();
      return;
    }

    setState(() {
      _isSearching = true;
    });

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      FirebaseFirestore.instance
          .collection('medical_certificates')
          .where('generatedBy', isEqualTo: userId)
          .get()
          .then((querySnapshot) {
        final results = querySnapshot.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final name = (data['name'] ?? '').toLowerCase();
          final matricNumber = (data['matricNumber'] ?? '').toLowerCase();
          final lowerQuery = query.toLowerCase();
          return name.contains(lowerQuery) || matricNumber.contains(lowerQuery);
        }).toList();

        setState(() {
          _filteredDocs = results;
          _isSearching = false;
        });
      });
    }
  }

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
                                Color(0xFF8E44AD), // Deep purple
                                Color(0xFF3498DB), // Soft blue
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    hintText: 'Search patients by name or matric number',
                    hintStyle: const TextStyle(color: Colors.black54),
                    prefixIcon: const Icon(Icons.search, color: Colors.black54),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear, color: Colors.black54),
                      onPressed: () {
                        _searchController.clear();
                        _fetchRecentActivity();
                      },
                    ),
                  ),
                  style: const TextStyle(color: Colors.black),
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
                        child: _isSearching
                            ? const Center(child: CircularProgressIndicator())
                            : _filteredDocs.isEmpty
                                ? const Center(
                                    child: Text(
                                      'No recent activity.',
                                      style: TextStyle(color: Color(0xFF9DA3B4)),
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: _filteredDocs.length,
                                    itemBuilder: (context, index) {
                                      final activity = _filteredDocs[index].data()
                                          as Map<String, dynamic>;
                                      final name = activity['name'] ?? 'Unknown';
                                      final matricNumber =
                                          activity['matricNumber'] ?? 'Unknown';
                                      final stayOffDays =
                                          activity['stayOffDays'] ?? 'Unknown';
                                      final documentId = _filteredDocs[index].id;

                                      return Container(
                                        margin:
                                            const EdgeInsets.symmetric(vertical: 8.0),
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
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Matric Number: $matricNumber',
                                                style: const TextStyle(
                                                    color: Colors.white70),
                                              ),
                                              Text(
                                                'Stay-Off Days: $stayOffDays',
                                                style: const TextStyle(
                                                    color: Colors.white70),
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
