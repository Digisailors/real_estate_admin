import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TileFormField extends StatelessWidget {
  const TileFormField({
    Key? key,
    required this.controller,
    required this.title,
    this.maxLines = 1,
    this.onChanged,
    this.keyboardType = TextInputType.multiline,
    this.inputFormatters,
    this.suffix,
    this.preffix,
    this.enabled,
    this.validator,
    this.obscureText = false,
  }) : super(key: key);

  final TextEditingController controller;
  final String title;
  final int? maxLines;
  final void Function(String)? onChanged;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? suffix;
  final Widget? preffix;
  final bool? enabled;
  final String? Function(String?)? validator;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: TextFormField(
          validator: validator,
          enabled: enabled,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          obscureText: obscureText,
          onChanged: onChanged,
          controller: controller,
          decoration: InputDecoration(
            prefix: preffix,
            errorStyle: const TextStyle(fontSize: 8),
            filled: true,
            fillColor:
                (enabled ?? true) ? Colors.transparent : Colors.grey.shade300,
            border: const OutlineInputBorder(),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 22),
            suffix: suffix,
          ),
          maxLines: maxLines,
        ),
      ),
    );
  }
}
