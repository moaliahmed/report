import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:report/const/app_const.dart';
import 'package:report/screens/auth/log_in_screen.dart';

class ShowReport extends StatefulWidget {
  const ShowReport({super.key});

  @override
  _ShowReportState createState() => _ShowReportState();
}

class _ShowReportState extends State<ShowReport> {
  final String adminEmail = 'admin@gmail.com';
  String? selectedDevice = 'الكل';
  String? selectedGovernorate = 'الكل';
  String? searchMedicine; // اسم الدواء المبحوث عنه

  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Your Reports")),
        body: const Center(
          child: Text("You need to log in to see your reports."),
        ),
      );
    }

    bool isAdmin = currentUser.email == adminEmail;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Reports"),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LogInScreen()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (isAdmin)
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    textDirection: TextDirection.rtl, // تحديد اتجاه النص
                    decoration: const InputDecoration(
                      labelText: 'ابحث عن اسم الدواء',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchMedicine = value.trim();
                      });
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(' المحافظه'),
                      Text('الجهاز المتاثر'),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DropdownButton<String>(
                        value: selectedGovernorate,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedGovernorate = newValue;
                          });
                        },
                        items: ['الكل', ...DropdownItems.governorates]
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DropdownButton<String>(
                        hint: const Text("اختر جهاز"),
                        value: selectedDevice,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedDevice = newValue;
                          });
                        },
                        items: ['الكل', ...DropdownItems.symptomsAppear]
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: isAdmin
                  ? selectedDevice != 'الكل' && selectedGovernorate != 'الكل'
                      ? FirebaseFirestore.instance
                          .collection('reports')
                          .where('symptoms_appear_of_any_device',
                              isEqualTo: selectedDevice)
                          .where('governorate', isEqualTo: selectedGovernorate)
                          .snapshots()
                      : selectedDevice != 'الكل'
                          ? FirebaseFirestore.instance
                              .collection('reports')
                              .where('symptoms_appear_of_any_device',
                                  isEqualTo: selectedDevice)
                              .snapshots()
                          : selectedGovernorate != 'الكل'
                              ? FirebaseFirestore.instance
                                  .collection('reports')
                                  .where('governorate',
                                      isEqualTo: selectedGovernorate)
                                  .snapshots()
                              : FirebaseFirestore.instance
                                  .collection('reports')
                                  .snapshots()
                  : FirebaseFirestore.instance
                      .collection('reports')
                      .where('user_id', isEqualTo: currentUser.uid)
                      .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final reports = snapshot.data!.docs;
                if (reports.isEmpty) {
                  return const Center(
                      child: Text("There are no matching reports."));
                }

                return ListView.builder(
                  itemCount: reports.length,
                  itemBuilder: (context, index) {
                    final report =
                        reports[index].data() as Map<String, dynamic>;
                    bool isBatchNumberImageUrl =
                        (report['batch_number'] as String?)
                                ?.startsWith('http') ??
                            false;

                    // إذا كان هناك قيمة للبحث ولم تكن الأسماء تحتوي على هذه القيمة، يتم تجاهل هذا التقرير
                    if (searchMedicine != null &&
                        !report['medicament_name']
                            .toString()
                            .contains(searchMedicine!)) {
                      return const SizedBox.shrink();
                    }

                    return Directionality(
                      textDirection: TextDirection.rtl,
                      child: Card(
                        margin: const EdgeInsets.all(10.0),
                        child: ExpansionTile(
                          title: Text(report['name'] ?? 'No Name',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          children: <Widget>[
                            ListTile(
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text("السن: ${report['age'] ?? 'غير محدد'}"),
                                  Text(
                                      "الوزن: ${report['weight'] ?? 'غير محدد'}"),
                                  Text(
                                      "النوع: ${report['gender'] ?? 'غير محدد'}"),
                                  Text(
                                      "المحافظة: ${report['governorate'] ?? 'غير محدد'}"),
                                  Text(
                                      "رقم الهاتف: ${report['phone_number'] ?? 'غير محدد'}"),
                                  Text(
                                      "اسم الدواء: ${report['medicament_name'] ?? 'غير محدد'}"),
                                  if (isBatchNumberImageUrl)
                                    Image.network(
                                      report['batch_number'],
                                      height: 200,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    )
                                  else
                                    Text(
                                        "رقم التشغيلة: ${report['batch_number'] ?? 'غير محدد'}"),
                                  Text(
                                      "التركيز: ${report['the_focus'] ?? 'غير محدد'}"),
                                  Text(
                                      "سبب استخدام الدواء: ${report['reason_for_using'] ?? 'غير محدد'}"),
                                  Text(
                                      "تاريخ بدء الاستخدام: ${report['start_date'] ?? 'غير محدد'}"),
                                  Text(
                                      "تاريخ نهاية الاستخدام: ${report['end_date'] ?? 'غير محدد'}"),
                                  Text(
                                      "الإجراء المتخذ: ${report['the_action_taken'] ?? 'غير محدد'}"),
                                  Text(
                                      "رد الفعل المماثل من قبل: ${report['similar_reaction'] ?? 'غير محدد'}"),
                                  Text(
                                      "وصف الأثر العكسي: ${report['description_effect'] ?? 'غير محدد'}"),
                                  Text(
                                      "ظهور الأعراض في أي جهاز: ${report['symptoms_appear_of_any_device'] ?? 'غير محدد'}"),
                                  Text(
                                      "حالة المريض الآن: ${report['the_patient_condition_now'] ?? 'غير محدد'}"),
                                  Text(
                                      "الأدوية الأخرى: ${report['other_medicines'] ?? 'لا يوجد'}"),
                                  Text(
                                      "الأمراض المزمنة: ${report['chronic_diseases'] ?? 'غير محدد'}"),
                                  Text(
                                      "تناول الدواء بشكل مزمن: ${report['taking_medication_chronically'] ?? 'غير محدد'}"),
                                  Text(
                                      "التعليق: ${report['comment'] ?? 'لا يوجد تعليق'}"),
                                  if (report['image_url'] != null &&
                                      report['image_url'].isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Image.network(
                                        report['image_url'],
                                        height: 200,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (BuildContext context,
                                            Widget child,
                                            ImageChunkEvent? loadingProgress) {
                                          if (loadingProgress == null) {
                                            return child;
                                          }
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                  : null,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
