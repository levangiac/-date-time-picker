/// Chuỗi văn bản của picker — hỗ trợ đa ngôn ngữ.
class PickerLocale {
  /// 12 tên tháng theo thứ tự tháng 1 → 12.
  final List<String> monthNames;

  /// 7 nhãn ngày trong tuần theo thứ tự Thứ 2 → Chủ nhật.
  final List<String> weekdayLabels;

  final String cancelText;
  final String confirmText;
  final String selectDateTitle;
  final String selectTimeTitle;
  final String amLabel;
  final String pmLabel;
  final String dateTabLabel;
  final String timeTabLabel;

  // ── Date range picker ──────────────────────────────────────────────────────
  final String selectRangeTitle;
  final String startDateLabel;
  final String endDateLabel;

  const PickerLocale({
    required this.monthNames,
    required this.weekdayLabels,
    required this.cancelText,
    required this.confirmText,
    required this.selectDateTitle,
    required this.selectTimeTitle,
    required this.amLabel,
    required this.pmLabel,
    required this.dateTabLabel,
    required this.timeTabLabel,
    this.selectRangeTitle = '',
    this.startDateLabel = '',
    this.endDateLabel = '',
  });

  /// Tiếng Việt (mặc định).
  static const vi = PickerLocale(
    monthNames: [
      'Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4',
      'Tháng 5', 'Tháng 6', 'Tháng 7', 'Tháng 8',
      'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12',
    ],
    weekdayLabels: ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'],
    cancelText: 'Hủy',
    confirmText: 'Xác nhận',
    selectDateTitle: 'Chọn ngày',
    selectTimeTitle: 'Chọn giờ',
    amLabel: 'SA',
    pmLabel: 'CH',
    dateTabLabel: 'Ngày',
    timeTabLabel: 'Giờ',
    selectRangeTitle: 'Chọn khoảng thời gian',
    startDateLabel: 'Từ ngày',
    endDateLabel: 'Đến ngày',
  );

  /// English.
  static const en = PickerLocale(
    monthNames: [
      'January', 'February', 'March', 'April',
      'May', 'June', 'July', 'August',
      'September', 'October', 'November', 'December',
    ],
    weekdayLabels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    cancelText: 'Cancel',
    confirmText: 'Confirm',
    selectDateTitle: 'Select Date',
    selectTimeTitle: 'Select Time',
    amLabel: 'AM',
    pmLabel: 'PM',
    dateTabLabel: 'Date',
    timeTabLabel: 'Time',
    selectRangeTitle: 'Select Date Range',
    startDateLabel: 'Start date',
    endDateLabel: 'End date',
  );
}
