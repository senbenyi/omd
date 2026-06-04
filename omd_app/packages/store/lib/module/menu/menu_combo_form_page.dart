import 'package:base/toast/nine_progress_hud.dart';
import 'package:base/toast/nine_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:store/module/a_color/store_colors.dart';
import 'package:store/module/menu/menu_api.dart';
import 'package:store/module/menu/menu_i18n.dart';
import 'package:store/module/menu/menu_widgets.dart';
import 'package:store/module/menu/menu_models.dart';
import 'package:store/module/menu/menu_price_utils.dart';

class MenuComboFormPage extends StatefulWidget {
  const MenuComboFormPage({
    super.key,
    required this.storeId,
    this.comboId,
    this.initialDetail,
  });

  final int storeId;
  final int? comboId;
  final MenuComboDetailModel? initialDetail;

  @override
  State<MenuComboFormPage> createState() => _MenuComboFormPageState();
}

class _MenuComboFormPageState extends State<MenuComboFormPage> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _itemQty = <int, int>{};

  var _loading = true;
  var _saving = false;
  final _allItems = <MenuItemListModel>[];
  final _categoryNames = <int, String>{};

  static const _sectionGap = 10.0;

  @override
  void initState() {
    super.initState();
    final detail = widget.initialDetail;
    if (detail != null) {
      _nameController.text = detail.name;
      _priceController.text = MenuPriceUtils.centsToYuanInput(detail.price);
      for (final item in detail.items) {
        _itemQty[item.id] = item.qty > 0 ? item.qty : 1;
      }
    }
    _loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final categoryResponse = await MenuApi.listCategories(widget.storeId);
      if (categoryResponse.isSuccess) {
        for (final category in categoryResponse.data ?? <MenuCategoryModel>[]) {
          _categoryNames[category.id] = category.name;
        }
      }

      final items = <MenuItemListModel>[];
      var page = 1;
      while (true) {
        final response = await MenuApi.listItems(
          storeId: widget.storeId,
          page: page,
          pageSize: 100,
        );
        if (!response.isSuccess || response.data == null) break;
        final batch = response.data!;
        items.addAll(batch.list);
        if (items.length >= batch.total || batch.list.isEmpty) break;
        page++;
      }

      if (mounted) {
        setState(() {
          _allItems
            ..clear()
            ..addAll(items);
          if (_itemQty.isNotEmpty) {
            _syncComboPriceFromSelection();
          }
        });
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  bool _isSelected(int itemId) => _itemQty.containsKey(itemId);

  int _selectedItemsTotalCents() {
    var total = 0;
    for (final item in _allItems) {
      final qty = _itemQty[item.id];
      if (qty != null) {
        total += item.price * qty;
      }
    }
    return total;
  }

  void _syncComboPriceFromSelection() {
    final cents = _selectedItemsTotalCents();
    _priceController.text =
        cents > 0 ? MenuPriceUtils.centsToYuanInput(cents) : '';
  }

  void _toggleItem(int itemId, bool selected) {
    setState(() {
      if (selected) {
        _itemQty[itemId] = _itemQty[itemId] ?? 1;
      } else {
        _itemQty.remove(itemId);
      }
      _syncComboPriceFromSelection();
    });
  }

  void _changeQty(int itemId, int delta) {
    if (!_isSelected(itemId)) {
      if (delta > 0) {
        setState(() {
          _itemQty[itemId] = 1;
          _syncComboPriceFromSelection();
        });
      }
      return;
    }
    final current = _itemQty[itemId]!;
    final next = current + delta;
    if (next < 1) return;
    setState(() {
      _itemQty[itemId] = next;
      _syncComboPriceFromSelection();
    });
  }

  List<SaveMenuComboItemEntry> _buildItemEntries() {
    final entries = <SaveMenuComboItemEntry>[];
    for (final item in _allItems) {
      final qty = _itemQty[item.id];
      if (qty == null) continue;
      entries.add(SaveMenuComboItemEntry(itemId: item.id, qty: qty));
    }
    return entries;
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      showAppToast(StoreMenuI18n.comboNameHint.tr);
      return;
    }

    final price = MenuPriceUtils.parseYuanToCents(_priceController.text);
    if (price == null) {
      showAppToast(StoreMenuI18n.comboPriceHint.tr);
      return;
    }
    if (_itemQty.isEmpty) {
      showAppToast(StoreMenuI18n.comboSelectItemsEmpty.tr);
      return;
    }

    setState(() => _saving = true);
    NineProgressHud.showLoading();
    try {
      final response = await MenuApi.saveCombo(
        widget.storeId,
        SaveMenuComboRequest(
          id: widget.comboId,
          name: name,
          price: price,
          items: _buildItemEntries(),
        ),
      );
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
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title =
        widget.comboId == null
            ? StoreMenuI18n.addCombo.tr
            : (widget.initialDetail?.name ?? StoreMenuI18n.addCombo.tr);

    return Scaffold(
      backgroundColor: StoreColors.scaffoldBackground,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: StoreColors.scaffoldBackground,
        centerTitle: true,
        title: Text(
          title,
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
                        _buildBasicCard(),
                        SizedBox(height: _sectionGap.h),
                        _buildDishSection(),
                      ],
                    ),
          ),
          MenuFormBottomSaveBar(
            label: StoreMenuI18n.save.tr,
            onPressed: _loading || _saving ? null : _save,
          ),
        ],
      ),
    );
  }

  Widget _buildBasicCard() {
    return MenuFormCard(
      padding: EdgeInsets.fromLTRB(14.w, 4.h, 14.w, 2.h),
      child: Column(
        children: [
          MenuFormInlineField(
            label: StoreMenuI18n.comboNameLabel.tr,
            child: MenuFormInlineInput(
              controller: _nameController,
              hintText: StoreMenuI18n.comboNameHint.tr,
              keyboardType: TextInputType.text,
              textAlign: TextAlign.end,
            ),
          ),
          MenuFormInlineField(
            label: StoreMenuI18n.comboPriceLabel.tr,
            showDivider: false,
            child: MenuFormInlineInput(
              controller: _priceController,
              hintText: StoreMenuI18n.comboPriceHint.tr,
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
        ],
      ),
    );
  }

  Widget _buildDishSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 2.w, bottom: 6.h),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  StoreMenuI18n.comboSelectItemsLabel.tr,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: StoreColors.primaryText,
                  ),
                ),
              ),
              Text(
                '${StoreMenuI18n.comboItemsTotalLabel.tr} ${MenuPriceUtils.formatCents(_selectedItemsTotalCents())}',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: StoreColors.tabSelected,
                ),
              ),
            ],
          ),
        ),
        if (_allItems.isEmpty)
          MenuFormCard(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Center(
                child: Text(
                  StoreMenuI18n.comboNoDishes.tr,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: StoreColors.secondaryText,
                  ),
                ),
              ),
            ),
          )
        else
          ..._buildGroupedItems(),
      ],
    );
  }

  List<Widget> _buildGroupedItems() {
    final grouped = <int, List<MenuItemListModel>>{};
    for (final item in _allItems) {
      grouped.putIfAbsent(item.categoryId, () => []).add(item);
    }

    final categoryIds =
        grouped.keys.toList()..sort((a, b) {
          final nameA = _categoryNames[a] ?? '';
          final nameB = _categoryNames[b] ?? '';
          return nameA.compareTo(nameB);
        });

    return [
      for (final categoryId in categoryIds) ...[
        Padding(
          padding: EdgeInsets.only(top: 4.h, bottom: 4.h, left: 2.w),
          child: Text(
            _categoryNames[categoryId] ?? StoreMenuI18n.unknownCategory.tr,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: StoreColors.secondaryText,
            ),
          ),
        ),
        MenuFormCard(
          padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 4.w),
          child: Column(
            children: [
              for (var i = 0; i < grouped[categoryId]!.length; i++) ...[
                if (i > 0)
                  Divider(
                    height: 1,
                    color: MenuLayout.divider.withValues(alpha: 0.85),
                  ),
                _DishSelectTile(
                  item: grouped[categoryId]![i],
                  selected: _isSelected(grouped[categoryId]![i].id),
                  qty: _itemQty[grouped[categoryId]![i].id] ?? 1,
                  onChanged:
                      (selected) =>
                          _toggleItem(grouped[categoryId]![i].id, selected),
                  onQtyChanged:
                      (delta) => _changeQty(grouped[categoryId]![i].id, delta),
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: 6.h),
      ],
    ];
  }
}

class _DishSelectTile extends StatelessWidget {
  const _DishSelectTile({
    required this.item,
    required this.selected,
    required this.qty,
    required this.onChanged,
    required this.onQtyChanged,
  });

  final MenuItemListModel item;
  final bool selected;
  final int qty;
  final ValueChanged<bool> onChanged;
  final ValueChanged<int> onQtyChanged;

  @override
  Widget build(BuildContext context) {
    final displayQty = selected ? qty : 1;
    final stepperEnabled = selected;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
      child: Row(
        children: [
          SizedBox(
            width: 36.w,
            height: 36.w,
            child: Checkbox(
              value: selected,
              activeColor: StoreColors.tabSelected,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              onChanged: (value) => onChanged(value ?? false),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () => onChanged(!selected),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: StoreColors.primaryText,
                    ),
                  ),
                  Text(
                    MenuPriceUtils.formatCents(item.price),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: StoreColors.tabSelected,
                    ),
                  ),
                ],
              ),
            ),
          ),
          _QtyIconButton(
            icon: Icons.remove,
            onTap:
                stepperEnabled && displayQty > 1
                    ? () => onQtyChanged(-1)
                    : null,
          ),
          SizedBox(
            width: 28.w,
            child: Text(
              '$displayQty',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color:
                    stepperEnabled
                        ? StoreColors.primaryText
                        : StoreColors.secondaryText,
              ),
            ),
          ),
          _QtyIconButton(icon: Icons.add, onTap: () => onQtyChanged(1)),
          Text(
            StoreMenuI18n.minQtyUnit.tr,
            style: TextStyle(fontSize: 12.sp, color: StoreColors.secondaryText),
          ),
        ],
      ),
    );
  }
}

class _QtyIconButton extends StatelessWidget {
  const _QtyIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Material(
      color:
          enabled
              ? StoreColors.tabSelected.withValues(alpha: 0.08)
              : MenuFormFieldStyle.fillColor,
      borderRadius: BorderRadius.circular(6.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6.r),
        child: SizedBox(
          width: 28.w,
          height: 28.w,
          child: Icon(
            icon,
            size: 16.sp,
            color:
                enabled
                    ? StoreColors.tabSelected
                    : StoreColors.secondaryText.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }
}
