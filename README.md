# vn_date_time_picker

A fully customizable date, time, date-time, and date range picker for Flutter — with Vietnamese & English support, year picker, haptic feedback, responsive portrait/landscape layout, and complete theming.

## Features

- **Date Picker** — month calendar with infinite scroll, tap header to open year grid
- **Time Picker** — scroll wheel (12h / 24h), AM/PM toggle, haptic feedback (bật/tắt)
- **Date-Time Picker** — combined tab UI (Date | Time)
- **Date Range Picker** — Google Calendar-style band highlight, year grid
- **i18n** — built-in Vietnamese & English; extensible to any language
- **Full theming** — every color, radius, and text style is overridable
- **Responsive** — portrait and landscape layouts, state preserved on rotation
- **Zero dependencies** — only Flutter SDK

---

## Screenshots

| Date Picker | Time Picker | Range Picker | Year Grid |
|:-----------:|:-----------:|:------------:|:---------:|
| _(portrait)_ | _(portrait)_ | _(portrait)_ | _(overlay)_ |

> Run `flutter run` inside `example/` to see all pickers on a real device.

---

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  vn_date_time_picker: ^0.2.0
```

Then import:

```dart
import 'package:vn_date_time_picker/vn_date_time_picker.dart';
```

---

## Quick Start

### Date Picker

```dart
final date = await showCustomDatePicker(
  context: context,
  config: DatePickerConfig(
    firstDate: DateTime(2020),
    lastDate: DateTime(2030),
    initialDate: DateTime.now(),
    locale: PickerLocale.vi,           // tiếng Việt
    weekStartDay: WeekStartDay.monday,
    dateFormatPattern: DateFormatPattern.ddMMMyyyy,
  ),
);
// date → DateTime? (null nếu người dùng bấm Hủy)
```

### Time Picker

```dart
final time = await showCustomTimePicker(
  context: context,
  config: TimePickerConfig(
    initialTime: TimeOfDay.now(),
    use24HourFormat: false,            // 12h với AM/PM
    locale: PickerLocale.vi,
    haptic: TimePickerHaptic.selectionClick, // rung nhẹ mỗi item (mặc định)
  ),
);
// time → TimeOfDay?
```

### Date-Time Picker

```dart
final result = await showCustomDateTimePicker(
  context: context,
  dateConfig: DatePickerConfig(
    firstDate: DateTime(2020),
    lastDate: DateTime(2030),
    locale: PickerLocale.vi,
  ),
  timeConfig: TimePickerConfig(
    use24HourFormat: false,
    locale: PickerLocale.vi,
  ),
);
// result → DateTimePickerResult?
// result.date      → DateTime
// result.time      → TimeOfDay
// result.toDateTime() → DateTime (combined)
```

### Date Range Picker

```dart
final range = await showCustomDateRangePicker(
  context: context,
  config: DateRangePickerConfig(
    firstDate: DateTime(2020),
    lastDate: DateTime(2030),
    locale: PickerLocale.vi,
    weekStartDay: WeekStartDay.monday,
  ),
);
// range → DateRange?
// range.start    → DateTime
// range.end      → DateTime
// range.dayCount → int (số ngày inclusive)
```

---

## API Reference

### `DatePickerConfig`

| Property | Type | Default | Description |
|---|---|---|---|
| `firstDate` | `DateTime` | required | Ngày nhỏ nhất có thể chọn |
| `lastDate` | `DateTime` | required | Ngày lớn nhất có thể chọn |
| `initialDate` | `DateTime?` | `DateTime.now()` | Ngày được chọn sẵn |
| `weekStartDay` | `WeekStartDay` | `.sunday` | Ngày đầu tuần |
| `dateFormatPattern` | `DateFormatPattern` | `.ddMMyyyy` | Định dạng ngày |
| `locale` | `PickerLocale` | `PickerLocale.vi` | Ngôn ngữ |
| `theme` | `PickerThemeData?` | _(app theme)_ | Giao diện |

### `TimePickerConfig`

| Property | Type | Default | Description |
|---|---|---|---|
| `initialTime` | `TimeOfDay?` | `TimeOfDay.now()` | Giờ chọn sẵn |
| `use24HourFormat` | `bool` | `false` | Chế độ 24h |
| `locale` | `PickerLocale` | `PickerLocale.vi` | Ngôn ngữ |
| `theme` | `PickerThemeData?` | _(app theme)_ | Giao diện |
| `haptic` | `TimePickerHaptic` | `.selectionClick` | Kiểu rung khi xoay bánh xe |

### `TimePickerHaptic`

```dart
TimePickerHaptic.none           // Tắt rung hoàn toàn
TimePickerHaptic.selectionClick // Rung nhẹ kiểu iOS (mặc định)
TimePickerHaptic.lightImpact    // Rung nhẹ hơn
TimePickerHaptic.mediumImpact   // Rung vừa
```

> **Android**: cần thêm vào `AndroidManifest.xml`:
> ```xml
> <uses-permission android:name="android.permission.VIBRATE"/>
> ```
> **iOS**: không cần quyền gì thêm.

### `DateRangePickerConfig`

| Property | Type | Default | Description |
|---|---|---|---|
| `firstDate` | `DateTime` | required | Giới hạn nhỏ nhất |
| `lastDate` | `DateTime` | required | Giới hạn lớn nhất |
| `initialRange` | `DateRange?` | `null` | Khoảng chọn sẵn |
| `weekStartDay` | `WeekStartDay` | `.sunday` | Ngày đầu tuần |
| `dateFormatPattern` | `DateFormatPattern` | `.ddMMyyyy` | Định dạng ngày |
| `locale` | `PickerLocale` | `PickerLocale.vi` | Ngôn ngữ |
| `theme` | `PickerThemeData?` | _(app theme)_ | Giao diện |

### `WeekStartDay`

```dart
WeekStartDay.monday   // Tuần bắt đầu từ Thứ 2
WeekStartDay.sunday   // Tuần bắt đầu từ Chủ nhật
WeekStartDay.saturday // Tuần bắt đầu từ Thứ 7
// ... tuesday, wednesday, thursday, friday
```

### `DateFormatPattern`

```dart
DateFormatPattern.ddMMyyyy     // 15/06/2024
DateFormatPattern.MMddyyyy     // 06/15/2024
DateFormatPattern.yyyyMMdd     // 2024-06-15
DateFormatPattern.ddMMyyyy_dot // 15.06.2024
DateFormatPattern.MMMddyyyy    // June 15, 2024
DateFormatPattern.ddMMMyyyy    // 15 June 2024
```

### `DateRange`

```dart
range.start    // → DateTime (ngày bắt đầu)
range.end      // → DateTime (ngày kết thúc)
range.dayCount // → int     (số ngày inclusive)
```

---

## Theming

### Cách 1 — Dùng màu của app (tự động)

Nếu không truyền `theme`, picker sẽ tự lấy `ColorScheme` của `MaterialApp`:

```dart
MaterialApp(
  theme: ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
    useMaterial3: true,
  ),
  // ... picker sẽ tự dùng màu indigo
)
```

### Cách 2 — Từ một màu seed

```dart
theme: PickerThemeData.fromSeed(Colors.teal),
```

### Cách 3 — Tùy chỉnh hoàn toàn

```dart
theme: PickerThemeData(
  // Màu cốt lõi
  primary: const Color(0xFF006494),
  onPrimary: Colors.white,
  surface: const Color(0xFFF8F9FA),
  onSurface: const Color(0xFF1C1B1F),
  disabledColor: const Color(0xFFBDBDBD),

  // Màu chi tiết (nullable — tự suy từ primary nếu null)
  weekdayRowColor: const Color(0xFFE3F2FD),  // nền hàng CN T2 T3…
  rangeBandColor: const Color(0xFFBBDEFB),   // dải khoảng range picker
  todayBorderColor: Colors.orange,           // viền ô hôm nay

  // Hình dạng
  dialogBorderRadius: 20.0,
  selectedDayRadius: 8.0,     // double.infinity = tròn hoàn toàn (mặc định)

  // Override decoration ngày được chọn (tùy chọn)
  selectedDayDecoration: BoxDecoration(
    gradient: const LinearGradient(
      colors: [Color(0xFF006494), Color(0xFF0096C7)],
    ),
    borderRadius: BorderRadius.circular(8),
  ),

  // TextStyle
  headerTitleStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
  headerSubtitleStyle: const TextStyle(fontSize: 12),
  weekdayStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
  dayStyle: const TextStyle(fontSize: 13),
  selectedDayStyle: const TextStyle(fontWeight: FontWeight.bold),
  timeWheelStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
  timeSelectedStyle: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
)
```

### Cách 4 — Override một phần với `copyWith`

```dart
theme: PickerThemeData.fromSeed(Colors.indigo).copyWith(
  todayBorderColor: Colors.orange,
  selectedDayRadius: 6,
  weekdayRowColor: Colors.indigo.shade50,
),
```

### Dark theme

```dart
theme: const PickerThemeData(
  primary: Color(0xFF90CAF9),
  onPrimary: Color(0xFF0D1B2A),
  surface: Color(0xFF1E1E2E),
  onSurface: Color(0xFFE0E0E0),
  disabledColor: Color(0xFF4A4A5A),
),
```

---

## Localization

### Tiếng Việt (mặc định)

```dart
locale: PickerLocale.vi,
```

### English

```dart
locale: PickerLocale.en,
```

### Ngôn ngữ tùy chỉnh

```dart
locale: const PickerLocale(
  monthNames: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
               'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
  weekdayLabels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
  cancelText: 'Cancel',
  confirmText: 'OK',
  selectDateTitle: 'Pick a date',
  selectTimeTitle: 'Pick a time',
  amLabel: 'AM',
  pmLabel: 'PM',
  dateTabLabel: 'Date',
  timeTabLabel: 'Time',
  selectRangeTitle: 'Select range',
  startDateLabel: 'From',
  endDateLabel: 'To',
),
```

---

## Sử dụng widget trực tiếp (không dùng dialog)

```dart
// Nhúng trực tiếp vào UI
CustomDatePicker(
  config: DatePickerConfig(
    firstDate: DateTime(2020),
    lastDate: DateTime(2030),
  ),
  onDateSelected: (date) => setState(() => _date = date),
)

CustomTimePicker(
  config: TimePickerConfig(
    haptic: TimePickerHaptic.selectionClick,
  ),
  onTimeSelected: (time) => setState(() => _time = time),
)

CustomDateRangePicker(
  config: DateRangePickerConfig(
    firstDate: DateTime(2020),
    lastDate: DateTime(2030),
  ),
  onRangeChanged: (range) => setState(() => _range = range),
)
```

---

## Yêu cầu môi trường

| Yêu cầu | Phiên bản tối thiểu |
|---|---|
| Dart SDK | ≥ 3.0.0 |
| Flutter | ≥ 3.27.0 |

---

## Changelog

Xem [CHANGELOG.md](CHANGELOG.md).

---

## License

MIT License — xem file [LICENSE](LICENSE).
