import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:real_estate_admin/Model/Property.dart';
import 'package:real_estate_admin/Model/Result.dart';
import 'package:real_estate_admin/Modules/Project/project_form_data.dart';
import 'package:real_estate_admin/Modules/Project/propertyController.dart';
import 'package:real_estate_admin/Modules/Project/property_form_data.dart';

class ProjectController extends ChangeNotifier {
  ProjectController(this.projectFormData);

  final ProjectFormData projectFormData;
  final CollectionReference<Map<String, dynamic>> projects =
      FirebaseFirestore.instance.collection('projects');
  Reference get projectStorageRef =>
      FirebaseStorage.instance.ref().child(projectFormData.reference.id);
  var storage = FirebaseStorage.instance;

  Future<String> uploadFile(Uint8List file, String name) async {
    var ref = projectStorageRef.child(name);
    var url = await ref
        .putData(file)
        .then((p0) => p0.ref.getDownloadURL())
        .catchError((error) {
      print(error.toString());
    });
    return url;
  }

  Future<Result> addProject() async {
    if (projectFormData.coverPhototData != null) {
      projectFormData.coverPhoto =
          await uploadFile(projectFormData.coverPhototData!, "coverPhoto.jpg");
    }
    var project = projectFormData.object;
    return project.reference.set(project.toJson()).then((value) {
      notifyListeners();
      return Result(
          tilte: Result.success, message: "Project Added Successfully");
    }).onError((error, stackTrace) => Result(
        tilte: Result.failure,
        message: 'Project Addition Failed.\n ${error.toString()}'));
  }

  Future<Result> updateProject() async {
    if (projectFormData.coverPhototData != null) {
      projectFormData.coverPhoto =
          await uploadFile(projectFormData.coverPhototData!, "coverPhoto");
    }
    
    if (projectFormData.deletedPhotos.isNotEmpty) {
      try {
        for (var element in projectFormData.deletedPhotos) {
          storage.refFromURL(element).delete();
        }
      } catch (e) {
        print(e.toString());
      }
    }
    var project = projectFormData.object;
    
    return project.reference.update(project.toJson()).then((value) {
      notifyListeners();
      return Result(
          tilte: Result.success, message: "Project updated Successfully");
    }).onError((error, stackTrace) {
      print(error.toString());
      return Result(
          tilte: Result.failure,
          message: 'Project update Failed.\n ${error.toString()}');
    });
  }

  Future<Result> deleteProject() async {
    if ((projectFormData.coverPhoto ?? '').isNotEmpty) {
      storage.refFromURL(projectFormData.coverPhoto!).delete();
    }
    await projectFormData.reference
        .collection('properties')
        .get()
        .then((snapshot) {
      var thisProperties = snapshot.docs.map((e) => Property.fromSnapshot(e));
      List<Future> futures = [];
      for (var property in thisProperties) {
        var propertyFormData = PropertyViewModel.fromProperty(property);
        var controller = PropertyController(
            propertyFormData: propertyFormData,
            project: projectFormData.object);
        futures.add(controller.deleteProperty());
      }
      return Future.wait(futures);
    });
    return projectFormData.reference
        .delete()
        .then((value) => Result(
            tilte: Result.success, message: "Project Deleted Successfully"))
        .onError((error, stackTrace) => Result(
            tilte: Result.failure,
            message: 'Project Deletion Failed.\n ${error.toString()}'));
  }

  Stream<List<Property>> getPropertiesAsStream({String? search, bool? isSold}) {
    Query<Map<String, dynamic>> query =
        projectFormData.reference.collection('properties');
    if ((search ?? '').isNotEmpty) {
      query =
          query.where('search', arrayContains: search!.toLowerCase().trim());
    }
    if (isSold != null) {
      query = query.where('isSold', isEqualTo: isSold);
    }
    return query.snapshots().map((event) {
      return event.docs.map((e) => Property.fromSnapshot(e)).toList();
    });
  }
}
