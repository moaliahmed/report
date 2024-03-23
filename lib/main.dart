import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:report/screens/auth/log_in_screen.dart';
import 'package:report/screens/auth/report_and_sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  runApp(const Report());
}

class Report extends StatelessWidget {
  const Report({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LogInScreen(),
    );
  }
}
