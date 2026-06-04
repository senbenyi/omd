import 'package:base/toast/nine_progress_hud.dart';
import 'package:base/toast/nine_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:store/module/a_color/store_colors.dart';
import 'package:store/module/menu/menu_api.dart';
import 'package:store/module/menu/menu_i18n.dart';
import 'package:store/module/menu/menu_models.dart';

/// 维度选择页返回结果。
class MenuDimensionPageResult {
  const MenuDimensionPageResult({required this.groups});

  final List<MenuTagGroupModel> groups;
}

class MenuDimensionPage extends StatefulWidget {
  const MenuDimensionPage({super.key, this.initialSelectedGroupIds = const {}});

  final Set<int> initialSelectedGroupIds;

  @override
  State<MenuDimensionPage> createState() => _MenuDimensionPageState();
}

class _MenuDimensionPageState extends State<MenuDimensionPage> {
  final _groups = <MenuTagGroupModel>[];
  final _selectedIds = <int>{};

  var _loading = true;

  @override
  void initState() {
    super.initState();
    _selectedIds.addAll(widget.initialSelectedGroupIds);
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    setState(() => _loading = true);
    try {
      final response = await MenuApi.listTagLibrary();
      if (!response.isSuccess) {
        showAppToast(
          response.message.isNotEmpty
              ? response.message
              : StoreMenuI18n.loadFailed.tr,
        );
        return;
      }
      if (mounted) {
        setState(() {
          _groups
            ..clear()
            ..addAll(response.data ?? []);
        });
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _toggleGroup(int groupId, bool selected) {
    setState(() {
      if (selected) {
        _selectedIds.add(groupId);
      } else {
        _selectedIds.remove(groupId);
      }
    });
  }

  Future<void> _addDimension() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(StoreMenuI18n.addTagGroup.tr),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: StoreMenuI18n.tagGroupHint.tr,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(StoreMenuI18n.cancel.tr),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text(StoreMenuI18n.confirm.tr),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;

    if (_groups.any((g) => g.name == name)) {
      showAppToast(StoreMenuI18n.tagGroupExists.tr);
      return;
    }

    NineProgressHud.showLoading();
    try {
      final response = await MenuApi.saveTagGroup(name);
      if (!response.isSuccess || response.data == null) {
        showAppToast(
          response.message.isNotEmpty
              ? response.message
              : StoreMenuI18n.loadFailed.tr,
        );
        return;
      }
      final group = response.data!;
      setState(() {
        _groups.add(group);
        _selectedIds.add(group.id);
      });
    } finally {
      NineProgressHud.dismiss();
    }
  }

  void _confirm() {
    final selected =
        _groups.where((g) => _selectedIds.contains(g.id)).toList(growable: false);
    Get.back(result: MenuDimensionPageResult(groups: selected));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StoreColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(StoreMenuI18n.dimensionPageTitle.tr),
        actions: [
          TextButton(onPressed: _confirm, child: Text(StoreMenuI18n.confirm.tr)),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
            child: Text(
              StoreMenuI18n.dimensionPageHint.tr,
              style: TextStyle(
                fontSize: 13.sp,
                color: StoreColors.secondaryText,
                height: 1.4,
              ),
            ),
          ),
          Expanded(
            child:
                _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _groups.isEmpty
                    ? Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32.w),
                        child: Text(
                          StoreMenuI18n.noTagGroups.tr,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: StoreColors.secondaryText,
                          ),
                        ),
                      ),
                    )
                    : ListView.separated(
                      padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
                      itemCount: _groups.length,
                      separatorBuilder: (_, __) => SizedBox(height: 10.h),
                      itemBuilder: (context, index) {
                        final group = _groups[index];
                        final selected = _selectedIds.contains(group.id);
                        return Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () => _toggleGroup(group.id, !selected),
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(8.w, 10.h, 12.w, 12.h),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Checkbox(
                                    value: selected,
                                    activeColor: StoreColors.tabSelected,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    visualDensity: VisualDensity.compact,
                                    onChanged:
                                        (value) => _toggleGroup(
                                          group.id,
                                          value ?? false,
                                        ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          group.name,
                                          style: TextStyle(
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.w600,
                                            color: StoreColors.primaryText,
                                          ),
                                        ),
                                        if (group.tastes.isNotEmpty) ...[
                                          SizedBox(height: 8.h),
                                          Wrap(
                                            spacing: 8.w,
                                            runSpacing: 8.h,
                                            children: [
                                              for (final option in group.tastes)
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 10.w,
                                                    vertical: 5.h,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: StoreColors
                                                        .tabSelected
                                                        .withValues(alpha: 0.08),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          6.r,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    option.value,
                                                    style: TextStyle(
                                                      fontSize: 12.sp,
                                                      color:
                                                          StoreColors
                                                              .primaryText,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
          ),
          Divider(height: 1.h, color: const Color(0xFFE4E7EC)),
          Material(
            color: Colors.white,
            child: InkWell(
              onTap: _addDimension,
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        StoreMenuI18n.addTagGroup.tr,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: StoreColors.tabSelected,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Icon(Icons.add, size: 20.sp, color: StoreColors.tabSelected),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
