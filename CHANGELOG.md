# Changelog

All notable changes to this project will be documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.3] - 2026-07-13

### Added
- Ảnh screenshots (`date_picker.png`, `time_picker.png`, `date_time_picker.png`, `range_picker.png`, `year_grid.png`) hiển thị trên trang pub.dev và README

## [0.2.2] - 2026-07-07

### Fixed
- **`CustomDateTimePicker` landscape — dialog overflow**: `Tab` icon+text nhận chiều cao mặc định `72px` (`kTextAndIconTabHeight`) dù nội dung chỉ cần ~37px, khiến tổng chiều cao (TabBar + content + action bar) vượt quá không gian dialog trên máy màn hình ngắn ở landscape → `RenderFlex OVERFLOWING`. Thêm hằng `kPickerTabBarHeight` (44px) và set `height` tường minh cho từng `Tab`.

## [0.2.1] - 2026-07-07

### Fixed
- Rút ngắn description trong pubspec.yaml (pub.dev yêu cầu 60–180 ký tự)
- Cập nhật homepage, repository, issue_tracker về đúng URL GitHub

## [0.2.0] - 2026-07-07

### Added
- `TimePickerHaptic` enum — bật/tắt và chọn kiểu rung khi xoay bánh xe giờ/phút
  - `TimePickerHaptic.none` — tắt rung
  - `TimePickerHaptic.selectionClick` — rung nhẹ kiểu iOS (mặc định)
  - `TimePickerHaptic.lightImpact` — rung rất nhẹ
  - `TimePickerHaptic.mediumImpact` — rung vừa
- `TimePickerConfig.haptic` property

### Fixed
- **Landscape rotation — layout crash**: `IntrinsicHeight` + `PageView`/`ListWheelScrollView` không tính được intrinsic height → thay bằng `SizedBox` với chiều cao tường minh
- **Landscape rotation — dialog overflow**: `insetPadding` của Dialog bị capture một lần lúc mở → dùng `OrientationBuilder` để reactive khi xoay
- **Landscape rotation — wheels disappear**: `ShaderMask + BlendMode.dstOut` mất compositing layer sau khi xoay → thay bằng gradient overlay (`Stack + Positioned + DecoratedBox`)
- **Landscape rotation — state reset**: `ListWheelScrollView` unmount/remount khi cấu trúc widget tree thay đổi → scroll controller khởi tạo lại từ `initialItem` → dùng `didChangeDependencies + addPostFrameCallback + jumpToItem` để sync vị trí
- **Landscape rotation — PageView reset**: `PageController` bị reset về tháng ban đầu khi xoay → fix tương tự với `didChangeDependencies + jumpToPage`
- **Date range picker landscape**: `_MonthNavRow` trong right panel gây thêm 44px → tích hợp navigation vào left panel mới `_RangeLandscapePanel`, right panel chỉ còn calendar
- Bỏ `SingleChildScrollView` bọc `CustomTimePicker` trong dialog — tránh nested scrollable với `ListWheelScrollView`
- `kPickerTimeLandscapeHeight` constant được thêm vào `picker_constants.dart`

## [0.1.0] - 2026-07-07

### Added
- `CustomDatePicker` — calendar với infinite scroll và year picker overlay
- `CustomTimePicker` — scroll wheel 12h/24h với AM/PM toggle
- `CustomDateTimePicker` — picker kết hợp dạng tab Date | Time
- `CustomDateRangePicker` — chọn khoảng ngày kiểu Google Calendar
- `showCustomDatePicker()`, `showCustomTimePicker()`, `showCustomDateTimePicker()`, `showCustomDateRangePicker()` — dialog helpers
- `PickerLocale` với preset `vi` (tiếng Việt) và `en` (English)
- `PickerThemeData` — tuỳ chỉnh toàn bộ màu sắc, hình dạng, text style
- `PickerThemeData.fromSeed(Color)` — tự suy ra theme từ một màu
- `PickerThemeData.of(context)` — lấy theme từ `ColorScheme` của app
- `DatePickerConfig`, `TimePickerConfig`, `DateRangePickerConfig`
- `WeekStartDay` enum — cấu hình ngày đầu tuần (Thứ 2 → Chủ nhật)
- `DateFormatPattern` enum — 6 định dạng ngày phổ biến
- `weekdayRowColor`, `rangeBandColor`, `todayBorderColor` trong `PickerThemeData`
- Responsive layout portrait và landscape
- Hỗ trợ Flutter ≥ 3.27.0 với `Color.withValues()`, `ColorScheme.of()`, `MediaQuery.orientationOf()`
