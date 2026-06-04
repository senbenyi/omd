import 'dart:async';
import 'package:flutter/material.dart';

import '../download_center/nine_image_provider.dart';

class OverlayToast {
  static void show(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder:
          (_) => Positioned(
            bottom: 100,
            right: 40,
            width: 100,
            height: 60,
            child: OverlayExamplePage(),
          ),
    );
    overlay.insert(entry);
  }
}

class OverlayExamplePage extends StatefulWidget {
  const OverlayExamplePage({super.key});

  @override
  State<OverlayExamplePage> createState() => _OverlayExamplePageState();
}

class _OverlayExamplePageState extends State<OverlayExamplePage> {
  StreamSubscription? _loginSubscription;
  int all = 0;
  int finish = 0;
  int wait = 0;
  int proce = 0;

  @override
  void initState() {
    super.initState();
    // 监听 UserLoginEvent
    _loginSubscription = downEventBus.on<DownloadProgressModel>().listen((
      event,
    ) {
      // 这里可以更新UI
      setState(() {
        all = event.all;
        finish = event.finish;
        wait = event.waitCount;
        proce = event.processing;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _loginSubscription?.cancel();
    _loginSubscription = null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("正在：$proce/$wait", style: const TextStyle(color: Colors.white)),
          Text(" 累计：$finish/$all", style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
