/// 菜单价格格式化（单位：分）。
class MenuPriceUtils {
  MenuPriceUtils._();

  static String formatCents(int cents) {
    final yuan = cents / 100;
    if (cents % 100 == 0) {
      return '¥${yuan.toStringAsFixed(0)}';
    }
    return '¥${yuan.toStringAsFixed(2)}';
  }

  /// 将用户输入的元字符串转为分，无效时返回 null。
  static int? parseYuanToCents(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;
    final value = double.tryParse(trimmed);
    if (value == null || value < 0) return null;
    return (value * 100).round();
  }

  static String centsToYuanInput(int cents) {
    if (cents <= 0) return '';
    final yuan = cents / 100;
    if (cents % 100 == 0) {
      return yuan.toStringAsFixed(0);
    }
    return yuan.toStringAsFixed(2);
  }
}
