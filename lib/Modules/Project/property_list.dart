import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:real_estate_admin/Model/Project.dart';
import 'package:real_estate_admin/Model/Property.dart';
import 'package:real_estate_admin/Model/Result.dart';
import 'package:real_estate_admin/Modules/Project/project_controller.dart';
import 'package:real_estate_admin/Modules/Project/project_form_data.dart';
import 'package:real_estate_admin/Modules/Project/project_list.dart';
import 'package:real_estate_admin/Modules/Project/property_form.dart';
import 'package:real_estate_admin/Modules/Project/property_view.dart';
import 'package:real_estate_admin/get_constants.dart';
import 'package:real_estate_admin/widgets/formfield.dart';
import 'package:real_estate_admin/widgets/future_dialog.dart';

import '../../Providers/session.dart';

class PropertyList extends StatefulWidget {
  const PropertyList({Key? key, required this.project}) : super(key: key);

  final Project project;

  @override
  State<PropertyList> createState() => _PropertyListState();
}

class _PropertyListState extends State<PropertyList> {
  Property? selectedProperty;
  int? selectedIndex;
  void Function(void Function())? reloadPropertyView;

  final search = TextEditingController();
  bool? isSold;
  bool? isSort;

  @override
  Widget build(BuildContext context) {
    var controller =
        ProjectController(ProjectFormData.fromProject(widget.project));
    return ChangeNotifierProvider<ProjectController>(
      create: (context) => controller,
      child: LayoutBuilder(builder: (context, constraints) {
        return Scaffold(
          floatingActionButtonLocation: constraints.maxWidth < 860
              ? FloatingActionButtonLocation.endFloat
              : FloatingActionButtonLocation.centerFloat,
          floatingActionButton: (AppSession().isAdmin)
              ? Padding(
                  padding: constraints.maxWidth < 860
                      ? const EdgeInsets.all(8)
                      : const EdgeInsets.only(right: 96, bottom: 16),
                  child: SizedBox(
                    height: 54,
                    width: 60,
                    child: FloatingActionButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0))),
                                  content: SizedBox(
                                      height: 800,
                                      width: 600,
                                      child: PropertyForm(
                                          project: widget.project)),
                                );
                              });
                        },
                        child: const Icon(Icons.add)),
                  ),
                )
              : null,
          body: StreamBuilder<List<Property>>(
              stream: controller.getPropertiesAsStream(
                  search: search.text.toLowerCase(), isSold: isSold),
              builder: (context, AsyncSnapshot<List<Property>> snapshot1) {
                return Row(
                  children: [
                    Expanded(
                        flex: 4,
                        child: Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    TextButton(
                                        onPressed: Navigator.of(context).pop,
                                        child: const Text("<< GO BACK")),
                                    Spacer(),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 30),
                                      child: Text(
                                        "Project : ${widget.project.name}",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  ListTile(
                                    title: const Text('Project Type'),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButtonFormField<bool?>(
                                          isDense: true,
                                          decoration: const InputDecoration(
                                              border: OutlineInputBorder()),
                                          value: isSold,
                                          items: const [
                                            DropdownMenuItem(
                                              child: Text("ALL"),
                                            ),
                                            DropdownMenuItem(
                                              value: false,
                                              child: Text("AVAILABLE"),
                                            ),
                                            DropdownMenuItem(
                                                value: true,
                                                child: Text("SOLD")),
                                          ],
                                          onChanged: (val) {
                                            setState(() {
                                              isSold = val;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  // ListTile(
                                  //   title: const Text('Sort By'),
                                  //   subtitle: Padding(
                                  //     padding: const EdgeInsets.symmetric(
                                  //         vertical: 8),
                                  //     child: DropdownButtonHideUnderline(
                                  //       child: DropdownButtonFormField<bool?>(
                                  //         isDense: true,
                                  //         decoration: const InputDecoration(
                                  //             border: OutlineInputBorder()),
                                  //         value: isSold,
                                  //         items: const [
                                  //           DropdownMenuItem(
                                  //             child: Text("A To Z"),
                                  //           ),
                                  //           DropdownMenuItem(
                                  //             value: false,
                                  //             child: Text("Z to A"),
                                  //           ),
                                  //         ],
                                  //         onChanged: (val) {
                                  //           setState(() {
                                  //             isSort = val;
                                  //           });
                                  //         },
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ),
                                  SizedBox(
                                    height: 72,
                                    child: TileFormField(
                                      onChanged: (p0) {
                                        setState(() {});
                                      },
                                      controller: search,
                                      title: 'Search',
                                      suffix: IconButton(
                                          onPressed: () {
                                            setState(() {});
                                          },
                                          icon: const Icon(Icons.search)),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(),
                              Expanded(
                                child: StreamBuilder<List<Property>>(
                                    stream: controller.getPropertiesAsStream(
                                        search: search.text.toLowerCase(),
                                        isSold: isSold),
                                    builder: (context,
                                        AsyncSnapshot<List<Property>>
                                            snapshot) {
                                      if (snapshot.connectionState ==
                                              ConnectionState.active &&
                                          snapshot.hasData) {
                                        if (snapshot.data!.isEmpty) {
                                          return const Center(
                                            child: Text(
                                                "No Properties for this project"),
                                          );
                                        } else {
                                          // selectedProperty = snapshot.data!.first;
                                          return StatefulBuilder(
                                              builder: (context, reload) {
                                            if (isDesktop(context)) {
                                              snapshot.data!.sort((a, b) =>
                                                  a.title.compareTo(b.title));
                                              return GridView.count(
                                                crossAxisCount: 2,
                                                padding:
                                                    const EdgeInsets.all(8),
                                                children: snapshot.data!
                                                    .map((e) => GestureDetector(
                                                          onTap: () {
                                                            selectedIndex =
                                                                snapshot.data!
                                                                    .indexOf(e);
                                                            reload(() {
                                                              selectedProperty =
                                                                  e;
                                                            });
                                                            if (reloadPropertyView !=
                                                                null) {
                                                              reloadPropertyView!(
                                                                  () {});
                                                            }
                                                          },
                                                          child: PropertyTile(
                                                            property: e,
                                                            selected: e
                                                                    .reference ==
                                                                selectedProperty
                                                                    ?.reference,
                                                          ),
                                                        ))
                                                    .toList(),
                                              );
                                            } else {
                                              snapshot.data!.sort((a, b) =>
                                                  b.title.compareTo(a.title));
                                              List<Property> list =
                                                  snapshot.data ?? [];
                                              return ListView.builder(
                                                  itemCount: list.length,
                                                  reverse: true,
                                                  itemBuilder:
                                                      (context, index) {
                                                    var property = list[index];
                                                    var projectController =
                                                        Provider.of<
                                                                ProjectController>(
                                                            context);
                                                    return ListTile(
                                                      selected: selectedProperty
                                                              ?.reference ==
                                                          property.reference,
                                                      title:
                                                          Text(property.title),
                                                      subtitle: Text(
                                                        NumberFormat.currency(
                                                                locale: 'en-IN')
                                                            .format(property
                                                                .propertyAmount),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      onTap: () {
                                                        selectedIndex = index;
                                                        if (constraints
                                                                .maxWidth >
                                                            860) {
                                                          reload(() {
                                                            selectedProperty =
                                                                property;
                                                          });
                                                          if (reloadPropertyView !=
                                                              null) {
                                                            reloadPropertyView!(
                                                                () {});
                                                          }
                                                        } else {
                                                          Navigator.of(context).push(
                                                              MaterialPageRoute(
                                                                  builder: (context) =>
                                                                      PropertyView(
                                                                          property:
                                                                              property)));
                                                        }
                                                      },
                                                      trailing: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          !AppSession().isAdmin
                                                              ? Container()
                                                              : IconButton(
                                                                  onPressed:
                                                                      () {
                                                                    showAlertDialog(
                                                                      context:
                                                                          context,
                                                                      message:
                                                                          "Do you really want to delete?",
                                                                      onPressed:
                                                                          () {
                                                                        var future = property
                                                                            .reference
                                                                            .delete()
                                                                            .then((value) =>
                                                                                Result.completed("Property Deleted Successfully"))
                                                                            .onError((error, stcak) {
                                                                          if (error
                                                                              is FirebaseException) {
                                                                            return Result(
                                                                                tilte: error.code,
                                                                                message: error.message ?? '');
                                                                          } else {
                                                                            return Result(
                                                                                tilte: 'Failed',
                                                                                message: error.toString());
                                                                          }
                                                                        });
                                                                        showFutureDialog(
                                                                            context,
                                                                            future:
                                                                                future);
                                                                      },
                                                                    );
                                                                  },
                                                                  icon: const Icon(
                                                                      Icons
                                                                          .delete,
                                                                      color: Colors
                                                                          .red)),
                                                          const SizedBox(
                                                              width: 8),
                                                          !AppSession().isAdmin
                                                              ? Container()
                                                              : IconButton(
                                                                  onPressed:
                                                                      () {
                                                                    showDialog(
                                                                        context:
                                                                            context,
                                                                        builder:
                                                                            (context) {
                                                                          return AlertDialog(
                                                                            shape:
                                                                                const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
                                                                            content: SizedBox(
                                                                                height: 800,
                                                                                width: 600,
                                                                                child: PropertyForm(
                                                                                  property: property,
                                                                                  project: projectController.projectFormData.object,
                                                                                )),
                                                                          );
                                                                        });
                                                                  },
                                                                  icon: const Icon(
                                                                      Icons
                                                                          .edit,
                                                                      color: Colors
                                                                          .black)),
                                                        ],
                                                      ),
                                                    );
                                                  });
                                            }
                                          });
                                        }
                                      }
                                      if (snapshot.hasError) {
                                        return Center(
                                          child: SelectableText(
                                              snapshot.data.toString()),
                                        );
                                      }
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }),
                              ),
                            ],
                          ),
                        )),
                    constraints.maxWidth < 860
                        ? Container()
                        : Expanded(
                            flex: 4,
                            child: Builder(builder: (context) {
                              return StatefulBuilder(
                                  builder: (context, reload) {
                                reloadPropertyView = reload;
                                if (selectedProperty == null) {
                                  return const Center(
                                    child: Text(
                                        "Please select a property to view"),
                                  );
                                } else {
                                  return PropertyView(
                                    property: snapshot1.data![selectedIndex!],
                                  );
                                }
                              });
                            })),
                  ],
                );
              }),
        );
      }),
    );
  }
}

