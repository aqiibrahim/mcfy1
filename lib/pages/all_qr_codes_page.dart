import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AllQRCodesPage extends StatefulWidget {
  const AllQRCodesPage({Key? key}) : super(key: key);

  @override
  _AllQRCodesPageState createState() => _AllQRCodesPageState();
}

class _AllQRCodesPageState extends State<AllQRCodesPage> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Generated QR Codes"),
        backgroundColor: const Color(0xFF6A1E55),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by name or matric number...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF6A1E55)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                hintStyle: const TextStyle(color: Color(0xFF9DA3B4)),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          // List of QR Codes
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('medical_certificates').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final docs = snapshot.data!.docs;

                // Filter the documents based on the search query
                final filteredDocs = docs.where((doc) {
                  final qrData = doc.data() as Map<String, dynamic>;
                  final name = qrData['name']?.toLowerCase() ?? '';
                  final matricNumber = qrData['matricNumber']?.toLowerCase() ?? '';

                  return name.contains(searchQuery) || matricNumber.contains(searchQuery);
                }).toList();

                if (filteredDocs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No results found.',
                      style: TextStyle(color: Color(0xFF9DA3B4)),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final qrData = filteredDocs[index].data() as Map<String, dynamic>;
                    final name = qrData['name'] ?? 'Unknown';
                    final matricNumber = qrData['matricNumber'] ?? 'Unknown';
                    final stayOffDays = qrData['stayOffDays'] ?? 'Unknown';

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          'Patient: $name',
                          style: const TextStyle(
                            color: Color.fromARGB(255, 255, 255, 255),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Matric Number: $matricNumber',
                              style: const TextStyle(color: Color(0xFF9DA3B4)),
                            ),
                            Text(
                              'Stay-Off Days: $stayOffDays',
                              style: const TextStyle(color: Color(0xFF9DA3B4)),
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
        ],
      ),
    );
  }
}
