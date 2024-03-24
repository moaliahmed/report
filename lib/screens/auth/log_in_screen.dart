import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:report/screens/auth/report_and_sign_in.dart';
import 'package:report/screens/pages/show_report.dart';
import 'package:report/widget/custom_text_feild.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomTextField(
                    keyboardType: TextInputType.emailAddress,
                    hint: 'Email',
                    controller: emailController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    hint: 'Password',
                    controller: passwordController,
                    isPassword: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your password";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: signInWithEmailAndPassword,
                    child: const Text('تسجيل الدخول'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => const SendReport()),
                          (Route<dynamic> route) => false);
                    },
                    child: const Text('ارسال تقرير وانشاء حساب '),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> signInWithEmailAndPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return const ShowReport();
      }));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User logged in successfully')),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'user-not-found') {
        errorMessage = 'لا يوجد مستخدم بهذا الاسم';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'الباسورد غير صحيح';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'الايميل غير صحيح';
      } else {
        errorMessage = 'An error occurred. Please try again later$e.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }
}
