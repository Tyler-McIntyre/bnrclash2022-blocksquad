import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bnrclash2022_blocksquad/send_payment_bottom_sheet.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import './campaign_image.dart';
import './models/project.dart';
import 'globals.dart' as globals;
import 'models/project_dao.dart';
import 'payment_bottom_sheet.dart';

// ----------------------------------------------------------------------------
// CampaignStats
// ----------------------------------------------------------------------------
class CampaignStats extends StatefulWidget {
  final String campaignId;

  const CampaignStats({Key? key, required this.campaignId}) : super(key: key);

  @override
  State<CampaignStats> createState() => _CampaignStats();
}

class _CampaignStats extends State<CampaignStats> {
  final donationController = TextEditingController();
  Project? _project;
  StreamSubscription<DatabaseEvent>? _streamSubscription;

  @override
  void dispose() {
    donationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    listenForProjectChanges();
  }

  @override
  void deactivate() {
    _streamSubscription?.cancel();
    super.deactivate();
  }

  void listenForProjectChanges() {
    ProjectDAO dao = ProjectDAO();
    _streamSubscription =
        dao.getProjectsRef().child(widget.campaignId).onValue.listen((event) {
      Project project = getProjectFromSnapshot(event.snapshot);
      setState(() {
        _project = project;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leadingWidth: 75,
          leading: const BackButton(
            color: Colors.black,
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: IconButton(
                icon: const Icon(FontAwesomeIcons.share,
                    color: Colors.black, size: 20),
                onPressed: () {},
              ),
            ),
          ],
        ),
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(child: mainBody(_project)));
  }

  Widget mainBody(Project? project) {
    if (project == null) {
      return const CircularProgressIndicator();
    }

    ProjectStatus status = getProjectStatus(project);

    return Center(
      child: Container(
          padding: const EdgeInsets.fromLTRB(40.0, 75.0, 40.0, 0),
          child: Column(
            children: [
              header(project),
              const Padding(
                padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                child: SizedBox(),
              ),
              description(project),
              pledged(project),
              goal(project),
              deadline(project),
              if (!isUserOwner(project) && status == ProjectStatus.running)
                donate(project),
              if (!isUserOwner(project) && status == ProjectStatus.running)
                donateButton(project),
              if (isUserOwner(project) && status == ProjectStatus.success)
                withdrawFundsButton(project,
                    'Congratulations your funds are available for withdrawl'),
              if (!isUserOwner(project) && status == ProjectStatus.failure)
                withdrawFundsButton(project,
                    '${project.title} did not meet it\'s goal, your refund is now available'),
              if (isUserOwner(project) && status == ProjectStatus.failure)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Text(
                    '${project.title} did not meet it\'s goal. Therefore, funds have been returned to the donor',
                    textAlign: TextAlign.center,
                  ),
                ),
              const Padding(
                padding: EdgeInsets.all(2.0),
                child: SizedBox(),
              )
            ],
          )),
    );
  }

