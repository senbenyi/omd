import 'package:base/log/nine_log.dart';
import 'package:base/toast/nine_toast.dart';
import 'package:get/get.dart';
import 'package:store/module/menu/menu_api.dart';
import 'package:store/module/menu/menu_i18n.dart';
import 'package:store/module/menu/menu_models.dart';

/// 套餐 Tab 独立状态与接口。
class MenuComboTabController extends GetxController {
  final combos = RxList<MenuComboModel>([]);
  final comboDetail = Rxn<MenuComboDetailModel>();
  final selectedComboId = RxnInt();

  final isLoadingSidebar = false.obs;
  final isLoadingDetail = false.obs;
  final isSavingCombo = false.obs;

  int? _boundStoreId;

  MenuComboModel? get selectedCombo {
    final id = selectedComboId.value;
    if (id == null) return null;
    for (final combo in combos) {
      if (combo.id == id) return combo;
    }
    return null;
  }

  int comboItemsTotalCents(MenuComboDetailModel? detail) {
    if (detail == null) return 0;
    var total = 0;
    for (final item in detail.items) {
      total += item.price * item.qty;
    }
    return total;
  }

  void reset() {
    combos.clear();
    comboDetail.value = null;
    selectedComboId.value = null;
    isLoadingSidebar.value = false;
    isLoadingDetail.value = false;
  }

  Future<void> ensureLoaded(int storeId) async {
    if (_boundStoreId != storeId) {
      _boundStoreId = storeId;
      reset();
    }
    if (combos.isEmpty && !isLoadingSidebar.value) {
      await loadCombos(storeId);
    } else if (selectedComboId.value != null) {
      await loadComboDetail(storeId: storeId, comboId: selectedComboId.value!);
    }
  }

  Future<void> loadCombos(int storeId) async {
    isLoadingSidebar.value = true;
    try {
      final response = await MenuApi.listCombos(storeId);
      if (!response.isSuccess) {
        showAppToast(
          response.message.isNotEmpty
              ? response.message
              : StoreMenuI18n.loadFailed.tr,
        );
        return;
      }

      final list = response.data ?? [];
      combos.assignAll(list);

      if (list.isEmpty) {
        selectedComboId.value = null;
        comboDetail.value = null;
        return;
      }

      final current = selectedComboId.value;
      if (current != null && list.any((c) => c.id == current)) {
        await loadComboDetail(storeId: storeId, comboId: current);
        return;
      }
      await selectCombo(storeId: storeId, comboId: list.first.id);
    } catch (e, stack) {
      NLog.e('套餐 Tab 加载套餐失败: $e\n$stack');
      showAppToast(StoreMenuI18n.loadFailed.tr);
    } finally {
      isLoadingSidebar.value = false;
    }
  }

  Future<void> selectCombo({
    required int storeId,
    required int comboId,
  }) async {
    selectedComboId.value = comboId;
    await loadComboDetail(storeId: storeId, comboId: comboId);
  }

  Future<void> loadComboDetail({
    required int storeId,
    required int comboId,
  }) async {
    isLoadingDetail.value = true;
    try {
      final response = await MenuApi.getComboDetail(storeId, comboId);
      if (!response.isSuccess) {
        showAppToast(
          response.message.isNotEmpty
              ? response.message
              : StoreMenuI18n.loadFailed.tr,
        );
        return;
      }
      comboDetail.value = response.data;
    } catch (e, stack) {
      NLog.e('套餐 Tab 加载详情失败: $e\n$stack');
      showAppToast(StoreMenuI18n.loadFailed.tr);
    } finally {
      isLoadingDetail.value = false;
    }
  }

  Future<void> reload(int storeId) async {
    final comboId = selectedComboId.value;
    if (comboId == null) {
      await loadCombos(storeId);
      return;
    }
    await loadCombos(storeId);
    if (combos.any((c) => c.id == comboId)) {
      await loadComboDetail(storeId: storeId, comboId: comboId);
    }
  }

  Future<bool> addCombo(int storeId, String name) async {
    isSavingCombo.value = true;
    try {
      final response = await MenuApi.saveCombo(
        storeId,
        SaveMenuComboRequest(name: name),
      );
      if (!response.isSuccess || response.data == null) {
        showAppToast(
          response.message.isNotEmpty
              ? response.message
              : StoreMenuI18n.loadFailed.tr,
        );
        return false;
      }

      showAppToast(StoreMenuI18n.saveSuccess.tr);
      await loadCombos(storeId);
      await selectCombo(storeId: storeId, comboId: response.data!.id);
      return true;
    } finally {
      isSavingCombo.value = false;
    }
  }
}
