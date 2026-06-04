import 'package:flutter/material.dart';
import 'package:customer/common/customer_translations.dart';
import 'package:customer/module/bottom_tab/customer_tab_placeholder.dart';

class CustomerTabMenuPage extends StatelessWidget {
  const CustomerTabMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomerTabPlaceholder(
      title: CustomerCommonI18n.tabMenu,
      icon: Icons.restaurant_menu_rounded,
      description: CustomerCommonI18n.menuDescription,
    );
  }
}
