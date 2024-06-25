import 'dart:async';
import 'dart:io';

import 'package:CeeRoom/core/middleware/middleware.dart';
import 'package:CeeRoom/core/models/api.dart';
import 'package:CeeRoom/core/models/media_info_model.dart';
import 'package:CeeRoom/core/services/local_storage/user.dart';
import 'package:CeeRoom/core/services/web_api/api_helper.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class MediaController {
  ApiHelper apiHelper = ApiHelper();
  http.Client? client;
  dio.CancelToken cancelToken = dio.CancelToken();

  Future<void> downloadMedia({
    required int mediaId,
    required ValueChanged<String> onSuccess,
    required ValueChanged<double> onProgress,
    VoidCallback? onError,
  }) async {
    try {
      var headers = {
        'token': LocalUser.getUser()!.accessToken!,
      };
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
          "${apiHelper.apiUri}${apiHelper.downloadMedia}",
        ),
      );
      client = http.Client();
      request.fields.addAll({'id': '$mediaId'});
      request.headers.addAll(headers);
      http.StreamedResponse response = await client!.send(request);
      List<int> bytes = [];
      response.stream.listen(
        (List<int> chunk) {
          bytes.addAll(chunk);
          if (response.contentLength != null) {
            final progress = bytes.length / response.contentLength!;
            onProgress(progress);
          }
        },
        onDone: () async {
          final header = response.headers['content-disposition'];
          final regex = RegExp('filename="([^"]+)"');
          final match = regex.firstMatch(header ?? '');
          final filename = match?.group(1) ?? 'file';
          final directory = await getApplicationDocumentsDirectory();
          final filePath = '${directory.path}/$filename';
          File file = File(filePath);
          await file.writeAsBytes(bytes);
          onSuccess.call(file.path);
          cancel();
        },
        onError: (e) {
          cancel();
          onError?.call();
        },
        cancelOnError: true,
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> uploadMedia({
    required File file,
    required String url,
    required ValueChanged<MediaInfoModel> onSuccess,
    required ValueChanged<double> onProgress,
    VoidCallback? onError,
    VoidCallback? onCancel,
  }) async {
    final dio.Dio d = dio.Dio();
    dio.FormData formData = dio.FormData();
    String fileName = file.path.split('/').last;
    formData.files.add(
      MapEntry(
        "file",
        await dio.MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
      ),
    );
    try {
      final res = await d.post(
        "${apiHelper.apiUri}$url",
        data: formData,
        options: dio.Options(
          headers: {
            "token": LocalUser.getUser()!.accessToken!,
          },
        ),
        onSendProgress: (sent, total) {
          onProgress(sent / total);
        },
        cancelToken: cancelToken,
      );
      Api api = Middleware.resultValidation(res.data);
      if (api.result!) {
        final mInfo = MediaInfoModel.fromJson(api.data);
        onSuccess.call(mInfo);
      }else{
        onError?.call();
      }
    } on dio.DioException catch (e) {
      if (dio.CancelToken.isCancel(e)) {
        onCancel?.call();
        debugPrint("Upload canceled");
      } else {
        onError?.call();
        debugPrint("Error uploading file: $e");
      }
    }
  }

  void cancel() {
    client?.close();
    cancelToken.cancel();
  }
}
