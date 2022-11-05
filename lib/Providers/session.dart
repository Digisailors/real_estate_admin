import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:real_estate_admin/Model/Agent.dart';
import 'package:real_estate_admin/Model/Project.dart';
import 'package:real_estate_admin/Model/Property.dart';
import 'package:real_estate_admin/Model/Result.dart';

import '../Model/Staff.dart';

class AppSession extends ChangeNotifier {
  static final AppSession _instance = AppSession._internal();

  List<Staff> staffs = [];
  List<Agent> agents = [];

  Staff? staff;

  AppSession._internal() {
    firbaseAuth.authStateChanges().listen((event) async {
      if (event != null) {
        staffs = await Staff.getStaffs();

        FirebaseFirestore.instance.collection('agents').get().then((value) => value.docs.map((e) => Agent.fromSnapshot(e)).toList()).then((value) {
          agents = value;
          print(agents.length);
        });
        staff = staffs.firstWhereOrNull((element) => element.reference.id == event.uid);
      }
      notifyListeners();
    });

    pageController.addListener(() {
      notifyListeners();
    });
  }

  factory AppSession() {
    return _instance;
  }
  bool? _isAdmin;
  bool get isAdmin => _isAdmin ?? AppSession().staff?.isAdmin ?? false;

  Property? selectedProperty;
  Project? selectedProject;

  Future<bool> checkAdmin() async {
    if (firbaseAuth.currentUser != null) {
      return firbaseAuth.currentUser!.getIdTokenResult().then((value) {
        if (value.claims!.keys.contains('isAdmin')) {
          _isAdmin = value.claims!['isAdmin'];
          return _isAdmin ?? false;
        }
        return false;
      });
    }
    return false;
  }

  Future<Result> signIn({required String email, required String password}) {
    return firbaseAuth.signInWithEmailAndPassword(email: email, password: password).then((value) {
      checkAdmin();
      return Result(tilte: Result.success, message: "Logged in sucessfully");
    }).onError((error, stackTrace) => Result(tilte: Result.failure, message: error.toString()));
  }

  final PageController pageController = PageController(initialPage: 1);

  final firbaseAuth = FirebaseAuth.instance;
  User? get currentUser => firbaseAuth.currentUser;
}
