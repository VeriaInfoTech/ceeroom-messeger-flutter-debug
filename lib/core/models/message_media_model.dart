import 'dart:async';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

class MessageMediaModel {
  int? id;
  String? mediaSize;
  String? name;
  double? uploadProgress;
  double? downloadProgress;
  String? path;
  String? mediaSource;
  CancelToken? cancelToken;
  http.Client? client;
  StreamSubscription<List<int>>? subscription;

  MessageMediaModel({
    this.id,
    this.uploadProgress,
    this.path,
    this.name,
    this.mediaSize,
    this.cancelToken,
    this.downloadProgress,
    this.client,
    this.subscription,
    this.mediaSource,
  });

  factory MessageMediaModel.fromJson(Map<String, dynamic> json) =>
      MessageMediaModel(
        id: json['id'],
        mediaSize: json["media_size"],
        name: json["name"],
        path: json.containsKey('path') ? json["path"] : null,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "media_size": mediaSize,
        "name": name,
      };

  Map<String, dynamic> storeLocalToJson() => {
        "id": id,
        "media_size": mediaSize,
        "name": name,
        "path": path,
      };
}
