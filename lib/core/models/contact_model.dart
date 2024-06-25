List<ContactModel> getAllContacts(data) =>
    data.map<ContactModel>((x) => ContactModel.fromJson(x)).toList();

class ContactModel {
  final int? id;
  final String? name;
  final String? identity;
  final String? email;
  final String? mobile;
  final List<String>? inviteMobile;
  final int? status;
  final dynamic? timeCreated;
  final String? firstName;
  final String? lastName;
  final DateTime? birthdate;
  final String? gender;
  final String? avatar;
  final String? timeCreatedView;

  ContactModel({
    this.id,
    this.name,
    this.identity,
    this.email,
    this.mobile,
    this.inviteMobile,
    this.status,
    this.timeCreated,
    this.firstName,
    this.lastName,
    this.birthdate,
    this.gender,
    this.avatar,
    this.timeCreatedView,
  });

  factory ContactModel.fromJson(Map<String, dynamic> json) => ContactModel(
        id: json["id"],
        name: json["name"] ?? 'No name',
        identity: json["identity"],
        email: json["email"],
        mobile: json["mobile"],
        status: json["status"],
        timeCreated: json["time_created"],
        firstName: json["first_name"],
        lastName: json["last_name"],
        birthdate: json["birthdate"] != null && json["birthdate"] != ''
            ? DateTime.parse(json["birthdate"])
            : null,
        gender: json["gender"],
        avatar: json["avatar"],
        timeCreatedView: json["time_created_view"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "mobile": mobile,
        "avatar": avatar,
      };
}
