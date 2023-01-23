import 'package:get/get.dart';

String? requiredValidator(String? string) {
  if ((string ?? '').trim().isEmpty) {
    return 'This is a required field';
  }
  return null;
}

String? requiredEmail(String? string) {
  if ((string ?? '').trim().isEmpty) {
    return 'This is a required field';
  }
  if (!(string ?? '').trim().isEmail) {
    return 'Please enter a valid email';
  }
  return null;
}



String validatePancard(String value) {
  String pattern = r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$';
  RegExp regExp = RegExp(pattern);
  if (value.isEmpty) {
    return 'Please Enter Pancard Number';
  } else if (!regExp.hasMatch(value)) {
    return 'Please Enter Valid Pancard Number';
  }
  
  return "";
}

String? requiredPhone(String? string) {
  if ((string ?? '').trim().isEmpty) {
    return 'This is a required field';
  }
  if (!(string ?? '').trim().isPhoneNumber) {
    return 'Please enter a valid phonenumber';
  }
  return null;
}

String? requiredPinCode(String? string) {
  if ((string ?? '').trim().isEmpty) {
    return 'This is a required field';
  }
  if (!(string ?? '').trim().isNumericOnly) {
    return 'Please enter a valid PIN code';
  }
  return null;
}
