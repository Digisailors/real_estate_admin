import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:real_estate_admin/Model/Result.dart';
import 'package:real_estate_admin/Model/Staff.dart';
import 'package:real_estate_admin/Modules/Staff/staff_form_state.dart';

class StaffController {
  StaffController({required this.formController});
  final StaffFormController formController;

  static final staffRef = FirebaseFirestore.instance.collection('staffs');
  Staff get staff => formController.staff;

  Future<Result> addStaff() {
    return staff.reference
        .set(staff.toJson())
        .then((value) => Result(tilte: Result.success, message: "Staff added Successfully"))
        .onError((error, stackTrace) => Result(tilte: "Staff addition Failed", message: error.toString()));
  }

  Future<Result> updateStaff() {
    return staff.reference
        .set(staff.toJson())
        .then((value) => Result(tilte: Result.success, message: "Staff record updated successfully"))
        .onError((error, stackTrace) => Result(tilte: Result.failure, message: "Staff record update failed"));
  }

  Future<Result> deleteStaff() {
    return staff.reference
        .delete()
        .then((value) => Result(tilte: Result.success, message: "Staff record updated successfully"))
        .onError((error, stackTrace) => Result(tilte: Result.failure, message: "Staff record update failed"));
  }

  static Future<List<Staff>> loadStaffs(String search) {
    return staffRef.where('search', arrayContains: search).get().then((snapshot) {
      return snapshot.docs.map((e) => Staff.fromSnapshot(e)).toList();
    });
  }
}
