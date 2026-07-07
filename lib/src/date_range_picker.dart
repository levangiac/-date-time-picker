import 'package:flutter/material.dart';
import 'models/picker_config.dart';
import 'picker_constants.dart';
import 'shared_widgets.dart';

const _kInitialPage = 1200;

/// Vai trò của một ô ngày trong range.
enum _DayRole { normal, start, end, inRange, single }

// ── Public widget ─────────────────────────────────────────────────────────────

class CustomDateRangePicker extends StatefulWidget {
  final DateRangePickerConfig config;
  final ValueChanged<DateRange?> onRangeChanged;

  const CustomDateRangePicker({
    super.key,
    required this.config,
    required this.onRangeChanged,
  });

  @override
  State<CustomDateRangePicker> createState() => _CustomDateRangePickerState();
}

class _CustomDateRangePickerState extends State<CustomDateRangePicker> {
  late DateTime? _start;
  late DateTime? _end;
  late DateTime _currentMonth;
  late final DateTime _originMonth;
  late final PageController _pageController;
  bool _showYearPicker = false;

  @override
  void initState() {
    super.initState();
    _start = widget.config.initialRange?.start;
    _end = widget.config.initialRange?.end;
    final anchor = _start ?? DateTime.now();
    _currentMonth = DateTime(anchor.year, anchor.month);
    _originMonth = _currentMonth;
    _pageController = PageController(initialPage: _kInitialPage);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Orientation change → PageView unmount/remount → jump về tháng hiện tại.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _showYearPicker) return;
      final delta = (_currentMonth.year - _originMonth.year) * 12 +
          (_currentMonth.month - _originMonth.month);
      final targetPage = _kInitialPage + delta;
      if (_pageController.hasClients &&
          _pageController.page?.round() != targetPage) {
        _pageController.jumpToPage(targetPage);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  DateTime _monthFromPage(int page) {
    final delta = page - _kInitialPage;
    var month = _originMonth.month + delta;
    var year = _originMonth.year;
    while (month > 12) { month -= 12; year++; }
    while (month < 1)  { month += 12; year--; }
    return DateTime(year, month);
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  void _onDayTap(DateTime date) {
    setState(() {
      if (_start == null || (_start != null && _end != null)) {
        // Phase 1: chọn ngày bắt đầu
        _start = date;
        _end = null;
      } else {
        // Phase 2: chọn ngày kết thúc
        if (date.isBefore(_start!)) {
          _end = _start;
          _start = date;
        } else {
          _end = date;
        }
      }
    });
    final range = (_start != null && _end != null)
        ? DateRange(start: _start!, end: _end!)
        : null;
    widget.onRangeChanged(range);
  }

  void _jumpToYear(int year) {
    final target = DateTime(year, _currentMonth.month);
    final delta = (target.year - _originMonth.year) * 12 +
        (target.month - _originMonth.month);
    final targetPage = _kInitialPage + delta;

    setState(() {
      _currentMonth = target;
      _showYearPicker = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pageController.hasClients) {
        _pageController.jumpToPage(targetPage);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = PickerThemeData.of(context, override: widget.config.theme);
    final isLandscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;
    return isLandscape ? _buildLandscape(t) : _buildPortrait(t);
  }

  // ── Portrait ───────────────────────────────────────────────────────────────

  Widget _buildPortrait(PickerThemeData t) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _RangeHeader(
          start: _start,
          end: _end,
          config: widget.config,
          theme: t,
        ),
        _MonthNavRow(
          month: _currentMonth,
          locale: widget.config.locale,
          theme: t,
          showYearPicker: _showYearPicker,
          onPrev: _showYearPicker
              ? null
              : () => _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut),
          onNext: _showYearPicker
              ? null
              : () => _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut),
          onYearTap: () =>
              setState(() => _showYearPicker = !_showYearPicker),
        ),
        SizedBox(
          height: kPickerContentHeight,
          child: _showYearPicker
              ? _RangeYearGrid(
                  currentYear: _currentMonth.year,
                  firstYear: widget.config.firstDate.year,
                  lastYear: widget.config.lastDate.year,
                  theme: t,
                  onYearSelected: _jumpToYear,
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _WeekdayRow(
                        labels: widget.config.orderedWeekdayLabels, theme: t),
                    SizedBox(height: kPickerCalendarHeight, child: _pageView(t)),
                  ],
                ),
        ),
      ],
    );
  }

  // ── Landscape ──────────────────────────────────────────────────────────────

  Widget _buildLandscape(PickerThemeData t) {
    // SizedBox thay IntrinsicHeight — PageView không có intrinsic height.
    // Month nav được tích hợp vào left panel để right panel chỉ cần
    // kPickerContentHeight (260px), tránh tràn màn hình landscape.
    return SizedBox(
      height: kPickerContentHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Panel trái — range info + month navigation
          Container(
            width: 160,
            color: t.primary,
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: _RangeLandscapePanel(
              start: _start,
              end: _end,
              config: widget.config,
              theme: t,
              currentMonth: _currentMonth,
              showYearPicker: _showYearPicker,
              onPrev: _showYearPicker
                  ? null
                  : () => _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut),
              onNext: _showYearPicker
                  ? null
                  : () => _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut),
              onYearTap: () =>
                  setState(() => _showYearPicker = !_showYearPicker),
            ),
          ),
          // Panel phải — chỉ chứa calendar (không có month nav)
          Expanded(
            child: _showYearPicker
                ? _RangeYearGrid(
                    currentYear: _currentMonth.year,
                    firstYear: widget.config.firstDate.year,
                    lastYear: widget.config.lastDate.year,
                    theme: t,
                    onYearSelected: _jumpToYear,
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _WeekdayRow(
                          labels: widget.config.orderedWeekdayLabels, theme: t),
                      SizedBox(
                          height: kPickerCalendarHeight, child: _pageView(t)),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // ── PageView ───────────────────────────────────────────────────────────────

  Widget _pageView(PickerThemeData t) {
    return PageView.builder(
      controller: _pageController,
      onPageChanged: (page) =>
          setState(() => _currentMonth = _monthFromPage(page)),
      itemBuilder: (_, page) {
        final month = _monthFromPage(page);
        return _RangeCalendarGrid(
          month: month,
          start: _start,
          end: _end,
          config: widget.config,
          theme: t,
          onDayTap: _onDayTap,
          isSameDay: _isSameDay,
        );
      },
    );
  }
}

// ── Header với khoảng đã chọn ─────────────────────────────────────────────────

class _RangeHeader extends StatelessWidget {
  final DateTime? start;
  final DateTime? end;
  final DateRangePickerConfig config;
  final PickerThemeData theme;

  const _RangeHeader({
    required this.start,
    required this.end,
    required this.config,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final locale = config.locale;
    final t = theme;
    final startStr = start != null ? config.formatDate(start!) : '—';
    final endStr = end != null ? config.formatDate(end!) : '—';

    return Container(
      color: t.primary,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            locale.selectRangeTitle,
            style: (t.headerSubtitleStyle ?? const TextStyle(fontSize: 12))
                .copyWith(color: t.onPrimary.withValues(alpha: 0.75)),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _dateChip(locale.startDateLabel, startStr, t,
                  active: start != null)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Icon(Icons.arrow_forward,
                    color: t.onPrimary.withValues(alpha: 0.6), size: 18),
              ),
              Expanded(child: _dateChip(locale.endDateLabel, endStr, t,
                  active: end != null)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dateChip(String label, String value, PickerThemeData t,
      {required bool active}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: active
            ? t.onPrimary.withValues(alpha: 0.2)
            : t.onPrimary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: active ? t.onPrimary.withValues(alpha: 0.5) : Colors.transparent,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  color: t.onPrimary.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                  fontSize: 13,
                  color: t.onPrimary,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

/// Panel trái cho landscape — hiển thị range info + month navigation.
class _RangeLandscapePanel extends StatelessWidget {
  final DateTime? start;
  final DateTime? end;
  final DateRangePickerConfig config;
  final PickerThemeData theme;
  final DateTime currentMonth;
  final bool showYearPicker;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;
  final VoidCallback onYearTap;

  const _RangeLandscapePanel({
    required this.start,
    required this.end,
    required this.config,
    required this.theme,
    required this.currentMonth,
    required this.showYearPicker,
    required this.onPrev,
    required this.onNext,
    required this.onYearTap,
  });

  @override
  Widget build(BuildContext context) {
    final locale = config.locale;
    final t = theme;
    final startStr = start != null ? config.formatDate(start!) : '—';
    final endStr = end != null ? config.formatDate(end!) : '—';
    final monthLabel =
        '${locale.monthNames[currentMonth.month - 1]} ${currentMonth.year}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Range info
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              locale.selectRangeTitle,
              style: (t.headerSubtitleStyle ?? const TextStyle(fontSize: 11))
                  .copyWith(color: t.onPrimary.withValues(alpha: 0.75)),
            ),
            const SizedBox(height: 10),
            _chip(locale.startDateLabel, startStr, t),
            const SizedBox(height: 4),
            Icon(Icons.arrow_downward,
                color: t.onPrimary.withValues(alpha: 0.45), size: 14),
            const SizedBox(height: 4),
            _chip(locale.endDateLabel, endStr, t),
          ],
        ),
        // Month navigation ở đáy panel
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: onYearTap,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    monthLabel,
                    style: (t.headerTitleStyle ??
                            const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 13))
                        .copyWith(color: t.onPrimary),
                  ),
                  const SizedBox(width: 2),
                  AnimatedRotation(
                    turns: showYearPicker ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(Icons.arrow_drop_down,
                        color: t.onPrimary.withValues(alpha: 0.7), size: 18),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                if (onPrev != null)
                  _RangeNavBtn(
                      icon: Icons.chevron_left,
                      color: t.onPrimary,
                      onTap: onPrev!)
                else
                  const SizedBox(width: 36),
                const SizedBox(width: 4),
                if (onNext != null)
                  _RangeNavBtn(
                      icon: Icons.chevron_right,
                      color: t.onPrimary,
                      onTap: onNext!)
                else
                  const SizedBox(width: 36),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _chip(String label, String value, PickerThemeData t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 9,
                color: t.onPrimary.withValues(alpha: 0.65),
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 1),
        Text(value,
            style: TextStyle(
                fontSize: 12,
                color: t.onPrimary,
                fontWeight: FontWeight.w600)),
      ],
    );
  }
}

