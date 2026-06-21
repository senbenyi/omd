import 'package:get/get.dart';

final class CustomerCommonI18n {
  const CustomerCommonI18n._();

  static const tabStore = 'customerTabStore';
  static const tabCombo = 'customerTabCombo';
  static const emptyMenu = 'customerEmptyMenu';
  static const emptyCombo = 'customerEmptyCombo';
  static const emptyOrder = 'customerEmptyOrder';
  static const emptyStores = 'customerEmptyStores';
  static const storeRestHint = 'customerStoreRestHint';
  static const storeStatusOpen = 'customerStoreStatusOpen';
  static const storeStatusRest = 'customerStoreStatusRest';
  static const retry = 'customerRetry';
  static const totalLabel = 'customerTotalLabel';
  static const selectedItems = 'customerSelectedItems';
  static const committedDishes = 'customerCommittedDishes';
  static const pendingDishes = 'customerPendingDishes';
  static const submitOrder = 'customerSubmitOrder';
  static const appendOrder = 'customerAppendOrder';
  static const orderDetail = 'customerOrderDetail';
  static const selectStore = 'customerSelectStore';
  static const committedOrderTitle = 'customerCommittedOrderTitle';
  static const pendingCartTitle = 'customerPendingCartTitle';
  static const submitting = 'customerSubmitting';
  static const itemTag = 'customerItemTag';
  static const comboTag = 'customerComboTag';
}

class CustomerTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'zh_CN': customerCommonZhCN,
    'zh_TW': customerCommonZhTW,
    'en_US': customerCommonEnUS,
  };
}

const customerCommonZhCN = {
  CustomerCommonI18n.tabStore: '店铺',
  CustomerCommonI18n.tabCombo: '套餐',
  CustomerCommonI18n.emptyMenu: '暂无菜品',
  CustomerCommonI18n.emptyCombo: '暂无套餐',
  CustomerCommonI18n.emptyOrder: '还没有选择菜品',
  CustomerCommonI18n.emptyStores: '暂无店铺',
  CustomerCommonI18n.storeRestHint: '店铺休息中，可浏览菜单，暂不可下单',
  CustomerCommonI18n.storeStatusOpen: '营业中',
  CustomerCommonI18n.storeStatusRest: '休息中',
  CustomerCommonI18n.retry: '重试',
  CustomerCommonI18n.totalLabel: '合计',
  CustomerCommonI18n.selectedItems: '已选 @count 个菜品',
  CustomerCommonI18n.committedDishes: '已下单 @count 道菜',
  CustomerCommonI18n.pendingDishes: '等待下单 @count 道菜',
  CustomerCommonI18n.submitOrder: '提交订单',
  CustomerCommonI18n.appendOrder: '提交',
  CustomerCommonI18n.orderDetail: '详情',
  CustomerCommonI18n.selectStore: '选择店铺',
  CustomerCommonI18n.committedOrderTitle: '已下单',
  CustomerCommonI18n.pendingCartTitle: '待提交',
  CustomerCommonI18n.submitting: '提交中...',
  CustomerCommonI18n.itemTag: '菜品',
  CustomerCommonI18n.comboTag: '套餐',
};

const customerCommonZhTW = {
  CustomerCommonI18n.tabStore: '店鋪',
  CustomerCommonI18n.tabCombo: '套餐',
  CustomerCommonI18n.emptyMenu: '暫無菜品',
  CustomerCommonI18n.emptyCombo: '暫無套餐',
  CustomerCommonI18n.emptyOrder: '還沒有選擇菜品',
  CustomerCommonI18n.emptyStores: '暫無店鋪',
  CustomerCommonI18n.storeRestHint: '店鋪休息中，可瀏覽菜單，暫不可下單',
  CustomerCommonI18n.storeStatusOpen: '營業中',
  CustomerCommonI18n.storeStatusRest: '休息中',
  CustomerCommonI18n.retry: '重試',
  CustomerCommonI18n.totalLabel: '合計',
  CustomerCommonI18n.selectedItems: '已選 @count 個菜品',
  CustomerCommonI18n.committedDishes: '已下單 @count 道菜',
  CustomerCommonI18n.pendingDishes: '等待下單 @count 道菜',
  CustomerCommonI18n.submitOrder: '提交訂單',
  CustomerCommonI18n.appendOrder: '提交',
  CustomerCommonI18n.orderDetail: '詳情',
  CustomerCommonI18n.selectStore: '選擇店鋪',
  CustomerCommonI18n.committedOrderTitle: '已下單',
  CustomerCommonI18n.pendingCartTitle: '待提交',
  CustomerCommonI18n.submitting: '提交中...',
  CustomerCommonI18n.itemTag: '菜品',
  CustomerCommonI18n.comboTag: '套餐',
};

const customerCommonEnUS = {
  CustomerCommonI18n.tabStore: 'Stores',
  CustomerCommonI18n.tabCombo: 'Combos',
  CustomerCommonI18n.emptyMenu: 'No dishes yet',
  CustomerCommonI18n.emptyCombo: 'No combos yet',
  CustomerCommonI18n.emptyOrder: 'Your order is empty',
  CustomerCommonI18n.emptyStores: 'No stores yet',
  CustomerCommonI18n.storeRestHint: 'This store is closed. You can browse the menu but cannot order.',
  CustomerCommonI18n.storeStatusOpen: 'Open',
  CustomerCommonI18n.storeStatusRest: 'Closed',
  CustomerCommonI18n.retry: 'Retry',
  CustomerCommonI18n.totalLabel: 'Total',
  CustomerCommonI18n.selectedItems: '@count selected',
  CustomerCommonI18n.committedDishes: 'Ordered @count dishes',
  CustomerCommonI18n.pendingDishes: 'Pending @count dishes',
  CustomerCommonI18n.submitOrder: 'Submit order',
  CustomerCommonI18n.appendOrder: 'Submit',
  CustomerCommonI18n.orderDetail: 'Details',
  CustomerCommonI18n.selectStore: 'Select store',
  CustomerCommonI18n.committedOrderTitle: 'Submitted',
  CustomerCommonI18n.pendingCartTitle: 'Pending',
  CustomerCommonI18n.submitting: 'Submitting...',
  CustomerCommonI18n.itemTag: 'Dish',
  CustomerCommonI18n.comboTag: 'Combo',
};
