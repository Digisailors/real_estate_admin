// ignore: file_names
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:real_estate_admin/Model/Result.dart';

import 'Lead.dart';
import 'Project.dart';

enum ComissionType { percent, amount }

enum PropertyType { house, apartment, plot }

enum Unit {
  sqft,
}

class Property {
  String? docId;
  Project? parentProject;
  String? plotNumber;
  String? surveyNumber;
  String? dtcpNumber;
  String? district;
  String? taluk;
  String features;
  String? description;
  List<dynamic> photos;
  double propertyAmount;
  String? coverPhoto;
  String title;
  List<Lead> leads;

  ComissionType? comissionType;
  Commission? agentComission;
  Commission? superAgentComission;
  Commission? staffComission;
  bool isSold;
  DocumentReference reference;
  int leadCount;

  DocumentReference get projectRef => FirebaseFirestore.instance.doc(reference.path.split('/properties').first);

  Property({
    required this.title,
    this.leadCount = 0,
    this.plotNumber,
    this.surveyNumber,
    this.dtcpNumber,
    this.district,
    this.taluk,
    required this.features,
    this.description,
    this.coverPhoto,
    required this.photos,
    this.propertyAmount = 0,
    this.comissionType,
    this.agentComission,
    this.superAgentComission,
    this.staffComission,
    this.parentProject,
    required this.leads,
    required this.isSold,
    required this.reference,
  });

  Map<String, dynamic> toJson() => {
        'leadCount': leadCount,
        "title": title,
        "docId": docId,
        "parentProject": parentProject?.toJson(),
        "plotNumber": plotNumber,
        "surveyNumber": surveyNumber,
        "dtcpNumber": dtcpNumber,
        "district": district,
        "taluk": taluk,
        "features": features,
        "description": description,
        "coverPhoto": coverPhoto,
        "photos": photos,
        "propertyAmount": propertyAmount,
        "comissionType": comissionType?.index,
        "agentComission": agentComission?.toJson(),
        "superAgentComission": superAgentComission?.toJson(),
        "staffComission": staffComission?.toJson(),
        "leads": leads.map((e) => e.toJson()).toList(),
        "isSold": isSold,
        "search": search,
      };

  Stream<List<Lead>> getLeads() {
    return reference.collection('leads').snapshots().map((snapsot) => snapsot.docs.map((e) => Lead.fromJson(e.data(), e.reference)).toList());
  }

  Future<Result> addLead(Lead lead) {
    var batch = FirebaseFirestore.instance.batch();
    lead.reference = reference.collection('leads').doc();
    batch.set(lead.reference, lead.toJson());
    batch.update(lead.propertyRef, {'leadCount': FieldValue.increment(1)});
    return batch.commit().then((value) {
      return Result(tilte: Result.success, message: 'Lead added successfully');
    });
  }

  List<String> get search {
    List<String> returns = [];
    returns.addAll(makeSearchstring(plotNumber ?? ''));
    returns.addAll(makeSearchstring(surveyNumber ?? ''));
    returns.addAll(makeSearchstring(dtcpNumber ?? ''));
    returns.addAll(makeSearchstring(title));
    return returns;
  }

  List<String> makeSearchstring(String string) {
    if (string.isEmpty) {
      return [];
    }
    List<String> wordList = string.split(' ');
    Set<String> list = {};
    for (var element in wordList) {
      for (int i = 1; i < element.length; i++) {
        list.add(element.substring(0, i).trim().toLowerCase());
      }
      list.add(element.trim().toLowerCase());
    }
    list.add(string.toLowerCase());
    return list.toList();
  }

  factory Property.fromSnapshot(DocumentSnapshot snapshot) {
    var json = snapshot.data() as Map<String, dynamic>;
    var unparsedLeads = json["leads"];
    List<Lead> leads = [];
    if (unparsedLeads is List && unparsedLeads.isNotEmpty) {
      leads = unparsedLeads.map((e) => Lead.fromJson(e, snapshot.reference)).toList();
    }
    return Property(
      reference: snapshot.reference,
      isSold: json["isSold"],
      title: json["title"],
      parentProject: json["parentProject"] != null ? Project.fromJson(json["parentProject"]) : null,
      plotNumber: json["plotNumber"],
      surveyNumber: json["surveyNumber"],
      dtcpNumber: json["dtcpNumber"],
      district: json["district"],
      taluk: json["taluk"],
      features: json["features"],
      description: json["description"],
      coverPhoto: json["coverPhoto"],
      photos: json["photos"].map((e) => e as String).toList(),
      propertyAmount: json["propertyAmount"],
      comissionType: json["comissionType"] != null ? ComissionType.values.elementAt(json["comissionType"]) : null,
      agentComission: Commission.fromJson(json["agentComission"]),
      superAgentComission: Commission.fromJson(json["superAgentComission"]),
      staffComission: Commission.fromJson(json["staffComission"]),
      leads: leads,
    );
  }
}

class Commission {
  ComissionType comissionType;
  double value;

  Commission({
    this.comissionType = ComissionType.amount,
    this.value = 0.0,
  });

  static Commission? fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return null;
    }
    return Commission(comissionType: ComissionType.values.elementAt(json["comissionType"]), value: json["value"]);
  }

  Map<String, dynamic> toJson() {
    return {"comissionType": comissionType.index, "value": value};
  }
}

class ComissionController {
  ComissionType comissionType = ComissionType.amount;
  TextEditingController value = TextEditingController(text: '0.00');

  ComissionController();

  factory ComissionController.fromComission(Commission? comission) {
    var controler = ComissionController();
    if (comission != null) {
      controler.value.text = comission.value.toString();
      controler.comissionType = comission.comissionType;
    }
    return controler;
  }

  Commission get comission => Commission(comissionType: comissionType, value: double.tryParse(value.text) ?? 0);
}
