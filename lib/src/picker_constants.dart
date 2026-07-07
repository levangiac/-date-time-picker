/// Hằng số layout dùng chung cho tất cả calendar-based pickers.
const double kPickerCellSize = 36.0;
const double kPickerCalendarHeight = kPickerCellSize * 6 + 8; // 224
const double kPickerWeekdayRowHeight = 36.0;
/// Tổng chiều cao vùng nội dung calendar (weekday row + grid).
const double kPickerContentHeight =
    kPickerWeekdayRowHeight + kPickerCalendarHeight; // 260

/// Chiều cao landscape panel bên trái (time picker).
/// _kWheelH (240) + vertical padding top+bottom (12*2=24).
const double kPickerTimeLandscapeHeight = 264.0;
