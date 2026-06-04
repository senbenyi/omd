/// 菜单模块数据模型，与 [omd_api.openapi.yaml] 对齐。

class MenuCategoryModel {
  MenuCategoryModel({
    required this.id,
    required this.name,
    required this.sort,
    required this.itemCount,
  });

  factory MenuCategoryModel.fromJson(Map<String, dynamic> json) {
    return MenuCategoryModel(
      id: _parseInt(json['id']),
      name: json['name'] as String? ?? '',
      sort: _parseInt(json['sort']),
      itemCount: _parseInt(json['itemCount']),
    );
  }

  final int id;
  final String name;
  final int sort;
  final int itemCount;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sort': sort,
      'itemCount': itemCount,
    };
  }
}

class MenuItemListModel {
  MenuItemListModel({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.name,
    required this.price,
    required this.status,
    this.soldOut = false,
    this.tags = const [],
    this.createdAt = '',
  });

  factory MenuItemListModel.fromJson(Map<String, dynamic> json) {
    final rawTags = json['tags'];
    final tags = <String>[];
    if (rawTags is List) {
      for (final tag in rawTags) {
        final value = tag?.toString() ?? '';
        if (value.isNotEmpty) tags.add(value);
      }
    }
    return MenuItemListModel(
      id: _parseInt(json['id']),
      categoryId: _parseInt(json['categoryId']),
      categoryName: json['categoryName'] as String? ?? '',
      name: json['name'] as String? ?? '',
      price: _parseInt(json['price']),
      status: json['status'] as String? ?? 'off_sale',
      soldOut: json['soldOut'] == true,
      tags: tags,
      createdAt: json['createdAt'] as String? ?? '',
    );
  }

  final int id;
  final int categoryId;
  final String categoryName;
  final String name;
  final int price;
  final String status;
  final bool soldOut;
  final List<String> tags;
  final String createdAt;

  bool get isOnSale => status == 'on_sale';
  bool get isOffShelf => status == 'off_sale';
  String get tagsLabel => tags.join('，');
}

class MenuItemDetailModel {
  MenuItemDetailModel({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.name,
    required this.price,
    required this.status,
    this.description = '',
    this.imageUrl,
    this.durationMinutes = 0,
    this.minQty = 1,
    this.remark = '',
    this.remarkTags = const {},
    this.tags = const [],
    this.soldOut = false,
  });

  factory MenuItemDetailModel.fromJson(Map<String, dynamic> json) {
    final rawTags = json['tags'];
    final tags = <String>[];
    if (rawTags is List) {
      for (final tag in rawTags) {
        final value = tag?.toString() ?? '';
        if (value.isNotEmpty) tags.add(value);
      }
    }
    return MenuItemDetailModel(
      id: _parseInt(json['id']),
      categoryId: _parseInt(json['categoryId']),
      categoryName: json['categoryName'] as String? ?? '',
      name: json['name'] as String? ?? '',
      price: _parseInt(json['price']),
      status: json['status'] as String? ?? 'off_sale',
      description: json['description'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      durationMinutes: _parseInt(json['durationMinutes']),
      minQty: _parseInt(json['minQty']) > 0 ? _parseInt(json['minQty']) : 1,
      remark: json['remark'] as String? ?? '',
      remarkTags: parseRemarkTags(json['remarkTags']),
      tags: tags,
      soldOut: json['soldOut'] == true,
    );
  }

  final int id;
  final int categoryId;
  final String categoryName;
  final String name;
  final int price;
  final String status;
  final String description;
  final String? imageUrl;
  final int durationMinutes;
  final int minQty;
  final String remark;
  final Map<String, List<String>> remarkTags;
  final List<String> tags;
  final bool soldOut;

  bool get isOnSale => status == 'on_sale';
  bool get isOffShelf => status == 'off_sale';
}

class MenuTagGroupModel {
  MenuTagGroupModel({
    required this.id,
    required this.name,
    required this.tastes,
  });

  factory MenuTagGroupModel.fromJson(Map<String, dynamic> json) {
    final rawTastes = json['tastes'];
    final tastes = <MenuTagOptionModel>[];
    if (rawTastes is List) {
      for (final item in rawTastes) {
        if (item is Map) {
          tastes.add(MenuTagOptionModel.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }
    return MenuTagGroupModel(
      id: _parseInt(json['id']),
      name: json['name'] as String? ?? '',
      tastes: tastes,
    );
  }

  final int id;
  final String name;
  final List<MenuTagOptionModel> tastes;
}

class MenuTagOptionModel {
  MenuTagOptionModel({required this.id, required this.value});

  factory MenuTagOptionModel.fromJson(Map<String, dynamic> json) {
    return MenuTagOptionModel(
      id: _parseInt(json['id']),
      value: json['value'] as String? ?? '',
    );
  }

  final int id;
  final String value;
}

class SaveMenuItemRequest {
  SaveMenuItemRequest({
    this.id,
    required this.categoryId,
    required this.name,
    this.imageUrl,
    this.durationMinutes,
    this.minQty = 1,
    this.description,
    this.remark,
    this.remarkTags,
    this.tags,
    this.soldOut = false,
    this.status,
    this.price,
  });

  final int? id;
  final int categoryId;
  final String name;
  final String? imageUrl;
  final int? durationMinutes;
  final int minQty;
  final String? description;
  final String? remark;
  final Map<String, List<String>>? remarkTags;
  final List<String>? tags;
  final bool soldOut;
  final String? status;
  final int? price;

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'categoryId': categoryId,
      'name': name,
      if (imageUrl != null && imageUrl!.isNotEmpty) 'imageUrl': imageUrl,
      if (durationMinutes != null) 'durationMinutes': durationMinutes,
      'minQty': minQty,
      if (description != null && description!.isNotEmpty) 'description': description,
      if (remark != null && remark!.isNotEmpty) 'remark': remark,
      if (remarkTags != null && remarkTags!.isNotEmpty) 'remarkTags': remarkTags,
      if (tags != null && tags!.isNotEmpty) 'tags': tags,
      'soldOut': soldOut,
      if (status != null && status!.isNotEmpty) 'status': status,
      'price': price ?? 0,
    };
  }
}

class UpdateMenuItemStatusRequest {
  UpdateMenuItemStatusRequest({
    required this.itemId,
    required this.status,
  });

