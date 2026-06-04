import 'package:get/get.dart';

final class CustomerCommonI18n {
  const CustomerCommonI18n._();

  static const tabHome = 'customerTabHome';
  static const tabMenu = 'customerTabMenu';
  static const tabMine = 'customerTabMine';
  static const homeDescription = 'customerHomeDescription';
  static const menuDescription = 'customerMenuDescription';
  static const mineDescription = 'customerMineDescription';
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
  CustomerCommonI18n.tabHome: '首页',
  CustomerCommonI18n.tabMenu: '菜单',
  CustomerCommonI18n.tabMine: '我的',
  CustomerCommonI18n.homeDescription: '浏览店铺与推荐内容',
  CustomerCommonI18n.menuDescription: '点餐与菜单浏览',
  CustomerCommonI18n.mineDescription: '订单与个人中心',
};

const customerCommonZhTW = {
  CustomerCommonI18n.tabHome: '首頁',
  CustomerCommonI18n.tabMenu: '菜單',
  CustomerCommonI18n.tabMine: '我的',
  CustomerCommonI18n.homeDescription: '瀏覽店鋪與推薦內容',
  CustomerCommonI18n.menuDescription: '點餐與菜單瀏覽',
  CustomerCommonI18n.mineDescription: '訂單與個人中心',
};

const customerCommonEnUS = {
  CustomerCommonI18n.tabHome: 'Home',
  CustomerCommonI18n.tabMenu: 'Menu',
  CustomerCommonI18n.tabMine: 'Mine',
  CustomerCommonI18n.homeDescription: 'Browse stores and recommendations',
  CustomerCommonI18n.menuDescription: 'Order and browse menus',
  CustomerCommonI18n.mineDescription: 'Orders and account',
};
