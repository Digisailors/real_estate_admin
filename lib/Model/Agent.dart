import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:real_estate_admin/Model/Staff.dart';
import 'package:real_estate_admin/Providers/session.dart';

enum ActiveStatus {pendingApproval, active, blocked, all }

class Agent {
  int leadCount;
  int successfullLeadCount;
  String firstName;
  String? lastName;
  String phoneNumber;
  String? panCardNumber;
  String? addressLine1;
  String? addressLine2;
  String? city;
  String? state;
  String? country;
  String? pincode;
  String? accountHolderName;
  String? accountNumber;
  String? bankName;
  String? branch;
  String? ifscCode;
  String get docId => reference.id;
  String? email;
  DocumentReference reference;
  DocumentReference? superAgentReference;
  DocumentReference? approvedStaffReference;
  Agent? superAgent;
  Staff? approvedStaff;
  ActiveStatus activeStatus;

  String referenceCode;

  double commissionAmount;
  double sharedComissionAmount;

  Future<void> loadRefrences() async {
    if (superAgentReference != null) {
      superAgent = await superAgentReference!.get().then((value) => Agent.fromSnapshot(value));
    }
    if (approvedStaffReference != null) {
      approvedStaff = await approvedStaffReference!.get().then((value) => Staff.fromSnapshot(value));
    }
  }

  Agent({
    required this.leadCount,
    required this.successfullLeadCount,
    required this.referenceCode,
    this.panCardNumber,
    this.superAgentReference,
    this.approvedStaffReference,
    required this.phoneNumber,
    required this.firstName,
    this.lastName,
    this.email,
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.state,
    this.country,
    this.pincode,
    this.accountHolderName,
    this.accountNumber,
    this.bankName,
    this.branch,
    this.ifscCode,
    this.approvedStaff,
    this.activeStatus = ActiveStatus.pendingApproval,
    this.superAgent,
    this.commissionAmount = 0,
    this.sharedComissionAmount = 0,
    required this.reference,
  });

  Map<String, dynamic> toJson() => {
        'successfullLeadCount': successfullLeadCount,
        'leadCount': leadCount,
        "referenceCode": referenceCode,
        "firstName": firstName,
        "lastName": lastName,
        "phoneNumber": phoneNumber,
        "addressLine1": addressLine1,
        "addressLine2": addressLine2,
        "city": city,
        "state": state,
        "country": country,
        "pincode": pincode,
        "accountHolderName": accountHolderName,
        "accountNumber": accountNumber,
        "bankName": bankName,
        "branch": branch,
        "ifscCode": ifscCode,
        "panCardNumber": panCardNumber,
        "docId": docId,
        "superAgentReference": superAgentReference,
        "approvedStaffReference": approvedStaffReference,
        "email": email,
        'commissionAmount': commissionAmount,
        'sharedComissionAmount': sharedComissionAmount,
        "search": search,
        "activeStatus": activeStatus.index,
        "reference": reference,
      };

  static List<String> makeSearchstring(String string) {
    List<String> list = [];
    for (int i = 1; i < string.length; i++) {
      list.add(string.substring(0, i).toLowerCase());
    }
    list.add(string.toLowerCase());
    return list;
  }

  List<String> get search {
    List<String> returns = [];
    returns.addAll(makeSearchstring(firstName));
    if ((lastName ?? '').isNotEmpty) {
      returns.addAll(makeSearchstring(lastName!));
    }
    if ((panCardNumber ?? '').isNotEmpty) {
      returns.addAll(makeSearchstring(panCardNumber!));
    }
    if ((phoneNumber).isNotEmpty) {
      returns.addAll(makeSearchstring(phoneNumber));
    }

    return returns;
  }

  static Agent fromSnapshot(DocumentSnapshot snapshot) {
    var data = snapshot.data() as Map<String, dynamic>;
    return Agent(
      successfullLeadCount: data['successfullLeadCount'] ?? 0,
      leadCount: data['leadCount'] ?? 0,
      approvedStaff: data['approvedStaff'],
      reference: snapshot.reference,
      email: data["email"],
      activeStatus: data['activeStatus'] == null ? ActiveStatus.pendingApproval : ActiveStatus.values.elementAt(data['activeStatus']),
      referenceCode: data["referenceCode"],
      firstName: data["firstName"],
      lastName: data["lastName"],
      phoneNumber: data["phoneNumber"],
      addressLine1: data["addressLine1"],
      addressLine2: data["addressLine2"],
      city: data["city"],
      state: data["state"],
      country: data["country"],
      pincode: data["pincode"],
      accountHolderName: data["accountHolderName"],
      accountNumber: data["accountNumber"],
      bankName: data["bankName"],
      branch: data["branch"],
      ifscCode: data["ifscCode"],
      panCardNumber: data["panCardNumber"],
      superAgentReference: data["superAgentReference"],
      // approvedStaff: data['approvedStaff'],
      commissionAmount: data['commissionAmount'] ?? 0,
      sharedComissionAmount: data['sharedComissionAmount'] ?? 0,
      superAgent: AppSession().agents.firstWhereOrNull((element) => element.reference == data["superAgentReference"]),
      approvedStaffReference: data["approvedStaffReference"],
    );
  }

  factory Agent.fromJson(Map<String, dynamic> data) {
    return Agent(
      successfullLeadCount: data['successfullLeadCount'] ?? 0,
      leadCount: data['leadCount'] ?? 0,
      sharedComissionAmount: data['sharedComissionAmount'],
      email: data["email"],
      activeStatus: data['activeStatus'] == null ? ActiveStatus.pendingApproval : ActiveStatus.values.elementAt(data['activeStatus']),
      referenceCode: data["referenceCode"],
      firstName: data["firstName"],
      lastName: data["lastName"],
      phoneNumber: data["phoneNumber"],
      addressLine1: data["addressLine1"],
      addressLine2: data["addressLine2"],
      city: data["city"],
      state: data["state"],
      country: data["country"],
      pincode: data["pincode"],
      accountHolderName: data["accountHolderName"],
      accountNumber: data["accountNumber"],
      bankName: data["bankName"],
      branch: data["branch"],
      ifscCode: data["ifscCode"],
      panCardNumber: data["panCardNumber"],
      superAgentReference: data["superAgentReference"],
      approvedStaff: data["approvedStaff"],
      commissionAmount: data["commissionAmount"] ?? 0,
      superAgent: AppSession().agents.firstWhereOrNull((element) => element.reference == data["superAgentReference"]),
      approvedStaffReference: data["approvedStaffReference"],
      reference: data["reference"],
    );
  }

  Future<List<Agent>> getReferrals() async {
    return FirebaseFirestore.instance.collection('agents').where('superAgentReference', isEqualTo: reference).get().then((value) {
      return value.docs.map((e) => Agent.fromSnapshot(e)).toList();
    });
  }

  Future<void> disable() {
    return FirebaseFirestore.instance.collection('agents').doc(docId).update({
      "activeStatus": ActiveStatus.blocked.index,
    });
  }

  Future<void> enable() {
    return FirebaseFirestore.instance.collection('agents').doc(docId).update({
      "activeStatus": ActiveStatus.active.index,
    });
  }

  Future<void> approve() {
    return FirebaseFirestore.instance.collection('agents').doc(docId).update({
      "approvedStaffReference": AppSession().staff?.reference,
      "activeStatus": ActiveStatus.active.index,
    });
  }
}
