import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:real_estate_admin/Model/Agent.dart';

class AgentReferrals extends StatelessWidget {
  const AgentReferrals({Key? key, required this.agent}) : super(key: key);

  final Agent agent;

  @override
  Widget build(BuildContext context) {
    int i = 0;
    return Scaffold(
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ListTile(
                    leading: const Icon(Icons.circle),
                    title: const Text("SUPER AGENT"),
                    subtitle: Text((agent.superAgentReference == null
                            ? "NIL"
                            : agent.superAgent?.firstName ?? '') +
                        (agent.superAgent?.lastName ?? ''))),
              ),
              Expanded(
                child: ListTile(
                  title: const Text("COMMISSION EARNED "),
                  subtitle: Text(agent.sharedComissionAmount.toString()),
                ),
              ),
            ],
          ),
          ListTile(
            leading: const Icon(Icons.circle),
            title: const Text("MY REFERRAL CODE"),
            subtitle: Text(agent.referenceCode),
            trailing: IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: agent.referenceCode))
                      .then((value) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("REFERAAL CODE COPIED")));
                  });
                },
                icon: const Icon(Icons.copy)),
          ),
          const Divider(),
          Expanded(
            child: FutureBuilder(
              future: agent.getReferrals(),
              builder: (context, AsyncSnapshot<List<Agent>> snapshot) {
                if (snapshot.connectionState == ConnectionState.active ||
                    snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    var agents = snapshot.data;
                    double comissionEarned = snapshot.data!.fold<double>(
                        0.0,
                        (double previousValue, Agent element) =>
                            previousValue + element.sharedComissionAmount);
                    return SingleChildScrollView(
                      child: Table(
                        children: [
                          TableRow(
                            children: [
                              DataTable(
                                columns: const [
                                  DataColumn(label: Text("S.No")),
                                  DataColumn(label: Text("Agent")),
                                  // DataColumn(label: Text("Successfull\n Leads")),
                                  DataColumn(label: Text("Commission\n Earned")),
                                ],
                                rows: agents!
                                    .map((e) => DataRow(
                                          cells: [
                                            DataCell(Text((++i).toString())),
                                            DataCell(Text(e.firstName)),
                                            // DataCell(Text((Random().nextInt(10) + 5).toString())),
                                            DataCell(Text(e
                                                .sharedComissionAmount
                                                .toString())),
                                          ],
                                        ))
                                    .toList(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }
                  return const Center(
                    child: Text("No data found"),
                  );
                }
                if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString()));
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
