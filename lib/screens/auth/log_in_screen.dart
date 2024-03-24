import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:report/screens/pages/show_report.dart';
import 'package:report/widget/custom_text_feild.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'information_screen.dart';

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
    double myHeight = MediaQuery.of(context).size.height;
    double myWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Center(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      width: myWidth * .8,
                    ),
                    SizedBox(height: myHeight * .1),
                    CustomTextField(
                      keyboardType: TextInputType.emailAddress,
                      hint: 'البريد الالكتروني',
                      controller: emailController,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            !value.contains('@')) {
                          return 'الرجاء إدخال بريد إلكتروني صالح';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      hint: 'كلمة المرور',
                      controller: passwordController,
                      isPassword: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "كلمة المرور يجب أن تكون أطول من 6 أحرف";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: signInWithEmailAndPassword,
                      child: const Text('تسجيل الدخول'),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) =>
                                    const InformationScreen()),
                            (Route<dynamic> route) => false);
                      },
                      child: const Text('ارسال تقرير وانشاء حساب '),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: myHeight * .05),
                      padding: EdgeInsets.all(12),
                      width: myWidth,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey.shade200),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'تواصل معنا',
                              style: TextStyle(fontSize: 22, color: Colors.red),
                              textAlign: TextAlign.end,
                            ),SizedBox(height: myHeight*.02),
                            const Text(
                              'مقرات الهيئة: المنيل، العجوزة، الهرم، المعادي، المنصورية',
                              style: TextStyle(fontSize: 18),
                            ),
                            TextButton(
                                onPressed: () async {
                                  launchPhoneNumber('+15301');
                                },
                                child: Text(
                                  '15301',
                                  style: TextStyle(fontSize: 18),
                                )),
                            TextButton(
                                onPressed: () {
                                  launchEmail('info@edaegypt.gov.eg','Subject','Body');
                                },
                                child: Text(
                                  'info@edaegypt.gov.eg',
                                  style: TextStyle(fontSize: 18),
                                )),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

  }
  void launchPhoneNumber(String phoneNumber) async {
    final url = 'tel:$phoneNumber';

      await launchUrlString(url);

  }
  void launchEmail(String email, String subject, String body) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': subject,
        'body': body,
      },
    );

    final String emailLaunchString = emailLaunchUri.toString();

      await launchUrlString(emailLaunchString);

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
