import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:real_estate_admin/Model/Agent.dart';

import '../Agent/agent_screen.dart';

class AgentDataTable extends StatelessWidget {
  const AgentDataTable({super.key, required this.agents, required this.num1, required this.headColor});

  final List<Agent> agents;
  final int num1;
  final Color headColor;

  List<DataColumn> getColumns() {
    var columns = [
      const DataColumn(label: Text('AGENTS')),
    ];
    if (num1 == 0) {
      columns.add(
        const DataColumn(label: Text('LEADS')),
      );
    }
    if (num1 == 1) {
      columns.add(
        const DataColumn(label: Text('Conv. LEADS')),
      );
    }
    if (num1 == 2) {
      columns.add(
        const DataColumn(label: Text('Comission')),
      );
    }
    return columns;
  }

  DataRow getDatRow(Agent e, BuildContext context) {
    var cells = [
      DataCell(TextButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
                    content: SizedBox(height: 800, width: 600, child: AgentScreen(agent: e)),
                  );
                });
          },
          child: Text(e.firstName))),
    ];
    if (num1 == 0) {
      cells.add(
        DataCell(Text(e.leadCount.toString())),
      );
    }
    if (num1 == 1) {
      cells.add(
        DataCell(Text(e.successfullLeadCount.toString())),
      );
    }
    if (num1 == 2) {
      cells.add(
        DataCell(Text(NumberFormat.currency(locale: 'en-IN').format(e.commissionAmount))),
      );
    }
    return DataRow(cells: cells);
  }

  String getTitle() {
    switch (num1) {
      case 0:
        return "Top 5 agents in lead count";
      case 1:
        return "Top 5 agents with successfull leads";
      case 2:
        return "Top 5 agents with high comission";

      default:
        return 'NULL';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      color: headColor,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Text(getTitle()),
          ),
          SizedBox(
            height: kMinInteractiveDimension * 6,
            child: Container(
              color: Colors.white,
              child: Table(
                children: [
                  TableRow(
                    children: [
                      DataTable(columns: getColumns(), rows: agents.map((e) => getDatRow(e, context)).toList()),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