// ── Month navigation row (tách khỏi header màu) ───────────────────────────────

class _MonthNavRow extends StatelessWidget {
  final DateTime month;
  final PickerLocale locale;
  final PickerThemeData theme;
  final bool showYearPicker;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;
  final VoidCallback onYearTap;

  const _MonthNavRow({
    required this.month,
    required this.locale,
    required this.theme,
    required this.showYearPicker,
    required this.onPrev,
    required this.onNext,
    required this.onYearTap,
  });

  @override
  Widget build(BuildContext context) {
    final label = '${locale.monthNames[month.month - 1]} ${month.year}';
    final t = theme;
    return Container(
      color: t.surface,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Row(
        children: [
          if (onPrev != null)
            _RangeNavBtn(
                icon: Icons.chevron_left, color: t.onSurface, onTap: onPrev!)
          else
            const SizedBox(width: 40),
          Expanded(
            child: GestureDetector(
              onTap: onYearTap,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: (t.headerTitleStyle ??
                            const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 15))
                        .copyWith(color: t.onSurface),
                  ),
                  const SizedBox(width: 4),
                  AnimatedRotation(
                    turns: showYearPicker ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(Icons.arrow_drop_down,
                        color: t.onSurface.withValues(alpha: 0.6), size: 20),
                  ),
                ],
              ),
            ),
          ),
          if (onNext != null)
            _RangeNavBtn(
                icon: Icons.chevron_right, color: t.onSurface, onTap: onNext!)
          else
            const SizedBox(width: 40),
        ],
      ),
    );
  }
}

