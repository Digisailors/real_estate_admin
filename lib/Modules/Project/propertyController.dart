import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:real_estate_admin/Model/Project.dart';
import 'package:real_estate_admin/Model/Result.dart';
import 'package:real_estate_admin/Modules/Project/property_form_data.dart';

import '../../Model/Lead.dart';
import '../../Model/Property.dart';
import '../../Model/Staff.dart';

class PropertyController {
  final PropertyViewModel propertyFormData;
  final Project project;

  PropertyController({required this.propertyFormData, required this.project});
  CollectionReference<Map<String, dynamic>> get properties => project.reference.collection('properties');
  Reference get storage => FirebaseStorage.instance.ref().child(project.reference.id);
  CollectionReference get leadsRef => propertyFormData.reference.collection('leads');

  Future<String> uploadFile(Uint8List file, String name) async {
    var ref = storage.child(name);
    var url = await ref.putData(file).then((p0) => p0.ref.getDownloadURL()).catchError((error) {
      print(error.toString());
    });
    return url;
  }

  Future<Result> addProperty() async {
    if (propertyFormData.coverPhototData != null) {
      propertyFormData.coverPhoto = await uploadFile(propertyFormData.coverPhototData!, 'coverPhoto');
    }

    if (propertyFormData.photosData.isNotEmpty) {
      List<Future<String>> futures = [];
      int time = DateTime.now().millisecondsSinceEpoch;
      for (var element in propertyFormData.photosData) {
        futures.add(uploadFile(element, (time++).toString()));
      }
      propertyFormData.photos = await Future.wait(futures);
    }
    return propertyFormData.reference.set(propertyFormData.property.toJson()).then((value) async {
      final batch = FirebaseFirestore.instance.batch();
      if (propertyFormData.property.leads.isNotEmpty) {
        var leadsRef = propertyFormData.reference.collection('leads');
        for (var lead in propertyFormData.property.leads) {
          batch.set(leadsRef.doc(), lead.toJson());
        }
        await batch.commit();
      }
      return Result(tilte: Result.success, message: "Property added Successfully");
    }).onError((error, stackTrace) => Result(tilte: Result.failure, message: "Property Addition Fialed!"));
  }

  Future<Result> updateProperty() async {
    if (propertyFormData.coverPhototData != null) {
      propertyFormData.coverPhoto = await uploadFile(propertyFormData.coverPhototData!, 'coverPhoto');
    }

    if (propertyFormData.photosData.isNotEmpty) {
      List<Future<String>> futures = [];
      int time = DateTime.now().millisecondsSinceEpoch;
      for (var element in propertyFormData.photosData) {
        futures.add(uploadFile(element, (time++).toString()));
      }
      var urls = await Future.wait(futures);
      propertyFormData.photos.addAll(urls);
    }
    if (propertyFormData.deletedPhotos.isNotEmpty) {
      for (var element in propertyFormData.deletedPhotos) {
        FirebaseStorage.instance.refFromURL(element).delete();
      }
    }
    return propertyFormData.reference
        .update(propertyFormData.property.toJson())
        .then((value) => Result(tilte: Result.success, message: "Property updated Successfully"))
        .onError((error, stackTrace) => Result(tilte: Result.failure, message: "Property update failed!"));
  }

  Future<Result> deleteProperty() {
    var deletedPhotos = [];
    deletedPhotos.add(propertyFormData.coverPhoto);
    deletedPhotos.addAll(propertyFormData.photos);
    for (var element in propertyFormData.deletedPhotos) {
      FirebaseStorage.instance.refFromURL(element).delete();
    }
    return propertyFormData.reference
        .delete()
        .then((value) => Result(tilte: Result.success, message: "Property updated Successfully"))
        .onError((error, stackTrace) => Result(tilte: Result.failure, message: "Property update failed!"));
  }

  Stream<List<Lead>> getLeads() {
    return leadsRef.snapshots().map((snapsot) => snapsot.docs.map((e) => Lead.fromJson(e.data(), e.reference)).toList());
  }

  addLead(Lead lead) {
    DocumentReference reference = leadsRef.doc();
    lead.reference = reference;
    reference.set(lead.toJson());
  }

  assignStaff({required Lead lead, required Staff staff}) {
    lead.staff = staff;
  }

  Future<Result> markAsSold() {
    return propertyFormData.reference
        .update({"isSold": true})
        .then((value) => Result(tilte: Result.success, message: "Property is sold as marked"))
        .onError((error, stackTrace) => Result(tilte: Result.failure, message: error.toString()));
  }
}
