import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:real_estate_admin/Model/Agent.dart';
import 'package:real_estate_admin/Model/Project.dart';
import 'package:real_estate_admin/Model/Property.dart';
import 'package:real_estate_admin/Model/Staff.dart';
import 'package:real_estate_admin/Modules/Project/Sales/sale_form.dart';
import 'package:real_estate_admin/Modules/Project/leads/lead_form.dart';
import 'package:real_estate_admin/Modules/Project/property_view.dart';
import 'package:real_estate_admin/Providers/session.dart';

import '../../../Model/Lead.dart';
import '../../../widgets/formfield.dart';

class LeadList extends StatefulWidget {
  const LeadList({Key? key, this.property}) : super(key: key);

  final Property? property;

  @override
  State<LeadList> createState() => _LeadListState();
}

class _LeadListState extends State<LeadList> {
  Agent? agent;
  Staff? staff;
  bool? convertedLeads = false;

  final leadsRef = FirebaseFirestore.instance.collection("leads");

  late Query<Map<String, dynamic>> query;

  final searchController = TextEditingController();

  reload() {
    query = leadsRef;
    if (searchController.text.isNotEmpty) {
      query = query.where('search',
          arrayContains: searchController.text.toLowerCase().trim());
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text("LEADS"),
      //   centerTitle: true,
      // ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: SizedBox(
                height: 120,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        SizedBox(
                            width: 300,
                            child: TileFormField(
                                onChanged: (v) {
                                  setState(() {
                                    reload();
                                  });
                                },
                                controller: searchController,
                                title: "SEARCH")),
                        // ElevatedButton(
                        //     onPressed: reload, child: const Text("SEARCH")),
                        SizedBox(
                          width: 300,
                          child: ListTile(
                            title: const Text("STAFF"),
                            subtitle: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: DropdownButtonFormField<Staff?>(
                                  value: staff,
                                  items: AppSession()
                                      .staffs
                                      .map((staffIterable) =>
                                          DropdownMenuItem<Staff?>(
                                            value: staffIterable,
                                            child:
                                                Text(staffIterable.firstName),
                                          ))
                                      .followedBy([
                                    const DropdownMenuItem<Staff?>(
                                      value: null,
                                      child: Text("ALL"),
                                    )
                                  ]).toList(),
                                  isExpanded: true,
                                  decoration: const InputDecoration(
                                      border: OutlineInputBorder()),
                                  onChanged: (val) {
                                    setState(() {
                                      staff = val;
                                    });
                                  }),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 300,
                          child: ListTile(
                            title: const Text("AGENT"),
                            subtitle: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: DropdownButtonFormField<Agent?>(
                                  value: agent,
                                  items: AppSession()
                                      .agents
                                      .map((agentIterable) =>
                                          DropdownMenuItem<Agent?>(
                                            value: agentIterable,
                                            child:
                                                Text(agentIterable.firstName),
                                          ))
                                      .followedBy([
                                    const DropdownMenuItem<Agent?>(
                                      value: null,
                                      child: Text("ALL"),
                                    )
                                  ]).toList(),
                                  isExpanded: true,
                                  decoration: const InputDecoration(
                                      border: OutlineInputBorder()),
                                  onChanged: (val) {
                                    setState(() {
                                      agent = val;
                                    });
                                  }),
                            ),
                          ),
                        ),
                        const SizedBox(width: 32),
                        ElevatedButton(
                          onPressed: () {
                            searchController.clear();
                            setState(() {
                              staff = null;
                              agent = null;
                            });
                          },
                          child: const Text("Clear"),
                        ),
                        const SizedBox(width: 32),
                      ]),
                ),
              ),
            ),
          ),
          Expanded(
            // child: Container(),
            child: StreamBuilder<List<Lead>>(
                stream: Lead.getLeads(
                    agent: agent, staff: staff, search: searchController.text),
                builder: (context, AsyncSnapshot<List<Lead>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.active &&
                      snapshot.hasData) {
                    return Card(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(
                              width: double.maxFinite,
                              child: PaginatedDataTable(
                                showFirstLastButtons: true,
                                dragStartBehavior: DragStartBehavior.start,
                                rowsPerPage: 20,
                                // (Get.height ~/ kMinInteractiveDimension) - 7,
                                columns: LeadListSource.getColumns(),
                                source: LeadListSource(
                                  snapshot.data ?? [],
                                  context: context,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    printError(info: snapshot.error.toString());
                    return Center(
                      child: SelectableText(snapshot.error.toString()),
                    );
                  }
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }),
          )
        ],
      ),
    );
  }
}

class LeadListSource extends DataTableSource {
  final List<Lead> leads;
  final BuildContext context;
  LeadListSource(this.leads, {required this.context});

