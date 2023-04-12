import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:real_estate_admin/Model/Project.dart';
import 'package:real_estate_admin/Model/Result.dart';
import 'package:real_estate_admin/Modules/Project/property_form_data.dart';

import '../../Model/Lead.dart';
import '../../Model/Property.dart';
import '../../Model/Staff.dart';
import '../../Model/helper models/attachment.dart';

class PropertyController {
  final PropertyViewModel propertyFormData;
  final Project project;

  PropertyController({required this.propertyFormData, required this.project});
  CollectionReference<Map<String, dynamic>> get properties =>
      project.reference.collection('properties');
  Reference get storage =>
      FirebaseStorage.instance.ref().child(project.reference.id);
  CollectionReference get leadsRef =>
      propertyFormData.reference.collection('leads');

  Future<String> uploadFile(Uint8List file, String name) async {
    var ref = storage.child(name);
    var url = await ref
        .putData(file)
        .then((p0) => p0.ref.getDownloadURL())
        .catchError((error) {
      print(error.toString());
    });
    return url;
  }

  Future<List<Attachment>> uploadDocuments() {
    List<Attachment> returns = [];
    returns.addAll(propertyFormData.attachments);
    List<Future<Attachment>> tempFutures = [];
    for (var element in propertyFormData.files) {
      tempFutures.add(uploadAttachment(element.bytes!, element.name));
    }
    return Future.wait(tempFutures).then((value) {
      returns.addAll(value);
      return returns;
    });
  }

  Future<Result> addProperty() async {
    try {
      propertyFormData.propertyID ??= await Property.getNextPropertyId();
    } catch (e) {
      return Result(tilte: "Failed", message: "Unable to get the property id");
    }

    try {
      if (propertyFormData.coverPhototData != null) {
        propertyFormData.coverPhoto = await uploadFile(
            propertyFormData.coverPhototData!,
            'coverPhoto${propertyFormData.propertyID}');
      }
    } catch (e) {
      return Result(
          tilte: "Error uploading coverphoto",
          message: 'Unknown error occurred, Cannot upload coverphoto');
    }
    List<Future> futures = [];
    if (propertyFormData.photosData.isNotEmpty) {
      List<Future<String>> photoFutures = [];
      int time = DateTime.now().millisecondsSinceEpoch;
      for (var element in propertyFormData.photosData) {
        photoFutures.add(uploadFile(element, (time++).toString()));
      }
      futures.add(Future.wait(photoFutures)
          .then((value) => propertyFormData.photos.addAll(value)));
    }
    if (propertyFormData.attachments.isNotEmpty) {
      try {
        futures.add(uploadDocuments()
            .then((value) => propertyFormData.attachments = value));
      } catch (e) {
        return Result(
            tilte: "Error uploading documents",
            message: 'Unknown error occurred, Cannot upload attachemtns');
      }
    }
    try {
      await Future.wait(futures);
    } catch (e) {
      return Result(
          tilte: "Error uploading documents",
          message: 'Unknown error occurred, Cannot upload attachemtns');
    }
    print("prinnt");
    print(propertyFormData.property.toJson());
    return propertyFormData.reference
        .set(propertyFormData.property.toJson())
        .then((value) async {
      final batch = FirebaseFirestore.instance.batch();
      if (propertyFormData.property.leads.isNotEmpty) {
        var leadsRef = propertyFormData.reference.collection('leads');
        for (var lead in propertyFormData.property.leads) {
          batch.set(leadsRef.doc(), lead.toJson());
        }
        await batch.commit();
      }
      return Result(
          tilte: Result.success, message: "Property added Successfully");
    });
  }

  Future<Result> updateProperty() async {
    if (propertyFormData.coverPhototData != null) {
      propertyFormData.coverPhoto = await uploadFile(
          propertyFormData.coverPhototData!,
          'coverPhoto${propertyFormData.propertyID}');
    }

    List<Future> futures = [];
    if (propertyFormData.photosData.isNotEmpty) {
      List<Future<String>> photoFutures = [];
      int time = DateTime.now().millisecondsSinceEpoch;
      for (var element in propertyFormData.photosData) {
        photoFutures.add(uploadFile(element, (time++).toString()));
      }
      futures.add(Future.wait(photoFutures)
          .then((value) => propertyFormData.photos.addAll(value)));
    }
    futures.add(uploadDocuments()
        .then((value) => propertyFormData.attachments = value));
    await Future.wait(futures);
    if (propertyFormData.deletedPhotos.isNotEmpty) {
      for (var element in propertyFormData.deletedPhotos) {
        FirebaseStorage.instance.refFromURL(element).delete();
      }
    }
    if (propertyFormData.deletedAtachments.isNotEmpty) {
      for (var element in propertyFormData.deletedAtachments) {
        FirebaseStorage.instance.refFromURL(element.url).delete();
      }
    }
    return propertyFormData.reference
        .update(propertyFormData.property.toJson())
        .then((value) => Result(
            tilte: Result.success, message: "Property updated Successfully"))
        .onError((error, stackTrace) =>
            Result(tilte: Result.failure, message: "Property update Failed!"));
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
        .then((value) => Result(
            tilte: Result.success, message: "Property updated Successfully"))
        .onError((error, stackTrace) =>
            Result(tilte: Result.failure, message: "Property update Failed!"));
  }

  Stream<List<Lead>> getLeads() {
    return leadsRef.snapshots().map((snapsot) =>
        snapsot.docs.map((e) => Lead.fromJson(e.data(), e.reference)).toList());
  }

  addLead(Lead lead) {
    DocumentReference reference = leadsRef.doc();
    lead.reference = reference;
    reference.set(lead.toJson());
  }

  assignStaff({required Lead lead, required Staff staff}) {
    lead.staff = staff;
  }

  Future<Attachment> uploadAttachment(Uint8List file, String name) async {
    var ref = storage.child(name);
    var url = await ref.putData(file).then((p0) => p0.ref.getDownloadURL());
    return Attachment(
        name: name, url: url, attachmentLocation: AttachmentLocation.cloud);
  }

  Future<Result> markAsSold() {
    return propertyFormData.reference
        .update({"isSold": true})
        .then((value) => Result(
            tilte: Result.success, message: "Property is sold as marked"))
        .onError((error, stackTrace) =>
            Result(tilte: Result.failure, message: error.toString()));
  }
}
