class Project {
  late String creator;
  late String deadline;
  late String description;
  late String goalSats;
  late String satsFunded;
  late String title;
  late String image;

  Project({
    required this.creator,
    required this.deadline,
    required this.description,
    required this.goalSats,
    required this.satsFunded,
    required this.title,
    required this.image,
  });

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'creator': creator,
        'deadline': deadline,
        'description': description,
        'goalSats': goalSats,
        'satsFunded': satsFunded,
        'title': title,
        'image': image,
      };
}