class _RangeNavBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _RangeNavBtn(
      {required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}

// ── Weekday row ───────────────────────────────────────────────────────────────

class _WeekdayRow extends StatelessWidget {
  final List<String> labels;
  final PickerThemeData theme;

  const _WeekdayRow({required this.labels, required this.theme});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: kPickerWeekdayRowHeight,
      child: Container(
        color: theme.resolvedWeekdayRowColor,
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: labels
              .map((d) => Expanded(
                    child: Center(
                      child: Text(
                        d,
                        style: theme.weekdayStyle ??
                            TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color:
                                  theme.onSurface.withValues(alpha: 0.45),
                              letterSpacing: 0.3,
                            ),
                      ),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }
}

// ── Range calendar grid ───────────────────────────────────────────────────────

class _RangeCalendarGrid extends StatelessWidget {
  final DateTime month;
  final DateTime? start;
  final DateTime? end;
  final DateRangePickerConfig config;
  final PickerThemeData theme;
  final ValueChanged<DateTime> onDayTap;
  final bool Function(DateTime, DateTime) isSameDay;

  const _RangeCalendarGrid({
    required this.month,
    required this.start,
    required this.end,
    required this.config,
    required this.theme,
    required this.onDayTap,
    required this.isSameDay,
  });

  _DayRole _role(DateTime date) {
    if (start == null) return _DayRole.normal;
    final isStart = isSameDay(date, start!);
    if (end == null) return isStart ? _DayRole.single : _DayRole.normal;
    final isEnd = isSameDay(date, end!);
    if (isStart && isEnd) return _DayRole.single;
    if (isStart) return _DayRole.start;
    if (isEnd) return _DayRole.end;
    if (date.isAfter(start!) && date.isBefore(end!)) return _DayRole.inRange;
    return _DayRole.normal;
  }

  bool _isFirstInRow(int dayIndex, int offset) {
    return (dayIndex + offset) % 7 == 0;
  }

  bool _isLastInRow(int dayIndex, int offset) {
    return (dayIndex + offset) % 7 == 6;
  }

  @override
  Widget build(BuildContext context) {
    final firstOfMonth = DateTime(month.year, month.month, 1);
    final lastOfMonth = DateTime(month.year, month.month + 1, 0);
    final offset =
        (firstOfMonth.weekday - config.weekStartDay.dartWeekday + 7) % 7;
    final today = DateTime.now();

    final cells = <Widget>[
      for (var i = 0; i < offset; i++) const SizedBox.shrink(),
      for (var d = 1; d <= lastOfMonth.day; d++)
        _buildRangeDay(
          date: DateTime(month.year, month.month, d),
          today: today,
          dayIndex: d - 1,
          offset: offset,
          lastDay: lastOfMonth.day,
        ),
    ];

    return GridView(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisExtent: kPickerCellSize,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      children: cells,
    );
  }

  Widget _buildRangeDay({
    required DateTime date,
    required DateTime today,
    required int dayIndex,
    required int offset,
    required int lastDay,
  }) {
    final role = _role(date);
    final isDisabled =
        date.isBefore(config.firstDate) || date.isAfter(config.lastDate);
    final isToday = isSameDay(date, today);
    final t = theme;
    final bandColor = t.resolvedRangeBandColor;

    // Xác định có phải đầu/cuối hàng để tránh band chạm viền
    final firstRow = _isFirstInRow(dayIndex, offset);
    final lastRow = _isLastInRow(dayIndex, offset);
    final isLastDay = dayIndex == lastDay - 1;

    TextStyle textStyle;
    Color? circleColor;
    Color textColor;

    if (role == _DayRole.normal) {
      textColor = isDisabled
          ? t.disabledColor
          : isToday
              ? t.primary
              : t.onSurface;
      textStyle = TextStyle(
          fontSize: 13,
          fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
          color: textColor);
    } else if (role == _DayRole.inRange) {
      textColor = t.onSurface;
      textStyle = TextStyle(fontSize: 13, color: textColor);
    } else {
      // start, end, single
      circleColor = t.primary;
      textColor = t.onPrimary;
      textStyle = TextStyle(
          fontSize: 13, fontWeight: FontWeight.bold, color: textColor);
    }

    return GestureDetector(
      onTap: isDisabled ? null : () => onDayTap(date),
      child: SizedBox(
        height: kPickerCellSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Band background — chỉ vẽ khi có range
            if (role != _DayRole.normal && role != _DayRole.single)
              Positioned.fill(
                child: _buildBand(
                  role: role,
                  bandColor: bandColor,
                  firstRow: firstRow,
                  lastRow: lastRow || isLastDay,
                ),
              ),

            // Nửa band bổ sung cho start/end khi cần
            if (role == _DayRole.start && end != null && !isLastDay)
              Positioned.fill(
                child: Row(children: [
                  const Spacer(),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      color: lastRow ? Colors.transparent : bandColor,
                    ),
                  ),
                ]),
              ),
            if (role == _DayRole.end && start != null && !firstRow)
              Positioned.fill(
                child: Row(children: [
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      color: firstRow ? Colors.transparent : bandColor,
                    ),
                  ),
                  const Spacer(),
                ]),
              ),

            // Circle (selected / today)
            if (circleColor != null)
              Container(
                width: kPickerCellSize - 6,
                height: kPickerCellSize - 6,
                decoration: BoxDecoration(
                  color: circleColor,
                  shape: BoxShape.circle,
                ),
              ),
            if (circleColor == null && isToday)
              Container(
                width: kPickerCellSize - 6,
                height: kPickerCellSize - 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: t.resolvedTodayBorderColor, width: 1.5),
                ),
              ),

            // Text
            Text('${date.day}', style: textStyle),
          ],
        ),
      ),
    );
  }

  Widget _buildBand(
      {required _DayRole role,
      required Color bandColor,
      required bool firstRow,
      required bool lastRow}) {
    if (role == _DayRole.inRange) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        color: bandColor,
      );
    }
    return const SizedBox.shrink();
  }
}

