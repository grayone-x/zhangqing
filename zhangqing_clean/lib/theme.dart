import 'package:flutter/material.dart';

class AppColors {
  static const bg       = Color(0xFFEDF4FB); // baby蓝底
  static const card     = Colors.white;
  static const border   = Color(0xFFEDF3FA);
  static const primary  = Color(0xFF3E7BD9); // 主蓝
  static const textMain = Color(0xFF2B3A4E);
  static const textSub  = Color(0xFF8FA6BF);
  static const textWeak = Color(0xFFA8BCD4);
  static const danger   = Color(0xFFE26D6D); // 删除
}

const appShadow = [
  BoxShadow(color: Color(0x143C6EB4), blurRadius: 8, offset: Offset(0, 2)),
];

ThemeData appTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: AppColors.textMain),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bg,
      foregroundColor: AppColors.textMain,
      elevation: 0,
      centerTitle: false,
    ),
  );
}

/// 头像：pastel 底色 + 名字末字
class AvatarStyle {
  static const List<Color> _bg = [
    Color(0xFFE3EDFB), Color(0xFFE2F3E8), Color(0xFFF3E4F5),
    Color(0xFFFBEDDC), Color(0xFFE0F0F0), Color(0xFFFBE3E9),
  ];
  static const List<Color> _fg = [
    Color(0xFF3E7BD9), Color(0xFF4C9A6E), Color(0xFF9B6BB5),
    Color(0xFFC98A5B), Color(0xFF4AA8A0), Color(0xFFD66A8E),
  ];
  static Color bgOf(String name) => _bg[name.hashCode.abs() % _bg.length];
  static Color fgOf(String name) => _fg[name.hashCode.abs() % _fg.length];
  static String lastChar(String name) =>
      name.isEmpty ? '?' : name.substring(name.length - 1);
}
