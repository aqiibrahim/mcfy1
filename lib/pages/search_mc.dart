import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'qr_details_page.dart'; // Import QRDetailsPage for navigation

class SearchMCPage extends StatefulWidget {
  const SearchMCPage({Key? key}) : super(key: key);

  @override
  State<SearchMCPage> createState() => _SearchMCPageState();
}

class _SearchMCPageState extends State<SearchMCPage> {
  final TextEditingController searchController = TextEditingController();
  List<QueryDocumentSnapshot> searchResults = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchAllMCs();
    searchController.addListener(() {
      searchMC(searchController.text.trim());
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // Fetch all medical certificates
  Future<void> fetchAllMCs() async {
    setState(() {
      isLoading = true;
    });

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('medical_certificates')
          .orderBy('timestamp', descending: true)
          .get();

      setState(() {
        searchResults = querySnapshot.docs;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  // Real-time search Firestore for matching MC records
  Future<void> searchMC(String query) async {
    if (query.isEmpty) {
      fetchAllMCs();
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final nameQuerySnapshot = await FirebaseFirestore.instance
          .collection('medical_certificates')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: query + '\uf8ff')
          .get();

      final matricQuerySnapshot = await FirebaseFirestore.instance
          .collection('medical_certificates')
          .where('matricNumber', isGreaterThanOrEqualTo: query)
          .where('matricNumber', isLessThan: query + '\uf8ff')
          .get();

      setState(() {
        searchResults = [
          ...nameQuerySnapshot.docs,
          ...matricQuerySnapshot.docs,
        ];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  // Navigate to QRDetailsPage
  void navigateToQRDetails(String serialNumber, Map<String, dynamic> mcData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRDetailsPage(
          serialNumber: serialNumber,
          mcData: mcData,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Medical Certificates'),
        backgroundColor: const Color(0xFF6A1E55),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Enhanced Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.grey),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search by Name or Matric Number...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  if (searchController.text.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        searchController.clear();
                        fetchAllMCs();
                      },
                      child: const Icon(Icons.clear, color: Colors.grey),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Loading indicator
            if (isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),

            // Search Results
            if (!isLoading && searchResults.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    final result = searchResults[index];
                    final name = result['name'];
                    final matricNumber = result['matricNumber'];
                    final serialNumber = result['serialNumber']; // Assuming Firestore has 'serialNumber'
                    final mcData = result.data() as Map<String, dynamic>;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('Matric Number: $matricNumber'),
                        trailing: const Icon(Icons.arrow_forward),
                        onTap: () => navigateToQRDetails(serialNumber, mcData),
                      ),
                    );
                  },
                ),
              ),

            // No results message
            if (!isLoading && searchResults.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    'No medical certificates found.',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
