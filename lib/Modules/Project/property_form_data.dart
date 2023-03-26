import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:real_estate_admin/Modules/Project/text_editing_controller.dart';
import '../../Model/Lead.dart';
import '../../Model/Property.dart';
import 'package:image_picker_web/image_picker_web.dart';

import '../../Model/helper models/attachment.dart';

enum Provide { network, memory, logo }

class PropertyViewModel extends ChangeNotifier {
  final title = TextEditingController();
  final plotNumber = TextEditingController();
  final surveyNumber = TextEditingController();
  final dtcpNumber = TextEditingController();
  final district = TextEditingController();
  final taluk = TextEditingController();
  final features = TextEditingController();
  final description = TextEditingController();
  final propertyAmount = TextEditingController();
  // CurrencyTextFieldController(
  //     rightSymbol: 'Rs. ', decimalSymbol: '.', thousandSymbol: ',');
  final buildUpArea = TextEditingController();
  final costPerSqft = TextEditingController();
  final sellingAmounts = TextEditingController();
  final propertyAmounts = TextEditingController();

  int? bedroomCount;
  final uds = TextEditingController();

  bool isCarParkingAvailable = false;
  bool isPrivateTerraceAvailable = false;

  ComissionController staffComission = ComissionController();
  ComissionController agentComission = ComissionController();
  ComissionController superAgentComission = ComissionController();
  final sellingAmount = CurrencyTextFieldController(
      rightSymbol: 'Rs. ', decimalSymbol: '.', thousandSymbol: ',');
  Facing? facing;

  double get sellingPrice => sellingAmount.doubleValue;
  int? propertyID;

  ComissionType comissionType = ComissionType.amount;
  DocumentReference? _reference;
  DocumentReference get reference =>
      _reference ?? projectReference.collection('properties').doc();

  final DocumentReference projectReference;

  List<dynamic> photos = [];
  List<Attachment> attachments = [];
  List<Attachment> deletedAtachments = [];
  List<dynamic> deletedPhotos = [];
  String? coverPhoto;
  bool isSold = false;
  List<Lead> leads = [];
  int leadCount = 0;

  Uint8List? coverPhototData;
  List<Uint8List> photosData = [];
  List<PlatformFile> files = [];
  List<Uint8List> get filesData => files
      .map((e) => e.bytes)
      .where((element) => element != null)
      .map((e) => e!)
      .toList();
  Provide show = Provide.logo;

  PropertyViewModel(this.projectReference);

  Future<void> pickImages() async {
    var files = await ImagePickerWeb.getMultiImagesAsBytes();
    if ((files ?? []).isNotEmpty) {
      photosData.addAll(files!);
    }
    notifyListeners();
    return;
  }

