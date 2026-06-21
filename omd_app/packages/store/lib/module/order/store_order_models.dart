class StoreOrderLineModel {
  StoreOrderLineModel({
    required this.type,
    required this.id,
    required this.name,
    required this.unitPrice,
    required this.qty,
    required this.subtotal,
  });

  factory StoreOrderLineModel.fromJson(Map<String, dynamic> json) {
    return StoreOrderLineModel(
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

class StoreOrderModel {
  StoreOrderModel({
    required this.orderId,
    required this.storeId,
    required this.tableNumber,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    required this.items,
  });

  factory StoreOrderModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final items = <StoreOrderLineModel>[];
    if (rawItems is List) {
      for (final item in rawItems) {
        if (item is Map) {
          items.add(StoreOrderLineModel.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }
    return StoreOrderModel(
      orderId: _parseInt(json['orderId']),
      storeId: _parseInt(json['storeId']),
      tableNumber: _parseInt(json['tableNumber'], def: 1),
      totalAmount: _parseInt(json['totalAmount']),
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
  final List<StoreOrderLineModel> items;

  bool get isPending => status == 'pending';
  bool get isSettled => status == 'settled';
}

class StoreOrderListItemModel {
  StoreOrderListItemModel({
    required this.orderId,
    required this.tableNumber,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    required this.itemCount,
  });

  factory StoreOrderListItemModel.fromJson(Map<String, dynamic> json) {
    return StoreOrderListItemModel(
      orderId: _parseInt(json['orderId']),
      tableNumber: _parseInt(json['tableNumber'], def: 1),
      totalAmount: _parseInt(json['totalAmount']),
      status: json['status'] as String? ?? 'pending',
      createdAt: json['createdAt'] as String? ?? '',
      itemCount: _parseInt(json['itemCount']),
    );
  }

  final int orderId;
  final int tableNumber;
  final int totalAmount;
  final String status;
  final String createdAt;
  final int itemCount;

  bool get isPending => status == 'pending';
  bool get isSettled => status == 'settled';
}

class StoreOrderPageModel {
  StoreOrderPageModel({required this.list, required this.total});

  final List<StoreOrderListItemModel> list;
  final int total;
}

int _parseInt(dynamic value, {int def = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? def;
  return def;
}
