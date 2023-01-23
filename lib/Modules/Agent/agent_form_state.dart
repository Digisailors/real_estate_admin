import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:real_estate_admin/Model/Staff.dart';

import '../../Model/Agent.dart';

class AgentFormController {
  var referralCode = TextEditingController();
  AgentFormController();
  TextEditingController firstName = TextEditingController();
  TextEditingController lastName = TextEditingController();
  TextEditingController phoneNumber = TextEditingController();
  TextEditingController panCardNumber = TextEditingController();
  TextEditingController addressLine1 = TextEditingController();
  TextEditingController addressLine2 = TextEditingController();
  TextEditingController city = TextEditingController();
  TextEditingController state = TextEditingController();
  TextEditingController country = TextEditingController();
  TextEditingController pincode = TextEditingController();
  TextEditingController accountHolderName = TextEditingController();
  TextEditingController accountNumber = TextEditingController();
  TextEditingController bankName = TextEditingController();
  TextEditingController branch = TextEditingController();
  TextEditingController ifscCode = TextEditingController();
  TextEditingController email = TextEditingController();
  DocumentReference? agentReference;
  DocumentReference? approvedStaffReference;
  Agent? superAgent;
  Staff? approvedStaff;
  String? referenceCode;
  ActiveStatus activeStatus = ActiveStatus.pendingApproval;
  double commissionAmount = 0.0;
  double sharedComissionAmount = 0.0;
  int leadCount = 0;
  int successfullLeadCount = 0;

  factory AgentFormController.fromAgent(Agent agent) {
    var controller = AgentFormController();
    controller._reference = agent.reference;
    controller.referenceCode = agent.referenceCode;
    controller.panCardNumber.text = agent.panCardNumber?.toUpperCase() ?? '';
    controller.agentReference = agent.superAgentReference;
    controller.approvedStaffReference = agent.approvedStaffReference;
    controller.phoneNumber.text = agent.phoneNumber;
    controller.firstName.text = agent.firstName;
    controller.lastName.text = agent.lastName ?? '';
    controller.email.text = agent.email ?? '';
    controller.addressLine1.text = agent.addressLine1 ?? '';
    controller.addressLine2.text = agent.addressLine2 ?? '';
    controller.city.text = agent.city ?? '';
    controller.state.text = agent.state ?? '';
    controller.country.text = agent.country ?? '';
    controller.pincode.text = agent.pincode ?? '';
    controller.accountHolderName.text = agent.accountHolderName ?? '';
    controller.accountNumber.text = agent.accountNumber ?? '';
    controller.bankName.text = agent.bankName ?? '';
    controller.branch.text = agent.branch ?? '';
    controller.ifscCode.text = agent.ifscCode ?? '';
    controller.activeStatus = agent.activeStatus;
    controller.commissionAmount = agent.commissionAmount;
    controller.sharedComissionAmount = agent.sharedComissionAmount;
    controller.leadCount = agent.leadCount;
    controller.successfullLeadCount = agent.successfullLeadCount;
    return controller;
  }

  String get newReferenceCode =>
      (Random.secure().nextInt(999999) + 100000).toString();
  DocumentReference? _reference;
  DocumentReference get reference {
    return _reference ?? FirebaseFirestore.instance.collection('agents').doc();
  }

  Agent get agent => Agent(
        successfullLeadCount: successfullLeadCount,
        leadCount: leadCount,
        referenceCode: referenceCode ?? newReferenceCode,
        panCardNumber: panCardNumber.text,
        superAgentReference: agentReference,
        approvedStaffReference: approvedStaffReference,
        phoneNumber: phoneNumber.text,
        firstName: firstName.text,
        lastName: lastName.text,
        email: email.text,
        addressLine1: addressLine1.text,
        addressLine2: addressLine2.text,
        city: city.text,
        state: state.text,
        country: country.text,
        pincode: pincode.text,
        accountHolderName: accountHolderName.text,
        accountNumber: accountNumber.text,
        bankName: bankName.text,
        branch: branch.text,
        ifscCode: ifscCode.text,
        approvedStaff: approvedStaff,
        superAgent: superAgent,
        reference: reference,
        activeStatus: activeStatus,
        commissionAmount: commissionAmount,
        sharedComissionAmount: sharedComissionAmount,
      );
}
