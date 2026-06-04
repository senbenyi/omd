// tool/gen_assets.dart
import 'dart:io';

/// 自动生成 common_ui 插件中的 assets 静态变量。
/// 扫描 assets/public 目录下所有文件，生成 lib/gen/assets.dart。
//运行命令
// dart run tool/gen_assets.dart
// tool/gen_assets.dart
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;

/// 自动生成 common_ui 插件中的 assets 静态变量（驼峰命名，不含文件夹名）
/// 扫描 assets/public 目录下所有文件，生成 lib/gen/assets.dart。
void main() {
  const packageName = 'common_ui'; // ⚠️ 插件包名
  const assetsDir = 'assets/public';
  const outputFile = 'lib/generated/assets.dart';

  final dir = Directory(assetsDir);
  if (!dir.existsSync()) {
    stderr.writeln('❌ 错误: 未找到目录 $assetsDir');
    exit(1);
  }

  final buffer =
      StringBuffer()
        ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND')
        ..writeln('// ignore_for_file: constant_identifier_names')
        ..writeln()
        ..writeln('/// 自动生成的资源路径类，用于访问 assets 中的资源。')
        ..writeln('class CommonUiAssets {')
        ..writeln('  CommonUiAssets._();')
        ..writeln();

  final files =
      dir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => !f.path.endsWith('.DS_Store'))
          .toList();

  final usedNames = <String>{};

  for (var file in files) {
    final relativePath = file.path.replaceAll('\\', '/');

    // 取出文件名部分（不含文件夹）
    final baseName = p.basename(relativePath); // e.g. home_icon.png

    // 生成变量名（驼峰）
    var variableName = _toCamelCase(baseName);

    // 若存在重复文件名（不同文件夹），自动加序号后缀
    if (usedNames.contains(variableName)) {
      var i = 2;
      while (usedNames.contains('$variableName$i')) {
        i++;
      }
      variableName = '$variableName$i';
    }
    usedNames.add(variableName);

    final assetPath = 'packages/$packageName/$relativePath';
    buffer.writeln("  static const String $variableName = '$assetPath';");
  }

  buffer.writeln('}');

  final output = File(outputFile);
  output.createSync(recursive: true);
  output.writeAsStringSync(buffer.toString());

  print('✅ 已生成资源文件：$outputFile');
  print('共计 ${files.length} 个资源文件。');
}

/// 将文件名转为驼峰命名（home_icon.png → homeIconPng）
String _toCamelCase(String name) {
  name = name.split('.').join('_'); // 把扩展名分开一起处理
  name = name.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
  final parts = name.split('_').where((e) => e.isNotEmpty).toList();
  if (parts.isEmpty) return '';
  final first = parts.first.toLowerCase();
  final rest =
      parts
          .skip(1)
          .map((p) => p[0].toUpperCase() + p.substring(1).toLowerCase())
          .join();
  return first + rest;
}
