import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;

class MCDisplayPage extends StatelessWidget {
  final String documentId;

  MCDisplayPage({
    Key? key,
    required this.documentId,
  }) : super(key: key);

  Future<Uint8List> _generatePDF(Map<String, dynamic> data) async {
    final pdf = pw.Document();

    // Load the images
    final logo1 = pw.MemoryImage(
      (await rootBundle.load('assets/IIUM_Logo.png')).buffer.asUint8List(),
    );
    final logo2 = pw.MemoryImage(
      (await rootBundle.load('assets/IIUM_Sejahtera_Clinic.png')).buffer.asUint8List(),
    );

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Container(
          padding: const pw.EdgeInsets.all(20),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Image(logo1, height: 40),
                  pw.SizedBox(width: 10),
                  pw.Image(logo2, height: 180),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'IIUM SEJAHTERA CLINIC',
                      style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      'MEDICAL CERTIFICATE',
                      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text('This is to certify that I have examined:', style: pw.TextStyle(fontSize: 12)),
              pw.SizedBox(height: 5),
              pw.Text('Name: ${data['name']}', style: pw.TextStyle(fontSize: 12)),
              pw.Text('Matric/Staff/IC: ${data['matricNumber']}', style: pw.TextStyle(fontSize: 12)),
              pw.Text('Of Kulliyyah/Department: ${data['department']}', style: pw.TextStyle(fontSize: 12)),
              pw.SizedBox(height: 10),
              pw.Text(
                'Advised the following:',
                style: pw.TextStyle(fontSize: 12),
              ),
              pw.Text(
                'To stay off work/to take complete bedrest for a period of ${data['stayOffDays']} days with effect from ${data['effectingFrom']} to ${data['until']}.',
                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('DATE: _____________________________', style: pw.TextStyle(fontSize: 12)),
                      pw.Text('Doctor stamp', style: pw.TextStyle(fontSize: 12)),
                    ],
                  ),
                  pw.BarcodeWidget(
                    data: data['qrData'],
                    barcode: pw.Barcode.qrCode(),
                    width: 60,
                    height: 60,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    return pdf.save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Certificate'),
        backgroundColor: Colors.transparent,
        elevation: 2,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF1A1A1D),
                Color(0xFF3B1C32),
                Color(0xFF6A1E55),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('medical_certificates')
            .doc(documentId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading data.'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Certificate not found.'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          return Stack(
            children: [
              // Gradient Background
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF1A1A1D), // Dark gray
                      Color(0xFF3B1C32), // Deep purple
                      Color(0xFF6A1E55), // Vibrant purple
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              Center(
                child: SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Card(
                          color: const Color(0xFF3B1C32), // Match with the theme
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 5, // Adds a floating effect
                          shadowColor: Colors.black.withOpacity(0.3),
                          child: Padding(
                            padding: const EdgeInsets.all(25),
                            child: Column(
                              children: [
                                Text(
                                  'Name: ${data['name']}',
                                  style: const TextStyle(fontSize: 18, color: Colors.white),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Matric Number: ${data['matricNumber']}',
                                  style: const TextStyle(fontSize: 18, color: Colors.white),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Department: ${data['department']}',
                                  style: const TextStyle(fontSize: 18, color: Colors.white),
                                ),
                                const SizedBox(height: 10),
                                QrImageView(
                                  data: data['qrData'],
                                  size: 150.0,
                                  backgroundColor: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFA726),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                          ),
                          onPressed: () async {
                            final pdf = await _generatePDF(data);
                            await Printing.layoutPdf(
                              onLayout: (format) async => pdf,
                            );
                          },
                          child: const Text(
                            'Print MC',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
