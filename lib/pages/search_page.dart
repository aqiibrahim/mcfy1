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

  void _onSearchChanged() {
    _performSearch(_searchController.text.trim());
  }

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
          .get();

      // Filter results locally for substring matches
      final results = searchSnapshot.docs.where((doc) {
        final data = doc.data();
        final name = data['name']?.toString().toLowerCase() ?? '';
        final matricNumber = data['matricNumber']?.toString().toLowerCase() ?? '';
        final queryLower = query.toLowerCase();
        return name.contains(queryLower) || matricNumber.contains(queryLower);
      }).toList();

      setState(() {
        _searchResults = results;
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
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100), // Adjust height
        child: Stack(
          children: [
            Container(
              height: 120,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF6A1E55), // Similar to the QR Details gradient
                    Color(0xFF3B1C32),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                      const Text(
                        'Search Medical Certificates',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                hintText: 'Search by Name or Matric Number',
                hintStyle: const TextStyle(color: Colors.black54),
                prefixIcon: const Icon(Icons.search, color: Colors.black54),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear, color: Colors.black54),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchResults = [];
                    });
                  },
                ),
              ),
              style: const TextStyle(color: Colors.black),
            ),
          ),
          _isSearching
              ? const CircularProgressIndicator()
              : Expanded(
                  child: _searchResults.isEmpty
                      ? const Center(
                          child: Text(
                            'No results found.',
                            style: TextStyle(color: Color.fromARGB(217, 255, 255, 255)),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final docData = _searchResults[index].data() as Map<String, dynamic>;
                            final name = docData['name'] ?? 'Unknown';
                            final matricNumber = docData['matricNumber'] ?? 'Unknown';
                            final documentId = _searchResults[index].id;

                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0), // Adjust padding here
                              child: Card(
                                color: Colors.white.withOpacity(0.1),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(16),
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
