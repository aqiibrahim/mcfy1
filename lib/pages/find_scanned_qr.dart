import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'qr_details_page.dart';

class FindScannedQRPage extends StatefulWidget {
  const FindScannedQRPage({Key? key}) : super(key: key);

  @override
  State<FindScannedQRPage> createState() => _FindScannedQRPageState();
}

class _FindScannedQRPageState extends State<FindScannedQRPage> {
  final TextEditingController searchController = TextEditingController();
  List<QueryDocumentSnapshot> searchResults = [];

  Future<void> searchScannedQRs(String query) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception("User not authenticated.");
      }

      final subCollectionRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('scanned_qrs');

      final querySnapshot = await subCollectionRef
          .where('name', isEqualTo: query)
          .get();

      // If no results for name, try searching by matric number
      if (querySnapshot.docs.isEmpty) {
        final secondaryQuerySnapshot = await subCollectionRef
            .where('matricNumber', isEqualTo: query)
            .get();

        setState(() {
          searchResults = secondaryQuerySnapshot.docs;
        });
      } else {
        setState(() {
          searchResults = querySnapshot.docs;
        });
      }
    } catch (e) {
      print("Error while searching: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Scanned QR'),
        backgroundColor: const Color(0xFF2B2129),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Input
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Enter name or matric number',
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, color: Color(0xFFE5D1B8)),
                  onPressed: () {
                    final query = searchController.text.trim();
                    if (query.isNotEmpty) {
                      searchScannedQRs(query);
                    }
                  },
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 20),
            // Search Results
            Expanded(
              child: searchResults.isEmpty
                  ? const Center(
                      child: Text(
                        'No results found.',
                        style: TextStyle(
                          color: Color(0xFFE5D1B8),
                          fontSize: 16,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
                        final data = searchResults[index].data() as Map<String, dynamic>;
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
                                    color: Color(0xFFE5D1B8),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Stay-Off Days: $stayOffDays',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFFE5D1B8),
                                  ),
                                ),
                              ],
                            ),
                          ),
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
