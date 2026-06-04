class AppVersionModel {
  VersionModel? ios;
  VersionModel? android;

  AppVersionModel({this.ios, this.android});

  AppVersionModel.fromJson(Map<String, dynamic> json) {
    ios = json['ios'] != null ? VersionModel.fromJson(json['ios']) : null;
    android =
    json['android'] != null ? VersionModel.fromJson(json['android']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (ios != null) {
      data['ios'] = ios!.toJson();
    }
    if (android != null) {
      data['android'] = android!.toJson();
    }
    return data;
  }
}

class VersionModel {
  int? versionCode;
  String? versionName;
  List<String>? tips;
  bool? isUpgrade;
  String? downloadUrl;

  VersionModel(
      {this.versionCode,
        this.versionName,
        this.tips,
        this.isUpgrade,
        this.downloadUrl});

  VersionModel.fromJson(Map<String, dynamic> json) {
    versionCode = json['versionCode'];
    versionName = json['versionName'];
    tips = json['tips'].cast<String>();
    isUpgrade = json['isUpgrade'];
    downloadUrl = json['downloadUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['versionCode'] = versionCode;
    data['versionName'] = versionName;
    data['tips'] = tips;
    data['isUpgrade'] = isUpgrade;
    data['downloadUrl'] = downloadUrl;
    return data;
  }
}

