import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:real_estate_admin/Model/Lead.dart';
import 'package:real_estate_admin/Model/Property.dart';
import 'package:real_estate_admin/Model/Result.dart';
import 'package:real_estate_admin/Model/Staff.dart';
import 'package:real_estate_admin/Modules/Dashboard/bar_chart.dart';
import 'package:real_estate_admin/Modules/Project/propertyController.dart';
import 'package:real_estate_admin/Modules/Project/property_form_data.dart';
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
  final costPerSqft = TextEditingController();
  // final costPerSqfttemp = TextEditingController();
  final sellingAmount = TextEditingController();
  // CurrencyTextFieldController(
  //     rightSymbol: 'Rs. ', decimalSymbol: '.', thousandSymbol: ',');

  double get sellingPrice => double.parse(sellingAmount.text.replaceAll(",", ""));

  Property? property;
  @override
  void initState() {
    super.initState();
    widget.lead.loadReferences();
    loadProperty();
    // print(property?.costPerSqft.toString());
    // print(costPerSqfttemp.text);
    // costPerSqft.text = NumberFormat.currency(
    //   locale: 'en-IN',
    //   symbol: '',
    //   decimalDigits: 0,
    // ).format(property?.costPerSqft ?? 0).toString();
    // costPerSqfttemp = TextEditingController(
    //     text: NumberFormat.currency(
    //   locale: 'en-IN',
    //   symbol: '',
    //   decimalDigits: 0,
    // ).format(property?.costPerSqft ?? 0).toString());

    // costPerSqft.text = costPerSqfttemp.text;

    // costPerSqfttemp.text = (property?.costPerSqft ?? 0).toString();

    // sellingAmount.text = widget.lead.sellingAmount.toString();
    agentComission = widget.lead.agentComission != null ? ComissionController.fromComission(widget.lead.agentComission!) : ComissionController();
    staffComission = widget.lead.staffComission != null ? ComissionController.fromComission(widget.lead.staffComission!) : ComissionController();
    superAgentComission =
        widget.lead.superAgentComission != null ? ComissionController.fromComission(widget.lead.superAgentComission!) : ComissionController();
  }

  bool loadingProperty = false;

  loadProperty() {
    loadingProperty = true;
    widget.lead.propertyRef.get().then((value) => Property.fromSnapshot(value)).then((value) {
      loadingProperty = false;
      property = value;
      if (widget.lead.agentComission == null && property!.agentComission != null) {
        agentComission = ComissionController.fromComission(property!.agentComission!);
      }
      if (widget.lead.staffComission == null && property!.staffComission != null) {
        staffComission = ComissionController.fromComission(property!.staffComission!);
      }
      if (widget.lead.superAgentComission == null && property!.superAgentComission != null) {
        superAgentComission = ComissionController.fromComission(property!.superAgentComission!);
      }
      if (mounted) {
        setState(() {});
      }
    });
  }

  BoxDecoration myBoxDecoration() {
    return BoxDecoration(
      border: Border.all(width: 1.0, color: Colors.grey),
      borderRadius: const BorderRadius.all(Radius.circular(5.0) //                 <--- border radius here
          ),
    );
  }

  final _formKey = GlobalKey<FormState>();

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
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TileFormField(
                          prefixText: '₹ ',
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                            IndianCurrencyFormatter(),
                          ],
                          controller: comission.value,
                          validator: (val) {
                            double actualAmount = comission.comissionType == ComissionType.percent
                                ? (comission.comission.value * sellingPrice / 100)
                                : comission.comission.value;
                            if (actualAmount > sellingPrice) {
                              return "Commission amount Should be less than Selling price";
                            }
                          },
                          onChanged: (val) {
                            reload(() {});
                          },
                          title: "COMMISSION",
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                          flex: 1,
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
                                          ? NumberFormat.currency(locale: 'en-IN', symbol: '₹ ', decimalDigits: 0)
                                              .format((comission.comission.value * sellingPrice / 100))
                                          : NumberFormat.currency(locale: 'en-IN', symbol: '₹ ', decimalDigits: 0).format(comission.comission.value),
                                      style: Theme.of(context).textTheme.bodyText2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )),
                      // Expanded(
                      //   flex: 3,
                      //   child: ListTile(
                      //     leading: Radio<ComissionType>(
                      //         value: ComissionType.amount,
                      //         groupValue: comission.comissionType,
                      //         onChanged: (val) {
                      //           reload(() {
                      //             comission.comissionType =
                      //                 val ?? comission.comissionType;
                      //           });
                      //         }),
                      //     title: const Text("Amount"),
                      //   ),
                      // ),
                      // Expanded(
                      //   flex: 3,
                      //   child: ListTile(
                      //     leading: Radio<ComissionType>(
                      //         value: ComissionType.percent,
                      //         groupValue: comission.comissionType,
                      //         onChanged: (val) {
                      //           reload(() {
                      //             comission.comissionType =
                      //                 val ?? comission.comissionType;
                      //           });
                      //         }),
                      //     title: const Text("Percent"),
                      //   ),
                      // ),
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
      body: Builder(builder: (context) {
        if (!loadingProperty) {
          return SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  TileFormField(controller: TextEditingController(text: widget.lead.name), title: "Buyer Name", enabled: false),
                  TileFormField(controller: TextEditingController(text: widget.lead.phoneNumber), title: "Buyer Contact", enabled: false),
                  TileFormField(controller: TextEditingController(text: widget.lead.governmentId), title: "Buyer ID", enabled: false),
                  TileFormField(
                    enabled: false,
                    controller: TextEditingController(
                        text: NumberFormat.currency(
                      locale: 'en-IN',
                      symbol: '₹ ',
                      decimalDigits: 0,
                    ).format(property?.costPerSqft ?? 0).toString()),
                    title: "Basic Cost Per Sqft.",
                  ),
                  StatefulBuilder(builder: (context, reload) {
                    widget.lead.propertyRef.get().then((value) {
                      reload(() {
                        property = Property.fromSnapshot(value);
                      });
                    });
                    return TileFormField(
                      // prefixText: '₹ ',
                      enabled: false,
                      controller: TextEditingController(
                          text: NumberFormat.currency(
                        locale: 'en-IN',
                        decimalDigits: 0,
                        symbol: '₹ ',
                      ).format(property?.propertyAmounts ?? 0).toString()),
                      title: "Basic Price",
                    );
                  }),
                  TileFormField(
                    prefixText: '₹ ',
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      IndianCurrencyFormatter(),
                    ],
                    controller: costPerSqft,
                    title: "Cost Per Sqft.",
                    onChanged: (val) {
                      setState(() {
                        print(property!.buildUpArea!);
                        if (costPerSqft.text.isEmpty) {
                          sellingAmount.text = "0";
                        }
                        double sellingAmounts =
                            double.parse(property!.buildUpArea!.replaceAll(",", "")) * double.parse(costPerSqft.text.replaceAll(",", ""));
                        final formatter = NumberFormat.currency(locale: 'en_IN', symbol: '', decimalDigits: 0).format(sellingAmounts);
                        sellingAmount.text = formatter.toString();
                      });
                    },
                  ),
                  TileFormField(
                    enabled: false,
                    prefixText: '₹ ',
                    // inputFormatters: [
                    //   FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    //   IndianCurrencyFormatter(),
                    // ],
                    validator: (val) {
                      if (val!.isEmpty) {
                        return 'Please enter selling amount';
                      }
                      // if (val.isNotEmpty) {
                      //   if (double.parse(
                      //           sellingAmount.text.replaceAll(",", "")) ==
                      //       0) {
                      //     return 'Please enter a amount greater than 0';
                      //   } else {
                      //     var number = double.tryParse(
                      //             sellingAmount.text.replaceAll(",", "")) ??
                      //         0;
                      //     if (property != null) {
                      //       if (property!.propertyAmount > number) {
                      //         return 'Selling amount is less than property amount';
                      //       }
                      //     }
                      //   }
                      // }
                      return null;
                    },
                    controller: sellingAmount,
                    title: "Selling Amount",
                  ),
                  const Text(
                    "* Price excludes TNEB, Private Terrace, Car Parking, Stamp Duty, Registration, GST etc.",
                    textAlign: TextAlign.start,
                    style: TextStyle(color: Colors.red),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  const Divider(),
                  getComission(comission: staffComission, title: 'STAFF COMMISSION', name: widget.lead.staff?.firstName ?? '', isStaff: true),
                  getComission(comission: agentComission, title: 'AGENT COMMISSION', name: widget.lead.agent?.firstName ?? ''),
                  getComission(comission: superAgentComission, title: 'SUPER AGENT COMMISSION', name: widget.lead.agent?.superAgent?.firstName ?? ''),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      height: 60,
                      width: double.maxFinite,
                      child: widget.lead.leadStatus == LeadStatus.sold
                          ? Container()
                          : ElevatedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
                                          content: SizedBox(
                                              height: 150,
                                              width: 400,
                                              child: Column(
                                                children: [
                                                  // Row(
                                                  //   mainAxisAlignment:
                                                  //       MainAxisAlignment
                                                  //           .spaceBetween,
                                                  //   children: [
                                                  //     const Text(
                                                  //         'Property Amount'),
                                                  //     Text(property!
                                                  //         .propertyAmounts
                                                  //         .toString()),
                                                  //   ],
                                                  // ),
                                                  const SizedBox(height: 10),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [Text("Selling Amount"), Text(sellingAmount.text)],
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [const Text('Staff Commission'), Text(staffComission.value.text)],
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [const Text('Agent Commission'), Text(agentComission.value.text)],
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [const Text('Super Agent Commission'), Text(superAgentComission.value.text)],
                                                  ),
                                                ],
                                              )),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context, 'Cancel');
                                              },
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () async {
                                                if (_formKey.currentState!.validate()) {
                                                  var future;
                                                  var lead = widget.lead;
                                                  if (AppSession().isAdmin) {
                                                    lead.leadStatus = LeadStatus.sold;
                                                    lead.soldOn = DateTime.now().trimTime();
                                                  } else if (widget.lead.leadStatus != LeadStatus.sold) {
                                                    lead.leadStatus = LeadStatus.pendingApproval;
                                                  }
                                                  lead.staffComission = staffComission.comission;
                                                  lead.agentComission = agentComission.comission;
                                                  lead.superAgentComission = superAgentComission.comission;
                                                  lead.sellingAmount = double.parse(sellingAmount.text.replaceAll(",", ""));
                                                  print(lead.toJson());

                                                  future = lead.propertyRef
                                                      .get()
                                                      .then((value) => Property.fromSnapshot(value))
                                                      .then((property) async {
                                                        if (property.isSold) {
                                                          throw Exception("Property already sold");
                                                        } else {
                                                          property.isSold = true;
                                                          property.sellingAmounts = lead.sellingAmount;
                                                          property.sellingAmount = lead.sellingAmount;
                                                          property.staffComission = lead.staffComission;
                                                          property.agentComission = lead.agentComission;
                                                          property.superAgentComission = lead.superAgentComission;
                                                        }
                                                        var batch = FirebaseFirestore.instance.batch();
                                                        await property.reference.collection('leads').get().then((value) {
                                                          for (var element in value.docs) {
                                                            if (element.reference != lead.reference) {
                                                              batch.update(element.reference, {"isParentPropertySold": true});
                                                            }
                                                          }
                                                        });
                                                        batch.update(lead.reference, lead.toJson());
                                                        return batch.commit();
                                                      })
                                                      .then((value) => Result(tilte: 'Success', message: "Record saved succesfully"))
                                                      .onError((error, stackTrace) =>
                                                          Result(tilte: 'Failed', message: "Record is not updated\n${error.toString()}"));

                                                  showFutureDialog2(
                                                    context,
                                                    future: future,
                                                  );
                                                }
                                              },
                                              child: const Text('OK'),
                                            ),
                                          ],
                                          title: const Text('Are you sure?', textAlign: TextAlign.center),
                                          titlePadding: const EdgeInsets.all(16),
                                          titleTextStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 22),
                                        );
                                      });
                                }
                              },
                              child: Text(widget.lead.leadStatus == LeadStatus.lead
                                  ? "MARK PROPERTY AS SOLD"
                                  : (widget.lead.leadStatus == LeadStatus.pendingApproval
                                      ? (AppSession().isAdmin ? "SAVE AND APPROVE" : "SAVE")
                                      : "SAVE")),
                            ),
                    ),
                  )
                ],
              ),
            ),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      }),
    );
  }
}
