import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:real_estate_admin/Model/Agent.dart';
import 'package:real_estate_admin/Modules/Agent/agent_form.dart';
import 'package:real_estate_admin/Modules/Agent/agent_screen.dart';
import 'package:real_estate_admin/Providers/session.dart';
import 'package:real_estate_admin/widgets/formfield.dart';

class AgentList extends StatefulWidget {
  const AgentList({Key? key}) : super(key: key);

  @override
  State<AgentList> createState() => _AgentListState();
}

class _AgentListState extends State<AgentList> {
  @override
  void initState() {
    query = agentsRef;
    searchController.addListener(() {
      if (searchController.text.isEmpty) {
        reload();
      }
    });
    super.initState();
  }

  final agentsRef = FirebaseFirestore.instance.collection("agents");

  late Query<Map<String, dynamic>> query;

  final searchController = TextEditingController();
  ActiveStatus activeStatus = ActiveStatus.all;

  reload() {
    query = agentsRef;
    // if (activeStatus == ActiveStatus.all) {
    //   query = agentsRef;
    // }
    query = query.where('activeStatus', isEqualTo: activeStatus.index);
    if (searchController.text.isNotEmpty) {
      query = query.where('search', arrayContains: searchController.text.toLowerCase().trim());
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Colors.white,
      //   title: const Text(
      //     "AGENTS LIST",
      //     style: TextStyle(color: Colors.black),
      //   ),
      //   centerTitle: true,
      // ),
      floatingActionButton: (AppSession().isAdmin)
          ? Padding(
              padding: const EdgeInsets.all(56.0),
              child: FloatingActionButton(
                onPressed: () {
                  // Get.to(() => const AgentForm());
                  showDialog(
                      context: context,
                      builder: (context) {
                        return const AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
                          content: SizedBox(height: 800, width: 600, child: AgentForm()),
                        );
                      });
                },
                child: const Icon(Icons.add),
              ),
            )
          : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: 100,
                width: 800,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(width: 300, child: TileFormField(controller: searchController, title: "SEARCH")),
                      SizedBox(
                        width: 300,
                        child: ListTile(
                          title: const Text("STATUS"),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: DropdownButtonFormField<ActiveStatus>(
                              value: activeStatus,
                              items: const [
                                DropdownMenuItem(value: ActiveStatus.all, child: Text("ALL")),
                                DropdownMenuItem(value: ActiveStatus.active, child: Text("ACTIVE")),
                                DropdownMenuItem(value: ActiveStatus.blocked, child: Text("BLOCKED")),
                                DropdownMenuItem(value: ActiveStatus.pendingApproval, child: Text("YET TO APPROVE")),
                              ],
                              onChanged: (val) {
                                activeStatus = val ?? activeStatus;
                                reload();
                              },
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ElevatedButton(
                            onPressed: reload,
                            child: const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text("SEARCH"),
                            )),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: StreamBuilder(
                stream: query.snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.active || snapshot.hasData) {
                    List<Agent> agents = [];
                    agents = snapshot.data!.docs.map((e) => Agent.fromSnapshot(e)).toList();
                    if (agents.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Text("No agents are available"),
                        ),
                      );
                    } else {
                      return PaginatedDataTable(
                        rowsPerPage: (Get.height ~/ kMinInteractiveDimension) - 7,
                        source: AgentListSource(agents, context: context),
                        columns: AgentListSource.getColumns(),
                      );
                    }
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: SelectableText(snapshot.data.toString()),
                    );
                  }
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AgentListSource extends DataTableSource {
  final List<Agent> agents;
  final BuildContext context;
  AgentListSource(this.agents, {required this.context});

  final _format = NumberFormat.currency(locale: 'en-IN');

  @override
  DataRow? getRow(int index) {
    // TODO: implement getRow
    final e = agents[(index)];

    return DataRow.byIndex(
      color: MaterialStateProperty.all(e.activeStatus == ActiveStatus.active ? Colors.lightGreen.shade100 : Colors.white),
      index: index,
      cells: [
        // DataCell(Text((index + 1).toString())),
        DataCell(TextButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
                      content: SizedBox(height: 800, width: 600, child: AgentScreen(agent: e)),
                    );
                  });
            },
            child: Text("${e.firstName} ${e.lastName}"))),
        DataCell(Text(e.phoneNumber)),
        DataCell(Text(e.panCardNumber ?? '')),
        DataCell(Text(e.email ?? '')),
        DataCell(SelectableText(e.referenceCode)),
        DataCell(Text(e.superAgent?.firstName ?? '')),
        DataCell(Text(e.approvedStaff?.firstName ?? '')),
        DataCell(Row(children: [
          (e.activeStatus == ActiveStatus.active)
              ? Expanded(
                  flex: 2,
                  child: TextButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
                                title: const Text("Are you sure ?"),
                                content: const Text("This will disable the agent, and stop him from adding leads"),
                                actions: [
                                  TextButton(onPressed: Navigator.of(context).pop, child: const Text("NO")),
                                  TextButton(
                                      onPressed: () {
                                        e.disable();
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text("YES")),
                                ],
                              );
                            });
                      },
                      child: const Text("BLOCK")),
                )
              : Expanded(
                  flex: 2,
                  child: TextButton(
                      onPressed: e.activeStatus == ActiveStatus.pendingApproval ? e.approve : e.enable,
                      child: Text(e.activeStatus == ActiveStatus.pendingApproval ? "APPROVE" : "ACTIVATE")),
                ),
          Expanded(
            flex: 1,
            child: IconButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
                          content: SizedBox(
                              height: 800,
                              width: 600,
                              child: AgentForm(
                                agent: e,
                              )),
                        );
                      });
                },
                icon: const Icon(Icons.edit)),
          ),
        ])),
      ],
    );
  }

  @override
  // TODO: implement isRowCountApproximate
  bool get isRowCountApproximate => false;

  @override
  // TODO: implement rowCount
  int get rowCount => (agents.length);

  @override
  // TODO: implement selectedRowCount
  int get selectedRowCount => 0;

  static List<DataColumn> getColumns() {
    List<DataColumn> list = [];
    list.addAll([
      // const DataColumn(label: Text("S.No")),
      const DataColumn(label: Text('Name')),
      const DataColumn(label: Text('Phone')),
      const DataColumn(label: Text('PAN')),
      const DataColumn(label: Text('Email')),
      const DataColumn(label: Text('Referral Code')),
      const DataColumn(label: Text('Referred By')),
      const DataColumn(label: Text('Approved by')),
      DataColumn(
          label: Row(
        children: const [
          SizedBox(
            width: 30,
          ),
          Text(
            'Actions',
            textAlign: TextAlign.end,
          ),
        ],
      )),
    ]);
    return list;
  }
}
