class ApiError {
  int? code;
  String? message;
  String? credential;
  String? mobile;
  String? otp;
  String? email;

  ApiError({
    this.code,
    this.message,
    this.credential,
    this.mobile,
    this.otp,
    this.email,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      code: json['code'],
      message: json['message'] is String ? json['message'] : null,
      credential: isMessageStringOrEmpty(message: json['message'])
          ? null
          : json['message']['credential'],
      mobile: isMessageStringOrEmpty(message: json['message'])
          ? null
          : json['message']['mobile'],
      otp: isMessageStringOrEmpty(message: json['message'])
          ? null
          : json['message']['otp'],
      email: isMessageStringOrEmpty(message: json['message'])
          ? null
          : json['message']['email'],
    );
  }

  static bool isMessageStringOrEmpty({dynamic message}) {
    return message == null || message is String;
  }
}
