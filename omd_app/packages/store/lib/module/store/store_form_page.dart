import 'package:base/toast/nine_progress_hud.dart';
import 'package:base/toast/nine_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:store/module/a_color/store_colors.dart';
import 'package:store/module/store/store_api.dart';
import 'package:store/module/store/store_i18n.dart';
import 'package:store/module/store/store_models.dart';
import 'package:store/module/store/store_time_picker_sheet.dart';
import 'package:store/module/store/store_time_utils.dart';

/// 新增 / 编辑店铺统一表单页。
class StoreFormPage extends StatefulWidget {
  const StoreFormPage({super.key, this.store});

  /// 为 null 时表示新增店铺。
  final StoreModel? store;

  @override
  State<StoreFormPage> createState() => _StoreFormPageState();
}

class _StoreFormPageState extends State<StoreFormPage> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _contactController = TextEditingController();
  final _vipLevelController = TextEditingController(text: '1');
  final _referrerController = TextEditingController();

  var _isOpen24Hours = false;
  late TimeOfDay _openTime;
  late TimeOfDay _closeTime;
  final _closedWeekdays = <int>{};

  bool get _isEdit => widget.store != null;

  @override
  void initState() {
    super.initState();
    final store = widget.store;
    if (store != null) {
      _nameController.text = store.name;
      _addressController.text = store.address;
      _phoneController.text = store.phone;
      _contactController.text = store.contactName;
      _vipLevelController.text = '${store.serviceInfo.vipLevel}';
      _referrerController.text = store.serviceInfo.referrerId ?? '';
      _isOpen24Hours = store.businessHours.isOpen24Hours;
      _openTime = store.businessHours.openTime != null
          ? StoreTimeOfDayMs.toTimeOfDay(store.businessHours.openTime!)
          : const TimeOfDay(hour: 9, minute: 0);
      _closeTime = store.businessHours.closeTime != null
          ? StoreTimeOfDayMs.toTimeOfDay(store.businessHours.closeTime!)
          : const TimeOfDay(hour: 22, minute: 0);
      _closedWeekdays.addAll(store.closedWeekdays);
    } else {
      _openTime = const TimeOfDay(hour: 9, minute: 0);
      _closeTime = const TimeOfDay(hour: 22, minute: 0);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _contactController.dispose();
    _vipLevelController.dispose();
    _referrerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StoreColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          _isEdit ? StoreStoreI18n.editStore.tr : StoreStoreI18n.addStore.tr,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 32.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _LabeledField(
              label: StoreStoreI18n.nameLabel.tr,
              child: _buildTextField(
                controller: _nameController,
                hint: StoreStoreI18n.nameHint.tr,
              ),
            ),
            SizedBox(height: 16.h),
            _LabeledField(
              label: StoreStoreI18n.addressLabel.tr,
              child: _buildTextField(
                controller: _addressController,
                hint: StoreStoreI18n.addressHint.tr,
                maxLines: 2,
              ),
            ),
            SizedBox(height: 16.h),
            _LabeledField(
              label: StoreStoreI18n.phoneLabel.tr,
              child: _buildTextField(
                controller: _phoneController,
                hint: StoreStoreI18n.phoneHint.tr,
                keyboardType: TextInputType.phone,
              ),
            ),
            SizedBox(height: 16.h),
            _LabeledField(
              label: StoreStoreI18n.contactLabel.tr,
              child: _buildTextField(
                controller: _contactController,
                hint: StoreStoreI18n.contactHint.tr,
              ),
            ),
            SizedBox(height: 16.h),
            _LabeledField(
              label: StoreStoreI18n.vipLevelLabel.tr,
              child: _buildTextField(
                controller: _vipLevelController,
                hint: StoreStoreI18n.vipLevelHint.tr,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
            SizedBox(height: 16.h),
            _LabeledField(
              label: StoreStoreI18n.referrerLabel.tr,
              child: _buildTextField(
                controller: _referrerController,
                hint: StoreStoreI18n.referrerHint.tr,
              ),
            ),
            SizedBox(height: 20.h),
            _buildBusinessHoursSection(),
            SizedBox(height: 20.h),
            _buildClosedWeekdaysSection(),
            SizedBox(height: 28.h),
            SizedBox(
              height: 48.h,
              child: FilledButton(
                onPressed: _onSave,
                style: FilledButton.styleFrom(
                  backgroundColor: StoreColors.tabSelected,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                child: Text(
                  StoreStoreI18n.saveButton.tr,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessHoursSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            StoreStoreI18n.businessHours.tr,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: StoreColors.primaryText,
            ),
          ),
          SizedBox(height: 12.h),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              StoreStoreI18n.open24Hours.tr,
              style: TextStyle(fontSize: 14.sp, color: StoreColors.primaryText),
            ),
            value: _isOpen24Hours,
            activeTrackColor: StoreColors.tabSelected.withValues(alpha: 0.35),
            activeThumbColor: StoreColors.tabSelected,
            onChanged: (value) => setState(() => _isOpen24Hours = value),
          ),
          if (!_isOpen24Hours) ...[
            SizedBox(height: 8.h),
            Row(
              children: [
                Expanded(
                  child: _TimeSelectorTile(
                    label: StoreStoreI18n.openTime.tr,
                    time: _openTime,
                    onTap: () => _pickTime(isOpen: true),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: Text(
                    '—',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: StoreColors.secondaryText,
                    ),
                  ),
                ),
                Expanded(
                  child: _TimeSelectorTile(
                    label: StoreStoreI18n.closeTime.tr,
                    time: _closeTime,
                    onTap: () => _pickTime(isOpen: false),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildClosedWeekdaysSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            StoreStoreI18n.closedWeekdays.tr,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: StoreColors.primaryText,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            StoreStoreI18n.closedWeekdaysHint.tr,
            style: TextStyle(fontSize: 12.sp, color: StoreColors.secondaryText),
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children:
                StoreWeekdayOption.options.map((option) {
                  final selected = _closedWeekdays.contains(option.value);
                  return FilterChip(
                    label: Text(option.labelKey.tr),
                    selected: selected,
                    selectedColor: StoreColors.tabSelected.withValues(alpha: 0.15),
                    checkmarkColor: StoreColors.tabSelected,
                    labelStyle: TextStyle(
                      fontSize: 13.sp,
                      color:
                          selected
                              ? StoreColors.tabSelected
                              : StoreColors.primaryText,
                    ),
                    onSelected: (value) {
                      setState(() {
                        if (value) {
                          _closedWeekdays.add(option.value);
                        } else {
                          _closedWeekdays.remove(option.value);
                        }
                      });
                    },
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: TextStyle(fontSize: 15.sp, color: StoreColors.primaryText),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: StoreColors.secondaryText, fontSize: 15.sp),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: Color(0xFFE4E7EC)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: Color(0xFFE4E7EC)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(
            color: StoreColors.tabSelected,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  Future<void> _pickTime({required bool isOpen}) async {
    final initial = isOpen ? _openTime : _closeTime;
    final title =
        isOpen ? StoreStoreI18n.openTime.tr : StoreStoreI18n.closeTime.tr;
    final picked = await showStoreTimePickerSheet(
      context,
      initialTime: initial,
      title: title,
    );
    if (picked == null) return;
    setState(() {
      if (isOpen) {
        _openTime = picked;
      } else {
        _closeTime = picked;
      }
    });
  }

  Future<void> _onSave() async {
    final name = _nameController.text.trim();
    final address = _addressController.text.trim();
    final phone = _phoneController.text.trim();
    final contact = _contactController.text.trim();
    final vipLevel = int.tryParse(_vipLevelController.text.trim()) ?? 1;

    if (name.isEmpty ||
        address.isEmpty ||
        phone.isEmpty ||
        contact.isEmpty) {
      showAppToast(StoreStoreI18n.formIncomplete.tr);
      return;
    }

    if (!_isOpen24Hours) {
      final openMinutes = _openTime.hour * 60 + _openTime.minute;
      final closeMinutes = _closeTime.hour * 60 + _closeTime.minute;
      if (openMinutes >= closeMinutes) {
        showAppToast(StoreStoreI18n.invalidBusinessHours.tr);
        return;
      }
    }

    final businessHours = StoreBusinessHours(
      isOpen24Hours: _isOpen24Hours,
      openTime: _isOpen24Hours ? null : StoreTimeOfDayMs.fromTimeOfDay(_openTime),
      closeTime: _isOpen24Hours ? null : StoreTimeOfDayMs.fromTimeOfDay(_closeTime),
    );

    final request = SaveStoreRequest(
      id: widget.store?.id,
      name: name,
      address: address,
      phone: phone,
      contactName: contact,
      vipLevel: vipLevel,
      referrerId: _referrerController.text.trim(),
      businessHours: businessHours,
      closedWeekdays: _closedWeekdays.toList()..sort(),
    );

    NineProgressHud.showLoading();
    try {
      final response = await StoreApi.saveStore(request);
      if (!response.isSuccess) {
        showAppToast(
          response.message.isNotEmpty
              ? response.message
              : StoreStoreI18n.loadFailed.tr,
        );
        return;
      }
      showAppToast(StoreStoreI18n.saveSuccess.tr);
      Get.back(result: true);
    } finally {
      NineProgressHud.dismiss();
    }
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: StoreColors.primaryText,
          ),
        ),
        SizedBox(height: 8.h),
        child,
      ],
    );
  }
}

class _TimeSelectorTile extends StatelessWidget {
  const _TimeSelectorTile({
    required this.label,
    required this.time,
    required this.onTap,
  });

  final String label;
  final TimeOfDay time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE4E7EC)),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12.sp, color: StoreColors.secondaryText),
            ),
            SizedBox(height: 4.h),
            Text(
              text,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: StoreColors.primaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
