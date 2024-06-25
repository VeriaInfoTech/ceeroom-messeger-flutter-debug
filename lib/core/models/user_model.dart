import 'dart:convert';

class UserModel {
  UserModel({
    this.id,
    this.name,
    this.email,
    this.identity,
    this.mobile,
    this.status,
    this.roles,
    this.lastLogin,
    this.accessToken,
    this.refreshToken,
    this.avatar,
  });

  final int? id;
  final String? name;
  final String? email;
  final String? identity;
  final String? mobile;
  final int? status;
  final List<String>? roles;
  final int? lastLogin;
  final String? accessToken;
  final String? refreshToken;
  final String? avatar;

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json["id"],
    name: json["name"],
    email: json["email"],
    identity: json["identity"],
    mobile: json["mobile"],
    status: json["status"],
    roles: List<String>.from(json["roles"].map((x) => x)),
    lastLogin: json["last_login"],
    accessToken: json["access_token"],
    refreshToken: json["refresh_token"],
    avatar: json['avatar'],
  );

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "email": email,
      "identity": identity,
      "mobile": mobile,
      "status": status,
      "roles": roles,
      "last_login": lastLogin,
      "access_token": accessToken,
      "refresh_token": refreshToken,
      "avatar": avatar,
    };
  }

  UserModel copyWith({
    final int? id,
    final String? name,
    final String? email,
    final String? identity,
    final String? mobile,
    final int? status,
    final List<String>? roles,
    final int? lastLogin,
    final String? refreshToken,
    final String? accessToken,
    final String? avatar,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      identity: identity ?? this.identity,
      mobile: mobile ?? this.mobile,
      status: status ?? this.status,
      roles: roles ?? this.roles,
      lastLogin: lastLogin ?? this.lastLogin,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      avatar: avatar ?? this.avatar,
    );
  }

  String toJson() => json.encode(toMap());
}