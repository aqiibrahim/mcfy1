import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReportPage extends StatefulWidget {
  final String? reportId; // Null if creating a new report
  const ReportPage({Key? key, this.reportId}) : super(key: key);

  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.reportId != null) {
      _loadReportData(); // Load data if editing an existing report
    }
  }

  Future<void> _loadReportData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('reports')
          .doc(widget.reportId)
          .get();

      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          _subjectController.text = data['subject'] ?? '';
          _detailsController.text = data['details'] ?? '';
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading report: $e')),
      );
    }
  }

  Future<void> _saveReport() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not authenticated.')),
      );
      return;
    }

    final reportData = {
      'subject': _subjectController.text.trim(),
      'details': _detailsController.text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
      'reviewed': false, // New reports are unreviewed by default
    };

    try {
      if (widget.reportId == null) {
        // Create new report
        await FirebaseFirestore.instance.collection('reports').add(reportData);
      } else {
        // Update existing report
        await FirebaseFirestore.instance
            .collection('reports')
            .doc(widget.reportId)
            .update(reportData);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report saved successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving report: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.reportId == null ? 'Create Report' : 'Edit Report'),
        backgroundColor: const Color(0xFF2B2129),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(
                  labelText: 'Subject',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a subject.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _detailsController,
                decoration: const InputDecoration(
                  labelText: 'Details',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter details.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _saveReport,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2B2129),
                      ),
                      child: const Text('Save Report'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
