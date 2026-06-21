import 'package:customer/common/customer_json_utils.dart';

class CustomerStoreModel {
  CustomerStoreModel({
    required this.id,
    required this.name,
    required this.status,
    required this.address,
  });

  factory CustomerStoreModel.fromJson(Map<String, dynamic> json) {
    return CustomerStoreModel(
      id: customerParseInt(json['id']),
      name: json['name'] as String? ?? '',
      status: json['status'] as String? ?? 'rest',
      address: json['address'] as String? ?? '',
    );
  }

  final int id;
  final String name;
  final String status;
  final String address;

  bool get isOpen => status == 'open';
}
