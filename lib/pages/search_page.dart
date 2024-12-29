import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mcfy1/pages/mc_display_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<QueryDocumentSnapshot> _searchResults = [];
  bool _isSearching = false;

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      final searchSnapshot = await FirebaseFirestore.instance
          .collection('medical_certificates')
          .where('generatedBy', isEqualTo: userId)
          .where('name', isEqualTo: query)
          .get();

      final matricSnapshot = await FirebaseFirestore.instance
          .collection('medical_certificates')
          .where('generatedBy', isEqualTo: userId)
          .where('matricNumber', isEqualTo: query)
          .get();

      setState(() {
        _searchResults = [
          ...searchSnapshot.docs,
          ...matricSnapshot.docs
        ];
        _isSearching = false;
      });
    } else {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1D),
        title: const Text('Search Medical Certificates'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                hintText: 'Search by Name or Matric Number',
                hintStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white70),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchResults = [];
                    });
                  },
                ),
              ),
              onSubmitted: _performSearch,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          _isSearching
              ? const CircularProgressIndicator()
              : Expanded(
                  child: _searchResults.isEmpty
                      ? const Center(
                          child: Text(
                            'No results found.',
                            style: TextStyle(color: Colors.white70),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final docData = _searchResults[index].data()
                                as Map<String, dynamic>;
                            final name = docData['name'] ?? 'Unknown';
                            final matricNumber =
                                docData['matricNumber'] ?? 'Unknown';
                            final documentId = _searchResults[index].id;

                            return Card(
                              color: Colors.white.withOpacity(0.1),
                              child: ListTile(
                                title: Text(
                                  'Patient: $name',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  'Matric Number: $matricNumber',
                                  style: const TextStyle(color: Colors.white70),
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
    );
  }
}