// ── Year picker (tái sử dụng logic, tách widget riêng) ────────────────────────

class _RangeYearGrid extends StatefulWidget {
  final int currentYear;
  final int firstYear;
  final int lastYear;
  final PickerThemeData theme;
  final ValueChanged<int> onYearSelected;

  const _RangeYearGrid({
    required this.currentYear,
    required this.firstYear,
    required this.lastYear,
    required this.theme,
    required this.onYearSelected,
  });

  @override
  State<_RangeYearGrid> createState() => _RangeYearGridState();
}

class _RangeYearGridState extends State<_RangeYearGrid> {
  late final ScrollController _scrollCtrl;

  @override
  void initState() {
    super.initState();
    const cols = 3;
    const itemH = 48.0;
    final rowIndex = (widget.currentYear - widget.firstYear) ~/ cols;
    final offset = (rowIndex - 1) * itemH;
    _scrollCtrl =
        ScrollController(initialScrollOffset: offset.clamp(0, double.infinity));
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final years = List.generate(
      widget.lastYear - widget.firstYear + 1,
      (i) => widget.firstYear + i,
    );
    final thisYear = DateTime.now().year;
    final t = widget.theme;

    return GridView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisExtent: 44,
        crossAxisSpacing: 8,
        mainAxisSpacing: 4,
      ),
      itemCount: years.length,
      itemBuilder: (_, i) {
        final year = years[i];
        final isSelected = year == widget.currentYear;
        final isCurrent = year == thisYear;

        return GestureDetector(
          onTap: () => widget.onYearSelected(year),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: isSelected ? t.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(22),
              border: isCurrent && !isSelected
                  ? Border.all(color: t.primary, width: 1.5)
                  : null,
            ),
            child: Center(
              child: Text(
                '$year',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? t.onPrimary
                      : isCurrent
                          ? t.primary
                          : t.onSurface,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Dialog helper ─────────────────────────────────────────────────────────────

Future<DateRange?> showCustomDateRangePicker({
  required BuildContext context,
  required DateRangePickerConfig config,
}) {
  return showDialog<DateRange>(
    context: context,
    builder: (ctx) {
      DateRange? picked = config.initialRange;

      return OrientationBuilder(
        builder: (ctx2, orientation) {
          final t2 = PickerThemeData.of(ctx2, override: config.theme);
          final isLandscape = orientation == Orientation.landscape;

          return Dialog(
            backgroundColor: t2.surface,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(t2.dialogBorderRadius)),
            clipBehavior: Clip.antiAlias,
            insetPadding: isLandscape
                ? const EdgeInsets.symmetric(horizontal: 24, vertical: 4)
                : const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isLandscape ? 560 : 380,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomDateRangePicker(
                    config: config,
                    onRangeChanged: (r) => picked = r,
                  ),
                  PickerActionBar(
                    theme: t2,
                    locale: config.locale,
                    onCancel: () => Navigator.pop(ctx),
                    onConfirm: () => Navigator.pop(ctx, picked),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
