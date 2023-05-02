import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:real_estate_admin/Model/Agent.dart';
import 'package:real_estate_admin/Modules/Agent/agent_controller.dart';
import 'package:real_estate_admin/Modules/Agent/agent_form_state.dart';
import 'package:real_estate_admin/widgets/future_dialog.dart';
import 'package:real_estate_admin/widgets/utils.dart';

import '../../Providers/session.dart';
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

  final _formKey = GlobalKey<FormState>();

  AgentFormController controller = AgentFormController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AGENT FORM"),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: TileFormField(
                      controller: controller.firstName,
                      title: "FIRST NAME *",
                      validator: requiredValidator,
                    ),
                  ),
                  Expanded(
                    child: TileFormField(
                        controller: controller.lastName, title: "LAST NAME"),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: TileFormField(
                      controller: controller.email,
                      title: "EMAIL *",
                      validator: requiredEmail,
                    ),
                  ),
                  Expanded(
                    child: TileFormField(
                      inputFormatters: [LengthLimitingTextInputFormatter(10)],
                      controller: controller.phoneNumber,
                      title: "PHONE NUMBER *",
                      validator: requiredPhone,
                    ),
                  ),
                ],
              ),
              TileFormField(
                  inputFormatters: [LengthLimitingTextInputFormatter(10)],
                  validator: (val) {
                    if (requiredValidator(val) != null) {
                      return requiredValidator(val);
                    }
                    String pattern = r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$';
                    RegExp regex = RegExp(pattern);
                    if (!regex.hasMatch(val!)) {
                      return 'Invalid PAN Number';
                    }
                    if (widget.agent == null) {
                      if (AppSession()
                          .agents
                          .where((element) =>
                              element.panCardNumber!.toLowerCase() ==
                              val.toLowerCase())
                          .isNotEmpty) {
                        return "Duplicate PAN Number";
                      }
                    }
                  },
                  controller: controller.panCardNumber,
                  title: "PAN NUMBER *"),
              TileFormField(
                controller: controller.addressLine1,
                title: "ADDRESS LINE 1 *",
                validator: requiredValidator,
              ),
              TileFormField(
                  controller: controller.addressLine2, title: "ADDRESS LINE 2"),
              Row(
                children: [
                  Expanded(
                    child: TileFormField(
                      controller: controller.city,
                      title: "CITY *",
                      validator: requiredValidator,
                    ),
                  ),
                  Expanded(
                    child: TileFormField(
                      controller: controller.pincode,
                      title: "PIN CODE *",
                      validator: requiredPinCode,
                    ),
                  ),
                ],
              ),
              widget.agent == null
                  ? TileFormField(
                      controller: controller.referralCode, title: "REFERRAL")
                  : Container(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.maxFinite,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        var agentController =
                            AgentController(formController: controller);
                        var future;
                        if (widget.agent == null) {
                          future = agentController.addAgent();
                        } else {
                          future = agentController.updateAgent();
                        }
                        showFutureDialog(context, future: future);
                      }
                    },
                    child: const Text("SUBMIT"),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
