import 'package:firebase_database/firebase_database.dart';
import 'donations.dart';
import 'project.dart';

class DonationsDAO {
  final DatabaseReference _donationRef =
      FirebaseDatabase.instance.ref().child('donations');

  void saveDonation(Donations donation) {
    _donationRef.push().set(donation.toJson());
  }

  _getDonationsQuery() {
    return _donationRef.get();
  }
}

Future<int> getTotalForUser(String projectTitle, String login) async {
  int total = 0;
  List<Donations> list = await getDonationList();
  for (Donations donation in list) {
    //is the project title = the donation project title yes? ->
    if (donation.title.toLowerCase() == projectTitle.toLowerCase()) {
      //check the user name / creator = login ->
      if (login.toLowerCase() == donation.creator.toLowerCase() ||
          login.toLowerCase() == donation.user.toLowerCase()) {
        //add the amount to the total
        total += int.parse(donation.amt);
      }
    }
  }

  return total;
}

Future<List<Donations>> getDonationList() async {
  DonationsDAO dao = DonationsDAO();
  List<Donations> donationList = [];

  DataSnapshot snapshots = await dao._getDonationsQuery();

  for (DataSnapshot snapshot in snapshots.children) {
    Map donationSnapshot = snapshot.value as Map<dynamic, dynamic>;

    Donations donation = Donations(
      donationSnapshot.entries.toList()[2].value,
      donationSnapshot.entries.toList()[0].value,
      donationSnapshot.entries.toList()[3].value,
      donationSnapshot.entries.toList()[1].value,
    );

    donationList.add(donation);
  }

  return donationList;
}

void testSaveDonation() {
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

  Donations donation =
      Donations(project.title, project.creator, 'donor@email.com', '500');

  DonationsDAO dao = DonationsDAO();
  dao.saveDonation(donation);
}
