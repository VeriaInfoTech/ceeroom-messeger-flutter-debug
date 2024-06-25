class VersionModel {
  String? status;
  String? lastVersion;
  String? url;
  bool? isForce;
  String? message;
  String? currentVersion;
  String? buttonTitle;
  String? title;
  String? stun;

  VersionModel({
    this.status,
    this.lastVersion,
    this.url,
    this.isForce,
    this.message,
    this.currentVersion,
    this.buttonTitle,
    this.title,
    this.stun,
  });

  factory VersionModel.fromJson(Map<String, dynamic> json) {
    return VersionModel(
      status: json["status"],
      lastVersion: json["last_version"],
      url: json["url"],
      isForce: json["is_force"],
      message: json["message"],
      currentVersion: json["current_version"],
      buttonTitle: json["button_title"],
      title: json["title"],
      stun: json["stn"],
    );
  }
}
