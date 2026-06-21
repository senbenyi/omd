import 'package:common/utils/SharedStorageUtil.dart';
import 'package:customer/common/customer_constants.dart';
import 'package:customer/module/store/customer_store_models.dart';

/// 本地持久化上次选中的店铺。
abstract final class CustomerStorePrefs {
  static const _keyStoreId = 'customer_selected_store_id';
  static const _keyStoreName = 'customer_selected_store_name';
  static const _keyStoreOpen = 'customer_selected_store_open';

  static void restore({
    required void Function(int id) setStoreId,
    required void Function(String name) setStoreName,
    required void Function(bool open) setStoreOpen,
  }) {
    if (!SharedStorageUtil.contains(_keyStoreId)) return;

    final id = SharedStorageUtil.getInt(_keyStoreId);
    if (id <= 0) return;

    setStoreId(id);
    setStoreName(
      SharedStorageUtil.getString(_keyStoreName, CustomerConstants.defaultStoreName),
    );
    // 营业状态以接口为准；本地缓存可能来自其它店铺或已过期。
    setStoreOpen(true);
  }

  static Future<void> save(CustomerStoreModel store) async {
    await SharedStorageUtil.setInt(_keyStoreId, store.id);
    await SharedStorageUtil.setString(_keyStoreName, store.name);
    await SharedStorageUtil.setBool(_keyStoreOpen, store.isOpen);
  }
}
