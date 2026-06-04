import 'package:flutter/foundation.dart';

abstract class NineImageSubscription {
  late String imageUrl;
  late String uniqueKey;
  void listenDataChange(Uint8List data);
  void addListener(NineImageSubscription subscription);
  void removeSubscription();
}
