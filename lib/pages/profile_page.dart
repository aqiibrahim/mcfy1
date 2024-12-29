import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  final String role;

  const ProfilePage({Key? key, required this.role}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? profileImageUrl;
  int totalMCsGenerated = 0;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchProfilePicture();
    _fetchTotalMCs();
  }

  Future<void> _fetchProfilePicture() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

      if (userDoc.exists) {
        setState(() {
          profileImageUrl = userDoc.data()?['profileImageUrl'];
        });
      }
    }
  }

  Future<void> _fetchTotalMCs() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('medical_certificates')
          .where('generatedBy', isEqualTo: userId)
          .get();

      setState(() {
        totalMCsGenerated = querySnapshot.size;
      });
    }
  }

  Future<void> _uploadProfilePicture() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null && userId != null) {
      final file = File(pickedFile.path);
      final ref = FirebaseStorage.instance.ref().child('profileImages').child('$userId.jpg');

      try {
        final uploadTask = await ref.putFile(file);
        final imageUrl = await uploadTask.ref.getDownloadURL();

        // Save imageUrl to Firestore
        await FirebaseFirestore.instance.collection('users').doc(userId).update({'profileImageUrl': imageUrl});

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

  void _navigateToEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(), // Define the EditProfilePage below
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = widget.role == 'ClinicStaff' ? const Color(0xFF680C5D) : const Color(0xFF2B2129);
    final Color gradientStart = widget.role == 'ClinicStaff' ? const Color(0xFFF78FB3) : const Color(0xFFDD8E58);
    final Color gradientEnd = widget.role == 'ClinicStaff' ? const Color(0xFF680C5D) : const Color(0xFF2B2129);
    final Color iconColor = widget.role == 'ClinicStaff' ? const Color(0xFFFED4E0) : const Color(0xFFE5D1B8);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor,
        centerTitle: true,
        title: Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: iconColor,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            color: iconColor,
            onPressed: _navigateToEditProfile,
          ),
        ],
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
                .doc(FirebaseAuth.instance.currentUser?.uid)
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
                              ? NetworkImage(profileImageUrl!) as ImageProvider
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
                    title: 'ID Number',
                    value: idNumber,
                    icon: Icons.badge,
                    iconColor: iconColor,
                  ),
                  const SizedBox(height: 20),
                  Divider(color: Colors.white.withOpacity(0.5)),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      'Profile Statistics',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: iconColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildProfileItem(
                    title: 'Total MCs Generated',
                    value: totalMCsGenerated.toString(),
                    icon: Icons.bar_chart,
                    iconColor: iconColor,
                  ),
                  const SizedBox(height: 20),
                  Divider(color: Colors.white.withOpacity(0.5)),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            'Activity Timeline',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: iconColor,
                            ),
                          ),
                        ),
                        Expanded(
                          child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('loginHistory')
                                .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                                .orderBy('timestamp', descending: true)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              }

                              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                return const Center(
                                  child: Text(
                                    'No login history found.',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                );
                              }

                              final loginHistoryDocs = snapshot.data!.docs;

                              return ListView.builder(
                                shrinkWrap: true,
                                itemCount: loginHistoryDocs.length,
                                itemBuilder: (context, index) {
                                  final loginData = loginHistoryDocs[index].data() as Map<String, dynamic>;
                                  final timestamp = loginData['timestamp'] as Timestamp?;
                                  final formattedDate = timestamp != null
                                      ? DateFormat('dd MMM yyyy, hh:mm a').format(timestamp.toDate())
                                      : 'Unknown';

                                  return ListTile(
                                    title: Text(
                                      'Login Activity',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    subtitle: Text(
                                      formattedDate,
                                      style: TextStyle(color: Colors.white70),
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

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _idNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCurrentUserData();
  }

  Future<void> _loadCurrentUserData() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final data = userDoc.data();
        setState(() {
          _usernameController.text = data?['username'] ?? '';
          _idNumberController.text = data?['idNumber'] ?? '';
        });
      }
    }
  }

  Future<void> _updateUserProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        try {
          await FirebaseFirestore.instance.collection('users').doc(userId).update({
            'username': _usernameController.text.trim(),
            'idNumber': _idNumberController.text.trim(),
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
          Navigator.pop(context); // Return to ProfilePage
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating profile: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Username cannot be empty';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _idNumberController,
                decoration: const InputDecoration(
                  labelText: 'ID Number',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'ID Number cannot be empty';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateUserProfile,
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

