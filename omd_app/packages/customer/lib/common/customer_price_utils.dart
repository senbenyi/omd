/// 价格格式化（单位：分）。
abstract final class CustomerPriceUtils {
  static String formatCents(int cents) {
    final yuan = cents / 100;
    if (cents % 100 == 0) {
      return '¥${yuan.toStringAsFixed(0)}';
    }
    return '¥${yuan.toStringAsFixed(2)}';
  }
}
