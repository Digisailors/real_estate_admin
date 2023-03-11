import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:real_estate_admin/Modules/Project/text_editing_controller.dart';
import '../../Model/Lead.dart';
import '../../Model/Property.dart';
import 'package:image_picker_web/image_picker_web.dart';

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
  final propertyAmount = CurrencyTextFieldController(
      rightSymbol: 'Rs. ', decimalSymbol: '.', thousandSymbol: ',');
  final buildUpArea = TextEditingController();
  final bedroomCount = TextEditingController();
  final uds = TextEditingController();


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
  List<dynamic> deletedPhotos = [];
  String? coverPhoto;
  bool isSold = false;
  List<Lead> leads = [];
  int leadCount = 0;

  Uint8List? coverPhototData;
  List<Uint8List> photosData = [];
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
        propertyAmount: propertyAmount.doubleValue,
        comissionType: comissionType,
        agentComission: agentComission.comission,
        superAgentComission: superAgentComission.comission,
        staffComission: staffComission.comission,
        leads: leads,
        isSold: isSold,
        reference: reference,
        bedroomCount: int.tryParse(bedroomCount.text),
        buildUpArea: buildUpArea.text,
        docId: reference.id,
        documents: [],
        facing: facing,
        leadCount: leadCount,
        // parentProject:  ,
        sellingAmount: double.tryParse(sellingAmount.text),
        uds: uds.text,
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
    propertyViewModel.agentComission = property.agentComission == null
        ? ComissionController.fromComission(property.agentComission!)
        : ComissionController();
    propertyViewModel.superAgentComission = property.superAgentComission == null
        ? ComissionController.fromComission(property.superAgentComission!)
        : ComissionController();
    propertyViewModel.staffComission = property.staffComission == null
        ? ComissionController.fromComission(property.staffComission!)
        : ComissionController();
    propertyViewModel.isSold = property.isSold;
    propertyViewModel.leads = property.leads;
    propertyViewModel._reference = property.reference;
    propertyViewModel.propertyID = property.propertyID;
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
