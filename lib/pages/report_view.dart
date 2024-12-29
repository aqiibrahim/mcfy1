import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportViewPage extends StatelessWidget {
  final String reportId;

  const ReportViewPage({Key? key, required this.reportId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Details'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('reports')
            .doc(reportId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching report'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Report not found'));
          }
          final report = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Subject: ${report['subject']}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text('Details: ${report['details'] ?? 'No details provided'}'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection('reports')
                        .doc(reportId)
                        .update({'isReviewed': true});
                    Navigator.pop(context);
                  },
                  child: const Text('Mark as Reviewed'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
