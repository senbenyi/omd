import 'package:common/commonui/bottom_area.dart';
import 'package:flutter/material.dart';

class GoTabGuidePage extends StatelessWidget {
  const GoTabGuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const BoottomBarAreaWrap(
      child: Text(
        "老板发财",
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}
