import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'report_view.dart';

class ReportListView extends StatefulWidget {
  const ReportListView({Key? key}) : super(key: key);

  @override
  State<ReportListView> createState() => _ReportListViewState();
}

class _ReportListViewState extends State<ReportListView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _removeOldReports();
  }

  // Remove reports older than a week
  Future<void> _removeOldReports() async {
    try {
      final now = DateTime.now();
      final oneWeekAgo = now.subtract(const Duration(days: 7));
      final snapshot = await _firestore.collection('reports').get();

      for (var doc in snapshot.docs) {
        final timestamp = (doc['timestamp'] as Timestamp).toDate();
        if (timestamp.isBefore(oneWeekAgo)) {
          await _firestore.collection('reports').doc(doc.id).delete();
        }
      }
    } catch (e) {
      debugPrint("Error removing old reports: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        backgroundColor: const Color(0xFF2B2129),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('reports')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Color(0xFF2B2129), fontSize: 18),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final reports = snapshot.data!.docs;

          if (reports.isEmpty) {
            return const Center(
              child: Text(
                'No reports available.',
                style: TextStyle(color: Color(0xFF2B2129), fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index].data() as Map<String, dynamic>;
              final subject = report['subject'] ?? 'Unknown Subject';
              final isReviewed = report['reviewed'] ?? false;

              // Modify subject text based on review status
              final displayText =
                  isReviewed ? '$subject [Reviewed]' : subject;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ReportViewPage(reportId: reports[index].id),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(
                      vertical: 5, horizontal: 10),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: isReviewed
                        ? const Color(0xFF708A81) // Muted green for reviewed
                        : const Color(0xFFDD8E58), // Orange for unreviewed
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    displayText,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFFE5D1B8),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
