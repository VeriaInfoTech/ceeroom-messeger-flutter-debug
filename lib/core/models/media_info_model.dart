class MediaInfoModel {
  final int? id;
  final dynamic slug;
  final String? title;
  final int? userId;
  final int? companyId;
  final String? access;
  final String? storage;
  final String? type;
  final String? extension;
  final int? size;
  final int? downloadCount;
  final int? status;
  final int? timeCreate;
  final int? timeUpdate;
  final Information? information;
  final String? userIdentity;
  final String? userName;
  final String? userEmail;
  final String? userMobile;
  final String? timeCreateView;
  final String? timeUpdateView;
  final String? originalName;
  final String? sizeView;
  final String? avatar;
  double? uploadProgress;
  String? localPath;

  MediaInfoModel({
    this.id,
    this.slug,
    this.title,
    this.userId,
    this.companyId,
    this.access,
    this.storage,
    this.type,
    this.extension,
    this.size,
    this.downloadCount,
    this.status,
    this.timeCreate,
    this.timeUpdate,
    this.information,
    this.userIdentity,
    this.userName,
    this.userEmail,
    this.userMobile,
    this.avatar,
    this.timeCreateView,
    this.timeUpdateView,
    this.originalName,
    this.sizeView,
    this.uploadProgress,
    this.localPath,
  });

  factory MediaInfoModel.fromJson(Map<String, dynamic> json) => MediaInfoModel(
        id: json["id"],
        slug: json["slug"],
        title: json["title"],
        userId: json["user_id"],
        companyId: json["company_id"],
        access: json["access"],
        storage: json["storage"],
        type: json["type"],
        extension: json["extension"],
        size: json["size"],
        downloadCount: json["download_count"],
        status: json["status"],
        avatar: json["avatar"],
        timeCreate: json["time_create"],
        timeUpdate: json["time_update"],
        information: json["information"] == null
            ? null
            : Information.fromJson(json["information"]),
        userIdentity: json["user_identity"],
        userName: json["user_name"],
        userEmail: json["user_email"],
        userMobile: json["user_mobile"],
        timeCreateView: json["time_create_view"],
        timeUpdateView: json["time_update_view"],
        originalName: json["original_name"],
        sizeView: json["size_view"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "slug": slug,
        "title": title,
        "user_id": userId,
        "company_id": companyId,
        "access": access,
        "storage": storage,
        "type": type,
        "extension": extension,
        "size": size,
        "download_count": downloadCount,
        "status": status,
        "time_create": timeCreate,
        "time_update": timeUpdate,
        "information": information?.toJson(),
        "user_identity": userIdentity,
        "user_name": userName,
        "user_email": userEmail,
        "user_mobile": userMobile,
        "time_create_view": timeCreateView,
        "time_update_view": timeUpdateView,
        "original_name": originalName,
        "size_view": sizeView,
      };
}

class Information {
  final Download? download;
  final List<dynamic>? category;
  final List<dynamic>? review;
  final List<History>? history;

  Information({
    this.download,
    this.category,
    this.review,
    this.history,
  });

  factory Information.fromJson(Map<String, dynamic> json) => Information(
        download: json["download"] == null
            ? null
            : Download.fromJson(json["download"]),
        category: json["category"] == null
            ? []
            : List<dynamic>.from(json["category"]!.map((x) => x)),
        review: json["review"] == null
            ? []
            : List<dynamic>.from(json["review"]!.map((x) => x)),
        history: json["history"] == null
            ? []
            : List<History>.from(
                json["history"]!.map((x) => History.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "download": download?.toJson(),
        "category":
            category == null ? [] : List<dynamic>.from(category!.map((x) => x)),
        "review":
            review == null ? [] : List<dynamic>.from(review!.map((x) => x)),
        "history": history == null
            ? []
            : List<dynamic>.from(history!.map((x) => x.toJson())),
      };
}

class Download {
  final String? publicUri;

  Download({
    this.publicUri,
  });

  factory Download.fromJson(Map<String, dynamic> json) => Download(
        publicUri: json["public_uri"],
      );

  Map<String, dynamic> toJson() => {
        "public_uri": publicUri,
      };
}

class History {
  final String? action;
  final Storage? storage;
  final int? userId;
  final HistoryData? data;

  History({
    this.action,
    this.storage,
    this.userId,
    this.data,
  });

  factory History.fromJson(Map<String, dynamic> json) => History(
        action: json["action"],
        storage:
            json["storage"] == null ? null : Storage.fromJson(json["storage"]),
        userId: json["user_id"],
        data: json["data"] == null ? null : HistoryData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "action": action,
        "storage": storage?.toJson(),
        "user_id": userId,
        "data": data?.toJson(),
      };
}

class HistoryData {
  final dynamic? title;
  final String? type;
  final String? extension;
  final int? status;
  final int? size;
  final int? timeUpdate;

  HistoryData({
    this.title,
    this.type,
    this.extension,
    this.status,
    this.size,
    this.timeUpdate,
  });

  factory HistoryData.fromJson(Map<String, dynamic> json) => HistoryData(
        title: json["title"],
        type: json["type"],
        extension: json["extension"],
        status: json["status"],
        size: json["size"],
        timeUpdate: json["time_update"],
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "type": type,
        "extension": extension,
        "status": status,
        "size": size,
        "time_update": timeUpdate,
      };
}

class Storage {
  final String? originalName;
  final dynamic fileTitle;
  final String? fileExtension;
  final int? fileSize;
  final String? fileName;
  final String? filePath;
  final String? fullPath;
  final String? mainPath;
  final String? localPath;

  Storage({
    this.originalName,
    this.fileTitle,
    this.fileExtension,
    this.fileSize,
    this.fileName,
    this.filePath,
    this.fullPath,
    this.mainPath,
    this.localPath,
  });

  factory Storage.fromJson(Map<String, dynamic> json) => Storage(
        originalName: json["original_name"],
        fileTitle: json["file_title"],
        fileExtension: json["file_extension"],
        fileSize: json["file_size"],
        fileName: json["file_name"],
        filePath: json["file_path"],
        fullPath: json["full_path"],
        mainPath: json["main_path"],
        localPath: json["local_path"],
      );

  Map<String, dynamic> toJson() => {
        "original_name": originalName,
        "file_title": fileTitle,
        "file_extension": fileExtension,
        "file_size": fileSize,
        "file_name": fileName,
        "file_path": filePath,
        "full_path": fullPath,
        "main_path": mainPath,
        "local_path": localPath,
      };
}