  Future<void> pickFiles() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      files = result.files;
    }
    notifyListeners();
    return;
  }

  List<Attachment> get tempAttachments {
    List<Attachment> returns = [];
    returns.addAll(files
        .map((e) => Attachment(
            name: e.name,
            url: '',
            attachmentLocation: AttachmentLocation.local,
            rawData: e.bytes))
        .toList());
    returns.addAll(attachments);
    // returns.add(null);
    return returns;
  }

  removeAttachement(Attachment attachment) {
    if (attachment.attachmentLocation == AttachmentLocation.local) {
      files.removeWhere((element) => element.name == attachment.name);
    } else {
      attachments.remove(attachment);
      deletedAtachments.add(attachment);
    }
  }

  Future<void> pickCoverPhoto() async {
    var mediaInfo = await ImagePickerWeb.getImageInfo;
    if (mediaInfo!.data != null && mediaInfo.fileName != null) {
      coverPhototData = mediaInfo.data;
      show = Provide.memory;
      notifyListeners();
    }
    return;
  }

  List<PhotoTile> getPhotoTiles() {
    List<PhotoTile> tiles = [];
    tiles.addAll(photos.map((e) => PhotoTile(e, null, () {
          deletedPhotos.add(e);
          photos.remove(e);
          notifyListeners();
        })));
    tiles.addAll(photosData.map((e) => PhotoTile(null, e, () {
          photosData.remove(e);
          notifyListeners();
        })));
    return tiles;
  }

  Property get property => Property(
        propertyID: propertyID!,
        title: title.text,
        plotNumber: plotNumber.text,
        surveyNumber: surveyNumber.text,
        dtcpNumber: dtcpNumber.text,
        district: district.text,
        taluk: taluk.text,
        features: features.text,
        description: description.text,
        coverPhoto: coverPhoto,
        photos: photos,
        propertyAmount: double.tryParse(propertyAmount.text) ?? 0,
        comissionType: comissionType,
        agentComission: agentComission.comission,
        superAgentComission: superAgentComission.comission,
        staffComission: staffComission.comission,
        leads: leads,
        isSold: isSold,
        reference: reference,
        bedroomCount: bedroomCount,
        buildUpArea: buildUpArea.text,
        docId: reference.id,
        documents: attachments,
        facing: facing,
        leadCount: leadCount,
        // parentProject:  ,
        sellingAmount: double.tryParse(sellingAmount.text),
        uds: uds.text,
        isCarParkingAvailable: isCarParkingAvailable,
        isPrivateTerraceAvailable: isPrivateTerraceAvailable,
        costPerSqft: double.parse(costPerSqft.text),
        sellingAmounts: double.tryParse(sellingAmounts.text),
        propertyAmounts: double.tryParse(propertyAmounts.text),
      );

  factory PropertyViewModel.fromProperty(Property property) {
    var propertyViewModel = PropertyViewModel(property.projectRef);
    propertyViewModel.title.text = property.title;
    propertyViewModel.plotNumber.text = property.plotNumber ?? '';
    propertyViewModel.surveyNumber.text = property.surveyNumber ?? '';
    propertyViewModel.dtcpNumber.text = property.dtcpNumber ?? '';
    propertyViewModel.district.text = property.district ?? '';
    propertyViewModel.taluk.text = property.taluk ?? '';
    propertyViewModel.features.text = property.features;
    propertyViewModel.description.text = property.description ?? '';
    propertyViewModel.coverPhoto = property.coverPhoto ?? '';
    propertyViewModel.photos = property.photos;
    propertyViewModel.propertyAmount.text = property.propertyAmount.toString();
    propertyViewModel.comissionType =
        property.comissionType ?? ComissionType.amount;
    propertyViewModel.agentComission = property.agentComission != null
        ? ComissionController.fromComission(property.agentComission!)
        : ComissionController();
    propertyViewModel.superAgentComission = property.superAgentComission != null
        ? ComissionController.fromComission(property.superAgentComission!)
        : ComissionController();
    propertyViewModel.staffComission = property.staffComission != null
        ? ComissionController.fromComission(property.staffComission!)
        : ComissionController();
    propertyViewModel.isSold = property.isSold;
    propertyViewModel.leads = property.leads;
    propertyViewModel._reference = property.reference;
    propertyViewModel.propertyID = property.propertyID;
    propertyViewModel.bedroomCount = property.bedroomCount;
    propertyViewModel.buildUpArea.text = property.buildUpArea ?? '';
    propertyViewModel.facing = property.facing;
    propertyViewModel.leadCount = property.leadCount;
    propertyViewModel.sellingAmount.text = property.sellingAmount.toString();
    propertyViewModel.uds.text = property.uds ?? '';
    propertyViewModel.isCarParkingAvailable =
        property.isCarParkingAvailable ?? false;
    propertyViewModel.isPrivateTerraceAvailable =
        property.isPrivateTerraceAvailable ?? false;
    propertyViewModel.costPerSqft.text = property.costPerSqft.toString();
    propertyViewModel.sellingAmounts.text = property.sellingAmounts.toString();
    propertyViewModel.propertyAmounts.text =
        property.propertyAmounts.toString();
    propertyViewModel.attachments = property.documents;

    return propertyViewModel;
  }
}

class PhotoTile {
  final String? url;
  final Uint8List? rawData;
  final void Function() remove;

  PhotoTile(this.url, this.rawData, this.remove);

  ImageProvider get provider {
    ImageProvider provider;
    if (rawData != null) {
      provider = MemoryImage(rawData!);
    } else {
      provider = NetworkImage(url!);
    }
    return provider;
  }
}
