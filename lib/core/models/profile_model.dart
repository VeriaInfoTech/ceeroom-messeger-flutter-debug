import 'dart:convert';

List<ProfileModel> getAllProfiles(data) =>
    data.map<ProfileModel>((item) => ProfileModel.fromJson(item)).toList();

class ProfileModel {
  ProfileModel({
    this.id,
    this.name,
    this.email,
    this.identity,
    this.mobile,
    this.firstName,
    this.lastName,
    this.idNumber,
    this.birthdate,
    this.gender,
    this.avatar,
    this.ipRegister,
    this.registerSource,
    this.homepage,
    this.phone,
    this.address1,
    this.country,
    this.state,
    this.city,
    this.zipCode,
    this.bankName,
    this.bankCard,
    this.bankAccount,
    this.company,
  });

  final int? id;
  final String? name;
  final String? email;
  final String? identity;
  final String? mobile;
  final String? firstName;
  final String? lastName;
  final String? idNumber;
  final String? birthdate;
  final String? gender;
  final String? avatar;
  final String? ipRegister;
  final String? registerSource;
  final String? homepage;
  final String? phone;
  final String? address1;
  final String? country;
  final String? state;
  final String? city;
  final String? zipCode;
  final String? bankName;
  final String? bankCard;
  final String? bankAccount;
  final String? company;

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json["id"],
      name: json["name"],
      email: json["email"],
      identity: json["identity"],
      mobile: json["mobile"],
      firstName: json["first_name"],
      lastName: json["last_name"],
      idNumber: json["id_number"],
      birthdate: json["birthdate"],
      gender: json["gender"],
      avatar: json["avatar"],
      ipRegister: json["ip_register"],
      registerSource: json["register_source"],
      homepage: json["homepage"],
      phone: json["phone"],
      address1: json["address_1"],
      country: json["country"],
      state: json["state"],
      city: json["city"],
      zipCode: json["zip_code"],
      bankName: json["bank_name"],
      bankCard: json["bank_card"],
      bankAccount: json["bank_account"],
      company: json["company"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "email": email,
      "identity": identity,
      "mobile": mobile,
      "first_name": firstName,
      "last_name": lastName,
      "id_number": idNumber,
      "birthdate": birthdate,
      "gender": gender,
      "avatar": avatar,
      "ip_register": ipRegister,
      "register_source": registerSource,
      "homepage": homepage,
      "phone": phone,
      "address_1": address1,
      "country": country,
      "state": state,
      "city": city,
      "zip_code": zipCode,
      "bank_name": bankName,
      "bank_card": bankCard,
      "bank_account": bankAccount,
    };
  }

  String toJson() => json.encode(toMap());

  ProfileModel copyWith({
    int? id,
    String? name,
    String? email,
    String? identity,
    String? mobile,
    String? firstName,
    String? lastName,
    String? idNumber,
    String? birthdate,
    String? gender,
    String? avatar,
    String? ipRegister,
    String? registerSource,
    String? homepage,
    String? phone,
    String? address1,
    String? country,
    String? state,
    String? city,
    String? zipCode,
    String? bankName,
    String? bankCard,
    String? bankAccount,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      identity: identity ?? this.identity,
      mobile: mobile ?? this.mobile,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      idNumber: idNumber ?? this.idNumber,
      birthdate: birthdate ?? this.birthdate,
      gender: gender ?? this.gender,
      avatar: avatar ?? this.avatar,
      ipRegister: ipRegister ?? this.ipRegister,
      registerSource: registerSource ?? this.registerSource,
      homepage: homepage ?? this.homepage,
      phone: phone ?? this.phone,
      address1: address1 ?? this.address1,
      country: country ?? this.country,
      state: state ?? this.state,
      city: city ?? this.city,
      zipCode: zipCode ?? this.zipCode,
      bankName: bankName ?? this.bankName,
      bankCard: bankCard ?? this.bankCard,
      bankAccount: bankAccount ?? this.bankAccount,
    );
  }
}