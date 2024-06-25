import 'package:CeeRoom/core/models/api_error.dart';

class Api {
  bool? result;
  ApiError? error;
  dynamic data;

  Api({this.result, this.error, this.data});

  factory Api.fromJson(Map<String, dynamic> json) {
    return Api(
      result: json['result'],
      error: ApiError.fromJson(json['error']),
      data: json['data'],
    );
  }
}
