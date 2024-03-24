import 'package:flutter/material.dart';

class CustomDropdownButton extends StatelessWidget {
  final String hint;
  final List<String> items;
  final String? selectedItem;
  final ValueChanged<String?> onChanged;
  final String label;

  const CustomDropdownButton({
    super.key,
    required this.hint,
    required this.items,
    this.selectedItem,
    required this.onChanged,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            border:  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            labelText: label,
          ),
          value: selectedItem,
          hint: Text(hint),
          onChanged: onChanged,
          items: items.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a $label';
            }
            return null;
          },
        ),
      ],
    );
  }
}
