import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'picker_locale.dart';
import 'picker_theme.dart';

export 'picker_locale.dart';
export 'picker_theme.dart';

/// Ngày bắt đầu của tuần hiển thị trong calendar.
enum WeekStartDay {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday;

  /// Giá trị weekday của Dart (Monday=1 … Sunday=7).
  int get dartWeekday => this == WeekStartDay.sunday ? 7 : index + 1;
}

/// Định dạng hiển thị ngày khi dùng [DatePickerConfig.formatDate].
enum DateFormatPattern {
  /// 15/06/2024
  ddMMyyyy,

  /// 06/15/2024
  MMddyyyy,

  /// 2024-06-15
  yyyyMMdd,

  /// 15.06.2024
  ddMMyyyy_dot,

  /// June 15, 2024  (dùng tên tháng từ locale)
  MMMddyyyy,

  /// 15 June 2024   (dùng tên tháng từ locale)
  ddMMMyyyy,
}

/// Khoảng ngày được chọn trong [CustomDateRangePicker].
class DateRange {
  final DateTime start;
  final DateTime end;

  const DateRange({required this.start, required this.end});

  /// Số ngày trong khoảng (inclusive).
  int get dayCount => end.difference(start).inDays + 1;

  @override
  String toString() => 'DateRange($start → $end)';
}

// ── Helper chung ──────────────────────────────────────────────────────────────

String _pad(int n) => n.toString().padLeft(2, '0');

String _formatDate(
    DateTime date, DateFormatPattern pattern, List<String> monthNames) {
  final d = _pad(date.day);
  final m = _pad(date.month);
  final y = date.year.toString();
  final monthName = monthNames[date.month - 1];

  return switch (pattern) {
    DateFormatPattern.ddMMyyyy     => '$d/$m/$y',
    DateFormatPattern.MMddyyyy     => '$m/$d/$y',
    DateFormatPattern.yyyyMMdd     => '$y-$m-$d',
    DateFormatPattern.ddMMyyyy_dot => '$d.$m.$y',
    DateFormatPattern.MMMddyyyy    => '$monthName $d, $y',
    DateFormatPattern.ddMMMyyyy    => '$d $monthName $y',
  };
}

List<String> _orderedWeekdays(PickerLocale locale, WeekStartDay weekStartDay) {
  final base = locale.weekdayLabels;
  final startIdx = weekStartDay.dartWeekday - 1;
  return [...base.sublist(startIdx), ...base.sublist(0, startIdx)];
}

// ── DatePickerConfig ──────────────────────────────────────────────────────────

/// Cấu hình cho date picker.
class DatePickerConfig {
  final DateTime? initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final WeekStartDay weekStartDay;
  final DateFormatPattern dateFormatPattern;
  final PickerLocale locale;
  final PickerThemeData? theme;

  const DatePickerConfig({
    this.initialDate,
    required this.firstDate,
    required this.lastDate,
    this.weekStartDay = WeekStartDay.sunday,
    this.dateFormatPattern = DateFormatPattern.ddMMyyyy,
    this.locale = PickerLocale.vi,
    this.theme,
  });

  List<String> get orderedWeekdayLabels =>
      _orderedWeekdays(locale, weekStartDay);

  String formatDate(DateTime date) =>
      _formatDate(date, dateFormatPattern, locale.monthNames);
}

// ── DateRangePickerConfig ─────────────────────────────────────────────────────

/// Cấu hình cho date range picker.
class DateRangePickerConfig {
  final DateRange? initialRange;
  final DateTime firstDate;
  final DateTime lastDate;
  final WeekStartDay weekStartDay;
  final DateFormatPattern dateFormatPattern;
  final PickerLocale locale;
  final PickerThemeData? theme;

  const DateRangePickerConfig({
    this.initialRange,
    required this.firstDate,
    required this.lastDate,
    this.weekStartDay = WeekStartDay.sunday,
    this.dateFormatPattern = DateFormatPattern.ddMMyyyy,
    this.locale = PickerLocale.vi,
    this.theme,
  });

  List<String> get orderedWeekdayLabels =>
      _orderedWeekdays(locale, weekStartDay);

  String formatDate(DateTime date) =>
      _formatDate(date, dateFormatPattern, locale.monthNames);
}

// ── TimePickerConfig ──────────────────────────────────────────────────────────

/// Kiểu rung phản hồi khi xoay bánh xe giờ/phút.
enum TimePickerHaptic {
  /// Không rung.
  none,

  /// Rung nhẹ kiểu "click" (mặc định, giống iOS system picker).
  selectionClick,

  /// Rung nhẹ hơn — chỉ cảm giác nhỏ.
  lightImpact,

  /// Rung vừa.
  mediumImpact,
}

/// Cấu hình cho time picker.
class TimePickerConfig {
  final TimeOfDay? initialTime;
  final bool use24HourFormat;
  final PickerLocale locale;
  final PickerThemeData? theme;

  /// Kiểu rung khi xoay bánh xe giờ/phút.
  /// Mặc định [TimePickerHaptic.selectionClick] — rung nhẹ mỗi item.
  /// Đặt [TimePickerHaptic.none] để tắt hoàn toàn.
  final TimePickerHaptic haptic;

  const TimePickerConfig({
    this.initialTime,
    this.use24HourFormat = false,
    this.locale = PickerLocale.vi,
    this.theme,
    this.haptic = TimePickerHaptic.selectionClick,
  });
}

/// Gọi haptic feedback theo kiểu được cấu hình.
void triggerTimeHaptic(TimePickerHaptic haptic) {
  switch (haptic) {
    case TimePickerHaptic.none:
      break;
    case TimePickerHaptic.selectionClick:
      HapticFeedback.selectionClick();
    case TimePickerHaptic.lightImpact:
      HapticFeedback.lightImpact();
    case TimePickerHaptic.mediumImpact:
      HapticFeedback.mediumImpact();
  }
}
