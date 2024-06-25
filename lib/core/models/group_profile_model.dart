class GroupProfileModel {
  final String? name;
  final String? identity;
  final String? bio;
  final String? avatar;

  GroupProfileModel({
    this.name,
    this.identity,
    this.bio,
    this.avatar,
  });

  factory GroupProfileModel.fromJson(Map<String, dynamic> json) =>
      GroupProfileModel(
        name: json["name"],
        identity: json["identity"],
        bio: json['bio'],
        avatar: json['avatar'],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "identity": identity,
        "bio": bio,
      };
}
