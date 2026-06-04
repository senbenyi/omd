import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppDimen {
  AppDimen._();
  static double get screenWidth => ScreenUtil().screenWidth;

  static double get screenHeight => ScreenUtil().screenHeight;

  static double get statusBarHeight => ScreenUtil().statusBarHeight;

  static double get bottomBarHeight => ScreenUtil().bottomBarHeight;

  static double bottomPadding(double value) =>
      bottomBarHeight > 0 ? bottomBarHeight : value;

  static double get dimen_0_1 => convert(0.1);

  static double get dimen_0_2 => convert(0.2);

  static double get dimen_0_3 => convert(0.3);

  static double get dimen_0_5 => convert(0.5);
  static double get dimen_0_8 => convert(0.8);
  static double get dimen_0_9 => convert(0.9);
  static double get dimen_1 => convert(1);

  static double get dimen_2 => convert(2);

  static double get dimen_3 => convert(3);

  static double get dimen_4 => convert(4);

  static double get dimen_5 => convert(5);

  static double get dimen_6 => convert(6);

  static double get dimen_7 => convert(7);

  static double get dimen_8 => convert(8);

  static double get dimen_9 => convert(9);

  static double get dimen_10 => convert(10);

  static double get dimen_11 => convert(11);

  static double get dimen_12 => convert(12);

  static double get dimen_13 => convert(13);

  static double get dimen_14 => convert(14);

  static double get dimen_15 => convert(15);

  static double get dimen_16 => convert(16);

  static double get dimen_17 => convert(17);

  static double get dimen_18 => convert(18);

  static double get dimen_19 => convert(19);

  static double get dimen_20 => convert(20);

  static double get dimen_22 => convert(22);
  static double get dimen_21 => convert(21);
  static double get dimen_24 => convert(24);

  static double get dimen_25 => convert(25);

  static double get dimen_26 => convert(26);

  static double get dimen_28 => convert(28);

  static double get dimen_30 => convert(30);
  static double get dimen_32 => convert(32);

  static double get dimen_33 => convert(33);
  static double get dimen_34 => convert(34);
  static double get dimen_34_5 => convert(34.5);
  static double get dimen_35 => convert(35);

  static double get dimen_36 => convert(36);

  static double get dimen_38 => convert(38);

  static double get dimen_40 => convert(40);

  static double get dimen_42 => convert(42);

  static double get dimen_44 => convert(44);
  static double get dimen_43 => convert(43);

  static double get dimen_45 => convert(45);

  static double get dimen_46 => convert(46);

  static double get dimen_48 => convert(48);

  static double get dimen_49 => convert(49);

  static double get dimen_50 => convert(50);

  static double get dimen_53 => convert(53);

  static double get dimen_54 => convert(54);

  static double get dimen_55 => convert(55);

  static double get dimen_56 => convert(56);

  static double get dimen_58 => convert(58);

  static double get dimen_60 => convert(60);

  static double get dimen_65 => convert(65);

  static double get dimen_70 => convert(70);

  static double get dimen_75 => convert(75);
  static double get dimen_77 => convert(77);
  static double get dimen_79 => convert(79);
  static double get dimen_78 => convert(78);
  static double get dimen_76 => convert(76);

  static double get dimen_80 => convert(80);

  static double get dimen_85 => convert(85);
  static double get dimen_86 => convert(86);
  static double get dimen_88 => convert(88);

  static double get dimen_90 => convert(90);

  static double get dimen_99 => convert(99);
  static double get dimen_100 => convert(100);
  static double get dimen_104 => convert(104);
  static double get dimen_105 => convert(105);
  static double get dimen_106 => convert(106);
  static double get dimen_107 => convert(107);
  static double get dimen_108 => convert(108);
  static double get dimen_110 => convert(110);

  static double get dimen_115 => convert(115);

  static double get dimen_120 => convert(120);

  static double get dimen_125 => convert(125);

  static double get dimen_130 => convert(130);

  static double get dimen_135 => convert(135);

  static double get dimen_138 => convert(138);

  static double get dimen_140 => convert(140);
  static double get dimen_146 => convert(146);
  static double get dimen_150 => convert(150);

  static double get dimen_155 => convert(155);

  static double get dimen_158 => convert(158);

  static double get dimen_160 => convert(160);

  static double get dimen_168 => convert(168);

  static double get dimen_170 => convert(170);

  static double get dimen_175 => convert(175);

  static double get dimen_179 => convert(179);

  static double get dimen_180 => convert(180);

  static double get dimen_185 => convert(185);

  static double get dimen_188 => convert(188);

  static double get dimen_190 => convert(190);
  static double get dimen_199 => convert(199);
  static double get dimen_200 => convert(200);

  static double get dimen_210 => convert(210);

  static double get dimen_220 => convert(220);

  static double get dimen_230 => convert(230);
  static double get dimen_232 => convert(232);
  static double get dimen_234 => convert(234);
  static double get dimen_236 => convert(236);
  static double get dimen_240 => convert(240);

  static double get dimen_250 => convert(250);

  static double get dimen_260 => convert(260);

  static double get dimen_270 => convert(270);
  static double get dimen_275 => convert(275);
  static double get dimen_280 => convert(280);
  static double get dimen_287 => convert(287);
  static double get dimen_285 => convert(285);

  static double get dimen_290 => convert(290);
  static double get dimen_294 => convert(294);
  static double get dimen_300 => convert(300);

  static double get dimen_310 => convert(310);

  static double get dimen_320 => convert(320);

  static double get dimen_350 => convert(350);

  static double get dimen_360 => convert(360);

  static double get dimen_370 => convert(370);

  static double get dimen_375 => convert(375);

  static double get dimen_380 => convert(380);

  static double get dimen_400 => convert(400);

  static double get dimen_500 => convert(500);

  static double convert(double value) {
    return ScreenUtil().setWidth(value);
  }

  static double sp(double value) {
    return ScreenUtil().setSp(value);
  }

  static double radius(double value) {
    return ScreenUtil().radius(value);
  }
}
