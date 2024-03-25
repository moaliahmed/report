import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ShowDataPicker extends StatelessWidget {
  const ShowDataPicker({
    super.key,
    required this.dateController,
    required this.text,
  });

  final TextEditingController dateController;
  final String text;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onTap: () async {
        final DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.parse('2000-01-01'),
          lastDate: DateTime.now(),
        );
        if (pickedDate != null) { // Check if "Cancel" was pressed
          dateController.text = DateFormat.yMMMd().format(pickedDate);
        }
      },
      controller: dateController,
      decoration: InputDecoration(
        label: Text(text),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'الرجاء إدخال $text';
        }
        return null;
      },
    );
  }
}
