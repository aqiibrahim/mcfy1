import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:encrypt/encrypt.dart' as encrypt; // Required for encryption/decryption
import 'dart:convert';
import 'package:mcfy1/pages/qr_details_page.dart';

/*class QRDetailsPage extends StatelessWidget {
  final String serialNumber;
  final Map<String, dynamic> mcData;

  const QRDetailsPage({Key? key, required this.serialNumber, required this.mcData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Serial Number: $serialNumber',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'MC Details:',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              mcData.entries
                  .map((entry) => '${entry.key}: ${entry.value}')
                  .join('\n'),
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}*/

class ScanQRPage extends StatefulWidget {
  const ScanQRPage({Key? key}) : super(key: key);

  @override
  ScanQRPageState createState() => ScanQRPageState();
}

class ScanQRPageState extends State<ScanQRPage> {
  @override
  void initState() {
    super.initState();
    requestCameraPermission();
  }

  Future<void> requestCameraPermission() async {
    var status = await Permission.camera.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camera permission is required to scan QR codes.')),
      );
    }
  }

  void handleQRScanResult(String scannedData) async {
  try {
    final serialNumber = scannedData; // Assuming decrypted data is the serial number
    print('Scanned Serial Number: $serialNumber');

    if (serialNumber.isEmpty) {
      throw Exception('Invalid QR code data.');
    }

    // Fetch the medical certificate document
    final mcDoc = await FirebaseFirestore.instance
        .collection('medical_certificates')
        .doc(serialNumber)
        .get();

    if (!mcDoc.exists) {
      throw Exception('No document found for the scanned QR code.');
    }

    final mcData = mcDoc.data() ?? {};

    // Save scanned QR details to Firestore (user's subcollection)
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('scanned_qrs')
          .doc(serialNumber) // Use serialNumber as the document ID
          .set({
        ...mcData,
        'serialNumber': serialNumber,
        'scannedAt': FieldValue.serverTimestamp(), // Timestamp for sorting
      });
    }

    // Navigate to the QRDetailsPage
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRDetailsPage(
          serialNumber: serialNumber,
          mcData: mcData,
        ),
      ),
    );
  } catch (e) {
    print('Error: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
      ),
      body: MobileScanner(controller: MobileScannerController(detectionSpeed: DetectionSpeed.noDuplicates),
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            final String? rawValue = barcode.rawValue;
            if (rawValue != null) {
              handleQRScanResult(rawValue);
            }
          }
        },
      ),
    );
  }
}
