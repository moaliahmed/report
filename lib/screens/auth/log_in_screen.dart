import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:report/screens/pages/show_report.dart';
import 'package:report/widget/custom_scafold_massage.dart';
import 'package:report/widget/custom_text_feild.dart';
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
                      'assets/images/logo.jpeg',
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
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.resolveWith((states) {
                          return Colors.deepPurple;
                        }),
                      ),
                      child: const Text(
                        'تسجيل الدخول',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.resolveWith(
                              (states) => Colors.purple)),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => const InformationScreen()),
                        );
                      },
                      child: const Text(
                        'ارسال تقرير وانشاء حساب ',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: myHeight * .04),
                      padding: const EdgeInsets.all(12),
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
                            ),
                            SizedBox(height: myHeight * .02),
                            const Text(
                              'مقرات الهيئة: المنيل، العجوزة، الهرم، المعادي، المنصورية',
                              style: TextStyle(fontSize: 18),
                            ),
                            SizedBox(height: myHeight * .01),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '15301 +',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.deepPurple),
                                ),
                                Text(
                                  'email:info@edaegypt.eg',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.deepPurple),
                                ),
                              ],
                            ),
                            SizedBox(height: myHeight * .01),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Dr. Ahmed saif eldin',
                                  style: TextStyle(fontSize: 18),
                                ),
                                Text(
                                  'Dr. Mostafa adel',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ],
                            ),
                            SizedBox(height: myHeight * .01),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Jana Moamen Elgamal',
                                  style: TextStyle(fontSize: 16),
                                ),
                                Text(
                                  'Menna Khaled Mohamed',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            SizedBox(height: myHeight * .01),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Mariam Raafat Noshy',
                                  style: TextStyle(fontSize: 16),
                                ),
                                Text(
                                  'Dian Gamal Mahmoud',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            SizedBox(height: myHeight * .01),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Mariam Mahmoud',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            SizedBox(height: myHeight * .01),
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
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const ShowReport()),
          (Route<dynamic> route) => false);
      showCustomSnackBar(context, "تم تسجيل الدخول بنجاح");
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
