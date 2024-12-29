import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_acc_details_page.dart';

class FindUserPage extends StatefulWidget {
  const FindUserPage({Key? key}) : super(key: key);

  @override
  State<FindUserPage> createState() => _FindUserPageState();
}

class _FindUserPageState extends State<FindUserPage> {
  final TextEditingController searchController = TextEditingController();
  List<QueryDocumentSnapshot> searchResults = [];

  Future<void> searchUsers(String query) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: query)
          .where('username', isLessThanOrEqualTo: query + '\uf8ff') // Fuzzy search
          .get();

      setState(() {
        searchResults = querySnapshot.docs;
      });
    } catch (e) {
      print("Error while searching users: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find User'),
        backgroundColor: const Color(0xFF3B1C32),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Enter username or ID number',
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear, color: Color(0xFFE5D1B8)),
                  onPressed: () {
                    setState(() {
                      searchController.clear();
                      searchResults = [];
                    });
                  },
                ),
              ),
              style: const TextStyle(color: Colors.white),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  searchUsers(value.trim());
                } else {
                  setState(() {
                    searchResults = [];
                  });
                }
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  final data = searchResults[index].data() as Map<String, dynamic>;
                  final name = data['username'] ?? 'Unknown';
                  final idNumber = data['idNumber'] ?? 'Unknown';
                  final userId = searchResults[index].id;

                  return ListTile(
                    title: Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFFE5D1B8),
                      ),
                    ),
                    subtitle: Text(
                      'ID Number: $idNumber',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFFE5D1B8),
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserAccountDetailsPage(
                            userId: userId,
                            userData: data,
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
    );
  }
}
