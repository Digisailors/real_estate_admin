import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:real_estate_admin/Model/Lead.dart';
import 'package:real_estate_admin/Modules/Dashboard/agentTable.dart';
import 'package:real_estate_admin/Modules/Dashboard/dashboardController.dart';
import 'package:real_estate_admin/Modules/Dashboard/bar_chart.dart';
import 'package:real_estate_admin/Modules/Dashboard/progresscard.dart';
import 'package:real_estate_admin/get_constants.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff7f9f8),
      body: GetBuilder(
          init: DashboardController(),
          builder: (_) {
            var controller = Get.find<DashboardController>();
            return LayoutBuilder(
              builder: (_, constrains) {
                printInfo(info: '${constrains.maxWidth}');
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Builder(builder: (context) {
                          var children = getProgressCardChildren(controller);
                          return constrains.maxWidth > 1000
                              ? Row(
                                  children: children,
                                )
                              : Column(
                                  children: [
                                    Row(
                                      children: children.sublist(0, 2),
                                    ),
                                    Row(
                                      children: children.sublist(2),
                                    )
                                  ],
                                );
                        }),
                        SizedBox(
                          height: Get.height * 0.4,
                          width: constrains.maxWidth,
                          child: LeadChart(
                            dateWiseLeads: controller.dateWiseLeads,
                            title: "Lead per day",
                            color: Colors.purpleAccent.shade100,
                          ),
                        ),
                        isMobile(context)
                            ? Column(children: getChildAgentTables(controller))
                            : Row(
                                children:
                                    getChildAgentTablesExpanded(controller),
                              ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
    );
  }

  List<Widget> getProgressCardChildren(DashboardController controller) {
    return [
      // Color.fromARGB(255, 231, 225, 251)
      Expanded(
        child: ProgressCard(
          valueColor: const Color.fromARGB(255, 174, 143, 253),
          backGroundColor: const Color.fromARGB(255, 231, 225, 251),
          denominator: controller.totalLeads.toDouble(),
          numerator: controller.totalSuccessleads.toDouble(),
          neumeratorTitle: 'Converted ',
          denominatorTitle: 'Total',
          cardTitle: 'Leads',
        ),
      ),
      Expanded(
        child: ProgressCard(
          valueColor: const Color.fromARGB(255, 254, 187, 108),
          backGroundColor: const Color.fromARGB(255, 253, 243, 233),
          denominator: controller.totalAgents.toDouble(),
          numerator: controller.totalActiveAgents.toDouble(),
          neumeratorTitle: 'Active',
          denominatorTitle: 'Total',
          cardTitle: 'Agents',
        ),
      ),
      Expanded(
        child: ProgressCard(
          valueColor: const Color.fromARGB(255, 69, 198, 168),
          backGroundColor: const Color.fromARGB(255, 232, 250, 234),
          denominator: controller.totalProperties.toDouble(),
          numerator: controller.totalSuccessleads.toDouble(),
          neumeratorTitle: 'Sold',
          denominatorTitle: 'Total',
          cardTitle: 'Properties',
        ),
      ),
      Expanded(
        child: ProgressCardLedger(
          valueColor: Colors.yellowAccent,
          backGroundColor: Colors.deepPurple.shade50,
          denominator: controller.comissionAmount,
          numerator: controller.soldAmount,
          neumeratorTitle: 'Pay-in',
          denominatorTitle: 'Pay-out',
          cardTitle: 'Ledgers',
        ),
      ),
    ];
  }

  List<Widget> getChildAgentTables(DashboardController controller) {
    return [
      Expanded(
        child: Row(
          children: [
            AgentDataTable(
                headColor: Colors.deepPurple.shade100,
                agents: controller.top5AgentsByLeads,
                num1: 0),
          ],
        ),
      ),
      Expanded(
        child: Row(
          children: [
            AgentDataTable(
                headColor: Colors.pink.shade100,
                agents: controller.top5AgentsBySuccessfull,
                num1: 1),
          ],
        ),
      ),
      Expanded(
        child: Row(
          children: [
            AgentDataTable(
                headColor: Colors.green.shade100,
                agents: controller.top5AgentsByComission,
                num1: 2),
          ],
        ),
      ),
    ];
  }

  List<Widget> getChildAgentTablesExpanded(DashboardController controller) {
    return [
      Expanded(
          child: AgentDataTable(
              headColor: Colors.deepPurple.shade100,
              agents: controller.top5AgentsByLeads,
              num1: 0)),
      Expanded(
          child: AgentDataTable(
              headColor: Colors.pink.shade100,
              agents: controller.top5AgentsBySuccessfull,
              num1: 1)),
      Expanded(
          child: AgentDataTable(
              headColor: Colors.green.shade100,
              agents: controller.top5AgentsByComission,
              num1: 2)),
    ];
  }
}
