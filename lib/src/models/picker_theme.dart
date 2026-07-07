import 'package:flutter/material.dart';

/// Toàn bộ tùy chỉnh giao diện picker.
///
/// Tất cả field đều optional — nếu null sẽ tự suy ra từ [primary]/[surface].
class PickerThemeData {
  // ── Màu nền & chữ chính ────────────────────────────────────────────────────

  /// Màu chính: header, ô ngày được chọn, band range, highlight wheel.
  final Color primary;

  /// Màu text/icon trên nền [primary].
  final Color onPrimary;

  /// Màu nền dialog/calendar/wheel.
  final Color surface;

  /// Màu text mặc định trên [surface].
  final Color onSurface;

  /// Màu text ngày bị vô hiệu (ngoài [firstDate]..[lastDate]).
  final Color disabledColor;

  // ── Màu tuỳ chỉnh thêm ────────────────────────────────────────────────────

  /// Màu nền hàng nhãn ngày trong tuần (CN, T2…).
  /// Mặc định: [primary] với alpha 0.08.
  final Color? weekdayRowColor;

  /// Màu dải highlight khoảng ngày (range picker).
  /// Mặc định: [primary] với alpha 0.12.
  final Color? rangeBandColor;

  /// Màu viền ô "hôm nay".
  /// Mặc định: [primary].
  final Color? todayBorderColor;

  // ── Hình dạng ─────────────────────────────────────────────────────────────

  /// Bán kính bo góc dialog. Mặc định: 16.
  final double dialogBorderRadius;

  /// Bán kính bo góc ô ngày được chọn.
  /// Dùng [double.infinity] để ra hình tròn (mặc định).
  final double selectedDayRadius;

  /// Override toàn bộ decoration ô ngày được chọn
  /// (ghi đè [primary] + [selectedDayRadius]).
  final BoxDecoration? selectedDayDecoration;

  // ── Text style ─────────────────────────────────────────────────────────────

  /// Tiêu đề header (tháng/năm, giờ hiển thị).
  final TextStyle? headerTitleStyle;

  /// Phụ đề header ("Chọn ngày", "Select Time"…).
  final TextStyle? headerSubtitleStyle;

  /// Text ngày trong calendar (trạng thái bình thường).
  final TextStyle? dayStyle;

  /// Text ngày được chọn.
  final TextStyle? selectedDayStyle;

  /// Text nhãn ngày trong tuần (CN, T2…).
  final TextStyle? weekdayStyle;

  /// Text item trên wheel giờ (chưa được chọn).
  final TextStyle? timeWheelStyle;

  /// Text item trên wheel giờ (đang được chọn).
  final TextStyle? timeSelectedStyle;

  const PickerThemeData({
    required this.primary,
    required this.onPrimary,
    this.surface = Colors.white,
    this.onSurface = const Color(0xFF1C1B1F),
    this.disabledColor = const Color(0xFFCAC4D0),
    this.weekdayRowColor,
    this.rangeBandColor,
    this.todayBorderColor,
    this.dialogBorderRadius = 16,
    this.selectedDayRadius = double.infinity,
    this.selectedDayDecoration,
    this.headerTitleStyle,
    this.headerSubtitleStyle,
    this.dayStyle,
    this.selectedDayStyle,
    this.weekdayStyle,
    this.timeWheelStyle,
    this.timeSelectedStyle,
  });

  // ── Getters suy ra từ màu chính ───────────────────────────────────────────

  /// Màu nền thực tế của hàng weekday (dùng [weekdayRowColor] nếu có).
  Color get resolvedWeekdayRowColor =>
      weekdayRowColor ?? primary.withValues(alpha: 0.08);

  /// Màu band dải khoảng ngày thực tế (dùng [rangeBandColor] nếu có).
  Color get resolvedRangeBandColor =>
      rangeBandColor ?? primary.withValues(alpha: 0.12);

  /// Màu viền hôm nay thực tế (dùng [todayBorderColor] nếu có).
  Color get resolvedTodayBorderColor => todayBorderColor ?? primary;

  // ── Factory ───────────────────────────────────────────────────────────────

  /// Tạo theme từ một màu seed, tự suy ra [onPrimary].
  factory PickerThemeData.fromSeed(Color seed) {
    final isDark =
        ThemeData.estimateBrightnessForColor(seed) == Brightness.dark;
    return PickerThemeData(
      primary: seed,
      onPrimary: isDark ? Colors.white : Colors.black87,
    );
  }

  /// Lấy theme từ [ColorScheme] của app; trả về [override] nếu có.
  static PickerThemeData of(BuildContext context,
      {PickerThemeData? override}) {
    if (override != null) return override;
    final cs = ColorScheme.of(context); // Flutter 3.27+
    return PickerThemeData(
      primary: cs.primary,
      onPrimary: cs.onPrimary,
      surface: cs.surface,
      onSurface: cs.onSurface,
      disabledColor: cs.onSurface.withValues(alpha: 0.25),
    );
  }

  // ── copyWith ──────────────────────────────────────────────────────────────

  PickerThemeData copyWith({
    Color? primary,
    Color? onPrimary,
    Color? surface,
    Color? onSurface,
    Color? disabledColor,
    Color? weekdayRowColor,
    Color? rangeBandColor,
    Color? todayBorderColor,
    double? dialogBorderRadius,
    double? selectedDayRadius,
    BoxDecoration? selectedDayDecoration,
    TextStyle? headerTitleStyle,
    TextStyle? headerSubtitleStyle,
    TextStyle? dayStyle,
    TextStyle? selectedDayStyle,
    TextStyle? weekdayStyle,
    TextStyle? timeWheelStyle,
    TextStyle? timeSelectedStyle,
  }) =>
      PickerThemeData(
        primary: primary ?? this.primary,
        onPrimary: onPrimary ?? this.onPrimary,
        surface: surface ?? this.surface,
        onSurface: onSurface ?? this.onSurface,
        disabledColor: disabledColor ?? this.disabledColor,
        weekdayRowColor: weekdayRowColor ?? this.weekdayRowColor,
        rangeBandColor: rangeBandColor ?? this.rangeBandColor,
        todayBorderColor: todayBorderColor ?? this.todayBorderColor,
        dialogBorderRadius: dialogBorderRadius ?? this.dialogBorderRadius,
        selectedDayRadius: selectedDayRadius ?? this.selectedDayRadius,
        selectedDayDecoration:
            selectedDayDecoration ?? this.selectedDayDecoration,
        headerTitleStyle: headerTitleStyle ?? this.headerTitleStyle,
        headerSubtitleStyle: headerSubtitleStyle ?? this.headerSubtitleStyle,
        dayStyle: dayStyle ?? this.dayStyle,
        selectedDayStyle: selectedDayStyle ?? this.selectedDayStyle,
        weekdayStyle: weekdayStyle ?? this.weekdayStyle,
        timeWheelStyle: timeWheelStyle ?? this.timeWheelStyle,
        timeSelectedStyle: timeSelectedStyle ?? this.timeSelectedStyle,
      );
}
