import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:real_estate_admin/Model/Result.dart';
import 'package:real_estate_admin/Modules/Project/Sales/comission_tile.dart';
import 'package:real_estate_admin/Modules/Project/propertyController.dart';
import 'package:real_estate_admin/widgets/utils.dart';

import '../../Model/Project.dart';
import '../../Model/Property.dart';
import '../../widgets/formfield.dart';
import '../../widgets/future_dialog.dart';
import 'property_form_data.dart';
import 'package:badges/badges.dart';

class PropertyForm extends StatefulWidget {
  const PropertyForm({Key? key, this.property, required this.project})
      : super(key: key);

  final Project project;
  final Property? property;

  @override
  State<PropertyForm> createState() => _PropertyFormState();
}

class _PropertyFormState extends State<PropertyForm> {
  final _formKey = GlobalKey<FormState>();

  Widget getCoverImage(PropertyViewModel data) {
    if (data.coverPhototData != null) {
      return Stack(
        children: [
          Positioned.fill(
            child: Image.memory(
              data.coverPhototData!,
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
                color: Colors.black.withOpacity(0.1),
                child: Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        data.coverPhototData = null;
                      });
                    },
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),
                )),
          ),
        ],
      );
    }
    if ((data.coverPhoto ?? '').isNotEmpty) {
      return Stack(
        children: [
          Image.network(data.coverPhoto!),
          Positioned.fill(
            child: Container(
                color: Colors.black.withOpacity(0.1),
                child: Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        data.deletedPhotos.add(data.coverPhoto);
                        data.coverPhoto = null;
                      });
                    },
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),
                )),
          ),
        ],
      );
    }
    return GestureDetector(
      onTap: () {
        data.pickCoverPhoto();
      },
      child: Center(
        child: Icon(
          Icons.add_a_photo,
          size: 100,
          color: Colors.grey.shade200,
        ),
      ),
    );
  }

  List<Widget> getPhotoTiles(PropertyViewModel data) {
    List<Widget> images = [];
    var tiles = data.getPhotoTiles();
    images.addAll(tiles
        .map((e) => Card(
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Image(image: e.provider, fit: BoxFit.cover),
                    ),
                  ),
                  Positioned(
                      child: CircleAvatar(
                          child: IconButton(
                              onPressed: e.remove,
                              icon: const Icon(Icons.close)))),
                ],
              ),
            ))
        .toList());
    images.add(
      Card(
        child: AspectRatio(
          aspectRatio: 1,
          child: IconButton(
            icon: const Icon(Icons.add_a_photo),
            onPressed: data.pickImages,
          ),
        ),
      ),
    );

    return images;
  }

  late PropertyViewModel model;

  @override
  void initState() {
    super.initState();
    if (widget.property != null) {
      model = PropertyViewModel.fromProperty(widget.property!);
    } else {
      model = PropertyViewModel(widget.project.reference);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => model,
      child: Consumer<PropertyViewModel>(builder: (context, data, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Add Property'),
            elevation: 0,
          ),
          body: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                        child: AspectRatio(
                            aspectRatio: 16 / 9, child: getCoverImage(data))),
                  ),
                  TileFormField(
                      controller: data.title,
                      title: "Title",
                      validator: requiredValidator),
                  Row(
                    children: [
                      Expanded(
                          child: TileFormField(
                        controller: data.plotNumber,
                        title: 'Plot Number',
                      )),
                      Expanded(
                          child: TileFormField(
                        controller: data.surveyNumber,
                        title: 'Survey / Patta Number',
                      ))
                    ],
                  ),
                  TileFormField(
                      controller: data.dtcpNumber, title: 'DTCP Number'),
                  Row(
                    children: [
                      Expanded(
                        child: TileFormField(
                            controller: data.district, title: 'District'),
                      ),
                      Expanded(
                        child: TileFormField(
                          controller: data.taluk,
                          title: 'Taluk',
                        ),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: TileFormField(
                              controller: data.uds, title: "UDS")),
                      Expanded(
                        child: TileFormField(
                            controller: data.buildUpArea,
                            title: "Build-up Area"),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          title: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Text("Bedroom Count"),
                          ),
                          subtitle: DropdownButtonFormField<int>(
                              value: data.bedroomCount,
                              items: <int>[1, 2, 3]
                                  .map((e) => DropdownMenuItem<int>(
                                      value: e, child: Text("$e BHK")))
                                  .followedBy([
                                const DropdownMenuItem(child: Text("None"))
                              ]).toList(),
                              isExpanded: true,
                              decoration: const InputDecoration(
                                  border: OutlineInputBorder()),
                              onChanged: (val) {
                                setState(() {
                                  data.bedroomCount = val;
                                });
                              }),
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                          title: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Text("Facing"),
                          ),
                          subtitle: DropdownButtonFormField<Facing?>(
                              value: data.facing,
                              items: Facing.values
                                  .map((e) => DropdownMenuItem(
                                      value: e, child: Text(e.name)))
                                  .followedBy([
                                const DropdownMenuItem(child: Text("None"))
                              ]).toList(),
                              isExpanded: true,
                              decoration: const InputDecoration(
                                  border: OutlineInputBorder()),
                              onChanged: (val) {
                                setState(() {
                                  data.facing = val;
                                });
                              }),
                        ),
                      ),
                    ],
                  ),

                  TileFormField(
                    controller: data.features,
                    title: 'Features',
                    maxLines: 8,
                  ),
                  TileFormField(
                    controller: data.description,
                    title: 'Description',
                    maxLines: 8,
                  ),
                  TileFormField(
                    controller: data.propertyAmount,
                    title: 'Property Value',
                    keyboardType: TextInputType.number,
                    validator: (p0) {
                      var required = requiredValidator(p0);
                      if (required != null) {
                        return required;
                      } else {
                        var plainText =
                            p0!.split('Rs. ').last.replaceAll(",", "");
                        if (plainText != null) {
                          var num = double.tryParse(plainText);
                          if (num == null) {
                            return 'Please enter a valid number';
                          }
                        }
                      }
                    },
                  ),

                  const Divider(),
                  ComissionTile(
                      comissionController: data.agentComission,
                      title: "Agent Comission",
                      name: "Agent"),
                  const Divider(),
                  ComissionTile(
                      comissionController: data.staffComission,
                      title: "Staff Comission",
                      name: "Staff"),
                  const Divider(),
                  ComissionTile(
                      comissionController: data.superAgentComission,
                      title: "Super Agent Commission",
                      name: "Super Agent"),
                  const Divider(),
                  ListTile(
                    title: const Text("Supporting Documents"),
                    subtitle: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: SizedBox(
                          height: 130,
                          child: Row(
                            children: getPhotoTiles(data),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // ListTile(
                  //   title: const Text("Comission Details"),
                  //   subtitle: SizedBox(height: 60, child: getComissionTile(comission: data.staffComission, title: 'Staff commission')),
                  // ),
                  // getComissionTile(comission: data.staffComission, title: 'Staff comission'),
                  // getComissionTile(comission: data.staffComission, title: 'Staff Commission'),
                  Container(
                    height: 60,
                    width: double.maxFinite,
                    margin: const EdgeInsets.all(16),
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          var propertyController = PropertyController(
                              propertyFormData: data, project: widget.project);
                          Future<Result> future;
                          if (widget.property != null) {
                            future = propertyController.updateProperty();
                          } else {
                            future = propertyController.addProperty();
                          }
                          showFutureDialog(context, future: future,
                              onSucess: (val) {
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          });
                        }
                      },
                      child: const Text("SAVE PROPERTY"),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
