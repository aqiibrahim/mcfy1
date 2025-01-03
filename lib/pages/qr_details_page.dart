import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QRDetailsPage extends StatefulWidget {
  final String serialNumber;
  final Map<String, dynamic> mcData;

  const QRDetailsPage({
    Key? key,
    required this.serialNumber,
    required this.mcData,
  }) : super(key: key);

  @override
  _QRDetailsPageState createState() => _QRDetailsPageState();
}

class _QRDetailsPageState extends State<QRDetailsPage> {
  String issuedBy = 'Loading...';

  @override
  void initState() {
    super.initState();
    fetchIssuer();
  }

  Future<void> fetchIssuer() async {
    try {
      final uid = widget.mcData['generatedBy'];
      if (uid != null) {
        final userDoc =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();
        if (userDoc.exists) {
          setState(() {
            issuedBy = userDoc.data()?['username'] ?? 'Unknown';
          });
        } else {
          setState(() {
            issuedBy = 'Unknown';
          });
        }
      } else {
        setState(() {
          issuedBy = 'Unknown';
        });
      }
    } catch (e) {
      setState(() {
        issuedBy = 'Error fetching data';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final topSpacing = MediaQuery.of(context).padding.top + kToolbarHeight + 40;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Stack(
          children: [
            Container(
              height: 120,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF5E4C92), // Similar to dashboard gradient
                    Color(0xFF362D59),
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
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      const Text(
                        'QR Details',
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Add proper spacing after AppBar
              SizedBox(height: topSpacing),

              // Serial Number Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF24243E),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Serial Number',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.serialNumber,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Color(0xFFECEDF5),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // MC Details Section
              const Text(
                'MC Details',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              // Display Details
              ..._buildMCDetails(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildMCDetails() {
    final details = [
      {'label': 'Name', 'value': widget.mcData['name'] ?? 'Unknown'},
      {'label': 'Matric Number', 'value': widget.mcData['matricNumber'] ?? 'Unknown'},
      {'label': 'Kulliyyah', 'value': widget.mcData['department'] ?? 'Unknown'},
      {'label': 'Disease', 'value': widget.mcData['disease'] ?? 'Unknown'},
      {'label': 'Stay-Off Days', 'value': widget.mcData['stayOffDays'] ?? 'Unknown'},
      {'label': 'Effective From', 'value': widget.mcData['effectingFrom'] ?? 'Unknown'},
      {'label': 'Until', 'value': widget.mcData['until'] ?? 'Unknown'},
      {'label': 'Issued By', 'value': issuedBy},
    ];

    return details.map((detail) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF3A3B59),
                Color(0xFF2A2B47),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  '${detail['label']}:',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFF6F7FA),
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: Text(
                  '${detail['value']}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFFCED1E6),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
}
