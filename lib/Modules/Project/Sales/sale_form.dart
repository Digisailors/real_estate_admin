import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:real_estate_admin/Model/Lead.dart';
import 'package:real_estate_admin/Model/Property.dart';
import 'package:real_estate_admin/Model/Result.dart';
import 'package:real_estate_admin/Model/Staff.dart';
import 'package:real_estate_admin/Modules/Dashboard/bar_chart.dart';
import 'package:real_estate_admin/Providers/session.dart';
import 'package:real_estate_admin/widgets/formfield.dart';
import 'package:real_estate_admin/widgets/future_dialog.dart';

import '../text_editing_controller.dart';

class SaleForm extends StatefulWidget {
  const SaleForm({
    Key? key,
    required this.lead,
  }) : super(key: key);

  final Lead lead;

  @override
  State<SaleForm> createState() => _SaleFormState();
}

class _SaleFormState extends State<SaleForm> {
  late ComissionController staffComission;
  late ComissionController agentComission;
  late ComissionController superAgentComission;
  final sellingAmount = CurrencyTextFieldController(rightSymbol: 'Rs. ', decimalSymbol: '.', thousandSymbol: ',');

  double get sellingPrice => sellingAmount.doubleValue;

  Property? property;
  @override
  void initState() {
    super.initState();
    widget.lead.loadReferences();
    print("AGENT COMISSION");
    print(widget.lead.agentComission?.toJson());
    sellingAmount.text = widget.lead.sellingAmount.toString();
    agentComission = widget.lead.agentComission != null ? ComissionController.fromComission(widget.lead.agentComission!) : ComissionController();
    staffComission = widget.lead.staffComission != null ? ComissionController.fromComission(widget.lead.staffComission!) : ComissionController();
    superAgentComission =
        widget.lead.superAgentComission != null ? ComissionController.fromComission(widget.lead.superAgentComission!) : ComissionController();
  }

  BoxDecoration myBoxDecoration() {
    return BoxDecoration(
      border: Border.all(width: 1.0, color: Colors.grey),
      borderRadius: const BorderRadius.all(Radius.circular(5.0) //                 <--- border radius here
          ),
    );
  }