  Color getColor(Lead lead) {
    switch (lead.leadStatus) {
      case LeadStatus.lead:
        return Colors.transparent;
      case LeadStatus.pendingApproval:
        return Colors.yellow.shade100;
      case LeadStatus.sold:
        return Colors.lightGreen.shade100;
      default:
        return Colors.transparent;
    }
  }

  @override
  DataRow? getRow(int index) {
    final _lead = leads[index];

    var dataRow = DataRow.byIndex(
      color: MaterialStateProperty.all(getColor(_lead)),
      index: index,
      cells: [
        DataCell(Text((index + 1).toString())),
        DataCell(Text(_lead.name)),
        DataCell(Text(_lead.email ?? "Nil")),
        DataCell(Text(_lead.phoneNumber ?? '')),
        DataCell(
          DropdownButtonFormField<DocumentReference?>(
              hint: _lead.staffRef == null
                  ? const Text(
                      'Not Assigned',
                      style: TextStyle(fontSize: 13),
                    )
                  : null,
              value: _lead.staffRef,
              items: [
                    const DropdownMenuItem<DocumentReference?>(
                      child: Text(
                        "None",
                        style: TextStyle(fontSize: 13),
                      ),
                    )
                  ] +
                  AppSession()
                      .staffs
                      .map((staff) => DropdownMenuItem<DocumentReference?>(
                            value: staff.reference,
                            child: Text(
                              staff.firstName,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ))
                      .toList(),
              isExpanded: true,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              onChanged:
                  _lead.leadStatus == LeadStatus.lead && AppSession().isAdmin
                      ? (val) {
                          if (val != null) {
                            _lead.assignStaff(val);
                          } else {
                            _lead.resignStaff();
                          }
                        }
                      : null),
        ),
        DataCell(Text(AppSession()
            .agents
            .where((element) => element.reference == _lead.agentRef)
            .first
            .firstName)),
        DataCell(Text(_lead.enquiryDate.toString().substring(0, 10))),
        DataCell(TextButton(
          onPressed: () {
            _lead.propertyRef.get().then((value) async {
              var property = Property.fromSnapshot(value);
              property.projectRef
                  .get()
                  .then((value) =>
                      Project.fromJson(value.data() as Map<String, dynamic>))
                  .then((project) {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0))),
                        content: SizedBox(
                          height: 800,
                          width: 600,
                          child: PropertyView(
                            projectName: project.name,
                            property: property,
                          ),
                        ),
                      );
                    });
              });
            });
          },
          // child: Text(_lead.parentProperty?.title ?? ""),
          child: Text(_lead.propertyName ?? ""),
          // child: Text('P${_lead.propertyID.toString().padLeft(6, '0')}'),
        )),
        DataCell(_lead.leadStatus != LeadStatus.lead
            ? Container()
            : ElevatedButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0))),
                          content: SizedBox(
                              height: 800,
                              width: 600,
                              child: SaleForm(
                                lead: _lead,
                              )),
                        );
                      });
                },
                child: const Text("Convert to sale"),
              )),
        DataCell(_lead.leadStatus == LeadStatus.sold
            ? const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(
                  Icons.edit,
                  color: Colors.grey,
                ),
              )
            : IconButton(
                onPressed: () async {
                  _lead.propertyRef
                      .get()
                      .then((value) => Property.fromSnapshot(value))
                      .then((property) {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0))),
                            content: SizedBox(
                                height: 800,
                                width: 600,
                                child: LeadForm(
                                  lead: _lead,
                                  property: property,
                                )),
                          );
                        });
                  });
                  ;
                },
                icon: const Icon(Icons.edit))),
        DataCell(_lead.leadStatus == LeadStatus.sold || !AppSession().isAdmin
            ? const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(
                  Icons.delete,
                  color: Colors.grey,
                ),
              )
            : IconButton(
                onPressed: () {
                  _lead.reference.delete();
                  _lead.propertyRef
                      .update({'leadCount': FieldValue.increment(-1)});
                },
                icon: const Icon(Icons.delete)))
      ],
    );
    if (!AppSession().isAdmin) {
      dataRow.cells.removeLast();
    }
    return dataRow;
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => (leads.length);

  @override
  int get selectedRowCount => 0;

  static List<DataColumn> getColumns() {
    List<DataColumn> list = [];
    list.addAll([
      const DataColumn(label: Text("S.No")),
      const DataColumn(label: Text("Name")),
      const DataColumn(label: Text("Email")),
      const DataColumn(label: Text("Phone")),
      const DataColumn(label: Text("Assigned")),
      const DataColumn(label: Text("Source")),
      const DataColumn(label: Text("Enquiry Date")),
      const DataColumn(label: Text("Property")),
      const DataColumn(label: Text("")),
      const DataColumn(label: Text("Edit")),
      const DataColumn(label: Text("Delete")),
    ]);
    if (!AppSession().isAdmin) {
      list.removeLast();
    }
    return list;
  }
}
