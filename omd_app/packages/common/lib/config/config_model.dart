class ConfigModel {
  String? id;
  String? dealerId;
  String? pKey;
  String value1;
  String value2;
  String? value3;
  String? value4;
  String? value5;

  ConfigModel({
    this.id,
    this.dealerId,
    this.pKey,
    this.value1 = '',
    this.value2 = '',
    this.value3,
    this.value4,
    this.value5,
  });

  factory ConfigModel.fromJson(Map<String, dynamic> json) {
    return ConfigModel(
      id: json['id'] ?? '', // id
      dealerId: json['dealerId'] ?? '', // dealerId
      pKey: json['a'], // pKey
      value1: json['b'] ?? '', // value1
      value2: json['c'] ?? '', // value2
      value3: json['d'], // value3
      value4: json['e'], // value4
      value5: json['f'], // value5
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dealerId': dealerId,
      'a': pKey,
      'b': value1,
      'c': value2,
      'd': value3,
      'e': value4,
      'f': value5,
    };
  }
}

class TvSettingModel {
  List<String> a;
  List<String> b;
  List<String> c;
  String d;
  String e;
  String f;
  String g;

  TvSettingModel({
    this.a = const [],
    this.b = const [],
    this.c = const [],
    this.d = '',
    this.e = '',
    this.f = '',
    this.g = '',
  });

  factory TvSettingModel.fromJson(Map<String, dynamic> json) {
    return TvSettingModel(
      a: List<String>.from(json['a'] ?? []),
      b: List<String>.from(json['b'] ?? []),
      c: List<String>.from(json['c'] ?? []),
      d: json['d'] ?? '',
      e: json['e'] ?? '',
      f: json['f'] ?? '',
      g: json['g'] ?? '',
    );
  }

  /// toJson
  Map<String, dynamic> toJson() {
    return {
      'a': a,
      'b': b,
      'c': c,
      'd': d,
      'e': e,
      'f': f,
      'g': g,
    };
  }
}