import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:real_estate_admin/Model/Staff.dart';
import 'package:real_estate_admin/Modules/Staff/staff_controller.dart';
import 'package:real_estate_admin/Modules/Staff/staff_form_state.dart';
import 'package:real_estate_admin/Providers/session.dart';
import 'package:real_estate_admin/widgets/formfield.dart';
import 'package:real_estate_admin/widgets/future_dialog.dart';
import 'package:real_estate_admin/widgets/utils.dart';

class StaffForm extends StatefulWidget {
  const StaffForm({Key? key, this.staff}) : super(key: key);
  final Staff? staff;
  @override
  State<StaffForm> createState() => _StaffFormState();
}

class _StaffFormState extends State<StaffForm> {
  @override
  void initState() {
    super.initState();
    if (widget.staff != null) {
      controller = StaffFormController.fromStaff(widget.staff!);
    }
  }

  final _formKey = GlobalKey<FormState>();
  StaffFormController controller = StaffFormController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("STAFF FORM"),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: TileFormField(
                        validator: requiredValidator,
                        controller: controller.firstName,
                        title: "First Name"),
                  ),
                  Expanded(
                    child: TileFormField(
                        controller: controller.lastName, title: "Last Name"),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: TileFormField(
                        validator: (string) {
                          if ((string ?? '').isEmpty ||
                              !(string ?? '').isEmail) {
                            return 'Please enter a valid email';
                          }
                        },
                        controller: controller.email,
                        title: "EMAIL"),
                  ),
                  Expanded(
                    child: TileFormField(
                        validator: (string) {
                          if ((string ?? '').trim().isEmpty) {
                            return 'Please enter a phonenumber';
                          }
                          if (!(string ?? '').trim().isPhoneNumber) {
                            return 'Please enter a valid phonenumber';
                          }
                          if (widget.staff == null) {
                            if (AppSession()
                                .staffs
                                .where((element) =>
                                    element.phoneNumber.toLowerCase() ==
                                    string!.toLowerCase())
                                .isNotEmpty) {
                              return "Phone Number Already Exists";
                            }
                          }
                          //8610729733
                          return null;
                        },
                        controller: controller.phoneNumber,
                        title: "PHONE NUMBER"),
                  ),
                ],
              ),
              TileFormField(
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10)
                  ],
                  validator: (val) {
                    if (requiredValidator(val) != null) {
                      return requiredValidator(val);
                    }
                    String pattern = r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$';
                    RegExp regex = RegExp(pattern);
                    if (!regex.hasMatch(val!)) {
                      return 'Invalid PAN Number';
                    }
                    if (widget.staff == null) {
                      if (AppSession()
                          .staffs
                          .where((element) =>
                              element.panCardNumber!.toLowerCase() ==
                              val.toLowerCase())
                          .isNotEmpty) {
                        return "Duplicate PAN Number";
                      }
                    }
                  },
                  controller: controller.panCardNumber,
                  title: "PAN NUMBER"),
              TileFormField(
                  controller: controller.addressLine1, title: "ADDRESS LINE 1"),
              TileFormField(
                  controller: controller.addressLine2, title: "ADDRESS LINE 2"),
              Row(
                children: [
                  Expanded(
                    child: TileFormField(
                        controller: controller.city, title: "CITY"),
                  ),
                  Expanded(
                    child: TileFormField(
                        controller: controller.pincode, title: "PIN CODE"),
                  ),
                ],
              ),
              AppSession().isAdmin
                  ? Row(
                      children: [
                        Expanded(
                          child: CheckboxListTile(
                              title: const Text('Mark as Admin'),
                              value: controller.isAdmin,
                              onChanged: (val) {
                                setState(() {
                                  controller.isAdmin =
                                      val ?? controller.isAdmin;
                                });
                              }),
                        ),
                        Expanded(
                          child: Container(),
                        ),
                      ],
                    )
                  : Container(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.maxFinite,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        var staffController =
                            StaffController(formController: controller);
                        // print(controller.staff.toJson());
                        var future;
                        if (widget.staff == null) {
                          future = staffController.addStaff();
                        } else {
                          future = staffController.updateStaff();
                        }
                        showFutureDialog(context, future: future);
                      }
                    },
                    child: const Text("SUBMIT"),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
