import 'package:firebase_database/firebase_database.dart';

import 'project.dart';

class ProjectDAO {
  final DatabaseReference _projectsRef =
      FirebaseDatabase.instance.ref().child('projects');

  void saveProject(Project project) {
    _projectsRef.push().set(project.toJson());
  }

  DatabaseReference getProjectsRef() => _projectsRef;

  getProjectQuery() {
    return _projectsRef;
  }

  Future<void> updateProjectFunding(Project project, String incrementAmount) async {
    DataSnapshot snapshot = await _projectsRef.orderByChild("title").equalTo(project.title).get();
    String projectKey = snapshot.children.first.key ?? "";
    Map map = snapshot.children.first.value as Map<dynamic, dynamic>;
    String amount = map["satsFunded"];
    var newAmount = int.parse(amount.replaceAll(",", "")) + int.parse(incrementAmount.replaceAll(",", ""));
    _projectsRef.update({
      "$projectKey/satsFunded": newAmount.toString()
    });
  }

  void testSaveProject() {
    Project project = Project(
      creator: 'ProjectOwner@NotReal.com',
      deadline: '${DateTime.utc(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        DateTime.now().hour + 6,
      )}',
      description:
          'As Marvin Wynn, the creator of The Edge states: "I always describe The Edge as a throw back to books of the 90’s. The book is influenced by X-Men and the WildStorm titles WildC.A.T.S., Stormwatch, etc. The goal is to tell a compelling story, with interesting characters and good art. Within that the stories are overarching, and things mentioned in early issues have pay offs later. The characters themselves drive the story, and their backgrounds are revealed as, more of the world is explored.',
      goalSats: '250,000',
      satsFunded: '1000',
      title: 'Save the planet',
      image:
          'http://saveanimalsfacingextinction.org/wp-content/uploads/2016/07/safe_fb_share2.png',
    );
    _projectsRef.push().set(project.toJson());
  }
}
