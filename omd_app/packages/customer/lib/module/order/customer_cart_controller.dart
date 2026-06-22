import 'package:get/get.dart';

class CustomerCartLine {
  CustomerCartLine({
    required this.type,
    required this.id,
    required this.name,
    required this.unitPrice,
    this.qty = 1,
  });

  final String type;
  final int id;
  final String name;
  final int unitPrice;
  int qty;

  String get key => '$type-$id';
  int get subtotal => unitPrice * qty;

  Map<String, dynamic> toOrderJson() {
    return {'type': type, 'id': id, 'qty': qty};
  }
}

class CustomerCartController extends GetxController {
  static CustomerCartController get to => Get.find<CustomerCartController>();

  final lines = <CustomerCartLine>[].obs;
  final revision = 0.obs;
  int? storeId;

  int get totalCents => lines.fold(0, (sum, line) => sum + line.subtotal);

  int get totalQty => lines.fold(0, (sum, line) => sum + line.qty);

  void _notifyChanged() {
    revision.value++;
  }

  void ensureStore(int newStoreId) {
    if (storeId == newStoreId) return;
    if (storeId != null && lines.isNotEmpty) {
      lines.clear();
    }
    storeId = newStoreId;
    _notifyChanged();
  }

  void _clearLinesOnly() {
    if (lines.isEmpty) return;
    lines.clear();
    _notifyChanged();
  }

  void addMenuItem({required int id, required String name, required int price}) {
    if (storeId == null) return;
    _addLine(type: 'item', id: id, name: name, unitPrice: price);
  }

  void addCombo({required int id, required String name, required int price}) {
    if (storeId == null) return;
    _addLine(type: 'combo', id: id, name: name, unitPrice: price);
  }

  void _addLine({
    required String type,
    required int id,
    required String name,
    required int unitPrice,
  }) {
    final key = '$type-$id';
    final index = lines.indexWhere((line) => line.key == key);
    if (index >= 0) {
      lines[index].qty += 1;
      _notifyChanged();
      return;
    }
    lines.add(
      CustomerCartLine(
        type: type,
        id: id,
        name: name,
        unitPrice: unitPrice,
      ),
    );
    _notifyChanged();
  }

  void increaseQty(String key) {
    final index = lines.indexWhere((line) => line.key == key);
    if (index < 0) return;
    lines[index].qty += 1;
    _notifyChanged();
  }

  void decreaseQty(String key) {
    final index = lines.indexWhere((line) => line.key == key);
    if (index < 0) return;
    if (lines[index].qty <= 1) {
      lines.removeAt(index);
      _notifyChanged();
      return;
    }
    lines[index].qty -= 1;
    _notifyChanged();
  }

  void clearLines() {
    _clearLinesOnly();
  }

  int qtyOf({required String type, required int id}) {
    final key = '$type-$id';
    for (final line in lines) {
      if (line.key == key) return line.qty;
    }
    return 0;
  }

  List<Map<String, dynamic>> toOrderItems() {
    return lines.map((line) => line.toOrderJson()).toList();
  }
}
