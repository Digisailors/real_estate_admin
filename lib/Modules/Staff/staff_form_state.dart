import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:real_estate_admin/Model/Staff.dart';

class StaffFormController {
  StaffFormController();
  TextEditingController firstName = TextEditingController();
  TextEditingController lastName = TextEditingController();
  TextEditingController phoneNumber = TextEditingController();
  TextEditingController panCardNumber = TextEditingController();
  TextEditingController addressLine1 = TextEditingController();
  TextEditingController addressLine2 = TextEditingController();
  TextEditingController city = TextEditingController();
  TextEditingController state = TextEditingController();
  TextEditingController country = TextEditingController();
  TextEditingController pincode = TextEditingController();
  TextEditingController accountHolderName = TextEditingController();
  TextEditingController accountNumber = TextEditingController();
  TextEditingController bankName = TextEditingController();
  TextEditingController branch = TextEditingController();
  TextEditingController ifscCode = TextEditingController();
  TextEditingController email = TextEditingController();

  TextEditingController password = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();
  Staff? superAgent;
  Staff? approvedStaff;
  bool isAdmin = false;
  double commissionAmount = 0;

  // String get newDocId => FirebaseFirestore.instance.collection('staffs').doc().id;

  DocumentReference? _reference;

  DocumentReference get reference {
    _reference ??= FirebaseFirestore.instance.collection('staffs').doc();
    return _reference!;
  }

  int leadCount = 0;
  int successfullLeadCount = 0;

  Staff get staff => Staff(
        successfullLeadCount: successfullLeadCount,
        leadCount: leadCount,
        commissionAmount: commissionAmount,
        reference: reference,
        panCardNumber: panCardNumber.text,
        // docId: docId ?? reference.id,
        phoneNumber: phoneNumber.text,
        firstName: firstName.text,
        lastName: lastName.text,
        email: email.text,
        addressLine1: addressLine1.text,
        addressLine2: addressLine2.text,
        city: city.text,
        state: state.text,
        country: country.text,
        pincode: pincode.text,
        accountHolderName: accountHolderName.text,
        bankName: bankName.text,
        branch: branch.text,
        ifscCode: ifscCode.text,
        isAdmin: isAdmin,
        password: password.text.trim(),
      );

  factory StaffFormController.fromStaff(Staff staff) {
    var controller = StaffFormController();
    controller.firstName.text = staff.firstName;
    controller.lastName.text = staff.lastName ?? '';
    controller.phoneNumber.text = staff.phoneNumber;
    controller.addressLine1.text = staff.addressLine1 ?? '';
    controller.addressLine2.text = staff.addressLine2 ?? '';
    controller.city.text = staff.city ?? '';
    controller.state.text = staff.state ?? '';
    controller.country.text = staff.country ?? '';
    controller.pincode.text = staff.pincode ?? '';
    controller.accountHolderName.text = staff.accountHolderName ?? '';
    controller.panCardNumber.text = staff.panCardNumber ?? '';
    controller.bankName.text = staff.bankName ?? '';
    controller.branch.text = staff.branch ?? '';
    controller.ifscCode.text = staff.ifscCode ?? '';
    controller.email.text = staff.email;
    controller._reference = staff.reference;
    controller.isAdmin = staff.isAdmin;
    controller.commissionAmount = staff.commissionAmount;
    controller.leadCount = staff.leadCount;
    controller.successfullLeadCount = staff.successfullLeadCount;
    return controller;
  }
}
