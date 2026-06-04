import 'dart:convert';
import 'dart:typed_data';
import 'dart:math';

enum FectchType { all, quanzhongsort, quanzhongRandom }

class AdsListModel {
  String id;
  String title;
  List<AdsModel> items;
  List<AdsModel> left;

  AdsListModel({
    this.id = '',
    this.title = '',
    this.items = const [],
    this.left = const [],
  });

  AdsModel fetchModel({bool isSort = true}) {
    if (left.isEmpty) {
      List<AdsModel> list = List.from(items);
      if (isSort) list.sort((a, b) => b.quanzhong.compareTo(a.quanzhong));
      left = list;
    }
    return left.removeAt(0);
  }

  List<AdsModel> getItemsSort({bool isSort = true}) {
    List<AdsModel> list = List.from(items);
    if (isSort) list.sort((a, b) => b.quanzhong.compareTo(a.quanzhong));
    return list;
  }

  factory AdsListModel.fromJson(Map<String, dynamic> json) {
    List items = json['items'] ?? [];
    List<AdsModel> list = items.map((v) => AdsModel.fromJson(v)).toList();
    return AdsListModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      items: list,
    );
  }

  factory AdsListModel.fromTvJson(Map<String, dynamic> json) {
    List items = json['items'] ?? [];
    List<AdsModel> list = items.map((v) => AdsModel.fromTvJson(v)).toList();
    return AdsListModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      items: list,
    );
  }
}

class AdsModel {
  String type;
  String id;
  String title;
  String targetUrl;
  String introduction;
  String iosDownLoadURL;
  String andoridDownloadUrl;
  String imgUrl;
  String downloadCount;
  String linkType;

  int adsType;
  String remark;

  // 从 videoUrl 解析出来的业务字段
  int? fenzu; // 分组
  int? weizhi; // 1=上 2=中 3=下
  int? tanchushunxu; // 弹出顺序（组级）
  int quanzhong; // 权重

  Uint8List? bytes;

  AdsModel({
    this.type = '',
    this.id = '',
    this.title = '',
    this.targetUrl = '',
    this.introduction = '',
    this.iosDownLoadURL = '',
    this.andoridDownloadUrl = '',
    this.imgUrl = '',
    this.downloadCount = '',
    this.adsType = 0,
    this.remark = '',
    this.fenzu,
    this.weizhi,
    this.tanchushunxu,
    this.quanzhong = 0,
    this.linkType = "0",
  });

  // ——— helpers ———
  static int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v.trim());
    return null;
  }

  static Map<String, dynamic> _videoUrlAsMap(dynamic raw) {
    if (raw == null) return {};
    if (raw is Map<String, dynamic>) return raw;
    if (raw is String && raw.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) return decoded;
      } catch (_) {
        /* ignore */
        return {};
      }
    }
    return {};
  }

  factory AdsModel.fromJson(Map<String, dynamic> json) {
    Map m = _videoUrlAsMap(json['i'] ?? ''); //videoUrl
    int downloadCount = _toInt(json['h'] ?? 0) ?? 0;
    if (downloadCount <= 1000) {
      int randomAddition = Random().nextInt(20000); // 0-4999 的随机数
      downloadCount += randomAddition; // 增加随机数，提升下载量显示
    }
    return AdsModel(
      // id
      id: json['a'] ?? '',
      // title
      title: json['b'] ?? '',
      // targetUrl
      targetUrl: json['c'] ?? '',
      // introduction
      introduction: json['d'] ?? '',
      // iosDownLoadUrl
      iosDownLoadURL: json['e'] ?? '',
      // andoridDownloadUrl
      andoridDownloadUrl: json['f'] ?? '',
      // imgUrl
      imgUrl: json['g'] ?? '',
      // downloadCount
      downloadCount:
          downloadCount > 9999
              ? '${(downloadCount / 10000).toStringAsFixed(1)}万'
              : downloadCount.toString(),
      //adsType
      adsType: _toInt('${json['j'] ?? 0}') ?? 0,
      // remark
      remark: json['k'] ?? '',
      type: json['type'] ?? '0',
      fenzu: _toInt(m['fenzu']),
      weizhi: _toInt(m['weizhi']),
      tanchushunxu: _toInt(m['tanchushunxu']),
      quanzhong: _toInt(m['quanzhong']) ?? 0,
      linkType: json['linkType'] ?? '0',
    );
  }

  factory AdsModel.fromTvJson(Map<String, dynamic> json) {
    int downloadCount = _toInt(json['downloadCount'] ?? 0) ?? 0;
    if (downloadCount <= 1000) {
      int randomAddition = Random().nextInt(20000); // 0-4999 的随机数
      downloadCount += randomAddition; // 增加随机数，提升下载量显示
    }
    return AdsModel(
      // id
      id: json['id'] ?? '',
      // title
      title: json['title'] ?? '',
      // targetUrl
      targetUrl: json['targetUrl'] ?? '',
      // introduction
      introduction: json['introduction'] ?? '',
      // iosDownLoadUrl
      iosDownLoadURL: json['iosDownLoadUrl'] ?? '',
      // andoridDownloadUrl
      andoridDownloadUrl: json['andoridDownloadUrl'] ?? '',
      // imgUrl
      imgUrl: json['imgUrl'] ?? '',
      // downloadCount
      downloadCount:
          downloadCount > 9999
              ? '${(downloadCount / 10000).toStringAsFixed(1)}万'
              : downloadCount.toString(),
      //adsType
      adsType: _toInt('${json['adsType'] ?? 0}') ?? 0,
      // remark
      remark: json['remark'] ?? '',
      linkType: json['linkType'] ?? '0',
    );
  }
  Map<String, dynamic> toJson() {
    return {
      // 原接口字段
      "a": id,
      "b": title,
      "c": targetUrl,
      "d": introduction,
      "e": iosDownLoadURL,
      "f": andoridDownloadUrl,
      "g": imgUrl,
      "h": downloadCount,
      "j": adsType,
      "k": remark,
      "type": type,
      "linkType": linkType,

      // videoUrl 对应的字段重新组装回 i
      "i": jsonEncode({
        "fenzu": fenzu,
        "weizhi": weizhi,
        "tanchushunxu": tanchushunxu,
        "quanzhong": quanzhong,
      }),
    };
  }
}
