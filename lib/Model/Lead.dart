import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:real_estate_admin/Model/Property.dart';
import 'package:real_estate_admin/Model/Result.dart';
import 'package:real_estate_admin/Model/Staff.dart';
import 'package:real_estate_admin/Providers/session.dart';
import 'Agent.dart';

enum LeadStatus { lead, pendingApproval, sold }

class Lead {
  String name;
  String? phoneNumber;
  String? address;
  String? email;
  String? governmentId;
  DateTime enquiryDate;
  LeadStatus leadStatus;
  double? sellingAmount;
  DocumentReference? staffRef;
  Commission? staffComission;
  DocumentReference? agentRef;
  Commission? agentComission;
  double? costPerSqft;

  Commission? superAgentComission;

  DocumentReference reference;
  Property? parentProperty;
  int propertyID;
  String? propertyName;
  DocumentReference get propertyRef => FirebaseFirestore.instance.doc(reference.path.split('/leads').first);

  Agent? agent;
  Staff? staff;
  DateTime? soldOn;

  bool isParentPropertySold;

  Lead({
    this.soldOn,
    required this.propertyID,
    required this.propertyName,
    this.parentProperty,
    this.sellingAmount,
    this.staffComission,
    this.agentComission,
    this.superAgentComission,
    required this.name,
    this.phoneNumber,
    this.address,
    this.email,
    required this.enquiryDate,
    this.agentRef,
    this.staff,
    this.staffRef,
    this.agent,
    this.governmentId,
    required this.reference,
    this.leadStatus = LeadStatus.lead,
    required this.isParentPropertySold,
    this.costPerSqft,
  });

  void assignStaff(DocumentReference staffRefence) async {
    staff = await staffRefence.get().then((value) => Staff.fromSnapshot(value));
    staffRef = staffRefence;
    reference.update(toJson());
  }

  void resignStaff() {
    staff = null;
    staffRef = null;
    reference.update(toJson());
  }

  loadReferences() {
    staff = AppSession().staffs.firstWhereOrNull((element) => element.reference == staffRef);
    agent = AppSession().agents.firstWhereOrNull((element) => element.reference == agentRef);
    if (agent != null && agent!.superAgentReference != null) {
      agent!.superAgent = AppSession().agents.firstWhereOrNull((element) => element.reference == agent!.superAgentReference);
    }
  }

  List<String> get search {
    List<String> returns = [];
    returns.addAll(makeSearchstring(name));
    returns.addAll(makeSearchstring(phoneNumber!));
    // returns.addAll(makeSearchstring(type));
    return returns;
  }

  List<String> makeSearchstring(String string) {
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

  toJson() => {
        "soldOn": soldOn,
        "name": name,
        "phoneNumber": phoneNumber,
        "address": address,
        "email": email,
        "enquiryDate": enquiryDate,
        "governmentId": governmentId,
        "agentRef": agentRef,
        "staffRef": staffRef,
        "reference": reference,
        "leadStatus": leadStatus.index,
        "agent": agent?.toJson(),
        "staff": staff?.toJson(),
        "agentComission": agentComission?.toJson(),
        "staffComission": staffComission?.toJson(),
        "superAgentComission": superAgentComission?.toJson(),
        "sellingAmount": sellingAmount,
        "staffComissionAmount": staffComissionAmount,
        "agentComissionAmount": agentComissionAmount,
        "superAgentComissionAmount": superAgentComissionAmount,
        'propertyID': propertyID,
        'propertyName': propertyName,
        "search": search,
        "isParentPropertySold": isParentPropertySold,
        "costPerSqft": costPerSqft,
      };
  factory Lead.fromJson(json, DocumentReference reference) {
    return Lead(
      soldOn: json["soldOn"]?.toDate(),
      propertyID: json['propertyID'],
      propertyName: json['propertyName'],
      parentProperty: json['property'],
      name: json["name"],
      phoneNumber: json["phoneNumber"],
      address: json["address"],
      email: json["email"],
      enquiryDate: json["enquiryDate"].toDate(),
      governmentId: json['governmentId'],
      agentRef: json["agentRef"],
      staffRef: json["staffRef"],
      reference: reference,
      leadStatus: LeadStatus.values.elementAt(json["leadStatus"]),
      agent: json["agent"] != null ? Agent.fromJson(json["agent"]) : null,
      staff: json["staff"] != null ? Staff.fromJson(json["staff"]) : null,
      agentComission: json['agentComission'] != null ? Commission.fromJson(json['agentComission']) : null,
      staffComission: json['staffComission'] != null ? Commission.fromJson(json['staffComission']) : null,
      superAgentComission: json['superAgentComission'] != null ? Commission.fromJson(json['superAgentComission']) : null,
      sellingAmount: json['sellingAmount'],
      costPerSqft: json['costPerSqft'],
      isParentPropertySold: json['isParentPropertySold'] ?? false,
    );
  }
  factory Lead.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    Map<String, dynamic> json = snapshot.data()!;
    return Lead.fromJson(json, snapshot.reference);
  }

