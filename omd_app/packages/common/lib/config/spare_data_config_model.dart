

class SpareDataConfigModel {
  String email;
  List<String> domains;
  String tg;
  String qr;
  String officialDomain;
  String brandDomain;
  String appName;
  List<BaseInfoModel> baseInfo;

  SpareDataConfigModel({
    this.email = '',
    this.domains = const [],
    this.tg = '',
    this.qr = '',
    this.officialDomain = '',
    this.brandDomain = '',
    this.appName = '',
    this.baseInfo = const [],
  });

  factory SpareDataConfigModel.fromJson(Map<String, dynamic> json) {
    return SpareDataConfigModel(
      email: json['Email'] ?? '',
      domains: List<String>.from(json['Domains'] ?? []),
      tg: json['TG'] ?? '',
      qr: json['QR'] ?? '',
      officialDomain: json['OfficialDomain'] ?? '',
      brandDomain: json['BrandDomain'] ?? '',
      appName: json['AppName'] ?? '',
      baseInfo: (json['BaseInfo'] as List? ?? [])
          .map((e) => BaseInfoModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Email': email,
      'Domains': domains,
      'TG': tg,
      'QR': qr,
      'OfficialDomain': officialDomain,
      'BrandDomain': brandDomain,
      'AppName': appName,
      'BaseInfo': baseInfo.map((e) => e.toJson()).toList(),
    };
  }
}

class BaseInfoModel {
  String a;
  String b;
  String c;
  String d;
  String e;
  String f;
  String g;
  String h;
  String i;
  String j;
  String k;
  String l;

  BaseInfoModel({
    this.a = '',
    this.b = '',
    this.c = '',
    this.d = '',
    this.e = '',
    this.f = '',
    this.g = '',
    this.h = '',
    this.i = '',
    this.j = '',
    this.k = '',
    this.l = '',
  });

  factory BaseInfoModel.fromJson(Map<String, dynamic> json) {
    return BaseInfoModel(
      a: json['a'] ?? '',
      b: json['b'] ?? '',
      c: json['c'] ?? '',
      d: json['d'] ?? '',
      e: json['e'] ?? '',
      f: json['f'] ?? '',
      g: json['g'] ?? '',
      h: json['h'] ?? '',
      i: json['i'] ?? '',
      j: json['j'] ?? '',
      k: json['k'] ?? '',
      l: json['l'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'a': a,
      'b': b,
      'c': c,
      'd': d,
      'e': e,
      'f': f,
      'g': g,
      'h': h,
      'i': i,
      'j': j,
      'k': k,
      'l': l,
    };
  }
}