import 'package:flutter/material.dart';

void showCustomSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        textDirection: TextDirection.rtl, // لضمان أن النص يظهر في الجانب الأيمن
      ),
      behavior: SnackBarBehavior.floating, // لجعل الرسالة تطفو فوق العناصر الأخرى
    ),
  );
}
