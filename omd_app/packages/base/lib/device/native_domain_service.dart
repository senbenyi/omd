import 'package:base/log/nine_log.dart';
import 'package:flutter/services.dart';

/// 原生域名检测服务
/// 通过MethodChannel调用Android/iOS原生的域名检测功能
class NativeDomainService {
  static const MethodChannel _channel = MethodChannel('cc.mg91/domain');

  static final NativeDomainService _instance = NativeDomainService._internal();

  factory NativeDomainService() => _instance;

  NativeDomainService._internal();

  // 初始化Kiwi并获取domain
  static Future<String?> initKiwi({
    required String kiwiAppKey,
    required String kiwiRs,
  }) async {
    try {
      final String? domain = await _channel.invokeMethod<String>('initKiwi', {
        'kiwiAppKey': kiwiAppKey,
        'kiwiRs': kiwiRs,
      });
      NLog.d('✅ Kiwi domain: $domain');
      return domain;
    } catch (e) {
      NLog.d('❌ Kiwi 初始化失败: $e');
      return null;
    }
  }

  // 获取缓存的 domain
  static Future<String?> getKiwiDomain() async {
    try {
      final String? domain = await _channel.invokeMethod('getKiwiDomain');
      return domain;
    } catch (e) {
      NLog.d('❌ 获取 Kiwi domain 失败: $e');
      return null;
    }
  }

  /// 检测并获取可用的API域名
  static Future<String> resolveApiDomain() async {
    try {
      NLog.d("[MG91]", "🚀 调用原生域名检测服务...");

      final stopwatch = Stopwatch()..start();
      final domain =
          await _channel.invokeMethod<String>('resolveApiDomain') ?? "";
      stopwatch.stop();

      if (domain.isNotEmpty) {
        NLog.d(
          "[MG91]",
          "✅ 原生域名检测成功: $domain (耗时: ${stopwatch.elapsedMilliseconds}ms)",
        );
      } else {
        NLog.d("[MG91]", "❌ 原生域名检测失败 (耗时: ${stopwatch.elapsedMilliseconds}ms)");
      }

      return domain;
    } on PlatformException catch (e) {
      NLog.e("[MG91]", "❌ 原生域名检测平台异常: ${e.code} - ${e.message}");
      return "";
    } catch (e) {
      NLog.e("[MG91]", "❌ 原生域名检测异常: $e");
      return "";
    }
  }

  /// 清除缓存的域名
  static Future<bool> clearCachedDomain() async {
    try {
      NLog.d("[MG91]", "🗑️ 清除原生缓存的域名...");
      final result =
          await _channel.invokeMethod<bool>('clearCachedDomain') ?? false;

      if (result) {
        NLog.d("[MG91]", "✅ 原生缓存域名清除成功");
      } else {
        NLog.d("[MG91]", "❌ 原生缓存域名清除失败");
      }

      return result;
    } on PlatformException catch (e) {
      NLog.e("[MG91]", "❌ 清除原生缓存域名平台异常: ${e.code} - ${e.message}");
      return false;
    } catch (e) {
      NLog.e("[MG91]", "❌ 清除原生缓存域名异常: $e");
      return false;
    }
  }

  /// 强制刷新域名（清除缓存并重新检测）
  static Future<String> forceRefreshDomain() async {
    try {
      NLog.d("[MG91]", "🔄 强制刷新原生域名检测");

      final stopwatch = Stopwatch()..start();
      final domain =
          await _channel.invokeMethod<String>('forceRefreshDomain') ?? "";
      stopwatch.stop();

      if (domain.isNotEmpty) {
        NLog.d(
          "[MG91]",
          "✅ 原生域名强制刷新成功: $domain (耗时: ${stopwatch.elapsedMilliseconds}ms)",
        );
      } else {
        NLog.d(
          "[MG91]",
          "❌ 原生域名强制刷新失败 (耗时: ${stopwatch.elapsedMilliseconds}ms)",
        );
      }

      return domain;
    } on PlatformException catch (e) {
      NLog.e("[MG91]", "❌ 原生域名强制刷新平台异常: ${e.code} - ${e.message}");
      return "";
    } catch (e) {
      NLog.e("[MG91]", "❌ 原生域名强制刷新异常: $e");
      return "";
    }
  }

  /// 获取当前缓存的域名（不验证有效性）
  static Future<String> getCurrentCachedDomain() async {
    try {
      final domain =
          await _channel.invokeMethod<String>('getCurrentCachedDomain') ?? "";
      NLog.d("[MG91]", "📋 获取原生缓存域名: $domain");
      return domain;
    } on PlatformException catch (e) {
      NLog.e("[MG91]", "❌ 获取原生缓存域名平台异常: ${e.code} - ${e.message}");
      return "";
    } catch (e) {
      NLog.e("[MG91]", "❌ 获取原生缓存域名异常: $e");
      return "";
    }
  }

  /// 检查域名是否已缓存
  static Future<bool> hasCachedDomain() async {
    try {
      final hasCache =
          await _channel.invokeMethod<bool>('hasCachedDomain') ?? false;
      NLog.d("[MG91]", "🔍 检查原生缓存域名: $hasCache");
      return hasCache;
    } on PlatformException catch (e) {
      NLog.e("[MG91]", "❌ 检查原生缓存域名平台异常: ${e.code} - ${e.message}");
      return false;
    } catch (e) {
      NLog.e("[MG91]", "❌ 检查原生缓存域名异常: $e");
      return false;
    }
  }

  /// 检查原生域名检测服务是否可用
  static Future<bool> isNativeServiceAvailable() async {
    try {
      // 尝试调用一个简单的方法来检查服务是否可用
      await _channel.invokeMethod<String>('getCurrentCachedDomain');
      return true;
    } catch (e) {
      NLog.d("[MG91]", "原生域名检测服务不可用: $e");
      return false;
    }
  }

  static Future<bool> isHuawei() async {
    final bool result = await _channel.invokeMethod('isHuawei');
    return result;
  }
}
