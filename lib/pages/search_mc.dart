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
    searchController.addListener(() {
      searchMC(searchController.text.trim());
    });
    fetchAllMCs();
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

  // Search Firestore for matching MC records
  Future<void> searchMC(String query) async {
    if (query.isEmpty) {
      fetchAllMCs();
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Query Firestore collection for name or matric number
      final querySnapshot = await FirebaseFirestore.instance
          .collection('medical_certificates')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: query + '\uf8ff')
          .get();

      // Fallback to search by matric number if no name matches
      if (querySnapshot.docs.isEmpty) {
        final matricQuerySnapshot = await FirebaseFirestore.instance
            .collection('medical_certificates')
            .where('matricNumber', isGreaterThanOrEqualTo: query)
            .where('matricNumber', isLessThanOrEqualTo: query + '\uf8ff')
            .get();
        searchResults = matricQuerySnapshot.docs;
      } else {
        searchResults = querySnapshot.docs;
      }
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
        title: const Text('Medical Certificates'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search bar
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search by Name or Matric Number',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Loading indicator while fetching data
            if (isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),

            // List of all or search results
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

                    return ListTile(
                      title: Text(name),
                      subtitle: Text('Matric Number: $matricNumber'),
                      trailing: const Icon(Icons.arrow_forward),
                      onTap: () => navigateToQRDetails(serialNumber, mcData), // Navigate to QRDetailsPage
                    );
                  },
                ),
              ),

            // Message when no results are found
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