  final int itemId;
  final String status;

  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'status': status,
    };
  }
}

class UpdateMenuItemSoldOutRequest {
  UpdateMenuItemSoldOutRequest({
    required this.itemId,
    required this.soldOut,
  });

  final int itemId;
  final bool soldOut;

  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'soldOut': soldOut,
    };
  }
}

Map<String, List<String>> parseRemarkTags(dynamic value) {
  if (value is! Map) return {};
  final result = <String, List<String>>{};
  value.forEach((key, raw) {
    final group = key.toString();
    if (group.isEmpty) return;
    if (raw is List) {
      final items =
          raw.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
      if (items.isNotEmpty) {
        result[group] = items;
      }
    }
  });
  return result;
}

class MenuPagedList<T> {
  MenuPagedList({required this.list, required this.page, required this.pageSize, required this.total});

  final List<T> list;
  final int page;
  final int pageSize;
  final int total;
}

class SaveMenuCategoryRequest {
  SaveMenuCategoryRequest({this.id, required this.name, this.sort});

  final int? id;
  final String name;
  final int? sort;

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      if (sort != null) 'sort': sort,
    };
  }
}

class MenuComboModel {
  MenuComboModel({
    required this.id,
    required this.name,
    required this.sort,
    required this.price,
    required this.itemCount,
  });

  factory MenuComboModel.fromJson(Map<String, dynamic> json) {
    return MenuComboModel(
      id: _parseInt(json['id']),
      name: json['name'] as String? ?? '',
      sort: _parseInt(json['sort']),
      price: _parseInt(json['price']),
      itemCount: _parseInt(json['itemCount']),
    );
  }

  final int id;
  final String name;
  final int sort;
  final int price;
  final int itemCount;
}

class MenuComboItemModel {
  MenuComboItemModel({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.name,
    required this.price,
    required this.status,
    this.qty = 1,
  });

  factory MenuComboItemModel.fromJson(Map<String, dynamic> json) {
    return MenuComboItemModel(
      id: _parseInt(json['id']),
      categoryId: _parseInt(json['categoryId']),
      categoryName: json['categoryName'] as String? ?? '',
      name: json['name'] as String? ?? '',
      price: _parseInt(json['price']),
      status: json['status'] as String? ?? 'off_sale',
      qty: _parseInt(json['qty']) > 0 ? _parseInt(json['qty']) : 1,
    );
  }

  final int id;
  final int categoryId;
  final String categoryName;
  final String name;
  final int price;
  final String status;
  final int qty;

  bool get isOnSale => status == 'on_sale';
}

class MenuComboDetailModel {
  MenuComboDetailModel({
    required this.id,
    required this.name,
    required this.price,
    required this.items,
  });

  factory MenuComboDetailModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final items = <MenuComboItemModel>[];
    if (rawItems is List) {
      for (final item in rawItems) {
        if (item is Map) {
          items.add(MenuComboItemModel.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }
    return MenuComboDetailModel(
      id: _parseInt(json['id']),
      name: json['name'] as String? ?? '',
      price: _parseInt(json['price']),
      items: items,
    );
  }

  final int id;
  final String name;
  final int price;
  final List<MenuComboItemModel> items;
}

class SaveMenuComboItemEntry {
  SaveMenuComboItemEntry({required this.itemId, this.qty = 1});

  final int itemId;
  final int qty;

  Map<String, dynamic> toJson() => {
    'itemId': itemId,
    'qty': qty,
  };
}

class SaveMenuComboContentRequest {
  SaveMenuComboContentRequest({
    required this.price,
    this.items = const [],
  });

  final int price;
  final List<SaveMenuComboItemEntry> items;

  Map<String, dynamic> toJson() => {
    'price': price,
    'items': items.map((e) => e.toJson()).toList(),
  };
}

class SaveMenuComboRequest {
  SaveMenuComboRequest({
    this.id,
    required this.name,
    this.price = 0,
    this.items = const [],
  });

  final int? id;
  final String name;
  final int price;
  final List<SaveMenuComboItemEntry> items;

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'name': name,
    'price': price,
    'items': items.map((e) => e.toJson()).toList(),
  };
}

/// 左侧选中项类型：分类、套餐、已售罄或已下架。
enum MenuSidebarKind { category, combo, soldOut, offShelf }

int _parseInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}
