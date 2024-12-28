import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsPage extends StatelessWidget {
  final String role; // Add role parameter for theme differentiation

  const SettingsPage({Key? key, required this.role}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine colors based on role
    final Color backgroundColor =
        role == 'ClinicStaff' ? const Color(0xFF680C5D) : const Color(0xFF2B2129);
    final Color gradientStart =
        role == 'ClinicStaff' ? const Color(0xFFF78FB3) : const Color(0xFFDD8E58);
    final Color gradientEnd =
        role == 'ClinicStaff' ? const Color(0xFF680C5D) : const Color(0xFF2B2129);
    final Color iconColor =
        role == 'ClinicStaff' ? const Color(0xFFFED4E0) : const Color(0xFFE5D1B8);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: const Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Color(0xFFE5D1B8),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: iconColor),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous page
          },
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [gradientStart, gradientEnd],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Account Settings',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color(0xFFE5D1B8),
              ),
            ),
            const SizedBox(height: 20),
            _buildSettingItem(
              icon: Icons.person,
              label: 'Edit Profile',
              onTap: () {
                // Navigate to Edit Profile Page
              },
              iconColor: iconColor,
            ),
            _buildSettingItem(
              icon: Icons.lock,
              label: 'Change Password',
              onTap: () {
                // Navigate to Change Password Page
              },
              iconColor: iconColor,
            ),
            const Divider(color: Color(0xFFE5D1B8), thickness: 1.0),
            const Text(
              'App Settings',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color(0xFFE5D1B8),
              ),
            ),
            const SizedBox(height: 20),
            _buildSettingItem(
              icon: Icons.notifications,
              label: 'Notifications',
              onTap: () {
                // Navigate to Notifications Page
              },
              iconColor: iconColor,
            ),
            _buildSettingItem(
              icon: Icons.language,
              label: 'Language',
              onTap: () {
                // Navigate to Language Selection Page
              },
              iconColor: iconColor,
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/loginRegister', (route) => false);
                  } catch (e) {
                    print('Error logging out: $e');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: backgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                      vertical: 15, horizontal: 30),
                ),
                child: Text(
                  'Logout',
                  style: TextStyle(color: iconColor, fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color iconColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          color: iconColor,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, color: iconColor),
      onTap: onTap,
    );
  }
}
