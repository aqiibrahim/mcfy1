import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart'; // Import number picker package
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:encrypt/encrypt.dart' as encrypt; // For encryption
import 'package:barcode/barcode.dart';
import 'mc_display_page.dart';


class GenerateMCPage extends StatefulWidget {
  const GenerateMCPage({Key? key}) : super(key: key);

  @override
  State<GenerateMCPage> createState() => _GenerateMCPageState();
}

class _GenerateMCPageState extends State<GenerateMCPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController matricNumberController = TextEditingController();
  final TextEditingController effectingFromController = TextEditingController();
  final TextEditingController untilController = TextEditingController();
  final TextEditingController departmentController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  int _stayOffDays = 1; // Default value for the number picker

  // Encryption setup
  final _key = encrypt.Key.fromUtf8('my 32 length key................'); // 32 chars key
  final _iv = encrypt.IV.fromLength(16); // Initialization vector for AES

  Future<String> _encryptData(String plainText) async {
    final encrypter = encrypt.Encrypter(encrypt.AES(encrypt.Key.fromUtf8('my 32 length key................')));
    return encrypter.encrypt(plainText, iv: _iv).base64;
  }

  Future<void> _generateMC() async {
  if (_formKey.currentState!.validate()) {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final documentId = FirebaseFirestore.instance.collection('medical_certificates').doc().id;

      // Gather all metadata to be stored
      final mcData = {
        'name': nameController.text.trim(),
        'matricNumber': matricNumberController.text.trim(),
        'stayOffDays': _stayOffDays,
        'effectingFrom': effectingFromController.text.trim(),
        'until': untilController.text.trim(),
        'department': departmentController.text.trim(),
        'serialNumber': documentId, // Unique serial number
        'generatedDate': DateTime.now().toIso8601String(), // Generation date
        'generatedBy': userId,
      };

      // Encrypt only the serial number
      //final encryptedSerialNumber = await _encryptData(documentId);
      //print('Generated Encrypted Data: $encryptedSerialNumber');

      // Store the serial number directly in the QR data
      final qrData = documentId;
      print('Generated QR Data (Unencrypted): $qrData');


      // Save metadata to Firestore
      await FirebaseFirestore.instance.collection('medical_certificates').doc(documentId).set({
        ...mcData, // Save all data
        'qrData': qrData, // Store the encrypted serial number
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Navigate to MC Display Page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MCDisplayPage(
            documentId: documentId, // Pass the Firestore document ID
          ),
        ),
      );

      // Clear the form fields
      nameController.clear();
      matricNumberController.clear();
      effectingFromController.clear();
      untilController.clear();
      departmentController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}


  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('dd/MM/yyyy').format(picked); // Format the date
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
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
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // AppBar
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        const Text(
                          'Generate MC',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Title
                    const Text(
                      'Input MC Details',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Form Fields
                    _buildLabel('Name'),
                    _buildTextField(
                      controller: nameController,
                      hintText: 'Enter full name',
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Please enter a name' : null,
                    ),

                    _buildLabel('Matric Number'),
                    _buildTextField(
                      controller: matricNumberController,
                      hintText: 'Enter matric number',
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter a matric number'
                          : null,
                    ),

                    _buildLabel('Stay Off Works (Days)'),
                    GestureDetector(
                      onTap: () => _showNumberPicker(context),
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: TextEditingController(
                            text: '$_stayOffDays days', // Dynamically show the updated value
                          ),
                          readOnly: true,
                          decoration: InputDecoration(
                            hintText: '$_stayOffDays days',
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            hintStyle: const TextStyle(color: Colors.white54),
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),

                    _buildLabel('Effecting From (Date)'),
                    _buildDateField(
                      controller: effectingFromController,
                      hintText: 'Select start date',
                      onTap: () => _selectDate(context, effectingFromController),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Please select a date' : null,
                    ),

                    _buildLabel('Until (Date)'),
                    _buildDateField(
                      controller: untilController,
                      hintText: 'Select end date',
                      onTap: () => _selectDate(context, untilController),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Please select a date' : null,
                    ),

                    _buildLabel('Kulliyyah/Department'),
                    _buildTextField(
                      controller: departmentController,
                      hintText: 'Enter kulliyyah or department',
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter the kulliyyah/department'
                          : null,
                    ),

                    const SizedBox(height: 30),

                    // Generate Button
                    Center(
                      child: ElevatedButton(
                        onPressed: _generateMC,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Generate',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showNumberPicker(BuildContext context) {
    int tempValue = _stayOffDays; // Temporary value to hold the current picker value

    showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter dialogSetState) {
            return AlertDialog(
              title: const Text('Select Number of Days'),
              content: NumberPicker(
                minValue: 1,
                maxValue: 30,
                value: tempValue,
                onChanged: (value) {
                  dialogSetState(() {
                    tempValue = value; // Update the temporary value dynamically
                  });
                },
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog without saving
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                    setState(() {
                      _stayOffDays = tempValue; // Save the selected value
                    });
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 20.0),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.white70,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        hintStyle: const TextStyle(color: Colors.white54),
      ),
      style: const TextStyle(color: Colors.white),
      validator: validator,
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String hintText,
    required VoidCallback onTap,
    String? Function(String?)? validator,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AbsorbPointer(
        child: TextFormField(
          controller: controller,
          readOnly: true,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            suffixIcon: const Icon(Icons.calendar_today, color: Colors.white70),
            hintStyle: const TextStyle(color: Colors.white54),
          ),
          style: const TextStyle(color: Colors.white),
          validator: validator,
        ),
      ),
    );
  }
}

