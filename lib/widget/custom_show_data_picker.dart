import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ShowDataPicker extends StatelessWidget {
  const ShowDataPicker({
    super.key,
    required this.dateController,
    required this.text
  });

  final TextEditingController dateController;
  final String text;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onTap: () {
        showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.parse('2000-01-01'),
            lastDate: DateTime.now())
            .then((value) => dateController.text =
            DateFormat.yMMMd().format(value!));
      },
      controller: dateController,
      decoration: InputDecoration(
        label: Text(text),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return 'الرجاء ادخال $text';
        }
        return null;
      },
    );
  }
}
