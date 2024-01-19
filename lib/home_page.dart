import 'package:bnrclash2022_blocksquad/models/project_dao.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'models/project.dart';
import 'campaign_stats.dart';
import 'globals.dart' as globals;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isPressed = false;
  ProjectDAO projectDao = ProjectDAO();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // This is just here to demonstrate that the global variable is being set and can be used anywhere
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 200,
        leading: const Padding(
          padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
          child: Text.rich(
            TextSpan(
                text: 'Sats',
                children: [
                  TextSpan(
                    text: 'me',
                    style: TextStyle(
                        fontSize: 29.5,
                        fontWeight: FontWeight.w300,
                        color: Colors.black),
                  ),
                ],
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange)),
          ),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Icon(
              Icons.add_box_outlined,
              color: Colors.black,
            ),
          )
        ],
      ),
      body: FirebaseAnimatedList(
        controller: _scrollController,
        query: projectDao.getProjectQuery(),
        itemBuilder: (context, snapshot, animation, index) {
          final projectSnapshot = snapshot.value as Map<dynamic, dynamic>;
          final projectKey = snapshot.key ?? "";
          Map projectMap = projectSnapshot;

          Project project = Project(
              image: projectMap.entries.toList()[0].value,
              creator: projectMap.entries.toList()[1].value,
              description: projectMap.entries.toList()[2].value,
              satsFunded: projectMap.entries.toList()[3].value,
              goalSats: projectMap.entries.toList()[4].value,
              deadline: projectMap.entries.toList()[5].value,
              title: projectMap.entries.toList()[6].value);

          int projectTimeLeft = getTimeLeft(project.deadline);
          String projectHoursLeft;
          if (projectTimeLeft / 24 < 1) {
            projectHoursLeft =
                'Only $projectTimeLeft ${projectTimeLeft == 1 ? 'hour' : 'hours'} left to donate!';
          } else {
            projectHoursLeft =
                'Only ${(projectTimeLeft / 24).floor()} ${projectTimeLeft == 1 ? 'day' : 'days'} left to donate!';
          }

          bool canDonate = true;
          if (projectTimeLeft == 0) {
            canDonate = false;
          }

          late Widget projectStatus =
              getProjectStatus(project.goalSats, project.satsFunded, canDonate);

          return Card(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    fit: FlexFit.loose,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: CachedNetworkImage(
                        imageUrl: project.image,
                        height: 200,
                        fit: BoxFit.fitWidth,
                        placeholder: (context, url) => Container(
                          height: 300.0,
                          width: MediaQuery.of(context).size.width - 24,
                          color: Colors.transparent,
                          child: Container(
                            decoration: const BoxDecoration(
                                color: Colors.grey,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0))),
                          ),
                        ),
                        placeholderFadeInDuration:
                            const Duration(milliseconds: 300),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: AppBar(
                      toolbarHeight: 38,
                      leadingWidth: double.infinity,
                      backgroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      leading: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: projectStatus,
                      ),
                      actions: [
                        IconButton(
                          icon: const Icon(FontAwesomeIcons.share,
                              color: Colors.black, size: 20),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(
                            FontAwesomeIcons.bitcoin,
                            color: Colors.orange,
                            size: 20,
                          ),
                          color: isPressed ? Colors.red : Colors.black,
                          onPressed: () {
                            setState(() {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        CampaignStats(campaignId: projectKey)),
                              );
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      project.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(project.description),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: projectTimeLeft > 0
                        ? Text(projectHoursLeft)
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  int getTimeLeft(String projectDeadline) {
    var projectDeadlineDateTime = DateTime.parse(projectDeadline);
    var projectHoursLeft =
        projectDeadlineDateTime.difference(DateTime.now()).inHours;

    if (projectHoursLeft <= 0) {
      return 0;
    }

    return projectHoursLeft;
  }

  Widget getProjectStatus(String goalSats, String satsFunded, bool canDonate) {
    Widget projectStatus;
    if ((double.parse(goalSats.replaceAll(RegExp(','), '')) >
            double.parse(satsFunded.replaceAll(RegExp(','), ''))) &&
        canDonate) {
      projectStatus =
          const Text('Funding', style: TextStyle(color: Colors.green));
    } else {
      projectStatus =
          const Text('Completed', style: TextStyle(color: Colors.orange));
    }

    return projectStatus;
  }
}
