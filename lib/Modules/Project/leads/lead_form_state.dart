import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:real_estate_admin/Model/Lead.dart';

import '../../../Model/Agent.dart';
import '../../../Model/Property.dart';
import '../../../Model/Staff.dart';
// import '../../../Model/staff.dart';

class LeadFormController {
  TextEditingController name = TextEditingController();
  TextEditingController phoneNumber = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController governmentId = TextEditingController();
  DateTime enquiryDate = DateTime.now();
  DocumentReference? agentRef;
  DocumentReference? staffRef;
  Agent? agent;
  Staff? staff;
  DocumentReference? _reference;
  LeadStatus leadStatus = LeadStatus.lead;
  int? propertyID;
  String? propertyName;

  ComissionController staffComission = ComissionController();
  ComissionController agentComission = ComissionController();
  ComissionController superAgentComission = ComissionController();
  final TextEditingController sellingAmount = TextEditingController(text: '0.00');

  DateTime? soldOn;

  DocumentReference get reference => _reference ?? propertyRef.collection('leads').doc();

  LeadFormController(this.propertyRef);

  final DocumentReference propertyRef;

  factory LeadFormController.fromLead(Lead lead) {
    var controller = LeadFormController(lead.propertyRef);
    controller.name.text = lead.name;
    controller.phoneNumber.text = lead.phoneNumber ?? '';
    controller.address.text = lead.address ?? '';
    controller.email.text = lead.email ?? '';
    controller.governmentId.text = lead.governmentId ?? '';
    controller.enquiryDate = lead.enquiryDate;
    controller.agentRef = lead.agentRef;
    controller.staffRef = lead.staffRef;
    controller.agent = lead.agent;
    controller.staff = lead.staff;
    controller._reference = lead.reference;
    controller.agentComission = ComissionController.fromComission(lead.agentComission);
    controller.staffComission = ComissionController.fromComission(lead.staffComission);
    controller.superAgentComission = ComissionController.fromComission(lead.superAgentComission);
    controller.sellingAmount.text = lead.sellingAmount.toString();
    controller.leadStatus = lead.leadStatus;
    controller.propertyID = lead.propertyID;
    controller.propertyName = lead.propertyName;
    controller.soldOn = lead.soldOn;
    return controller;
  }

  Lead get lead {
    return Lead(
      soldOn: soldOn,
      propertyID: propertyID!,
      propertyName : propertyName,
      name: name.text,
      enquiryDate: enquiryDate,
      agentRef: agentRef,
      address: address.text,
      agent: agent,
      email: email.text,
      governmentId: governmentId.text,
      phoneNumber: phoneNumber.text,
      reference: reference,
      staff: staff,
      staffRef: staffRef,
      agentComission: agentComission.comission,
      leadStatus: leadStatus,
      sellingAmount: double.tryParse(sellingAmount.text) ?? 0.0,
      staffComission: staffComission.comission,
      superAgentComission: superAgentComission.comission,
    );
  }
}
