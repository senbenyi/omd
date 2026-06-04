import 'package:flutter/material.dart';
import 'package:customer/common/customer_translations.dart';
import 'package:customer/module/bottom_tab/customer_tab_placeholder.dart';

class CustomerTabMinePage extends StatelessWidget {
  const CustomerTabMinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomerTabPlaceholder(
      title: CustomerCommonI18n.tabMine,
      icon: Icons.person_rounded,
      description: CustomerCommonI18n.mineDescription,
    );
  }
}
