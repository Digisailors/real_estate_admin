import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:real_estate_admin/Model/Staff.dart';
import 'package:real_estate_admin/Modules/Staff/staff_form.dart';

import '../../Providers/session.dart';
import '../../widgets/formfield.dart';

class StaffList extends StatefulWidget {
  const StaffList({Key? key}) : super(key: key);

  @override
  State<StaffList> createState() => _StaffListState();
}

class _StaffListState extends State<StaffList> {
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

  final agentsRef = FirebaseFirestore.instance.collection("staffs");

  late Query<Map<String, dynamic>> query;

  final searchController = TextEditingController();

  reload() {
    query = agentsRef;
    // if (activeStatus == ActiveStatus.all) {
    //   query = agentsRef;
    // }
//    query = query.where('activeStatus', isEqualTo: activeStatus.index);
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
      //   backgroundColor: Colors.white,
      //   title: const Text(
      //     "STAFF LIST",
      //     style: TextStyle(color: Colors.black),
      //   ),
      //   centerTitle: true,
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      // floatingActionButton: (AppSession().isAdmin)
      //     ? Padding(
      //         padding: const EdgeInsets.all(56.0),
      //         child: FloatingActionButton(
      //           onPressed: () {
      //             // Get.to(() => const AgentForm());
      //             showDialog(
      //                 context: context,
      //                 builder: (context) {
      //                   return const AlertDialog(
      //                     shape: RoundedRectangleBorder(
      //                         borderRadius:
      //                             BorderRadius.all(Radius.circular(10.0))),
      //                     content: SizedBox(
      //                         height: 800, width: 600, child: StaffForm()),
      //                   );
      //                 });
      //           },
      //           child: const Icon(Icons.add),
      //         ),
      //       )
      //     : null,
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
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                          width: 300,
                          child: TileFormField(
                              onChanged: (p0) {
                                setState(() {
                                  reload();
                                });
                              },
                              controller: searchController,
                              title: "SEARCH")),
                              SizedBox(width: 50,),
                      SizedBox(height: 35,width: 130,
                        child: ElevatedButton(
                                onPressed: () {
                  // Get.to(() => const AgentForm());
                  showDialog(
                      context: context,
                      builder: (context) {
                        return const AlertDialog(
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0))),
                          content: SizedBox(
                              height: 800, width: 600, child: StaffForm()),
                        );
                      });
                                },
                                child: const Text("Add Staff",style: TextStyle(fontSize: 18))),
                      ),                      // Padding(
                      //   padding: const EdgeInsets.all(16.0),
                      //   child: ElevatedButton(
                      //       onPressed: reload,
                      //       child: const Padding(
                      //         padding: EdgeInsets.all(16.0),
                      //         child: Text("SEARCH"),
                      //       )),
                      // )
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: query.snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                if (snapshot.connectionState == ConnectionState.active ||
                    snapshot.hasData) {
                  List<Staff> staffs = [];
                  staffs = snapshot.data!.docs
                      .map((e) => Staff.fromSnapshot(e))
                      .toList();
                  if (staffs.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text("No staffs are added yet"),
                      ),
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Card(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              SizedBox(
                                // height: double.maxFinite,
                                width: double.maxFinite,
                                child: PaginatedDataTable(
                                  showFirstLastButtons: true,
                                  rowsPerPage: 20,
                                  // (Get.height ~/ kMinInteractiveDimension) -
                                  //     4,
                                  columns: StaffListSource.getColumns(),
                                  source:
                                      StaffListSource(staffs, context: context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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
        ],
      ),
    );
  }
}

class StaffListSource extends DataTableSource {
  final List<Staff> staffs;
  final BuildContext context;
  StaffListSource(this.staffs, {required this.context});

  final _format = NumberFormat.currency(locale: 'en-IN');

  @override
  DataRow? getRow(int index) {
    // TODO: implement getRow
    final e = staffs[(index)];

    return DataRow.byIndex(
      index: index,
      cells: [
        // DataCell(Text((index + 1).toString())),
        DataCell(TextButton(
            onPressed: () {}, child: Text("${e.firstName} ${e.lastName}"))),
        DataCell(Text(e.phoneNumber)),
        DataCell(Text(e.panCardNumber ?? '')),
        DataCell(Text(e.email)),
        DataCell(Text(NumberFormat.currency(locale: 'en-IN', decimalDigits: 0)
            .format(e.commissionAmount))),
        DataCell(Text(e.leadCount.toString())),
        DataCell(Text(e.successfullLeadCount.toString())),
        DataCell(IconButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(10.0))),
                      content: SizedBox(
                          height: 800,
                          width: 600,
                          child: StaffForm(
                            staff: e,
                          )),
                    );
                  });
            },
            icon: const Icon(Icons.edit))),
        DataCell(IconButton(
            onPressed: () {
              e.delete();
            },
            icon: const Icon(Icons.delete))),
      ],
    );
  }

  @override
  // TODO: implement isRowCountApproximate
  bool get isRowCountApproximate => false;

  @override
  // TODO: implement rowCount
  int get rowCount => (staffs.length);

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
      const DataColumn(label: Text('Commission Earned')),
      const DataColumn(label: Text('Lead Count')),
      const DataColumn(label: Text('Converted Lead Count')),
      const DataColumn(label: Text('Edit')),
      const DataColumn(label: Text('Delete')),
    ]);
    return list;
  }
}
