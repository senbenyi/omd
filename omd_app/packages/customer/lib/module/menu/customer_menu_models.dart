import 'package:customer/common/customer_json_utils.dart';

class CustomerMenuItemModel {
  CustomerMenuItemModel({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.name,
    required this.price,
    this.tags = const [],
  });

  factory CustomerMenuItemModel.fromJson(Map<String, dynamic> json) {
    final rawTags = json['tags'];
    final tags = <String>[];
    if (rawTags is List) {
      for (final tag in rawTags) {
        final value = tag?.toString() ?? '';
        if (value.isNotEmpty) tags.add(value);
      }
    }
    return CustomerMenuItemModel(
      id: customerParseInt(json['id']),
      categoryId: customerParseInt(json['categoryId']),
      categoryName: json['categoryName'] as String? ?? '',
      name: json['name'] as String? ?? '',
      price: customerParseInt(json['price']),
      tags: tags,
    );
  }

  final int id;
  final int categoryId;
  final String categoryName;
  final String name;
  final int price;
  final List<String> tags;
}

class CustomerCategoryModel {
  CustomerCategoryModel({
    required this.id,
    required this.name,
    required this.sort,
    required this.itemCount,
  });

  factory CustomerCategoryModel.fromJson(Map<String, dynamic> json) {
    return CustomerCategoryModel(
      id: customerParseInt(json['id']),
      name: json['name'] as String? ?? '',
      sort: customerParseInt(json['sort']),
      itemCount: customerParseInt(json['itemCount']),
    );
  }

  final int id;
  final String name;
  final int sort;
  final int itemCount;
}

class CustomerComboModel {
  CustomerComboModel({
    required this.id,
    required this.name,
    required this.price,
    required this.itemCount,
  });

  factory CustomerComboModel.fromJson(Map<String, dynamic> json) {
    return CustomerComboModel(
      id: customerParseInt(json['id']),
      name: json['name'] as String? ?? '',
      price: customerParseInt(json['price']),
      itemCount: customerParseInt(json['itemCount']),
    );
  }

  final int id;
  final String name;
  final int price;
  final int itemCount;
}

class CustomerOrderLineModel {
  CustomerOrderLineModel({
    required this.type,
    required this.id,
    required this.name,
    required this.unitPrice,
    required this.qty,
    required this.subtotal,
  });

  factory CustomerOrderLineModel.fromJson(Map<String, dynamic> json) {
    return CustomerOrderLineModel(
      type: json['type'] as String? ?? 'item',
      id: customerParseInt(json['id']),
      name: json['name'] as String? ?? '',
      unitPrice: customerParseInt(json['unitPrice']),
      qty: customerParseInt(json['qty'], def: 1),
      subtotal: customerParseInt(json['subtotal']),
    );
  }

  final String type;
  final int id;
  final String name;
  final int unitPrice;
  final int qty;
  final int subtotal;
}

class CustomerOrderResultModel {
  CustomerOrderResultModel({
    required this.orderId,
    required this.storeId,
    required this.tableNumber,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    required this.items,
  });

  factory CustomerOrderResultModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final items = <CustomerOrderLineModel>[];
    if (rawItems is List) {
      for (final item in rawItems) {
        if (item is Map) {
          items.add(CustomerOrderLineModel.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }
    return CustomerOrderResultModel(
      orderId: customerParseInt(json['orderId']),
      storeId: customerParseInt(json['storeId']),
      tableNumber: customerParseInt(json['tableNumber'], def: 1),
      totalAmount: customerParseInt(json['totalAmount']),
      status: json['status'] as String? ?? 'pending',
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String?,
      items: items,
    );
  }

  final int orderId;
  final int storeId;
  final int tableNumber;
  final int totalAmount;
  final String status;
  final String createdAt;
  final String? updatedAt;
  final List<CustomerOrderLineModel> items;
}
