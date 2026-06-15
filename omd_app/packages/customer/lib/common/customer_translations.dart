import 'package:get/get.dart';

final class CustomerCommonI18n {
  const CustomerCommonI18n._();

  static const tabMenu = 'customerTabMenu';
  static const tabCombo = 'customerTabCombo';
  static const tabOrder = 'customerTabOrder';
  static const emptyMenu = 'customerEmptyMenu';
  static const emptyCombo = 'customerEmptyCombo';
  static const emptyOrder = 'customerEmptyOrder';
  static const goOrder = 'customerGoOrder';
  static const retry = 'customerRetry';
  static const totalLabel = 'customerTotalLabel';
  static const checkout = 'customerCheckout';
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
  CustomerCommonI18n.tabMenu: '菜单',
  CustomerCommonI18n.tabCombo: '套餐',
  CustomerCommonI18n.tabOrder: '订单',
  CustomerCommonI18n.emptyMenu: '暂无菜品',
  CustomerCommonI18n.emptyCombo: '暂无套餐',
  CustomerCommonI18n.emptyOrder: '还没有选择菜品',
  CustomerCommonI18n.goOrder: '去点餐',
  CustomerCommonI18n.retry: '重试',
  CustomerCommonI18n.totalLabel: '合计',
  CustomerCommonI18n.checkout: '结算',
  CustomerCommonI18n.submitting: '提交中...',
  CustomerCommonI18n.itemTag: '菜品',
  CustomerCommonI18n.comboTag: '套餐',
};

const customerCommonZhTW = {
  CustomerCommonI18n.tabMenu: '菜單',
  CustomerCommonI18n.tabCombo: '套餐',
  CustomerCommonI18n.tabOrder: '訂單',
  CustomerCommonI18n.emptyMenu: '暫無菜品',
  CustomerCommonI18n.emptyCombo: '暫無套餐',
  CustomerCommonI18n.emptyOrder: '還沒有選擇菜品',
  CustomerCommonI18n.goOrder: '去點餐',
  CustomerCommonI18n.retry: '重試',
  CustomerCommonI18n.totalLabel: '合計',
  CustomerCommonI18n.checkout: '結算',
  CustomerCommonI18n.submitting: '提交中...',
  CustomerCommonI18n.itemTag: '菜品',
  CustomerCommonI18n.comboTag: '套餐',
};

const customerCommonEnUS = {
  CustomerCommonI18n.tabMenu: 'Menu',
  CustomerCommonI18n.tabCombo: 'Combos',
  CustomerCommonI18n.tabOrder: 'Order',
  CustomerCommonI18n.emptyMenu: 'No dishes yet',
  CustomerCommonI18n.emptyCombo: 'No combos yet',
  CustomerCommonI18n.emptyOrder: 'Your order is empty',
  CustomerCommonI18n.goOrder: 'Browse menu',
  CustomerCommonI18n.retry: 'Retry',
  CustomerCommonI18n.totalLabel: 'Total',
  CustomerCommonI18n.checkout: 'Checkout',
  CustomerCommonI18n.submitting: 'Submitting...',
  CustomerCommonI18n.itemTag: 'Dish',
  CustomerCommonI18n.comboTag: 'Combo',
};