  getComission({required ComissionController comission, required String title, required String name, bool isStaff = false}) {
    return ListTile(
      title: Text(title),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Container(
          decoration: myBoxDecoration(),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: StatefulBuilder(builder: (context, reload) {
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: ListTile(
                        title: const Text("NAME"),
                        subtitle: isStaff
                            ? Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: DropdownButtonFormField<DocumentReference?>(
                                  value: widget.lead.staffRef,
                                  items: AppSession()
                                      .staffs
                                      .map((staff) => DropdownMenuItem<DocumentReference?>(
                                            value: staff.reference,
                                            child: Text(staff.firstName),
                                          ))
                                      .toList(),
                                  isExpanded: true,
                                  decoration: const InputDecoration(border: OutlineInputBorder()),
                                  onChanged: AppSession().isAdmin
                                      ? (val) {
                                          if (val != null) {
                                            widget.lead.staffRef = val;
                                            val.get().then((value) {
                                              widget.lead.staff = Staff.fromSnapshot(value);
                                            });
                                          }
                                        }
                                      : null,
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Container(
                                  decoration: myBoxDecoration(),
                                  // margin: const EdgeInsets.all(8),
                                  height: 56,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: Text(
                                        name.toString(),
                                        style: Theme.of(context).textTheme.bodyText2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                      )),
                      Expanded(
                        child: TileFormField(
                          controller: comission.value,
                          validator: (val) {
                            double actualAmount = comission.comissionType == ComissionType.percent
                                ? (comission.comission.value * sellingPrice / 100)
                                : comission.comission.value;
                            if (actualAmount > sellingPrice) {
                              return "Comission amount should not be higher than the Selling price";
                            }
                          },
                          onChanged: (val) {
                            reload(() {});
                          },
                          title: "COMISSION",
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                          flex: 4,
                          child: ListTile(
                            title: const Text("AMOUNT"),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Container(
                                decoration: myBoxDecoration().copyWith(color: Colors.grey.shade300),
                                // margin: const EdgeInsets.all(8),
                                height: 56,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Text(
                                      comission.comissionType == ComissionType.percent
                                          ? NumberFormat.currency(locale: 'en-IN').format((comission.comission.value * sellingPrice / 100))
                                          : NumberFormat.currency(locale: 'en-IN').format(comission.comission.value),
                                      style: Theme.of(context).textTheme.bodyText2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )),
                      Expanded(
                        flex: 3,
                        child: ListTile(
                          leading: Radio<ComissionType>(
                              value: ComissionType.amount,
                              groupValue: comission.comissionType,
                              onChanged: (val) {
                                reload(() {
                                  comission.comissionType = val ?? comission.comissionType;
                                });
                              }),
                          title: const Text("Amount"),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: ListTile(
                          leading: Radio<ComissionType>(
                              value: ComissionType.percent,
                              groupValue: comission.comissionType,
                              onChanged: (val) {
                                reload(() {
                                  comission.comissionType = val ?? comission.comissionType;
                                });
                              }),
                          title: const Text("Percent"),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SELL PROPERTY'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            TileFormField(controller: TextEditingController(text: widget.lead.name), title: "Buyer Name", enabled: false),
            TileFormField(controller: TextEditingController(text: widget.lead.phoneNumber), title: "Buyer Contact", enabled: false),
            TileFormField(controller: TextEditingController(text: widget.lead.governmentId), title: "Buyer ID", enabled: false),
            Row(
              children: [
                Expanded(
                  child: StatefulBuilder(builder: (context, reload) {
                    widget.lead.propertyRef.get().then((value) {
                      reload(() {
                        property = Property.fromSnapshot(value);
                      });
                    });
                    return TileFormField(
                      enabled: false,
                      controller: TextEditingController(text: property?.propertyAmount.toString()),
                      title: "Property Amount",
                    );
                  }),
                ),
                Expanded(
                  child: TileFormField(
                    validator: (val) {
                      if (val != null) {
                        if (double.tryParse(val) != null) {
                          return 'Please enter a valid amount';
                        } else {
                          var number = double.tryParse(val) ?? 0;
                          if (property != null) {
                            if (property!.propertyAmount < number) {
                              return 'Selling amount is less than property amount';
                            }
                          }
                        }
                      }
                    },
                    controller: sellingAmount,
                    title: "Selling Amount",
                    onChanged: (val) {
                      if (double.tryParse(val) != null) {
                        setState(() {});
                      }
                    },
                  ),
                ),
              ],
            ),
            getComission(comission: staffComission, title: 'STAFF COMISSION', name: widget.lead.staff?.firstName ?? '', isStaff: true),
            getComission(comission: agentComission, title: 'AGENT COMISSION', name: widget.lead.agent?.firstName ?? ''),
            getComission(comission: superAgentComission, title: 'SUPER AGENT COMISSION', name: widget.lead.agent?.superAgent?.firstName ?? ''),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                height: 60,
                width: double.maxFinite,
                child: widget.lead.leadStatus == LeadStatus.sold
                    ? Container()
                    : ElevatedButton(
                        onPressed: () async {
                          var future;
                          var lead = widget.lead;
                          if ((AppSession().staff?.isAdmin) ?? false) {
                            lead.leadStatus = LeadStatus.sold;
                            lead.soldOn = DateTime.now().trimTime();
                          } else if (widget.lead.leadStatus != LeadStatus.sold) {
                            lead.leadStatus = LeadStatus.pendingApproval;
                          }
                          lead.staffComission = staffComission.comission;
                          lead.agentComission = agentComission.comission;
                          lead.superAgentComission = superAgentComission.comission;
                          lead.sellingAmount = double.tryParse(sellingAmount.text) ?? 0;
                          future = lead.reference
                              .update(lead.toJson())
                              .then((value) => Result(tilte: 'Success', message: "Record saved succesfully"))
                              .onError((error, stackTrace) => Result(tilte: 'Failed', message: "Record is not updated \n ${error.toString()}"));

                          showFutureDialog(
                            context,
                            future: future,
                          );
                        },
                        child: Text(widget.lead.leadStatus == LeadStatus.lead
                            ? "MARK PROPERTY AS SOLD"
                            : (widget.lead.leadStatus == LeadStatus.pendingApproval ? (AppSession().isAdmin ? "SAVE AND APPROVE" : "SAVE") : "SAVE")),
                      ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
