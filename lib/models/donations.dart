import 'package:json_annotation/json_annotation.dart';

part 'donations.g.dart';

@JsonSerializable(explicitToJson: true)
class Donations {
  @JsonKey(name: "title")
  late String title;
  @JsonKey(name: "creator")
  late String creator;
  @JsonKey(name: "user")
  late String user;
  @JsonKey(name: "amt")
  late String amt;

  Donations(
    this.title,
    this.creator,
    this.user,
    this.amt,
  );
  factory Donations.fromJson(Map<String, dynamic> json) =>
      _$DonationsFromJson(json);

  Map<String, dynamic> toJson() => _$DonationsToJson(this);
}
