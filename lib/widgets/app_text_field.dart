import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final bool obscureText;
  final Widget? prefix;
  final Widget? suffix;
  final FocusNode? focusNode;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final int maxLines;

  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.obscureText = false,
    this.prefix,
    this.suffix,
    this.focusNode,
    this.textInputAction = TextInputAction.next,
    this.onFieldSubmitted,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          obscureText: obscureText,
          focusNode: focusNode,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefix,
            suffixIcon: suffix,
          ),
        ),
      ],
    );
  }
}
