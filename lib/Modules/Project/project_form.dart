import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:real_estate_admin/Modules/Project/project_controller.dart';
import 'package:real_estate_admin/Modules/Project/project_form_data.dart';

import '../../Model/Project.dart';
import '../../widgets/formfield.dart';
import '../../widgets/future_dialog.dart';

class ProjectForm extends StatelessWidget {
  ProjectForm({Key? key, this.project}) : super(key: key);

  final Project? project;

  final _formKey = GlobalKey<FormState>();

  Widget getCoverImage(BuildContext context) {
    var controller = Provider.of<ProjectFormData>(context);
    if (controller.coverPhototData != null) {
      return Stack(
        children: [
          Positioned.fill(
            child: Image.memory(
              controller.coverPhototData!,
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
                color: Colors.black.withOpacity(0.1),
                child: Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    onPressed: controller.removeCoverPhoto,
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
    if (controller.coverPhoto != null) {
      return Stack(
        children: [
          Image.network(controller.coverPhoto!),
          Positioned.fill(
            child: Container(
                color: Colors.black.withOpacity(0.1),
                child: Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    onPressed: controller.removeCoverPhoto,
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
        controller.pickCoverPhoto();
      },
      child: const Center(
        child: Icon(
          Icons.add_a_photo,
          size: 64,
        ),
      ),
    );
  }

  String? requiredValidator(String? string) {
    if ((string ?? '').trim().isEmpty) {
      return 'This is a required field';
    }
    return null;
  }

  ProjectFormData getFormData() {
    if (project != null) {
      return ProjectFormData.fromProject(project!);
    } else {
      return ProjectFormData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ChangeNotifierProvider<ProjectFormData>(
        create: (context) => getFormData(),
        child: Consumer<ProjectFormData>(builder: (context, controller, child) {
          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(child: AspectRatio(aspectRatio: 16 / 9, child: getCoverImage(context))),
                  ),
                  TileFormField(validator: requiredValidator, controller: controller.name, title: 'Project Name'),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(child: TileFormField(validator: requiredValidator, controller: controller.location, title: 'Project Location')),
                      Expanded(
                        child: ListTile(
                          title: const Text('Project Type'),
                          subtitle: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButtonFormField<String>(
                                isDense: true,
                                decoration: const InputDecoration(border: OutlineInputBorder()),
                                value: controller.type,
                                items: const [
                                  DropdownMenuItem<String>(
                                    value: 'House',
                                    child: Text("House"),
                                  ),
                                  DropdownMenuItem(value: 'Villa', child: Text("Villa")),
                                  DropdownMenuItem(value: 'Shop', child: Text("Shop")),
                                  DropdownMenuItem(value: 'Building', child: Text("Building")),
                                  DropdownMenuItem(value: 'Land', child: Text("Land")),
                                ],
                                onChanged: controller.onChanged,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 60,
                    width: double.maxFinite,
                    margin: const EdgeInsets.all(16),
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          var projectController = ProjectController(controller);

                          var future = (project == null) ? projectController.addProject() : projectController.updateProject();
                          showFutureDialog(
                            context,
                            future: future,
                            onSucess: (result) {
                              Navigator.of(context).pop();
                              if (result is Project) {}
                            },
                          );
                        }
                      },
                      child: const Text("SAVE PROJECT"),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // List<Widget> getPropertyWidgets(List<Property> properties) {
  //   return properties.map((e) => )
  // }
}
