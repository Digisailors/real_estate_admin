import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:real_estate_admin/Model/Property.dart';
import 'package:real_estate_admin/Providers/session.dart';
import 'package:real_estate_admin/widgets/formfield.dart';

BoxDecoration myBoxDecoration() {
  return BoxDecoration(
    border: Border.all(width: 1.0, color: Colors.grey),
    borderRadius: const BorderRadius.all(
        Radius.circular(5.0) //                 <--- border radius here
        ),
  );
}

class ComissionTile extends StatelessWidget {
  const ComissionTile({
    Key? key,
    required this.comissionController,
    required this.title,
    required this.name,
    this.validator,
    this.radioButton = true,
  }) : super(key: key);

  final ComissionController comissionController;
  final String title;
  final String name;
  final String? Function(String?)? validator;
  final bool? radioButton;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Container(
          decoration: myBoxDecoration(),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: StatefulBuilder(builder: (context, reload) {
              return Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TileFormField(
                      controller: comissionController.value,
                      validator: validator,
                      onChanged: (val) {
                        reload(() {});
                      },
                      title: "COMISSION",
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (radioButton!)
                    Expanded(
                      flex: 2,
                      child: ListTile(
                        leading: Radio<ComissionType>(
                            value: ComissionType.amount,
                            groupValue: comissionController.comissionType,
                            onChanged: (val) {
                              reload(() {
                                comissionController.comissionType =
                                    val ?? comissionController.comissionType;
                              });
                            }),
                        title: const Text("Amount"),
                      ),
                    ),
                  if (radioButton!)
                    Expanded(
                      flex: 2,
                      child: ListTile(
                        leading: Radio<ComissionType>(
                            value: ComissionType.percent,
                            groupValue: comissionController.comissionType,
                            onChanged: (val) {
                              reload(() {
                                comissionController.comissionType =
                                    val ?? comissionController.comissionType;
                              });
                            }),
                        title: const Text("Percent"),
                      ),
                    ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
