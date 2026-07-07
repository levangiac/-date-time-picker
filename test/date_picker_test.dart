import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vn_date_time_picker/vn_date_time_picker.dart';

Widget _wrap(Widget child) => MaterialApp(
      home: Scaffold(body: child),
    );

final _base = DatePickerConfig(
  firstDate: DateTime(2020),
  lastDate: DateTime(2030),
  initialDate: DateTime(2024, 6, 15),
  locale: PickerLocale.vi,
);

void main() {
  // ── Render & điều hướng ────────────────────────────────────────────────────

  testWidgets('renders header tháng VI', (tester) async {
    await tester.pumpWidget(_wrap(
      CustomDatePicker(config: _base, onDateSelected: (_) {}),
    ));
    expect(find.text('Tháng 6 2024'), findsOneWidget);
  });

  testWidgets('renders header month EN', (tester) async {
    final config = DatePickerConfig(
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDate: DateTime(2024, 6, 15),
      locale: PickerLocale.en,
    );
    await tester.pumpWidget(_wrap(
      CustomDatePicker(config: config, onDateSelected: (_) {}),
    ));
    expect(find.text('June 2024'), findsOneWidget);
  });

  testWidgets('chọn ngày gọi callback đúng', (tester) async {
    DateTime? picked;
    await tester.pumpWidget(_wrap(
      CustomDatePicker(config: _base, onDateSelected: (d) => picked = d),
    ));
    await tester.pumpAndSettle(); // PageView cần settle
    await tester.tap(find.text('20'));
    await tester.pump();
    expect(picked?.day, 20);
  });

  testWidgets('điều hướng sang tháng trước', (tester) async {
    await tester.pumpWidget(_wrap(
      CustomDatePicker(config: _base, onDateSelected: (_) {}),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pumpAndSettle(); // chờ animation PageView
    expect(find.text('Tháng 5 2024'), findsOneWidget);
  });

  // ── WeekStartDay ──────────────────────────────────────────────────────────

  test('VI - bắt đầu từ Chủ nhật (mặc định)', () {
    final c = DatePickerConfig(
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      weekStartDay: WeekStartDay.sunday,
      locale: PickerLocale.vi,
    );
    expect(c.orderedWeekdayLabels.first, 'CN');
    expect(c.orderedWeekdayLabels.last, 'T7');
  });

  test('VI - bắt đầu từ Thứ 2', () {
    final c = DatePickerConfig(
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      weekStartDay: WeekStartDay.monday,
      locale: PickerLocale.vi,
    );
    expect(c.orderedWeekdayLabels.first, 'T2');
    expect(c.orderedWeekdayLabels.last, 'CN');
  });

  test('EN - bắt đầu từ Sunday', () {
    final c = DatePickerConfig(
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      weekStartDay: WeekStartDay.sunday,
      locale: PickerLocale.en,
    );
    expect(c.orderedWeekdayLabels.first, 'Sun');
    expect(c.orderedWeekdayLabels.last, 'Sat');
  });

  test('EN - bắt đầu từ Monday', () {
    final c = DatePickerConfig(
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      weekStartDay: WeekStartDay.monday,
      locale: PickerLocale.en,
    );
    expect(c.orderedWeekdayLabels.first, 'Mon');
    expect(c.orderedWeekdayLabels.last, 'Sun');
  });

  // ── DateFormatPattern ─────────────────────────────────────────────────────

  final date = DateTime(2024, 6, 5);

  test('ddMMyyyy → 05/06/2024', () {
    final c = DatePickerConfig(
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      dateFormatPattern: DateFormatPattern.ddMMyyyy,
      locale: PickerLocale.vi,
    );
    expect(c.formatDate(date), '05/06/2024');
  });

  test('MMddyyyy → 06/05/2024', () {
    final c = DatePickerConfig(
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      dateFormatPattern: DateFormatPattern.MMddyyyy,
      locale: PickerLocale.en,
    );
    expect(c.formatDate(date), '06/05/2024');
  });

  test('yyyyMMdd → 2024-06-05', () {
    final c = DatePickerConfig(
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      dateFormatPattern: DateFormatPattern.yyyyMMdd,
      locale: PickerLocale.vi,
    );
    expect(c.formatDate(date), '2024-06-05');
  });

  test('ddMMMyyyy VI → 05 Tháng 6 2024', () {
    final c = DatePickerConfig(
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      dateFormatPattern: DateFormatPattern.ddMMMyyyy,
      locale: PickerLocale.vi,
    );
    expect(c.formatDate(date), '05 Tháng 6 2024');
  });

  test('MMMddyyyy EN → June 05, 2024', () {
    final c = DatePickerConfig(
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      dateFormatPattern: DateFormatPattern.MMMddyyyy,
      locale: PickerLocale.en,
    );
    expect(c.formatDate(date), 'June 05, 2024');
  });

  // ── PickerLocale ──────────────────────────────────────────────────────────

  test('PickerLocale.vi có đủ 12 tháng và 7 ngày', () {
    expect(PickerLocale.vi.monthNames.length, 12);
    expect(PickerLocale.vi.weekdayLabels.length, 7);
    expect(PickerLocale.vi.cancelText, 'Hủy');
    expect(PickerLocale.vi.amLabel, 'SA');
  });

  test('PickerLocale.en có đủ 12 tháng và 7 ngày', () {
    expect(PickerLocale.en.monthNames.length, 12);
    expect(PickerLocale.en.weekdayLabels.length, 7);
    expect(PickerLocale.en.cancelText, 'Cancel');
    expect(PickerLocale.en.amLabel, 'AM');
  });

  // ── PickerThemeData ───────────────────────────────────────────────────────

  test('PickerThemeData.fromSeed tạo onPrimary sáng cho màu tối', () {
    final t = PickerThemeData.fromSeed(Colors.black);
    expect(t.onPrimary, Colors.white);
  });

  test('PickerThemeData.fromSeed tạo onPrimary tối cho màu sáng', () {
    final t = PickerThemeData.fromSeed(Colors.white);
    expect(t.onPrimary, Colors.black87);
  });

  test('PickerThemeData.copyWith ghi đè đúng field', () {
    final t = PickerThemeData.fromSeed(Colors.blue)
        .copyWith(dialogBorderRadius: 24);
    expect(t.dialogBorderRadius, 24);
    expect(t.primary, Colors.blue);
  });

  // ── DateTimePickerResult ──────────────────────────────────────────────────

  test('DateTimePickerResult.toDateTime đúng', () {
    final r = DateTimePickerResult(
      date: DateTime(2024, 6, 15),
      time: const TimeOfDay(hour: 10, minute: 30),
    );
    final dt = r.toDateTime();
    expect(dt.year, 2024);
    expect(dt.month, 6);
    expect(dt.day, 15);
    expect(dt.hour, 10);
    expect(dt.minute, 30);
  });
}
