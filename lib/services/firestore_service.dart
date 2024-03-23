import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:report/model/add_repoet_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addReport(Report report) async {
    try {
      await _db.collection('reports').add(report.toMap());
      print("Report added successfully");
    } catch (e) {
      print(e.toString());
      rethrow;
    }
  }
}
