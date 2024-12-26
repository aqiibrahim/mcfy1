import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class PDFDisplayPage extends StatelessWidget {
  final String pdfUrl;

  const PDFDisplayPage({Key? key, required this.pdfUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Certificate'),
      ),
      body: FutureBuilder(
        future: _loadPDF(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading PDF: ${snapshot.error}'));
          }

          return PDFView(
            filePath: snapshot.data as String,
          );
        },
      ),
    );
  }

  Future<String> _loadPDF() async {
    // Download the PDF from the URL and return the local file path
    // Use packages like `dio` or `http` for downloading files.
    return pdfUrl; // For now, return the URL directly if already local
  }
}