  withdrawFundsButton(Project project, String message) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: SizedBox(
            width: MediaQuery.of(context).size.width / 1.25,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, double.infinity),
                  primary: Colors.deepOrange),
              onPressed: () {
                showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return SendPaymentBottomSheet(project.title);
                    });
              },
              icon: const Icon(FontAwesomeIcons.bitcoin),
              label: const Text('Withdraw your funds'),
            ),
          ),
        ),
        Text(
          message,
          style: const TextStyle(fontSize: 11),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Column header(Project project) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CampaignImage(project.image),
        Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.fromLTRB(0, 20.0, 0, 0),
          child: Text(project.title,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  SizedBox description(Project project) {
    return SizedBox(child: Text(project.description));
  }

  Column pledged(Project project) {
    return Column(
      children: [
        Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
            child: Text("${formatSats(project.satsFunded)} sats",
                style: const TextStyle(
                    fontSize: 32, fontWeight: FontWeight.bold))),
        Container(
            alignment: Alignment.centerLeft,
            child: const Text("Pledged", style: TextStyle(fontSize: 12)))
      ],
    );
  }

  Column goal(Project project) {
    return Column(
      children: [
        Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
            child: Text("${formatSats(project.goalSats)} sats",
                style: const TextStyle(
                    fontSize: 32, fontWeight: FontWeight.bold))),
        Container(
            alignment: Alignment.centerLeft,
            child: const Text("Goal", style: TextStyle(fontSize: 12)))
      ],
    );
  }

  Column deadline(Project project) {
    StatusDisplay statusDisplay = getProjectStatusDisplay(project);
    return Column(
      children: [
        Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
            child: Text(statusDisplay.title,
                style: const TextStyle(
                    fontSize: 32, fontWeight: FontWeight.bold))),
        Container(
            alignment: Alignment.centerLeft,
            child: Text(statusDisplay.subtitle,
                style: TextStyle(color: statusDisplay.subtitleColor))),
      ],
    );
  }

  Column donate(Project project) {
    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.fromLTRB(0, 16, 0, 10),
          child: const Text("Amount",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ),
        TextFormField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: "\$LBTC",
            ),
            controller: donationController,
            scrollPadding: const EdgeInsets.only(bottom: 40),
            keyboardType: TextInputType.number)
      ],
    );
  }

  showPaymentInvoice(Project project) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return PaymentBottomSheet(donationController.text, project);
        });
  }

  Padding donateButton(Project project) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
        child: SizedBox(
          width: MediaQuery.of(context).size.width / 1.25,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, double.infinity),
                primary: Colors.deepOrange),
            onPressed: () {
              showPaymentInvoice(project);
            },
            child: const Text('Donate'),
          ),
        ));
  }

  String formatSats(String sats) {
    var satInt = int.parse(sats.replaceAll(",", ""));
    var f = NumberFormat('###,###');
    return f.format(satInt);
  }

  StatusDisplay getProjectStatusDisplay(Project project) {
    ProjectStatus status = getProjectStatus(project);
    if (status == ProjectStatus.running) {
      return StatusDisplay(daysLeft(project), "Funding", Colors.green);
    } else if (status == ProjectStatus.success) {
      return StatusDisplay("Goal Reached!", "Complete", Colors.deepOrange);
    } else {
      return StatusDisplay(
          "Didn't hit the target...", "Refunds Issued", Colors.red);
    }
  }

  ProjectStatus getProjectStatus(Project project) {
    final goalDate = DateTime.parse(project.deadline);
    final now = DateTime.now();
    if (goalDate.difference(now) > const Duration(seconds: 0)) {
      return ProjectStatus.running;
    } else if (double.parse(project.satsFunded.replaceAll(",", "")) >=
        double.parse(project.goalSats.replaceAll(",", ""))) {
      return ProjectStatus.success;
    }
    return ProjectStatus.failure;
  }

  String daysLeft(Project project) {
    final goalDate = DateTime.parse(project.deadline);
    final now = DateTime.now();
    final diffDays = (goalDate.difference(now).inHours / 24).round();

    var out = "Last Day";
    if (diffDays > 1) {
      out = "$diffDays Days Left";
    } else if (diffDays > 0) {
      out = "$diffDays Day Left";
    }

    return out;
  }

  bool isUserOwner(Project project) {
    return project.creator == globals.loggedInUserName;
  }

  Project getProjectFromSnapshot(DataSnapshot snapshot) {
    final projectSnapshot = snapshot.value as Map<dynamic, dynamic>;
    Map projectMap = projectSnapshot;
    return Project(
        image: projectMap.entries.toList()[0].value,
        creator: projectMap.entries.toList()[1].value,
        description: projectMap.entries.toList()[2].value,
        satsFunded: projectMap.entries.toList()[3].value,
        goalSats: projectMap.entries.toList()[4].value,
        deadline: projectMap.entries.toList()[5].value,
        title: projectMap.entries.toList()[6].value);
  }
}

enum ProjectStatus { running, success, failure }

class StatusDisplay {
  String title;
  String subtitle;
  Color subtitleColor;
  StatusDisplay(this.title, this.subtitle, this.subtitleColor);
}
