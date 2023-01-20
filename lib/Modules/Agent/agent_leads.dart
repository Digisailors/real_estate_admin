import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:real_estate_admin/Model/Agent.dart';
import 'package:real_estate_admin/Model/Property.dart';
import 'package:real_estate_admin/Providers/session.dart';

import '../../Model/Lead.dart';
import '../Project/Sales/sale_form.dart';
import '../Project/leads/lead_form.dart';

class AgentLeads extends StatefulWidget {
  const AgentLeads({Key? key, required this.agent}) : super(key: key);
  @override
  State<AgentLeads> createState() => _LeadListState();
  final Agent agent;
}

class _LeadListState extends State<AgentLeads> {
  late Query<Map<String, dynamic>> query;

  int totalLeads = 0;
  int convertedLeads = 0;

  Future<List<Lead>> getLeads() async {
    return FirebaseFirestore.instance.collectionGroup('leads').where('agentRef', isEqualTo: widget.agent.reference).get().then((event) {
      return event.docs.map((e) {
        var lead = Lead.fromSnapshot(e);
        return lead;
      }).toList();
    }).catchError((error) {
      printError(info: 'ERROR OCCURED IN LEDAS');
      return [];
    });
  }

  Future<List<Property>> getProperties() async {
    List<Property> properties = [];
    List<Lead> leads = await getLeads();
    print(" LEAD LENGTH : ${leads.length}");
    if (leads.isEmpty) {
      return properties;
    }
    Set<DocumentReference> propertyRefs = leads.map((e) => e.propertyRef).toSet();
    properties = await Future.wait(propertyRefs.map((e) => e.get().then((value) => Property.fromSnapshot(value))).toList());
    for (var element in properties) {
      element.leads = leads.where((lead) => lead.propertyRef == element.reference).toList();
    }
    print(" lENGTH :${properties.length}");
    return properties;
  }

  // Future<List<Property>>

  int count = 0;

  getColor(Lead lead) {
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

  Table getLeadTable(
    List<Lead> leads,
    BuildContext context,
  ) {
    return Table(
      children: [
        TableRow(
          children: [
            DataTable(
              columns: const [
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('Contact')),
                DataColumn(label: Text('Agent')),
                DataColumn(label: Text('Staff')),
              ],
              rows: leads
                  .map((e) => DataRow(color: MaterialStateProperty.all(getColor(e)), cells: [
                        DataCell(Text(e.name)),
                        DataCell(Text(e.phoneNumber ?? e.email ?? '')),
                        DataCell(Text(widget.agent.firstName)),
                        DataCell(
                          DropdownButtonFormField<DocumentReference?>(
                              value: e.staffRef,
                              items: AppSession()
                                  .staffs
                                  .map((staff) => DropdownMenuItem<DocumentReference?>(
                                        value: staff.reference,
                                        child: Text(staff.firstName),
                                      ))
                                  .toList(),
                              isExpanded: true,
                              decoration: const InputDecoration(border: OutlineInputBorder()),
                              onChanged: (e.leadStatus == LeadStatus.sold || !AppSession().isAdmin)
                                  ? null
                                  : (val) {
                                      if (val != null) {
                                        e.assignStaff(val);
                                      }
                                    }),
                        ),
                      ]))
                  .toList(),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: FutureBuilder<List<Property>>(
          future: getProperties(),
          builder: (BuildContext context, AsyncSnapshot<List<Property>> snapshot) {
            if ((snapshot.connectionState == ConnectionState.active || snapshot.connectionState == ConnectionState.done) && snapshot.hasData) {
              var list = snapshot.data!;
              if (list.isEmpty) {
                return const Center(
                  child: Text("No Leads found"),
                );
              }
              var alllist = list.map((e) => e.leads).reduce((value, element) => value.followedBy(element).toList());
              var successlist = alllist.where((element) => element.leadStatus == LeadStatus.sold);
              var count = successlist.length;
              return SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      width: double.maxFinite,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            flex: 4,
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: CircularProgressIndicator(
                                        value: count / list.length,
                                        backgroundColor: Colors.grey,
                                        strokeWidth: 16,
                                      ),
                                    ),
                                    Positioned.fill(
                                        child: Center(
                                            child: Text(
                                      "$count/${snapshot.data!.fold<int>(0, (previousValue, element) => (previousValue + element.leads.length))}\n LEADS",
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 18),
                                    )))
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 4,
                                        child: ListTile(
                                          title: const Text("LEADS"),
                                          subtitle: Text(snapshot.data!.length.toString()),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 6,
                                        child: ListTile(
                                          title: const Text("CONVERTED"),
                                          subtitle: Text(count.toString()),
                                        ),
                                      ),
                                    ],
                                  ),
                                  ListTile(
                                    title: const Text("COMISSION EARNED"),
                                    subtitle: Text(successlist
                                        .fold<double>(0, (double previousValue, element) => previousValue + element.agentComissionAmount)
                                        .toString()),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(),
                  ]
                      .followedBy(snapshot.data!
                          .map((property) => Card(
                                child: ExpansionTile(
                                  trailing: Text(property.leadCount.toString()),
                                  title: Text(property.title),
                                  subtitle: Text(property.district ?? ''),
                                  children: [getLeadTable(property.leads, context)],
                                ),
                              ))
                          .toList())
                      .toList(),
                ),
              );
            }
            if (snapshot.hasError) {
              if (kDebugMode) {
                print(snapshot.error.toString());
              }
              return Center(
                child: Text(snapshot.error.toString()),
              );
            }

            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}
