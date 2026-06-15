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
      id: _parseInt(json['id']),
      categoryId: _parseInt(json['categoryId']),
      categoryName: json['categoryName'] as String? ?? '',
      name: json['name'] as String? ?? '',
      price: _parseInt(json['price']),
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

class CustomerComboModel {
  CustomerComboModel({
    required this.id,
    required this.name,
    required this.price,
    required this.itemCount,
  });

  factory CustomerComboModel.fromJson(Map<String, dynamic> json) {
    return CustomerComboModel(
      id: _parseInt(json['id']),
      name: json['name'] as String? ?? '',
      price: _parseInt(json['price']),
      itemCount: _parseInt(json['itemCount']),
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
      id: _parseInt(json['id']),
      name: json['name'] as String? ?? '',
      unitPrice: _parseInt(json['unitPrice']),
      qty: _parseInt(json['qty'], def: 1),
      subtotal: _parseInt(json['subtotal']),
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
    required this.tableNumber,
    required this.totalAmount,
    required this.status,
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
      orderId: _parseInt(json['orderId']),
      tableNumber: _parseInt(json['tableNumber'], def: 1),
      totalAmount: _parseInt(json['totalAmount']),
      status: json['status'] as String? ?? 'pending',
      items: items,
    );
  }

  final int orderId;
  final int tableNumber;
  final int totalAmount;
  final String status;
  final List<CustomerOrderLineModel> items;
}

int _parseInt(dynamic value, {int def = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? def;
  return def;
}
