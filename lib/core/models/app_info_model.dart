class AppInfo {
  String? buildNumber;
  String? platform;
  String? marketPlace;
  String? applicant;

  AppInfo({
    this.buildNumber,
    this.platform,
    this.marketPlace,
    this.applicant,
  });

  factory AppInfo.fromJson(Map<String, dynamic> json) {
    return AppInfo(
      platform: json['platform'],
      marketPlace: json['market_place'],
      applicant: json['applicant'],
      buildNumber: json['build_number'],
    );
  }
}
