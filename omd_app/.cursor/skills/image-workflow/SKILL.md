---
name: image-workflow
description: Documents the Flutter image asset flattening workflow and when to reuse it. Use when the user mentions image asset reorganization, asset path updates, or flattening assets/images.
---

# Image Asset Workflow 指南

## When to Use
- User requests guidance on flattening `assets/images/` or relocating image files.
- Asset path references need to be centralized into module-specific asset classes.
- Preparing documentation or repeating the same process on another branch.

## 工程前准备（中文步骤）
1. **确认目标目录**：核实当前项目是否使用 `assets/images/` 作为图片根目录，并记录所有子目录与文件。
2. **评估重名风险**：按文件名列出潜在冲突，决定是否需要重命名或加前缀。
3. **核对资产类**：确认各模块是否存在对应的 `Base*Asset`/实现类，缺失时提前规划新增文件。

## 扁平化处理流程（中文步骤）
1. **列出目录结构**：通过 `find` 或已有文档，获取 `assets/images/**` 下所有文件清单。
2. **执行文件迁移**：将每个子目录中的文件移动到根目录 `assets/images/`，保持文件名唯一。
3. **清理空目录**：确认所有文件已迁出后，删除对应的空子目录。
4. **更新配置**：将 `pubspec.yaml` 中的多条 `assets/images/...` 声明合并为单条 `assets/images/`。

## 批量更新代码引用（中文步骤）
1. **定位硬编码路径**：使用 `rg "assets/images/"` 搜索仍包含旧子目录路径的 Dart 文件。
2. **归属模块资产**：按模块（例如 Mine、Community、Comic、AppVersion）将图片常量写入对应实现类。
3. **替换调用方式**：将页面中的 `Image.asset` / `AssetImage` 等调用改为 `moduleAsset.xxx` Getter。
4. **新增或扩展资产类**：若模块未定义需要的 Getter，则同时更新 `Base*Asset` 与实现类。

## 后置检查（中文步骤）
1. **正则确认**：执行 `rg "assets/images/(common|home|video|versionPage|cartoon)/"`，确认旧路径已被清除。
2. **目录核对**：检查 `assets/images/` 是否仅保留扁平化后的文件，并验证无遗漏或意外新增。
3. **运行验证**：视需求执行 `flutter analyze` 或实际打开相关页面，确认资源加载正常。

## Documentation Expectations
- Maintain `lib/z_cursor/image.md` as the canonical reference for this workflow.
- When replicating across branches, capture any renamed files or channel-specific overrides.

## Example Usage
1. Locate hardcoded paths in community screens → add getters to `CommunityAssets`.
2. Introduce `AppVersionModule` asset binding → update `VersionUIOne/Two` to use getters.
3. Update mine widget icons → route through `MineAssets.copyRightIcon`.
