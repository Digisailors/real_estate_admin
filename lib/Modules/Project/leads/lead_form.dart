import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:real_estate_admin/Model/Lead.dart';
import 'package:real_estate_admin/Model/Property.dart';
import 'package:real_estate_admin/Model/Result.dart';
import 'package:real_estate_admin/Modules/Project/leads/lead_form_state.dart';
import 'package:real_estate_admin/widgets/formfield.dart';
import 'package:real_estate_admin/widgets/future_dialog.dart';
import 'package:real_estate_admin/widgets/utils.dart';

import '../../../Providers/session.dart';

class LeadForm extends StatefulWidget {
  const LeadForm({Key? key, this.lead, required this.property})
      : super(key: key);

  final Lead? lead;
  final Property property;

  @override
  State<LeadForm> createState() => _LeadFormState();
}

class _LeadFormState extends State<LeadForm> {
  bool isDuplicateLead = false;

  @override
  void initState() {
    if (widget.lead != null) {
      controller = LeadFormController.fromLead(widget.lead!);
    }
    super.initState();
  }

  late LeadFormController controller =
      LeadFormController(widget.property.reference);
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("LEAD"),
      ),
      body: SingleChildScrollView(
          child: Form(
        key: _formKey,
        child: Column(
          children: [
            const SizedBox(
              height: 60,
            ),
            Row(
              children: [
                Expanded(
                    child: TileFormField(
                  controller: controller.name,
                  title: 'NAME',
                  validator: requiredValidator,
                )),
                Expanded(
                    child: TileFormField(
                  controller: controller.phoneNumber,
                  title: 'PHONE',
                  validator: (val) {
                    var ret = requiredPhone(val);
                    if (ret != null) {
                      return ret;
                    }
                    if (isDuplicateLead) {
                      return 'A lead with the same contact has already been added';
                    }
                  },
                ))
              ],
            ),
            Row(
              children: [
                Expanded(
                    child: TileFormField(
                        controller: controller.address, title: 'ADDRESS')),
                Expanded(
                    child: TileFormField(
                        controller: controller.email, title: 'EMAIL'))
              ],
            ),
            Row(
              children: [
                Expanded(
                    child: TileFormField(
                        controller: controller.governmentId, title: 'GOVT.ID')),
                Expanded(
                    child: ListTile(
                  title: const Text("ENQUIRY DATE"),
                  subtitle: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: TextFormField(
                      controller: TextEditingController(
                          text: controller.enquiryDate
                              .toString()
                              .substring(0, 10)),
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        suffixIcon: GestureDetector(
                          onTap: () {
                            showDatePicker(
                              context: context,
                              initialDate: controller.enquiryDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            ).then((value) {
                              setState(() {
                                controller.enquiryDate =
                                    value ?? controller.enquiryDate;
                              });
                            });
                          },
                          child: const Icon(Icons.calendar_month),
                        ),
                      ),
                    ),
                  ),
                ))
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text("STAFF"),
                    subtitle: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: DropdownButtonFormField<DocumentReference?>(
                        value: controller.staffRef,
                        items: AppSession()
                            .staffs
                            .map(
                                (staff) => DropdownMenuItem<DocumentReference?>(
                                      value: staff.reference,
                                      child: Text(staff.firstName),
                                    ))
                            .toList(),
                        isExpanded: true,
                        decoration:
                            const InputDecoration(border: OutlineInputBorder()),
                        onChanged: controller.leadStatus == LeadStatus.lead &&
                                AppSession().isAdmin
                            ? (val) {
                                if (val != null) {
                                  controller.staffRef = val;
                                }
                              }
                            : null,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: const Text("AGENT"),
                    subtitle: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: DropdownButtonFormField<DocumentReference?>(
                        validator: (value) {
                          if (value == null) {
                            return 'Please select an agent';
                          }
                        },
                        value: controller.agentRef,
                        items: AppSession()
                            .agents
                            .map(
                                (agent) => DropdownMenuItem<DocumentReference?>(
                                      value: agent.reference,
                                      child: Text(agent.firstName),
                                    ))
                            .toList(),
                        isExpanded: true,
                        decoration:
                            const InputDecoration(border: OutlineInputBorder()),
                        onChanged: controller.leadStatus == LeadStatus.lead &&
                                AppSession().isAdmin
                            ? (val) {
                                if (val != null) {
                                  controller.agentRef = val;
                                }
                              }
                            : null,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.maxFinite,
                height: 60,
                child: ElevatedButton(
                    onPressed: () async {
                      isDuplicateLead = await widget.property.reference
                          .collection('leads')
                          .where('phoneNumber',
                              isEqualTo: controller.phoneNumber.text.trim())
                          .get()
                          .then((value) {
                        print(value.docs.length);
                        if (value.docs.isEmpty) {
                          return false;
                        }
                        if (widget.lead != null &&
                            value.docs.length == 1 &&
                            value.docs.first.reference ==
                                widget.lead?.reference) {
                          return false;
                        } else {
                          return true;
                        }
                      });
                      if (_formKey.currentState!.validate()) {
                        controller.propertyID = widget.property.propertyID;
                        controller.propertyName = widget.property.title;
                        var future = widget.lead == null
                            ? widget.property.addLead(controller.lead)
                            : widget.lead!.reference
                                .update(controller.lead.toJson())
                                .then((value) => Result(
                                    tilte: 'Success',
                                    message: 'Record modified Successfully'))
                                .onError((error, stackTrace) => Result(
                                    tilte: 'Failed',
                                    message:
                                        'Record not modified\n${error.toString()}'));
                        // ignore: use_build_context_synchronously
                        showFutureDialog(context, future: future,
                            onSucess: (val) {
                          Navigator.of(context).pop();
                        });
                      }
                    },
                    child: const Text("SUBMIT")),
              ),
            )
          ],
        ),
      )),
    );
  }
}
