import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:store/common/store_translations.dart';
import 'package:store/module/a_color/store_colors.dart';
import 'package:store/common/user/go_user_controller.dart';
import 'package:store/common/user/go_personal_info_status_store.dart';
import 'package:store/module/login/store_login_i18n.dart';

class StoreTabMinePage extends StatelessWidget {
  const StoreTabMinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 100.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              StoreCommonI18n.tabMine.tr,
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: StoreColors.primaryText,
              ),
            ),
            SizedBox(height: 24.h),
            Obx(() {
              final user = GoUserController.to.loginInfo.value;
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
                      user?.displayName ?? StoreLoginI18n.notLoggedIn.tr,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: StoreColors.primaryText,
                      ),
                    ),
                    if (GoPersonalInfoStatusStore.isLogin && user != null) ...[
                      SizedBox(height: 8.h),
                      if (user.phone != null && user.phone!.isNotEmpty)
                        Text(
                          user.phone!,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: StoreColors.secondaryText,
                          ),
                        ),
                      SizedBox(height: 4.h),
                      Text(
                        'ID: ${user.displayUserId}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: StoreColors.secondaryText,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
            const Spacer(),
            SizedBox(
              height: 48.h,
              child: OutlinedButton(
                onPressed: GoUserController.to.logOut,
                style: OutlinedButton.styleFrom(
                  foregroundColor: StoreColors.tabSelected,
                  side: const BorderSide(color: StoreColors.tabSelected),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                child: Text(
                  StoreLoginI18n.logout.tr,
                  style: TextStyle(fontSize: 15.sp),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
