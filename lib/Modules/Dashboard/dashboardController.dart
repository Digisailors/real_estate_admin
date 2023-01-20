import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:real_estate_admin/Model/Lead.dart';
import 'package:real_estate_admin/Modules/Agent/agent_controller.dart';

import 'package:real_estate_admin/Modules/Dashboard/bar_chart.dart';
import 'package:real_estate_admin/Providers/session.dart';
import '../../Model/Agent.dart';

final settings = FirebaseFirestore.instance.collection('config').doc('settings');
final counters = FirebaseFirestore.instance.collection('config').doc('counters');

class DashboardController extends GetxController {
  @override
  void onInit() async {
    fillDateWiseLeads();
    loadLeadsByEnquiryTime();
    loadLeadsBySellTime();
    loadtop5Agents();
    loadLeads();
    loadAgents();
    loadProperties();
    super.onInit();
  }

  List<Agent> top5AgentsByLeads = [];
  List<Agent> top5AgentsBySuccessfull = [];
  List<Agent> top5AgentsByComission = [];
  int totalLeads = 0;
  int totalSuccessleads = 0;
  double totalSoldAmount = 0;
  int totalProperties = 0;
  int totalSoldProperties = 0;
  int totalAgents = 0;
  int totalActiveAgents = 0;
  int totalStaffs = 0;
  Map<DateTime, List<Lead>> dateWiseLeads = {};
  Map<DateTime, List<Lead>> dateWiseSoldLeads = {};
  Map<DateTime, int> dateWiseLeadCount = {};
  Map<DateTime, double> dateWiseAmount = {};
  List<Lead> overAllLeads = [];
  int beforeCount = 0;
  double beforeAmount = 0;

  double get comissionAmount => overAllLeads.fold<double>(0,
      ((previousValue, element) => previousValue + element.agentComissionAmount + element.staffComissionAmount + element.superAgentComissionAmount));
  double get soldAmount => overAllLeads.fold<double>(0, ((previousValue, element) => previousValue + (element.sellingAmount ?? 0)));

  fillDateWiseLeads() {
    for (int i = 0; i < 31; i++) {
      var date = DateTime.now().subtract(Duration(days: i));
      dateWiseLeads[date.trimTime()] = [];
      dateWiseSoldLeads[date.trimTime()] = [];
      dateWiseLeadCount[date.trimTime()] = 0;
      dateWiseAmount[date.trimTime()] = 0;
    }
  }

  loadLeads() async {
    var date = DateTime.now().subtract(const Duration(days: 30));
    overAllLeads =
        await FirebaseFirestore.instance.collectionGroup('leads').get().then((value) => value.docs.map((e) => Lead.fromSnapshot(e)).toList());
    beforeCount = overAllLeads.where((element) => element.enquiryDate.isBefore(date)).length;
    totalLeads = overAllLeads.length;

    var convertedLeads = overAllLeads.where((element) => (element.leadStatus == LeadStatus.sold)).toList();
    totalSuccessleads = convertedLeads.length;
    totalSoldProperties = totalSuccessleads;

    beforeAmount = convertedLeads
        .where((element) => element.soldOn!.isBefore(date))
        .fold<double>(0, (previousValue, element) => previousValue + element.sellingAmount!);

    int incrementalCount = beforeCount;
    double incrementalAmount = beforeAmount;
    for (int i = 0; i < 30; i++) {
      var currentDate = DateTime.now().subtract(Duration(days: i)).trimTime();
      var leadstoWorkOn = overAllLeads.where((element) => element.enquiryDate.trimTime().isAtSameMomentAs(currentDate));
      dateWiseLeadCount[currentDate] = incrementalCount + leadstoWorkOn.length;
      incrementalCount = incrementalCount + leadstoWorkOn.length;
      dateWiseAmount[currentDate] = leadstoWorkOn
          .where((element) => element.leadStatus == LeadStatus.sold)
          .fold<double>(incrementalAmount, (previousValue, element) => previousValue + (element.sellingAmount ?? 0));
      // incrementalAmount = incrementalAmount + (element.sellingAmount ?? 0);
    }

    update();
  }

  loadAgents() async {
    var list = AppSession().agents;
    totalAgents = list.length;
    totalActiveAgents = list.where((element) => element.activeStatus == ActiveStatus.active).length;
    update();
  }

  loadProperties() async {
    totalProperties = await FirebaseFirestore.instance.collectionGroup('properties').get().then((value) => value.docs.length);
    update();
  }

  loadLeadsByEnquiryTime() {
    var date = DateTime.now().subtract(const Duration(days: 30));
    return FirebaseFirestore.instance
        .collectionGroup('leads')
        .orderBy('enquiryDate', descending: true)
        .where('enquiryDate', isGreaterThanOrEqualTo: date)
        .get()
        .then((value) {
      var leads = value.docs.map((e) => Lead.fromSnapshot(e)).toList();
      for (var lead in leads) {
        if (dateWiseLeads[lead.enquiryDate.trimTime()] == null) {
          dateWiseLeads[lead.enquiryDate.trimTime()] = [];
        }
        dateWiseLeads[lead.enquiryDate.trimTime()]?.add(lead);
      }
    });
  }

  loadLeadsBySellTime() {
    var date = DateTime.now().subtract(const Duration(days: 30));
    return FirebaseFirestore.instance
        .collectionGroup('leads')
        .orderBy('soldOn', descending: true)
        .where('soldOn', isGreaterThanOrEqualTo: date)
        .get()
        .then((value) {
      var leads = value.docs.map((e) => Lead.fromSnapshot(e)).toList();
      print("${leads.length}");
      printInfo(info: leads.length.toString());
      for (var lead in leads) {
        if (lead.soldOn != null) {
          if (dateWiseSoldLeads[lead.soldOn!.trimTime()] == null) {
            dateWiseSoldLeads[lead.soldOn!.trimTime()] = [];
          }
          dateWiseSoldLeads[lead.soldOn!.trimTime()]?.add(lead);
        }
      }
    });
  }

  loadtop5Agents() {
    FirebaseFirestore.instance.collection('agents').orderBy('leadCount', descending: true).limit(5).get().then((value) {
      top5AgentsByLeads = value.docs.map((e) => Agent.fromSnapshot(e)).toList();
      update();
    });
    FirebaseFirestore.instance.collection('agents').orderBy('successfullLeadCount', descending: true).limit(5).get().then((value) {
      top5AgentsBySuccessfull = value.docs.map((e) => Agent.fromSnapshot(e)).toList();
      update();
    });
    FirebaseFirestore.instance.collection('agents').orderBy('commissionAmount', descending: true).limit(5).get().then((value) {
      top5AgentsByComission = value.docs.map((e) => Agent.fromSnapshot(e)).toList();
      update();
    });
  }
}
