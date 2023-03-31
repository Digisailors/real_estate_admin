import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:real_estate_admin/Modules/Project/project_controller.dart';
import 'package:real_estate_admin/Modules/Project/project_form.dart';
import 'package:real_estate_admin/Modules/Project/project_form_data.dart';
import 'package:real_estate_admin/Modules/Project/property_list.dart';
import 'package:real_estate_admin/Providers/session.dart';
import 'package:real_estate_admin/get_constants.dart';
import 'package:real_estate_admin/widgets/formfield.dart';
import 'package:real_estate_admin/widgets/future_dialog.dart';

import '../../Model/Project.dart';

class ProjectList extends StatefulWidget {
  const ProjectList({Key? key}) : super(key: key);

  @override
  State<ProjectList> createState() => _ProjectListState();
}

final CollectionReference<Map<String, dynamic>> projects =
    FirebaseFirestore.instance.collection('projects');

class _ProjectListState extends State<ProjectList> {
  final search = TextEditingController();
  String? type;

  reloadQuery() {
    setState(() {
      query = projects;
      if (type != null) {
        query = query.where('type', isEqualTo: type);
      }
      if (search.text.isNotEmpty) {
        query = query.where('search', arrayContainsAny: search.text.split(' '));
      }
    });
  }

  void setType(String? val) {
    type = val;
    reloadQuery();
  }

  Query<Map<String, dynamic>> query = projects;
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Scaffold(
        // appBar: AppBar(
        //   title: const Text("PROJECTS"),
        // ),
        body: Column(
          children: [
            SizedBox(
              height: 100,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: 300,
                      child: ListTile(
                        title: const Text('Project Type'),
                        subtitle: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButtonFormField<String>(
                              isDense: true,
                              decoration: const InputDecoration(
                                  border: OutlineInputBorder()),
                              value: type,
                              items: const [
                                DropdownMenuItem<String>(
                                  child: Text("All"),
                                ),
                                DropdownMenuItem<String>(
                                  value: 'House',
                                  child: Text("Individual House"),
                                ),
                                DropdownMenuItem(
                                    value: 'Villa', child: Text("Villa")),
                                DropdownMenuItem(
                                    value: 'Shop', child: Text("Shop")),
                                DropdownMenuItem(
                                    value: 'Building',
                                    child: Text("Apartments")),
                                DropdownMenuItem(
                                    value: 'Land', child: Text("Land")),
                                DropdownMenuItem(
                                    value: 'Plots', child: Text("Plots")),
                                DropdownMenuItem(
                                    value: 'FormLand', child: Text("Form Land")),
                             ],
                              onChanged: setType,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                        width: 300,
                        child:
                            TileFormField(controller: search, title: 'Search')),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                          onPressed: reloadQuery, child: const Text("Search")),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: !AppSession().isAdmin
                          ? Container()
                          : ElevatedButton(
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
                                            child: ProjectForm()),
                                      );
                                    });
                              },
                              child: const Text("Add")),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                          onPressed: () {
                            setState(() {});
                          },
                          child: const Text("Refresh")),
                    )
                  ],
                ),
              ),
            ),
            const Divider(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: StreamBuilder(
                  stream: query.snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                          snapshot) {
                    if ((snapshot.connectionState == ConnectionState.active ||
                            snapshot.connectionState == ConnectionState.done) &&
                        snapshot.hasData) {
                      List<Project> projectslist = snapshot.data!.docs
                          .map((e) => Project.fromSnapshot(e))
                          .toList();
                      return LayoutBuilder(builder: (context, constraints) {
                        return GridView.count(
                          crossAxisCount: (constraints.maxWidth ~/ 245 == 0)
                              ? 1
                              : constraints.maxWidth ~/ 245,
                          children: projectslist
                              .map((e) => ProjectTile(project: e))
                              .toList(),
                        );
                      });
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: SelectableText(snapshot.error.toString()),
                      );
                    }
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ProjectTile extends StatelessWidget {
  const ProjectTile({Key? key, required this.project}) : super(key: key);
  final Project project;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {
              Get.to(() => PropertyList(project: project));
            },
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Column(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      project.coverPhoto ??
                          'https://picsum.photos/id/1/200/300',
                      fit: BoxFit.cover,
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    title: Text(project.name),
                    subtitle: Text(project.location),
                    trailing: !AppSession().isAdmin
                        ? null
                        : IconButton(
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
                                          child: ProjectForm(
                                            project: project,
                                          )),
                                    );
                                  });
                            },
                            icon: const Icon(Icons.edit)),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: !AppSession().isAdmin
                ? Container()
                : CircleAvatar(
                    foregroundColor: Colors.red,
                    backgroundColor: Colors.white,
                    child: IconButton(
                      onPressed: () {
                        var projectController = ProjectController(
                            ProjectFormData.fromProject(project));
                        projectController.deleteProject();

                        // showAlertDialog(
                        //   context: context,
                        //   message: "Are you sure you want to delete?",
                        //   onPressed: () {
                        //     var projectController = ProjectController(ProjectFormData.fromProject(project));
                        //     projectController.deleteProject();
                        //   },
                        // );
                      },
                      icon: const Icon(Icons.delete),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
