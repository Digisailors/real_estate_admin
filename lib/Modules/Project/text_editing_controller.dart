import 'package:flutter/material.dart';
import 'dart:math';

import 'package:intl/intl.dart';

/// A custom TextEditingController for currency input.
class CurrencyTextFieldController extends TextEditingController {
  final int _maxDigits = 11; // 999.999.999.99
  final int _numberOfDecimals = 2;

  final String _leftSymbol;
  final String _decimalSymbol;
  final String _thousandSymbol;
  String _previewsText = "";

  final _onlyNumbersRegex = new RegExp(r"[^\d]");

  double _value = 0.0;

  double get doubleValue => _value;
  String get leftSymbol => _leftSymbol;
  String get decimalSymbol => _decimalSymbol;
  String get thousandSymbol => _thousandSymbol;

  CurrencyTextFieldController(
      {String rightSymbol = "R\$ ",
      String decimalSymbol = ",",
      String thousandSymbol = "."})
      : _leftSymbol = rightSymbol,
        _decimalSymbol = decimalSymbol,
        _thousandSymbol = thousandSymbol {
    addListener(_listener);
  }

  _listener() {
    if (_previewsText == text) {
      if (_clear(text: text).length == _maxDigits) {
        _setSelectionBy(offset: text.length);
      }
      return;
    }

    final clearText = _clear(text: text);

    if (clearText.isEmpty) {
      _previewsText = "";
      text = "";
      return;
    }

    if (clearText.length > _maxDigits) {
      text = _previewsText;
      return;
    }

    if (!_isOnlyNumbers(string: clearText)) {
      text = _previewsText;
      return;
    }

    if ((double.tryParse(clearText) ?? 0.0) == 0.0) {
      _previewsText = "";
      text = "";
      return;
    }

    final maskedValue = "$_leftSymbol${_formatToNumber(string: clearText)}";

    _previewsText = maskedValue;
    _value = _getDoubleValueFor(string: clearText);
    text = maskedValue;

    _setSelectionBy(offset: text.length);
  }

  String _clear({required String text}) {
    return text
        .replaceAll(_leftSymbol, "")
        .replaceAll(_thousandSymbol, "")
        .replaceAll(_decimalSymbol, "")
        .trim();
  }

  _setSelectionBy({required int offset}) {
    selection = TextSelection.fromPosition(TextPosition(offset: offset));
  }

  bool _isOnlyNumbers({String? string}) {
    if (string == null || string.isEmpty) return false;

    final clearText = _getOnlyNumbers(string: string);

    return clearText != null ? (clearText.length == string.length) : false;
  }

  String? _getOnlyNumbers({String? string}) =>
      string?.replaceAll(_onlyNumbersRegex, "");

  String _formatToNumber({required String string}) {
    double value = _getDoubleValueFor(string: string);

    return _applyMaskTo(value: value);
  }

  double _getDoubleValueFor({required String string}) {
    return (double.tryParse(string) ?? 0.0) / pow(10, _numberOfDecimals);
  }

  String _applyMaskTo({required double value}) {
    return NumberFormat.simpleCurrency(locale: 'en_IN')
        .format(value)
        .split('₹ ')
        .last;
  }

  @override
  void dispose() {
    removeListener(_listener);
    super.dispose();
  }
}
