import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:real_estate_admin/Model/Property.dart';
import 'package:real_estate_admin/Model/Staff.dart';
import 'package:real_estate_admin/Modules/Project/leads/lead_form.dart';
import 'package:real_estate_admin/Modules/Project/leads/lead_list.dart';
import 'package:real_estate_admin/Providers/session.dart';
import 'package:real_estate_admin/helper.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../../Model/Lead.dart';
import '../../Model/helper models/attachment.dart';
import 'Sales/sale_form.dart';

class PropertyView extends StatefulWidget {
  const PropertyView({Key? key, required this.property}) : super(key: key);

  final Property property;

  @override
  State<PropertyView> createState() => _PropertyViewState();
}

class _PropertyViewState extends State<PropertyView> {
  void downloadFile(Attachment attachment) {
    // String url = "https://www.africau.edu/images/default/sample.pdf";
    final anchor = html.AnchorElement(href: attachment.url)
      ..setAttribute('download', attachment.name)
      ..click();
    anchor.remove();
  }

  @override
  void didChangeDependencies() {
    if (mounted) {
      setState(() {});
    }
    super.didChangeDependencies();
  }

  List<Widget> getFeatures() {
    List<Widget> widgets = [
      Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Feature',
              style: getText(context).headline5!.apply(
                    color: Colors.lightBlue,
                  ),
            ),
          ),
          const Spacer(),
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: TextButton.icon(
          //     onPressed: () {
          //       for (var i = 0; i < widget.property.documents.length; i++) {
          //         var attachment = widget.property.documents[i];
          //         final anchor = AnchorElement(href: attachment.url)
          //           ..setAttribute('download', 'file_$i');
          //         document.body!.append(anchor);
          //         window.open(anchor.href!, '_blank');
          //         anchor.remove();
          //       }
          //     },
          //     icon: const Icon(
          //       Icons.file_download,
          //       size: 16,
          //       color: Colors.lightBlue,
          //     ),
          //     label: Text(
          //       'Download Brochure',
          //       style: getText(context)
          //           .headline5!
          //           .apply(color: Colors.lightBlue, fontSizeFactor: 0.5),
          //     ),
          //   ),
          // )
        ],
      ),
      SizedBox(
        height: Get.height * 0.15,
        width: double.maxFinite,
        child: ListView.builder(
          itemCount: widget.property.documents.length,
          itemBuilder: (BuildContext context, int index) {
            var attachment = widget.property.documents[index];
            return ListTile(
              title: Text(attachment.name),
              trailing: TextButton.icon(
                onPressed: () {
                  // for (var i = 0; i < widget.property.documents.length; i++) {
                  //   var attachment = widget.property.documents[i];
                  final anchor = AnchorElement(href: attachment.url)
                    ..setAttribute('download', 'file_$index');
                  document.body!.append(anchor);
                  window.open(anchor.href!, '_self');
                  anchor.remove();
                  // }
                },
                icon: const Icon(
                  Icons.file_download,
                  size: 16,
                  color: Colors.lightBlue,
                ),
                label: Text(
                  'Download',
                  style: getText(context)
                      .headline5!
                      .apply(color: Colors.lightBlue, fontSizeFactor: 0.5),
                ),
              ),
            );
          },
        ),
      )
    ];
    widgets.addAll([
      Row(
        children: [
          Expanded(
              child: ListTile(
            title: const Text("Build-up Area"),
            subtitle: Text(widget.property.buildUpArea ?? "Nil"),
          )),
          Expanded(
              child: ListTile(
            title: const Text("UDS"),
            subtitle: Text(widget.property.uds?.toString() ?? "Nil"),
          ))
        ],
      ),
      Row(
        children: [
          Expanded(
              child: ListTile(
            title: const Text("Facing Direction"),
            subtitle: Text(
                widget.property.facing?.name.replaceAll("_", " ") ?? "Nil"),
          )),
          Expanded(
              child: ListTile(
            title: const Text("Bed Rooms"),
            subtitle: Text(widget.property.bedroomCount?.toString() ?? "Nil"),
          ))
        ],
      ),
      Row(
        children: [
          Expanded(
              child: ListTile(
            title: const Text("Private terrace"),
            subtitle: Text((widget.property.isPrivateTerraceAvailable!)
                ? "Available"
                : "Not Available"),
          )),
          Expanded(
              child: ListTile(
            title: const Text("Car Parking"),
            subtitle: Text((widget.property.isCarParkingAvailable ?? false)
                ? "Available"
                : "Not Available"),
          )),
        ],
      ),
    ]);
    widgets.addAll((widget.property.features).split('\n').map(
          (e) => Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(e,
                  style: getText(context).bodyText1!.apply(color: Colors.grey)),
            ),
          ),
        ));
    return widgets;
  }

  showImage(int index) {
    // pageController.initialPage = index;
    showDialog(
        context: context,
        builder: (context) {
          return PhotoViewGallery.builder(
            itemCount: widget.property.photos.length,
            builder: (BuildContext context, int index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: NetworkImage(widget.property.photos[index]),
                initialScale: PhotoViewComputedScale.contained * 0.8,
                heroAttributes:
                    PhotoViewHeroAttributes(tag: widget.property.photos[index]),
              );
            },
            loadingBuilder: (context, event) => const Center(
              child: SizedBox(
                width: 20.0,
                height: 20.0,
                child: CircularProgressIndicator(),
              ),
            ),
            // pageController: pageController,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECECEC),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: GestureDetector(
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return PhotoViewGallery.builder(
                              itemCount: widget.property.coverPhoto!.length,
                              builder: (BuildContext context, int index) {
                                return PhotoViewGalleryPageOptions(
                                  imageProvider:
                                      NetworkImage(widget.property.coverPhoto!),
                                  initialScale:
                                      PhotoViewComputedScale.contained * 0.8,
                                  heroAttributes: PhotoViewHeroAttributes(
                                      tag: widget.property.coverPhoto!),
                                );
                              },
                              loadingBuilder: (context, event) => const Center(
                                child: SizedBox(
                                  width: 20.0,
                                  height: 20.0,
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              // pageController: pageController,
                            );
                          });
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        widget.property.coverPhoto ?? '',
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.3,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            widget.property.photos.isEmpty
                ? Container()
                : SizedBox(
                    width: Get.width,
                    height: Get.height * 0.15,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8.0),
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.property.photos.length,
                      itemBuilder: (BuildContext context, int index) {
                        var img = widget.property.photos[index];
                        return Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              12, 12, 12, 12),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: GestureDetector(
                              onTap: () {
                                showImage(index);
                              },
                              child: Image.network(
                                img,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                clipBehavior: Clip.antiAliasWithSaveLayer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(12, 12, 12, 12),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: getFeatures()),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SizedBox(
                  // height: getHeight(context)*0.30,
                  width: Get.height * 0.90,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            'Description',
                            style: getText(context)
                                .headline5!
                                .apply(color: Colors.lightBlue),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            widget.property.description ??
                                'No Description mentioned',
                            textAlign: TextAlign.start,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SizedBox(
                  // height: getHeight(context)*0.40,
                  width: Get.height * 0.90,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            'Land Details',
                            style: getText(context)
                                .headline5!
                                .apply(color: Colors.lightBlue),
                          ),
                        ),
                        // ListTile(
                        //   leading: CircleAvatar(
                        //     // backgroundImage:NetworkImage('https://t4.ftcdn.net/jpg/02/79/66/93/360_F_279669366_Lk12QalYQKMczLEa4ySjhaLtx1M2u7e6.jpg',scale: 0.5),
                        //     radius: 40,
                        //     child: ClipRRect(
                        //       borderRadius: BorderRadius.circular(50.0),
                        //       child: const Image(
                        //         image: NetworkImage(
                        //           'https://t4.ftcdn.net/jpg/02/79/66/93/360_F_279669366_Lk12QalYQKMczLEa4ySjhaLtx1M2u7e6.jpg',
                        //         ),
                        //       ),
                        //     ),
                        //   ),
                        //   title: const Text('Jhon Doe'),
                        //   subtitle: const Text('Land Owner'),
                        // ),
                        const Divider(
                          thickness: 2,
                        ),
                        Row(
                          children: [
                            Expanded(
                                flex: 1,
                                child: ListTile(
                                  subtitle:
                                      Text(widget.property.dtcpNumber ?? 'Nil'),
                                  title: const Text('Approval Number'),
                                )),
                            Expanded(
                                flex: 1,
                                child: ListTile(
                                  subtitle:
                                      Text(widget.property.plotNumber ?? 'Nil'),
                                  title: const Text('Plot No'),
                                ))
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                                flex: 1,
                                child: ListTile(
                                  subtitle: Text(
                                      widget.property.surveyNumber ?? 'Nil'),
                                  title: const Text('Survey / Patta Number'),
                                )),
                            Expanded(
                                flex: 1,
                                child: ListTile(
                                  subtitle:
                                      Text(widget.property.district ?? 'Nil'),
                                  title: const Text('District'),
                                ))
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                                flex: 1,
                                child: ListTile(
                                  subtitle:
                                      Text(widget.property.taluk ?? 'Nil'),
                                  title: const Text('Taluk'),
                                )),
                            Expanded(
                                flex: 1,
                                child: ListTile(
                                  subtitle: Text(widget.property.propertyAmount
                                      .toString()),
                                  title: const Text('Property Value'),
                                ))
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                                flex: 1,
                                child: ListTile(
                                  subtitle: Text(widget.property.propertyAmounts
                                      .toString()),
                                  title: const Text('Propery Amount'),
                                )),
                            // Expanded(
                            //     flex: 1,
                            //     child: ListTile(
                            //       subtitle: Text(widget.property.sellingAmounts
                            //           .toString()),
                            //       title: const Text('Selling Amount'),
                            //     ))
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                                flex: 1,
                                child: ListTile(
                                  subtitle: Text(widget
                                      .property.agentComission!.value
                                      .toString()),
                                  title: const Text('Agent Comission'),
                                )),
                            Expanded(
                                flex: 1,
                                child: ListTile(
                                  subtitle: Text(widget
                                      .property.staffComission!.value
                                      .toString()),
                                  title: const Text('Staff Comission'),
                                ))
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                                flex: 1,
                                child: ListTile(
                                  subtitle: Text(widget
                                      .property.superAgentComission!.value
                                      .toString()),
                                  title: const Text('Super Agent Comission'),
                                )),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: StreamBuilder<List<Lead>>(
                  stream: widget.property.getLeads(),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<Lead>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.active &&
                        snapshot.hasData) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  'Leads',
                                  style: getText(context)
                                      .headline5!
                                      .apply(color: Colors.lightBlue),
                                ),
                              ),
                              Expanded(child: Container()),
                              widget.property.isSold
                                  ? Container()
                                  : Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      child: ElevatedButton(
                                          onPressed: () {
                                            showModalBottomSheet(
                                                isScrollControlled: true,
                                                constraints: BoxConstraints(
                                                    maxWidth:
                                                        double.maxFinite / 2,
                                                    minHeight:
                                                        Get.height * 0.8),
                                                backgroundColor:
                                                    Colors.transparent,
                                                context: context,
                                                builder: (context) {
                                                  return SizedBox(
                                                    height: Get.height * 0.7,
                                                    child: LayoutBuilder(
                                                        builder: (context,
                                                            constraints) {
                                                      return Container(
                                                        color:
                                                            Colors.transparent,
                                                        child: Align(
                                                          alignment: Alignment
                                                              .centerRight,
                                                          child: ConstrainedBox(
                                                            constraints: constraints
                                                                .copyWith(
                                                                    maxWidth:
                                                                        constraints.maxWidth /
                                                                            2),
                                                            child: LeadForm(
                                                                property: widget
                                                                    .property),
                                                          ),
                                                        ),
                                                      );
                                                    }),
                                                  );
                                                });
                                          },
                                          child: const Text('Add Lead')),
                                    )
                            ],
                          ),
                          const Divider(
                            thickness: 2,
                          ),
                          getLeadTable(snapshot, context),
                        ],
                      );
                    }
                    if (snapshot.hasError) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(child: Text(snapshot.error.toString())),
                      );
                    }
                    return const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(child: Text("Loading your leads...")),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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

  Table getLeadTable(AsyncSnapshot<List<Lead>> snapshot, BuildContext context) {
    return Table(
      children: [
        TableRow(
          children: [
            FittedBox(
              child: DataTable(
                columns: [
                  const DataColumn(label: Text('Name')),
                  const DataColumn(label: Text('Contact')),
                  const DataColumn(label: Text('Agent')),
                  const DataColumn(label: Text('Staff')),
                  DataColumn(label: Container()),
                ],
                rows: snapshot.data!
                    .map((e) => DataRow(
                            color: MaterialStateProperty.all(getColor(e)),
                            cells: [
                              DataCell(Text(e.name)),
                              DataCell(Text(e.phoneNumber ?? e.email ?? '')),
                              DataCell(Text(AppSession()
                                      .agents
                                      .firstWhereOrNull((element) =>
                                          element.reference == e.reference)
                                      ?.firstName ??
                                  "Agent not found")),
                              DataCell(
                                DropdownButtonFormField<DocumentReference?>(
                                    value: e.staffRef,
                                    items: AppSession()
                                        .staffs
                                        .map((staff) => DropdownMenuItem<
                                                DocumentReference?>(
                                              value: staff.reference,
                                              child: Text(staff.firstName),
                                            ))
                                        .toList(),
                                    isExpanded: true,
                                    decoration: const InputDecoration(
                                        border: OutlineInputBorder()),
                                    onChanged:
                                        e.leadStatus == LeadStatus.sold ||
                                                !AppSession().isAdmin
                                            ? null
                                            : (val) {
                                                if (val != null) {
                                                  e.assignStaff(val);
                                                }
                                              }),
                              ),
                              DataCell(Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: ElevatedButton(
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            if (e.leadStatus ==
                                                LeadStatus.sold) {
                                              return AlertDialog(
                                                shape:
                                                    const RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    10.0))),
                                                title: const Text(
                                                    "Operation Not Allowed"),
                                                content: const Text(
                                                    "Edit operation on sold transaction is not permitted"),
                                                actions: [
                                                  TextButton(
                                                      onPressed:
                                                          Navigator.of(context)
                                                              .pop,
                                                      child: const Text("Okay"))
                                                ],
                                              );
                                            }
                                            if (e.leadStatus ==
                                                LeadStatus.pendingApproval) {
                                              return AlertDialog(
                                                shape:
                                                    const RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    10.0))),
                                                content: SizedBox(
                                                    height: 800,
                                                    width: 600,
                                                    child: SaleForm(
                                                      lead: e,
                                                    )),
                                              );
                                            } else {
                                              return AlertDialog(
                                                shape:
                                                    const RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    10.0))),
                                                content: SizedBox(
                                                    height: 800,
                                                    width: 600,
                                                    child: LeadForm(
                                                      lead: e,
                                                      property: widget.property,
                                                    )),
                                              );
                                            }
                                          });
                                    },
                                    child: const Text("EDIT")),
                              )),
                            ]))
                    .toList(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class LeadTile extends StatelessWidget {
  const LeadTile({
    Key? key,
    required this.lead,
  }) : super(key: key);

  final Lead lead;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        title: Text(lead.name),
        subtitle: Text(lead.phoneNumber ?? lead.email ?? ''),
        children: [
          ListTile(
            title: const Text("Government ID"),
            subtitle: Text(lead.governmentId ?? ''),
          ),
          Row(
            children: [
              Expanded(
                child: ListTile(
                  title: const Text("Staff"),
                  subtitle: Text(lead.staff?.firstName ?? 'Staff Not Assigned'),
                ),
              ),
              Expanded(
                child: ListTile(
                  title: const Text("Staff Contact"),
                  subtitle:
                      Text(lead.staff?.phoneNumber ?? 'Staff Not Assigned'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
