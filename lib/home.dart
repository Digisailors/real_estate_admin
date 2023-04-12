import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:real_estate_admin/Model/Staff.dart';
import 'package:real_estate_admin/Modules/Agent/agent_list.dart';
// import 'package:real_estate_admin/Modules/Dashboard/AnotherDashboard/dashboard.dart';
import 'package:real_estate_admin/Modules/Dashboard/dashboard.dart';
import 'package:real_estate_admin/Modules/Project/Sales/sale_list.dart';
import 'package:real_estate_admin/Modules/Project/leads/lead_list.dart';
import 'package:real_estate_admin/Modules/Project/project_list.dart';
import 'package:real_estate_admin/Modules/Staff/staff_form.dart';
import 'package:real_estate_admin/Modules/Staff/staff_list.dart';
import 'package:real_estate_admin/Providers/session.dart';
// import 'package:real_estate_admin/auth_gate.dart';
import 'package:real_estate_admin/get_constants.dart';

class Home extends StatefulWidget {
  const Home({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int selectedTile = 0;
  @override
  Widget build(BuildContext context) {
    var session = AppSession();
    return Row(
      children: [
        isDesktop(context)
            ? Expanded(flex: 3, child: getDrawer(context, session))
            : Container(),
        Expanded(
            flex: 14,
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: selectedTile == 0 ? Colors.white : Colors.blue,
                iconTheme: IconThemeData(
                  color: selectedTile != 0 ? Colors.white : Colors.blue,
                ),
              ),
              drawer: isDesktop(context) ? null : getDrawer(context, session),
              body: widget.child,
            )),
      ],
    );
  }

  Card getDrawer(BuildContext context, AppSession session) {
    return Card(
      child: Drawer(
        // width: Get.width * 0.150,
        child: SingleChildScrollView(
          child: Column(
            children: [
              AspectRatio(
                aspectRatio: isDesktop(context) ? 1.5 : 2,
                child: Center(
                  child:
                      // Image.asset(
                      //   'mmalogo.png',
                      //   height: isDesktop(context) ? 100 : 80,
                      // ),
                      Image.network(
                    'https://firebasestorage.googleapis.com/v0/b/realestate-d0cd9.appspot.com/o/assets%2Fmmalogo.png?alt=media&token=33f943d7-9346-43a2-b655-88b0126134da',
                    height: isDesktop(context) ? 100 : 80,
                  ),
                ),
              ),
              ListTile(
                title: Center(
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.verified_user,
                      color: Colors.blue,
                    ),
                    Text(
                      AppSession().staff?.firstName ?? "No Username",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                  ],
                )),
              ),
              ListTile(
                selected: selectedTile == 0,
                title: const Text("Dashboard"),
                selectedColor: Colors.blue,
                trailing: const Icon(Icons.dashboard),
                onTap: () {
                  // session.pageController.jumpToPage(0);

                  setState(() {
                    selectedTile = 0;
                  });
                  Get.offAll(() => const Dashboard());
                },
              ),
              ListTile(
                selected: selectedTile == 1,
                title: const Text("Projects"),
                trailing: const Icon(Icons.tab),
                onTap: () {
                  // session.pageController.jumpToPage(1);
                  if (selectedTile != 1) {
                    Get.offAll(() => const ProjectList());
                  }
                  setState(() {
                    selectedTile = 1;
                  });
                },
              ),
              ListTile(
                selected: selectedTile == 2,
                title: const Text("Agents"),
                trailing: const Icon(Icons.people),
                onTap: () {
                  // session.pageController.jumpToPage(2);
                  setState(() {
                    selectedTile = 2;
                  });
                  Get.offAll(() => const AgentList());
                },
              ),
              AppSession().isAdmin
                  ? ListTile(
                      selected: selectedTile == 3,
                      title: const Text("Staffs"),
                      trailing: const Icon(Icons.people_sharp),
                      onTap: () {
                        // session.pageController.jumpToPage(2);
                        setState(() {
                          selectedTile = 3;
                        });
                        Get.offAll(() => const StaffList());
                      },
                    )
                  : Container(),
              ListTile(
                selected: selectedTile == 4,
                title: const Text("Leads"),
                trailing: const Icon(Icons.people_sharp),
                onTap: () {
                  // session.pageController.jumpToPage(2);
                  setState(() {
                    selectedTile = 4;
                  });
                  Get.offAll(() => const LeadList());
                },
              ),
              ListTile(
                selected: selectedTile == 5,
                title: const Text("Sales"),
                trailing: const Icon(Icons.people_sharp),
                onTap: () {
                  // session.pageController.jumpToPage(2);
                  setState(() {
                    selectedTile = 5;
                  });
                  Get.offAll(() => const SaleList());
                },
              ),
              ListTile(
                title: const Text("My Profile"),
                trailing: const Icon(Icons.person),
                onTap: () async {
                  AppSession().staff = await FirebaseFirestore.instance
                      .collection('staffs')
                      .doc(AppSession().firbaseAuth.currentUser!.uid)
                      .get()
                      .then((snapshot) => Staff.fromSnapshot(snapshot));
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
                              child: StaffForm(staff: AppSession().staff)),
                        );
                      });
                },
              ),
              ListTile(
                title: const Text("Logout"),
                trailing: const Icon(Icons.logout),
                onTap: () {
                  session.firbaseAuth.signOut();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
