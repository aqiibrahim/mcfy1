import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  final String role;

  const ProfilePage({Key? key, required this.role}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String username = 'User';
  String email = '';

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            username = userDoc['username'] ?? 'User';
            email = user.email ?? 'No email';
          });
        }
      }
    } catch (e) {
      print('Error fetching user profile: $e');
    }
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushNamedAndRemoveUntil(context, '/loginRegister', (route) => false);
    } catch (e) {
      print('Error logging out: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor =
        widget.role == 'ClinicStaff' ? const Color(0xFF680C5D) : const Color(0xFF2B2129);
    final Color gradientStart =
        widget.role == 'ClinicStaff' ? const Color(0xFFF78FB3) : const Color(0xFFDD8E58);
    final Color gradientEnd =
        widget.role == 'ClinicStaff' ? const Color(0xFF680C5D) : const Color(0xFF2B2129);
    final Color iconColor =
        widget.role == 'ClinicStaff' ? const Color(0xFFFED4E0) : const Color(0xFFE5D1B8);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: Text(
          'Profile - ${widget.role}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: iconColor,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [gradientStart, gradientEnd],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: iconColor,
                  child: Icon(Icons.person, size: 60, color: backgroundColor),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  username,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: iconColor,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  email,
                  style: TextStyle(
                    fontSize: 16,
                    color: iconColor,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Divider(color: Colors.white.withOpacity(0.5)),
              const SizedBox(height: 20),
              _buildProfileItem(
                title: 'Role',
                value: widget.role,
                icon: Icons.assignment_ind,
                iconColor: iconColor,
              ),
              const SizedBox(height: 10),
              _buildProfileItem(
                title: 'Username',
                value: username,
                icon: Icons.person,
                iconColor: iconColor,
              ),
              const Spacer(),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _logout,
                  icon: Icon(Icons.logout, color: backgroundColor),
                  label: Text(
                    'Logout',
                    style: TextStyle(color: backgroundColor),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: iconColor,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
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

  Widget _buildProfileItem({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor),
        const SizedBox(width: 10),
        Text(
          '$title: ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: iconColor,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: iconColor,
            ),
          ),
        ),
      ],
    );
  }
}
