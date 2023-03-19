import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:real_estate_admin/Model/Result.dart';

class Staff {
  final String firstName;
  final String? lastName;
  final String phoneNumber;
  final String? addressLine1;
  final String? addressLine2;
  final String? city;
  final String? state;
  final String? country;
  final String? pincode;
  final String? accountHolderName;
  final String? panCardNumber;
  final String? bankName;
  final String? branch;
  final String? ifscCode;
  final String email;
  final DocumentReference reference;
  final bool isAdmin;
  double commissionAmount;
  int leadCount;
  int successfullLeadCount;
  String? password;

  Staff({
    required this.leadCount,
    required this.successfullLeadCount,
    required this.commissionAmount,
    this.isAdmin = false,
    required this.reference,
    required this.phoneNumber,
    required this.firstName,
    this.lastName,
    required this.email,
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.state,
    this.country,
    this.pincode,
    this.accountHolderName,
    this.panCardNumber,
    this.bankName,
    this.branch,
    this.ifscCode,
    this.password,
  });

  Map<String, dynamic> toJson() => {
        'successfullLeadCount': successfullLeadCount,
        'leadCount': leadCount,
        'isAdmin': isAdmin,
        "reference": reference,
        "phoneNumber": phoneNumber,
        "firstName": firstName,
        "lastName": lastName,
        "email": email,
        "addressLine1": addressLine1,
        "addressLine2": addressLine2,
        "city": city,
        "state": state,
        "country": country,
        "pincode": pincode,
        "accountHolderName": accountHolderName,
        "panCardNumber": panCardNumber,
        "bankName": bankName,
        "branch": branch,
        "ifscCode": ifscCode,
        "password": password,
        "search": search
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

  static Staff fromSnapshot(DocumentSnapshot snapshot) {
    var data = snapshot.data() as Map<String, dynamic>;
    return Staff(
      successfullLeadCount: data['successfullLeadCount'] ?? 0,
      leadCount: data['leadCount'] ?? 0,
      commissionAmount: data['commissionAmount'] ?? 0,
      isAdmin: data['isAdmin'] ?? false,
      reference: snapshot.reference,
      phoneNumber: data["phoneNumber"],
      firstName: data["firstName"],
      lastName: data["lastName"],
      email: data["email"],
      addressLine1: data["addressLine1"],
      addressLine2: data["addressLine2"],
      city: data["city"],
      state: data["state"],
      country: data["country"],
      pincode: data["pincode"],
      accountHolderName: data["accountHolderName"],
      panCardNumber: data["panCardNumber"],
      bankName: data["bankName"],
      branch: data["branch"],
      ifscCode: data["ifscCode"],
    );
  }

  factory Staff.fromJson(data) {
    return Staff(
      successfullLeadCount: data['successfullLeadCount'] ?? 0,
      leadCount: data['leadCount'] ?? 0,
      commissionAmount: data['commissionAmount'] ?? 0,
      isAdmin: data['isAdmin'] ?? false,
      reference: data['reference'],
      phoneNumber: data["phoneNumber"],
      firstName: data["firstName"],
      lastName: data["lastName"],
      email: data["email"],
      addressLine1: data["addressLine1"],
      addressLine2: data["addressLine2"],
      city: data["city"],
      state: data["state"],
      country: data["country"],
      pincode: data["pincode"],
      accountHolderName: data["accountHolderName"],
      panCardNumber: data["panCardNumber"],
      bankName: data["bankName"],
      branch: data["branch"],
      ifscCode: data["ifscCode"],
    );
  }

  static Future<List<Staff>> getStaffs() {
    return FirebaseFirestore.instance.collection('staffs').get().then((value) => value.docs.map((e) => Staff.fromSnapshot(e)).toList());
  }

  @override
  bool operator ==(Object other) {
    if (other is Staff) {
      if (reference == other.reference) {
        return true;
      }
    }
    return false;
  }

  @override
  // TODO: implement hashCode
  int get hashCode => super.hashCode;

  Future<Result> delete() {
    return reference
        .delete()
        .then((value) => Result(tilte: Result.success, message: "Staff deleted successfully"))
        .onError((error, stackTrace) => Result(tilte: Result.failure, message: "Could not delete document"));
  }
}
