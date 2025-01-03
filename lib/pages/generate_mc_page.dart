import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
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
  final TextEditingController diseaseController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  int _stayOffDays = 1;

  final _key = encrypt.Key.fromUtf8('my 32 length key................');
  final _iv = encrypt.IV.fromLength(16);

  Future<void> _generateMC() async {
    if (_formKey.currentState!.validate()) {
      try {
        final userId = FirebaseAuth.instance.currentUser!.uid;
        final documentId = FirebaseFirestore.instance.collection('medical_certificates').doc().id;

        final mcData = {
          'name': nameController.text.trim(),
          'matricNumber': matricNumberController.text.trim(),
          'stayOffDays': _stayOffDays,
          'effectingFrom': effectingFromController.text.trim(),
          'until': untilController.text.trim(),
          'department': departmentController.text.trim(),
          'disease': diseaseController.text.trim(),
          'serialNumber': documentId,
          'generatedDate': DateTime.now().toIso8601String(),
          'generatedBy': userId,
        };

        final qrData = documentId;

        await FirebaseFirestore.instance.collection('medical_certificates').doc(documentId).set({
          ...mcData,
          'qrData': qrData,
          'timestamp': FieldValue.serverTimestamp(),
        });

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MCDisplayPage(
              documentId: documentId,
            ),
          ),
        );

        nameController.clear();
        matricNumberController.clear();
        effectingFromController.clear();
        untilController.clear();
        departmentController.clear();
        diseaseController.clear();
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
        controller.text = DateFormat('dd/MM/yyyy').format(picked);
        if (controller == effectingFromController) {
          _updateUntilDate(picked);
        }
      });
    }
  }

  void _updateUntilDate(DateTime effectingFrom) {
    final DateTime untilDate = effectingFrom.add(Duration(days: _stayOffDays - 1));
    untilController.text = DateFormat('dd/MM/yyyy').format(untilDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    const Text(
                      'Generate MC',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Input MC Details',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
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
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Please enter a matric number' : null,
                ),
                _buildLabel('Stay Off Works (Days)'),
                GestureDetector(
                  onTap: () => _showNumberPicker(context),
                  child: AbsorbPointer(
                    child: _buildTextField(
                      controller: TextEditingController(text: '$_stayOffDays days'),
                      hintText: '$_stayOffDays days',
                      validator: null,
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
                  hintText: 'Automatically calculated',
                  onTap: () => _selectDate(context, untilController),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Please select a date' : null,
                ),
                _buildLabel('Disease'),
                _buildTextField(
                  controller: diseaseController,
                  hintText: 'Enter the disease',
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Please enter the disease' : null,
                ),
                _buildLabel('Kulliyyah/Department'),
                _buildTextField(
                  controller: departmentController,
                  hintText: 'Enter kulliyyah or department',
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Please enter the kulliyyah/department' : null,
                ),
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6A1E55),
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _generateMC,
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
    );
  }

  void _showNumberPicker(BuildContext context) {
    int tempValue = _stayOffDays;

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
                    tempValue = value;
                  });
                },
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _stayOffDays = tempValue;
                      if (effectingFromController.text.isNotEmpty) {
                        final effectingFromDate = DateFormat('dd/MM/yyyy').parse(effectingFromController.text);
                        _updateUntilDate(effectingFromDate);
                      }
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
          color: Colors.black54,
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
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF6A1E55),
            Color(0xFF3B1C32),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hintText,
          filled: true,
          fillColor: Colors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          hintStyle: const TextStyle(color: Colors.white70),
        ),
        style: const TextStyle(color: Colors.white),
        validator: validator,
      ),
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
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF6A1E55),
              Color(0xFF3B1C32),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: AbsorbPointer(
          child: TextFormField(
            controller: controller,
            readOnly: true,
            decoration: InputDecoration(
              hintText: hintText,
              filled: true,
              fillColor: Colors.transparent,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              suffixIcon: const Icon(Icons.calendar_today, color: Colors.white70),
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              hintStyle: const TextStyle(color: Colors.white70),
            ),
            style: const TextStyle(color: Colors.white),
            validator: validator,
          ),
        ),
      ),
    );
  }
}
