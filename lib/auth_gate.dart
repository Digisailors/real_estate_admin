import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
// import 'package:real_estate_admin/Modules/Dashboard/AnotherDashboard/dashboard.dart';
import 'package:real_estate_admin/Modules/Dashboard/dashboard.dart';
import 'package:real_estate_admin/Providers/session.dart';
import 'package:real_estate_admin/home.dart';
import 'package:real_estate_admin/login_screen.dart';
import 'package:real_estate_admin/main.dart';

import 'Modules/Project/project_list.dart';

class AuthGate extends StatelessWidget {
  AuthGate({Key? key}) : super(key: key);

  // Widget getPage() {
  //   var session = AppSession();
  //   switch (session.pageController.) {
  //     case value:

  //       break;
  //     default:
  //   }
  // }

  final List<Widget> pages = [
    Container(
      color: Colors.black,
    ),
    const ProjectList(),
    Container(
      color: Colors.blue,
    ),
    Container(
      color: Colors.red,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    var session = AppSession();
    return StreamBuilder<User?>(
      stream: session.firbaseAuth.authStateChanges(),
      builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData) {
            return StatefulBuilder(builder: (context, reload) {
              AppSession().checkAdmin().then((val) {
                reload(() {});
              });

              return Consumer(
                builder: ((context, value, child) {
                  return GetMaterialApp(
                    scrollBehavior: MyCustomScrollBehavior(),
                    defaultTransition: Transition.noTransition,
                    home: const Dashboard(),
                    builder: (context, child) {
                      return Home(child: child!);
                    },
                  );
                }),
              );
            });
          } else {
            return const LoginScreen();
          }
        }
        if (snapshot.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(snapshot.error.toString())));
          return const LoginScreen();
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
