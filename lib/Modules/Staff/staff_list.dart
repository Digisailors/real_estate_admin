import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:real_estate_admin/Model/Staff.dart';
import 'package:real_estate_admin/Modules/Staff/staff_form.dart';

class StaffList extends StatefulWidget {
  const StaffList({Key? key}) : super(key: key);

  @override
  State<StaffList> createState() => _StaffListState();
}

class _StaffListState extends State<StaffList> {
  @override
  void initState() {
    query = agentsRef;
    super.initState();
  }

  final agentsRef = FirebaseFirestore.instance.collection("staffs");

  late Query<Map<String, dynamic>> query;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Colors.white,
      //   title: const Text(
      //     "STAFFS LIST",
      //     style: TextStyle(color: Colors.black),
      //   ),
      //   centerTitle: true,
      // ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(56.0),
        child: FloatingActionButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) {
                  return const AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                    content:
                        SizedBox(height: 800, width: 600, child: StaffForm()),
                  );
                });
          },
          child: const Icon(Icons.add),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            StreamBuilder(
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
                        child: SizedBox(
                          width: double.maxFinite,
                          child: PaginatedDataTable(
                            rowsPerPage:
                                (Get.height ~/ kMinInteractiveDimension) - 4,
                            columns: StaffListSource.getColumns(),
                            source: StaffListSource(staffs, context: context),
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
          ],
        ),
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
        DataCell(Text(
            NumberFormat.currency(locale: 'en-IN').format(e.commissionAmount))),
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
      const DataColumn(label: Text('Comission Earned')),
      const DataColumn(label: Text('Lead count')),
      const DataColumn(label: Text('Converted LeadCount')),
      const DataColumn(label: Text('Edit')),
      const DataColumn(label: Text('Delete')),
    ]);
    return list;
  }
}
