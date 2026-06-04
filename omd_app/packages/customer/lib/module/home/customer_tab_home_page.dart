import 'package:flutter/material.dart';
import 'package:customer/common/customer_translations.dart';
import 'package:customer/module/bottom_tab/customer_tab_placeholder.dart';

class CustomerTabHomePage extends StatelessWidget {
  const CustomerTabHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomerTabPlaceholder(
      title: CustomerCommonI18n.tabHome,
      icon: Icons.home_rounded,
      description: CustomerCommonI18n.homeDescription,
    );
  }
}
