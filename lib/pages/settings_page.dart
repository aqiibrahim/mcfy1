import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2B2129),
        title: const Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Color(0xFFE5D1B8),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFE5D1B8)),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous page
          },
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
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
            ),
            _buildSettingItem(
              icon: Icons.lock,
              label: 'Change Password',
              onTap: () {
                // Navigate to Change Password Page
              },
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
            ),
            _buildSettingItem(
              icon: Icons.language,
              label: 'Language',
              onTap: () {
                // Navigate to Language Selection Page
              },
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Log out function here
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2B2129),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                      vertical: 15, horizontal: 30),
                ),
                child: const Text(
                  'Logout',
                  style: TextStyle(color: Color(0xFFE5D1B8), fontSize: 18),
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
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFE5D1B8)),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFFE5D1B8),
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, color: Color(0xFFE5D1B8)),
      onTap: onTap,
    );
  }
}