  double get staffComissionAmount {
    if (staffComission != null && sellingAmount != null) {
      if (staffComission!.comissionType == ComissionType.percent) {
        return sellingAmount! * staffComission!.value / 100;
      } else {
        return staffComission!.value;
      }
    } else {
      return 0.0;
    }
  }

  double get agentComissionAmount {
    if (staffComission != null && sellingAmount != null) {
      if (agentComission!.comissionType == ComissionType.percent) {
        return sellingAmount! * agentComission!.value / 100;
      } else {
        return agentComission!.value;
      }
    } else {
      return 0.0;
    }
  }

  double get superAgentComissionAmount {
    if (staffComission != null && sellingAmount != null) {
      if (superAgentComission!.comissionType == ComissionType.percent) {
        return sellingAmount! * superAgentComission!.value / 100;
      } else {
        return superAgentComission!.value;
      }
    } else {
      return 0.0;
    }
  }

  static Stream<List<Lead>> getLeads({Agent? agent, Staff? staff, String search = "", bool showONlySold = false}) {
    var query = FirebaseFirestore.instance.collectionGroup('leads').where('leadStatus', isEqualTo: LeadStatus.lead.index);
    if (showONlySold) {
      query = query.where("isParentPropertySold", isEqualTo: false);
    }
    if (agent != null) {
      // print(agent.reference);
      query = query.where('agentRef', isEqualTo: agent.reference);
    }
    if (staff != null) {
      // print(staff.reference);
      query = query.where('staffRef', isEqualTo: staff.reference);
    }
    if (search.isNotEmpty) {
      query = query.where('search', arrayContains: search.toLowerCase().trim());
    }
    return query.snapshots().map((event) {
      return event.docs.map((e) => Lead.fromSnapshot(e)).toList();
    });
  }

  static Stream<List<Lead>> getSales({Agent? agent, Staff? staff, LeadStatus? leadStatus}) {
    var query = FirebaseFirestore.instance.collectionGroup('leads');
    if (leadStatus == null) {
      query = query.where('leadStatus', isNotEqualTo: LeadStatus.lead.index);
    } else {
      query = query.where('leadStatus', isEqualTo: leadStatus.index);
    }

    return query.snapshots().map((event) {
      var list = event.docs.map((e) => Lead.fromSnapshot(e));

      if (agent != null) {
        list = list.where((element) => element.agentRef == agent.reference);
      }
      if (staff != null) {
        list = list.where((element) => element.staffRef == staff.reference);
      }
      return list.toList();
    });
  }

  Future<Result> convertToSaleApproval({
    required double sellingAmount,
    required Commission staffComission,
    required Commission agentComission,
    required Commission superAgentComission,
  }) async {
    if (AppSession().isAdmin) {
      this.sellingAmount = sellingAmount;
      this.staffComission = staffComission;
      this.agentComission = agentComission;
      this.superAgentComission = superAgentComission;
      leadStatus = LeadStatus.pendingApproval;
      reference.update(toJson()).then((value) => Result(tilte: "Lead Modified", message: "The Lead is moved to Sales List for approval"));
    } else {
      return convertToSale(
        agentComission: agentComission,
        sellingAmount: sellingAmount,
        staffComission: staffComission,
        superAgentComission: superAgentComission,
      );
    }
    return Result(tilte: 'Unknown Error', message: "Unknown Error Occured");
  }

  Future<Result> convertToSale({
    required double sellingAmount,
    required Commission staffComission,
    required Commission agentComission,
    required Commission superAgentComission,
  }) async {
    this.sellingAmount = sellingAmount;
    this.staffComission = staffComission;
    this.agentComission = agentComission;
    this.superAgentComission = superAgentComission;

    await agent?.loadRefrences();

    return propertyRef.get().then((value) {
      if (value.exists) {
        var property = Property.fromSnapshot(value);
        if (property.isSold) {
          return Result(tilte: Result.failure, message: "The Property has been already sold");
        } else {
          return FirebaseFirestore.instance
              .runTransaction((transaction) async {
                leadStatus = LeadStatus.sold;
                transaction.update(reference, toJson());
                transaction.update(propertyRef, {'isSold': true});
                if (staffRef != null) {
                  transaction.update(staffRef!, {'commissionAmount': FieldValue.increment(staffComissionAmount)});
                }
                if (agent?.reference != null) {
                  transaction.update(agent!.reference, {
                    'commissionAmount': FieldValue.increment(agentComissionAmount),
                    'sharedComissionAmount': FieldValue.increment(superAgentComissionAmount),
                  });
                }
                if (agent?.superAgentReference != null) {
                  transaction.update(agent!.superAgentReference!, {'commissionAmount': FieldValue.increment(superAgentComissionAmount)});
                }
                return transaction;
              })
              .then((value) => Result(tilte: Result.success, message: "The property is now marked as sold"))
              .onError((error, stackTrace) => Result(tilte: Result.failure, message: error.toString()));
        }
      } else {
        return Result(tilte: Result.failure, message: "Error occured, Could not load property");
      }
    });
  }
}
