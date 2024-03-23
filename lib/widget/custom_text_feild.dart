import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String hint;
  final TextEditingController controller;
  final bool isPassword;
  final TextInputType? keyboardType;
  final String? Function(String?) validator;
  final Icon? prefixIcon;
  const CustomTextField({
    Key? key,
    required this.hint,
    required this.controller,
    this.isPassword = false,
    this.keyboardType, 
    this.prefixIcon, 
    required this.validator,
  }) : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _isVisible;

  @override
  void initState() {
    super.initState();
    _isVisible = !widget.isPassword;
  }

  void _toggleVisibility() {
    setState(() {
      _isVisible = !_isVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: !_isVisible,
      validator: widget.validator,
      keyboardType: widget.keyboardType, // استخدام keyboardType هنا
      decoration: InputDecoration(
        hintText: widget.hint,
        border: OutlineInputBorder(),
        prefixIcon:widget.prefixIcon ,
        suffixIcon: widget.isPassword
            ? IconButton(
                icon:
                    Icon(_isVisible ? Icons.visibility : Icons.visibility_off),
                onPressed: _toggleVisibility,
              )
            : null,
      ),
    );
  }
}
