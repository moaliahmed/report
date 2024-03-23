import 'package:cloud_firestore/cloud_firestore.dart';

class Report {
  String? name;
  String? age;
  String? weight;
  String? gender;
  String? governorate;
  String? reportSubmitter;
  String? userId; // إذا كنت ترغب في إضافة معرف المستخدم

  Report({
    this.name,
    this.age,
    this.weight,
    this.gender,
    this.governorate,
    this.reportSubmitter,
    this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age,
      'weight': weight,
      'gender': gender,
      'governorate': governorate,
      'reportSubmitter': reportSubmitter,
      'user_id': userId,   
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}
