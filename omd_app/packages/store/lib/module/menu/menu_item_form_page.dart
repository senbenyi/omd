import 'dart:io';

import 'package:base/toast/nine_progress_hud.dart';
import 'package:base/toast/nine_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:store/module/a_color/store_colors.dart';
import 'package:store/module/menu/menu_api.dart';
import 'package:store/module/menu/menu_widgets.dart';
import 'package:store/module/menu/menu_i18n.dart';
import 'package:store/module/menu/menu_dimension_page.dart';
import 'package:store/module/menu/menu_models.dart';
import 'package:store/module/menu/menu_price_utils.dart';

class MenuItemFormPage extends StatefulWidget {
  const MenuItemFormPage({
    super.key,
    required this.storeId,
    required this.categoryId,
    required this.categoryName,
    this.itemId,
    this.itemName,
  });

  final int storeId;
  final int categoryId;
  final String categoryName;
  final int? itemId;
  final String? itemName;

  bool get isEditing => itemId != null && itemId! > 0;

  @override
  State<MenuItemFormPage> createState() => _MenuItemFormPageState();
}

class _MenuItemFormPageState extends State<MenuItemFormPage> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _minQtyController = TextEditingController(text: '1');
  final _durationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _remarkController = TextEditingController();
  final _customTagController = TextEditingController();

  final _groupOptions = <String, List<String>>{};
  final _groupIds = <String, int?>{};
  final _selectedTags = <String, Set<String>>{};

  static const _defaultProductTags = ['新品', '畅销', '推荐'];
  final _productTagOptions = <String>[..._defaultProductTags];
  final _selectedProductTags = <String>{};
  bool _soldOut = false;
  bool _offShelf = false;

  File? _localImage;
  String? _imageUrl;

  var _loading = false;
  int? _editCategoryId;

  static const _sectionGap = 10.0;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      _loading = true;
      _loadDetail();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _minQtyController.dispose();
    _durationController.dispose();
    _descriptionController.dispose();
    _remarkController.dispose();
    _customTagController.dispose();
    super.dispose();
  }

  Future<void> _openDimensionPage() async {
    final selectedIds = _groupIds.values.whereType<int>().toSet();
    final result = await Get.to<MenuDimensionPageResult>(
      () => MenuDimensionPage(initialSelectedGroupIds: selectedIds),
    );
    if (result == null) return;
    _applyDimensionSelection(result.groups);
  }

  void _applyDimensionSelection(List<MenuTagGroupModel> groups) {
    final keptTags = <String, Set<String>>{};
    for (final group in groups) {
      keptTags[group.name] = _selectedTags[group.name] ?? <String>{};
    }

    setState(() {
      _groupOptions.clear();
      _groupIds.clear();
      _selectedTags.clear();
      for (final group in groups) {
        _groupIds[group.name] = group.id;
        _groupOptions[group.name] = group.tastes
            .map((e) => e.value)
            .toList(growable: false);
        _selectedTags[group.name] = keptTags[group.name] ?? <String>{};
      }
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return;
    setState(() {
      _localImage = File(picked.path);
      _imageUrl = null;
    });
  }

  void _removeFlavorGroup(String groupName) {
    setState(() {
      _groupOptions.remove(groupName);
      _groupIds.remove(groupName);
      _selectedTags.remove(groupName);
    });
  }

  void _toggleTag(String groupName, String value) {
    setState(() {
      final selected = _selectedTags.putIfAbsent(groupName, () => {});
      if (selected.contains(value)) {
        selected.remove(value);
      } else {
        selected.add(value);
      }
    });
  }

  void _toggleProductTag(String tag) {
    setState(() {
      if (_selectedProductTags.contains(tag)) {
        _selectedProductTags.remove(tag);
      } else {
        _selectedProductTags.add(tag);
      }
    });
  }

  void _addCustomProductTag() {
    final tag = _customTagController.text.trim();
    if (tag.isEmpty) return;
    if (_productTagOptions.contains(tag)) {
      showAppToast(StoreMenuI18n.productTagExists.tr);
      _selectedProductTags.add(tag);
      _customTagController.clear();
      return;
    }
    setState(() {
      _productTagOptions.add(tag);
      _selectedProductTags.add(tag);
      _customTagController.clear();
    });
  }

  Future<void> _loadDetail() async {
    try {
      final response = await MenuApi.getItemDetail(
        storeId: widget.storeId,
        itemId: widget.itemId!,
      );
      if (!response.isSuccess || response.data == null) {
        showAppToast(
          response.message.isNotEmpty
              ? response.message
              : StoreMenuI18n.loadFailed.tr,
        );
        if (mounted) Get.back();
        return;
      }

      final libraryResponse = await MenuApi.listTagLibrary();
      final libraryGroups =
          libraryResponse.isSuccess
              ? libraryResponse.data ?? <MenuTagGroupModel>[]
              : <MenuTagGroupModel>[];

      if (!mounted) return;
      _applyDetail(response.data!, libraryGroups);
    } catch (_) {
      showAppToast(StoreMenuI18n.loadFailed.tr);
      if (mounted) Get.back();
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _applyDetail(
    MenuItemDetailModel detail,
    List<MenuTagGroupModel> libraryGroups,
  ) {
    _editCategoryId = detail.categoryId;
    _nameController.text = detail.name;
    _priceController.text = MenuPriceUtils.centsToYuanInput(detail.price);
    _minQtyController.text = '${detail.minQty}';
    if (detail.durationMinutes > 0) {
      _durationController.text = '${detail.durationMinutes}';
    }
    _descriptionController.text = detail.description;
    _remarkController.text = detail.remark;
    _imageUrl = detail.imageUrl;
    _soldOut = detail.soldOut;
    _offShelf = detail.isOffShelf;

    final productTags = <String>[..._defaultProductTags];
    for (final tag in detail.tags) {
      if (!productTags.contains(tag)) productTags.add(tag);
    }
    _productTagOptions
      ..clear()
      ..addAll(productTags);
    _selectedProductTags
      ..clear()
      ..addAll(detail.tags);

    _groupOptions.clear();
    _groupIds.clear();
    _selectedTags.clear();

    for (final group in libraryGroups) {
      final selected = detail.remarkTags[group.name];
      if (selected == null || selected.isEmpty) continue;
      _groupIds[group.name] = group.id;
      _groupOptions[group.name] = group.tastes
          .map((e) => e.value)
          .toList(growable: false);
      _selectedTags[group.name] = selected.toSet();
    }

    detail.remarkTags.forEach((groupName, values) {
      if (values.isEmpty || _groupOptions.containsKey(groupName)) return;
      _groupOptions[groupName] = List<String>.from(values);
      _selectedTags[groupName] = values.toSet();
    });

    setState(() {});
  }

  Map<String, List<String>> _buildRemarkTagsPayload() {
    final payload = <String, List<String>>{};
    _selectedTags.forEach((group, values) {
      if (values.isEmpty) return;
      payload[group] = values.toList()..sort();
    });
    return payload;
  }

  Future<void> _onSave() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      showAppToast(StoreMenuI18n.itemNameHint.tr);
      return;
    }

    final price = MenuPriceUtils.parseYuanToCents(_priceController.text);
    if (price == null) {
      showAppToast(StoreMenuI18n.itemPriceHint.tr);
      return;
    }

    final minQtyText = _minQtyController.text.trim();
    final minQty = minQtyText.isEmpty ? 1 : int.tryParse(minQtyText);
    if (minQty == null || minQty < 1) {
      showAppToast(StoreMenuI18n.minQtyInvalid.tr);
      return;
    }

    NineProgressHud.showLoading();
    try {
      var imageUrl = _imageUrl;
      if (_localImage != null) {
        final upload = await MenuApi.uploadImage(_localImage!.path);
        if (!upload.isSuccess || upload.data == null) {
          showAppToast(
            upload.message.isNotEmpty
                ? upload.message
                : StoreMenuI18n.uploadFailed.tr,
          );
          return;
        }
        imageUrl = upload.data;
      }

      final duration = int.tryParse(_durationController.text.trim());
      final categoryId = _editCategoryId ?? widget.categoryId;
      final request = SaveMenuItemRequest(
        id: widget.itemId,
        categoryId: categoryId,
        name: name,
        price: price,
        imageUrl: imageUrl,
        minQty: minQty,
        durationMinutes: duration,
        description: _descriptionController.text.trim(),
        remark: _remarkController.text.trim(),
        remarkTags: _buildRemarkTagsPayload(),
        tags: _selectedProductTags.toList()..sort(),
        soldOut: _soldOut,
        status: _offShelf ? 'off_sale' : 'on_sale',
      );

      final response = await MenuApi.saveItem(widget.storeId, request);
      if (!response.isSuccess) {
        showAppToast(
          response.message.isNotEmpty
              ? response.message
              : StoreMenuI18n.loadFailed.tr,
        );
        return;
      }

      showAppToast(StoreMenuI18n.saveSuccess.tr);
      Get.back(result: true);
    } finally {
      NineProgressHud.dismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    final editName =
        _nameController.text.trim().isNotEmpty
            ? _nameController.text.trim()
            : (widget.itemName ?? '');
    final pageTitle =
        widget.isEditing
            ? StoreMenuI18n.editItemTitle.trParams({'name': editName})
            : StoreMenuI18n.addItemTitle.trParams({
              'category': widget.categoryName,
            });

    return Scaffold(
      backgroundColor: StoreColors.scaffoldBackground,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: StoreColors.scaffoldBackground,
        centerTitle: true,
        title: Text(
          pageTitle,
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w600,
            color: StoreColors.primaryText,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child:
                _loading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView(
                      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 12.h),
                      children: [
                        _buildImagePicker(),
                        SizedBox(height: _sectionGap.h),
                        _buildMainInfoCard(),
                        SizedBox(height: _sectionGap.h),
                        _buildStatusCard(),
                        SizedBox(height: _sectionGap.h),
                        _buildProductTagsSection(),
                        SizedBox(height: _sectionGap.h),
                        _buildFlavorSection(),
                        SizedBox(height: _sectionGap.h),
                        _buildDescriptionCard(),
                        SizedBox(height: _sectionGap.h),
                        _buildRemarkCard(),
                      ],
                    ),
          ),
          if (!_loading)
            MenuFormBottomSaveBar(
              label: StoreMenuI18n.save.tr,
              onPressed: _onSave,
            ),
        ],
      ),
    );
  }

  Widget _buildMainInfoCard() {
    return MenuFormCard(
      padding: EdgeInsets.fromLTRB(14.w, 4.h, 14.w, 2.h),
      child: Column(
        children: [
          MenuFormInlineField(
            label: StoreMenuI18n.itemNameLabel.tr,
            child: MenuFormInlineInput(
              controller: _nameController,
              hintText: StoreMenuI18n.itemNameHint.tr,
              keyboardType: TextInputType.text,
              textAlign: TextAlign.end,
            ),
          ),
          MenuFormInlineField(
            label: StoreMenuI18n.itemPriceLabel.tr,
            child: MenuFormInlineInput(
              controller: _priceController,
              hintText: StoreMenuI18n.itemPriceHint.tr,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: false,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              prefixText: '¥ ',
              textAlign: TextAlign.end,
            ),
          ),
          MenuFormInlineField(
            label: StoreMenuI18n.minQtyLabel.tr,
            child: MenuFormInlineInput(
              controller: _minQtyController,
              hintText: StoreMenuI18n.minQtyHint.tr,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: false,
                signed: false,
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              suffix: Text(
                StoreMenuI18n.minQtyUnit.tr,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: StoreColors.secondaryText,
                ),
              ),
              textAlign: TextAlign.end,
            ),
          ),
          MenuFormInlineField(
            label: StoreMenuI18n.durationLabel.tr,
            child: MenuFormInlineInput(
              controller: _durationController,
              hintText: StoreMenuI18n.durationHint.tr,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: false,
                signed: false,
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              suffix: Text(
                StoreMenuI18n.durationUnit.tr,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: StoreColors.secondaryText,
                ),
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return MenuFormCard(
      padding: EdgeInsets.fromLTRB(14.w, 4.h, 14.w, 10.h),
      child: Column(
        children: [
          MenuFormInlineField(
            label: StoreMenuI18n.soldOutLabel.tr,
            child: MenuFormSegmentToggle(
              value: _soldOut,
              leftLabel: StoreMenuI18n.soldOutFormLeft.tr,
              rightLabel: StoreMenuI18n.soldOutFormRight.tr,
              onChanged: (value) => setState(() => _soldOut = value),
            ),
          ),
          MenuFormInlineField(
            label: StoreMenuI18n.offShelfFormLabel.tr,
            showDivider: false,
            child: MenuFormSegmentToggle(
              value: _offShelf,
              leftLabel: StoreMenuI18n.shelfFormLeft.tr,
              rightLabel: StoreMenuI18n.shelfFormRight.tr,
              onChanged: (value) => setState(() => _offShelf = value),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductTagsSection() {
    return MenuFormCard(
      padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            StoreMenuI18n.productTagsLabel.tr,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: StoreColors.primaryText,
            ),
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 6.w,
            runSpacing: 6.h,
            children: [
              for (final tag in _productTagOptions)
                FilterChip(
                  label: Text(tag, style: TextStyle(fontSize: 12.sp)),
                  labelPadding: EdgeInsets.symmetric(horizontal: 4.w),
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  selected: _selectedProductTags.contains(tag),
                  onSelected: (_) => _toggleProductTag(tag),
                  selectedColor: StoreColors.tabSelected.withValues(
                    alpha: 0.12,
                  ),
                  checkmarkColor: StoreColors.tabSelected,
                  side: const BorderSide(color: MenuLayout.divider),
                ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _customTagController,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _addCustomProductTag(),
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: StoreColors.primaryText,
                  ),
                  decoration: MenuFormFieldStyle.decoration(
                    hintText: StoreMenuI18n.productTagHint.tr,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              TextButton(
                onPressed: _addCustomProductTag,
                child: Text(
                  StoreMenuI18n.addProductTag.tr,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: StoreColors.tabSelected,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMultilineCard({
    required String label,
    required String hint,
    required TextEditingController controller,
    required int minLines,
    required int maxLines,
  }) {
    return MenuFormCard(
      child: MenuFormFieldRow(
        label: label,
        child: TextField(
          controller: controller,
          maxLines: maxLines,
          minLines: minLines,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          style: TextStyle(
            fontSize: 13.sp,
            color: StoreColors.primaryText,
            height: 1.35,
          ),
          decoration: MenuFormFieldStyle.decoration(hintText: hint),
        ),
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return _buildMultilineCard(
      label: StoreMenuI18n.itemDescriptionLabel.tr,
      hint: StoreMenuI18n.itemDescriptionHint.tr,
      controller: _descriptionController,
      minLines: 1,
      maxLines: 2,
    );
  }

  Widget _buildRemarkCard() {
    return _buildMultilineCard(
      label: StoreMenuI18n.remarkLabel.tr,
      hint: StoreMenuI18n.remarkHint.tr,
      controller: _remarkController,
      minLines: 1,
      maxLines: 2,
    );
  }

  Widget _buildFlavorSection() {
    return MenuFormCard(
      padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  StoreMenuI18n.flavorOptionsLabel.tr,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: StoreColors.primaryText,
                  ),
                ),
              ),
              IconButton(
                onPressed: _openDimensionPage,
                icon: Icon(
                  Icons.add_circle_outline,
                  size: 22.sp,
                  color: StoreColors.tabSelected,
                ),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(minWidth: 32.w, minHeight: 32.w),
                tooltip: StoreMenuI18n.manageDimensions.tr,
              ),
            ],
          ),
          if (_groupOptions.isEmpty)
            Padding(
              padding: EdgeInsets.only(top: 4.h, bottom: 4.h),
              child: Text(
                StoreMenuI18n.noTagGroups.tr,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: StoreColors.secondaryText,
                ),
              ),
            )
          else
            ..._groupOptions.entries.map(_buildFlavorListItem),
        ],
      ),
    );
  }

  Widget _buildImagePicker() {
    final hasImage =
        _localImage != null || (_imageUrl != null && _imageUrl!.isNotEmpty);

    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: double.infinity,
        height: 120.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: const [
            BoxShadow(
              color: MenuLayout.cardShadow,
              blurRadius: 12,
              offset: Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (_localImage != null)
              Image.file(_localImage!, fit: BoxFit.cover)
            else if (_imageUrl != null && _imageUrl!.isNotEmpty)
              Image.network(_imageUrl!, fit: BoxFit.cover)
            else
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFE8F1FF),
                      StoreColors.scaffoldBackground,
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 32.sp,
                      color: StoreColors.tabSelected.withValues(alpha: 0.85),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      StoreMenuI18n.pickImage.tr,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: StoreColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            if (hasImage)
              Positioned(
                right: 12.w,
                bottom: 12.h,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.edit_outlined,
                        size: 14.sp,
                        color: Colors.white,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        StoreMenuI18n.pickImage.tr,
                        style: TextStyle(fontSize: 12.sp, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlavorListItem(MapEntry<String, List<String>> entry) {
    final groupName = entry.key;
    final options = entry.value;
    final selected = _selectedTags[groupName] ?? {};

    return Padding(
      padding: EdgeInsets.only(top: 6.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  groupName,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: StoreColors.secondaryText,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _removeFlavorGroup(groupName),
                icon: Icon(
                  Icons.remove_circle_outline,
                  size: 20.sp,
                  color: StoreColors.secondaryText,
                ),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(minWidth: 28.w, minHeight: 28.w),
                tooltip: StoreMenuI18n.removeFlavorGroup.tr,
              ),
            ],
          ),
          if (options.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 6.h),
              child: Wrap(
                spacing: 5.w,
                runSpacing: 4.h,
                children: [
                  for (final option in options)
                    FilterChip(
                      label: Text(option, style: TextStyle(fontSize: 12.sp)),
                      labelPadding: EdgeInsets.symmetric(horizontal: 4.w),
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                      selected: selected.contains(option),
                      onSelected: (_) => _toggleTag(groupName, option),
                      selectedColor: StoreColors.tabSelected.withValues(
                        alpha: 0.12,
                      ),
                      checkmarkColor: StoreColors.tabSelected,
                      side: BorderSide(color: MenuLayout.divider),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
