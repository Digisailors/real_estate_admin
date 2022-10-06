import 'package:flutter/material.dart';
import 'package:real_estate_admin/Model/Agent.dart';
import 'package:real_estate_admin/Modules/Agent/agent_controller.dart';
import 'package:real_estate_admin/Modules/Agent/agent_form_state.dart';
import 'package:real_estate_admin/widgets/future_dialog.dart';

import '../../widgets/formfield.dart';

class AgentForm extends StatefulWidget {
  const AgentForm({Key? key, this.agent}) : super(key: key);
  final Agent? agent;

  @override
  State<AgentForm> createState() => _AgentFormState();
}

class _AgentFormState extends State<AgentForm> {
  @override
  void initState() {
    super.initState();
    if (widget.agent != null) {
      controller = AgentFormController.fromAgent(widget.agent!);
    }
  }

  AgentFormController controller = AgentFormController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AGENT FORM"),
      ),
      body: Column(
        children: [
          const SizedBox(height: 30),
          Row(
            children: [
              Expanded(
                child: TileFormField(controller: controller.firstName, title: "First Name"),
              ),
              Expanded(
                child: TileFormField(controller: controller.lastName, title: "Last Name"),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: TileFormField(controller: controller.email, title: "EMAIL"),
              ),
              Expanded(
                child: TileFormField(controller: controller.phoneNumber, title: "PHONE NUMBER"),
              ),
            ],
          ),
          TileFormField(controller: controller.panCardNumber, title: "PAN NUMBER"),
          TileFormField(controller: controller.addressLine1, title: "ADDRESS LINE 1"),
          TileFormField(controller: controller.addressLine2, title: "ADDRESS LINE 2"),
          Row(
            children: [
              Expanded(
                child: TileFormField(controller: controller.city, title: "CITY"),
              ),
              Expanded(
                child: TileFormField(controller: controller.pincode, title: "PIN CODE"),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.maxFinite,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  var agentController = AgentController(formController: controller);
                  var future;
                  if (widget.agent == null) {
                    future = agentController.addAgent();
                  } else {
                    future = agentController.updateAgent();
                  }
                  showFutureDialog(context, future: future);
                },
                child: const Text("SUBMIT"),
              ),
            ),
          )
        ],
      ),
    );
  }
}
