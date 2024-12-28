import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  final String role;

  const ProfilePage({Key? key, required this.role}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? profileImageUrl;
  final ImagePicker _picker = ImagePicker();

  Future<void> _uploadProfilePicture() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null && userId != null) {
      final file = File(pickedFile.path);
      final ref = FirebaseStorage.instance
          .ref()
          .child('profileImages')
          .child('$userId.jpg');

      try {
        final uploadTask = await ref.putFile(file);
        final imageUrl = await uploadTask.ref.getDownloadURL();

        // Save imageUrl to Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({'profileImageUrl': imageUrl});

        setState(() {
          profileImageUrl = imageUrl; // Update the UI with the uploaded image
        });
      } catch (e) {
        print('Upload error: $e');
      }
    } else {
      print('No file selected or user not logged in.');
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

    final userId = FirebaseAuth.instance.currentUser?.uid;

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
          child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const Center(
                  child: Text(
                    'User data not found.',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              final userData = snapshot.data!.data() as Map<String, dynamic>;
              final username = userData['username'] ?? 'User';
              final email = userData['email'] ?? 'No email';
              final idNumber = userData['idNumber'] ?? 'N/A';
              final profileImageUrl = userData['profileImageUrl'];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: iconColor,
                          backgroundImage: profileImageUrl != null
                              ? NetworkImage(profileImageUrl) as ImageProvider
                              : null,
                          child: profileImageUrl == null
                              ? Icon(Icons.person, size: 60, color: backgroundColor)
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _uploadProfilePicture,
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.white,
                              child: Icon(Icons.camera_alt, size: 20, color: backgroundColor),
                            ),
                          ),
                        ),
                      ],
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
                  const SizedBox(height: 10),
                  _buildProfileItem(
                    title: 'ID Number',
                    value: idNumber,
                    icon: Icons.badge,
                    iconColor: iconColor,
                  ),
                  const Spacer(),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/loginRegister', (route) => false);
                      },
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
              );
            },
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