class PropertyTile extends StatelessWidget {
  const PropertyTile({Key? key, required this.property, this.selected = false})
      : super(key: key);

  final Property property;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    var projectController = Provider.of<ProjectController>(context);

    return Container(
      color: selected ? Colors.blue : Colors.white,
      child: Card(
        shape: RoundedRectangleBorder(),
        borderOnForeground: true,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: property.coverPhoto == null
                        ? Image.asset('assets/logo.png')
                        : Image.network(
                            property.coverPhoto!,
                            fit: BoxFit.cover,
                          ),
                  ),
                  Positioned.fill(
                      child: property.isSold
                          ? Opacity(
                              opacity: 0.5,
                              child: Image.asset('assets/sold.png'),
                            )
                          : Container()),
                ],
              ),
              const Divider(),
              ListTile(
                title: Text(
                  property.title,
                  overflow: TextOverflow.ellipsis,
                ),
                selected: selected,
                subtitle: Text(
                  NumberFormat.currency(locale: 'en-IN')
                      .format(property.propertyAmount),
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Column(
                  children: [
                    Text(
                      "Leads\n${property.leadCount}",
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              ButtonBar(
                children: [
                  TextButton(
                      onPressed: () {
                        var future = property.reference
                            .delete()
                            .then((value) => Result.completed(
                                "Property Deleted Successfully"))
                            .onError((error, stcak) {
                          if (error is FirebaseException) {
                            return Result(
                                tilte: error.code,
                                message: error.message ?? '');
                          } else {
                            return Result(
                                tilte: 'Failed', message: error.toString());
                          }
                        });
                        showFutureDialog(context, future: future);
                      },
                      child: const Text("DELETE")),
                  TextButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(10.0))),
                                content: SizedBox(
                                    height: 800,
                                    width: 600,
                                    child: PropertyForm(
                                      property: property,
                                      project: projectController
                                          .projectFormData.object,
                                    )),
                              );
                            });
                      },
                      child: const Text("EDIT")),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
