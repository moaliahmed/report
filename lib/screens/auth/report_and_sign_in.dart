import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:report/const/app_const.dart';
import 'package:report/widget/custom_drop_down.dart';
import 'package:report/widget/custom_scafold_massage.dart';
import 'package:report/widget/custom_text_feild.dart';

class SendReport extends StatefulWidget {
  const SendReport({super.key});

  @override
  _SendReportState createState() => _SendReportState();
}

class _SendReportState extends State<SendReport> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  bool _isLoading = false; // لتتبع حالة الإرسال
  String? selectedGender;
  String? governorates;

  void _createUserAndSendReport() async {
    if (!_formKey.currentState!.validate()) {
      // إذا لم يتم ملء الحقول بشكل صحيح
      showCustomSnackBar(context, "الرجاء ملئ جميع الحقول");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      await FirebaseFirestore.instance.collection('reports').add({
        'name': nameController.text,
        'age': ageController.text,
        'weight': weightController.text,
        'gender': selectedGender,
        'governorate': governorates,
        'user_id': userCredential.user!.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });

      showCustomSnackBar(context, "'تم إرسال التقرير بنجاح!'");

      _resetFields();
    } on FirebaseAuthException catch (e) {
      _handleFirebaseAuthError(e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _resetFields() {
    emailController.clear();
    passwordController.clear();
    nameController.clear();
    ageController.clear();
    weightController.clear();
    setState(() {
      selectedGender = null;
      governorates = null;
    });
  }

  void _handleFirebaseAuthError(FirebaseAuthException e) {
    String errorMessage = 'حدث خطأ، الرجاء المحاولة مرة أخرى';
    switch (e.code) {
      case 'weak-password':
        errorMessage = 'الباسورد ضعيف';
        break;
      case 'email-already-in-use':
        errorMessage = 'تم استخدام هذا الايميل من قبل';
        break;
      case 'invalid-email':
        errorMessage = 'الايميل غير صحيح';
        break;
      default:
        break;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        errorMessage,
        textDirection: TextDirection.rtl,
      ),
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إرسال تقرير')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              CustomTextField(
                prefixIcon: const Icon(Icons.email_outlined),
                keyboardType: TextInputType.emailAddress,
                hint: 'البريد الإلكتروني',
                controller: emailController,
                validator: (value) {
                  if (value == null || value.isEmpty || !value.contains('@')) {
                    return 'الرجاء إدخال بريد إلكتروني صالح';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              CustomTextField(
                prefixIcon: const Icon(Icons.lock_outline),
                hint: 'كلمة المرور',
                controller: passwordController,
                isPassword: true,
                validator: (value) {
                  if (value == null || value.isEmpty || value.length < 6) {
                    return 'كلمة المرور يجب أن تكون أطول من 6 أحرف';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              CustomTextField(
                hint: 'الاسم',
                controller: nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال الاسم';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              CustomTextField(
                keyboardType: TextInputType.number,
                hint: 'العمر',
                controller: ageController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال العمر';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // إضافة CustomDropdownButton لاختيار الجنس
              CustomDropdownButton(
                label: "النوع",
                hint: "اختر النوع",
                items: DropdownItems.genders,
                selectedItem: selectedGender,
                onChanged: (value) {
                  setState(() {
                    selectedGender = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              // إضافة CustomDropdownButton لاختيار المحافظة
              CustomDropdownButton(
                label: "المحافظة",
                hint: "اختر المحافظة",
                items: DropdownItems.governorates,
                selectedItem: governorates,
                onChanged: (value) {
                  setState(() {
                    governorates = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              CustomTextField(
                keyboardType: TextInputType.number,
                hint: 'الوزن',
                controller: weightController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال الوزن';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _createUserAndSendReport,
                      child: const Text('إرسال التقرير'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
