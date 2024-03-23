import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ShowReport extends StatefulWidget {
  const ShowReport({super.key});

  @override
  _ShowReportState createState() => _ShowReportState();
}

class _ShowReportState extends State<ShowReport> {
  String? userId = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Your Reports")),
        body: const Center(
          child: Text("You need to log in to see your reports."),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Your Reports")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('reports')
            .where('user_id', isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final reports = snapshot.data!.docs;

          if (reports.isEmpty) {
            return const Center(
                child: Text("You haven't submitted any reports yet."));
          }

          return ListView.builder(
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index].data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.all(10.0),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(10.0),
                    title: Text(
                      report['name'] ?? 'No Name',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("السن: ${report['age']}"),
                        Text("الوزن: ${report['weight']}"),
                        Text("النوع: ${report['gender']}"),
                        Text("المحافظه: ${report['governorate']}"),
                        Text("المرسل: ${report['reportSubmitter']}"),
                        Text(
                          "التاريخ :${report['timestamp']?.toDate().toString() ?? 'N/A'}",
                        ),
                      ],
                    ),
                    isThreeLine: true,
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
