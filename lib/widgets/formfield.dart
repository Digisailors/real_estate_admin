import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

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
    this.prefixText, this.initialValue,
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
  final String? prefixText;
  final String? initialValue;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: TextFormField(
          initialValue: initialValue,
          validator: validator,
          enabled: enabled,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          obscureText: obscureText,
          onChanged: onChanged,
          controller: controller,
          decoration: InputDecoration(
            prefixText: prefixText,
            prefix: preffix,
            errorStyle: const TextStyle(fontSize: 12),
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

class IndianCurrencyFormatter extends TextInputFormatter {
  final formatter =
      NumberFormat.currency(locale: 'en_IN', symbol: '', decimalDigits: 0);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final double? parsed = double.tryParse(newValue.text);
    if (parsed != null) {
      final formatted = formatter.format(parsed);
      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
    return newValue;
  }
}
