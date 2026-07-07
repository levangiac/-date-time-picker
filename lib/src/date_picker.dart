import 'package:flutter/material.dart';
import 'models/picker_config.dart';
import 'picker_constants.dart';
import 'shared_widgets.dart';

const _kInitialPage = 1200;

// ── Public widget ─────────────────────────────────────────────────────────────

class CustomDatePicker extends StatefulWidget {
  final DatePickerConfig config;
  final ValueChanged<DateTime> onDateSelected;

  const CustomDatePicker({
    super.key,
    required this.config,
    required this.onDateSelected,
  });

  @override
  State<CustomDatePicker> createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<CustomDatePicker> {
  late DateTime _selectedDate;
  late DateTime _currentMonth;
  late final DateTime _originMonth;
  late final PageController _pageController;
  bool _showYearPicker = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.config.initialDate ?? DateTime.now();
    _currentMonth = DateTime(_selectedDate.year, _selectedDate.month);
    _originMonth = _currentMonth;
    _pageController = PageController(initialPage: _kInitialPage);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Orientation change → cấu trúc widget tree thay đổi (Column ↔ Row)
    // → PageView unmount/remount với initialPage từ initState.
    // Jump lại đúng tháng hiện tại sau khi frame hoàn tất.
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

  void _jumpToYear(int year) {
    final target = DateTime(year, _currentMonth.month);
    final delta = (target.year - _originMonth.year) * 12 +
        (target.month - _originMonth.month);
    final targetPage = _kInitialPage + delta;

    // Ẩn year grid trước → PageView được mount lại → rồi mới jump
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

  // ── Portrait ─────────────────────────────────────────────────────────────

  Widget _buildPortrait(PickerThemeData t) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _MonthHeader(
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
              ? _YearGrid(
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

  // ── Landscape ────────────────────────────────────────────────────────────

  Widget _buildLandscape(PickerThemeData t) {
    final locale = widget.config.locale;
    final monthName = locale.monthNames[_currentMonth.month - 1];
    final weekday = locale.weekdayLabels[(_selectedDate.weekday - 1) % 7];

    // SizedBox thay IntrinsicHeight — PageView không có intrinsic height
    return SizedBox(
      height: kPickerContentHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Panel trái
          Container(
            width: 140,
            color: t.primary,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$monthName ${_currentMonth.year}',
                      style: (t.headerSubtitleStyle ??
                              const TextStyle(fontSize: 13))
                          .copyWith(
                              color: t.onPrimary.withValues(alpha: 0.75)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_selectedDate.day}',
                      style: (t.headerTitleStyle ??
                              const TextStyle(
                                  fontSize: 52,
                                  fontWeight: FontWeight.w300))
                          .copyWith(color: t.onPrimary),
                    ),
                    Text(
                      weekday,
                      style: (t.headerSubtitleStyle ??
                              const TextStyle(fontSize: 13))
                          .copyWith(
                              color: t.onPrimary.withValues(alpha: 0.75)),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _NavBtn(
                        icon: Icons.chevron_left,
                        color: t.onPrimary,
                        onTap: () => _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut)),
                    _NavBtn(
                        icon: Icons.chevron_right,
                        color: t.onPrimary,
                        onTap: () => _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut)),
                  ],
                ),
              ],
            ),
          ),
          // Panel phải
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _WeekdayRow(
                    labels: widget.config.orderedWeekdayLabels, theme: t),
                SizedBox(height: kPickerCalendarHeight, child: _pageView(t)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── PageView ──────────────────────────────────────────────────────────────

  Widget _pageView(PickerThemeData t) {
    return PageView.builder(
      controller: _pageController,
      onPageChanged: (page) =>
          setState(() => _currentMonth = _monthFromPage(page)),
      itemBuilder: (_, page) {
        final month = _monthFromPage(page);
        return _CalendarGrid(
          month: month,
          selectedDate: _selectedDate,
          config: widget.config,
          theme: t,
          onDayTap: (date) {
            setState(() => _selectedDate = date);
            widget.onDateSelected(date);
          },
          isSameDay: _isSameDay,
        );
      },
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _MonthHeader extends StatelessWidget {
  final DateTime month;
  final PickerLocale locale;
  final PickerThemeData theme;
  final bool showYearPicker;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;
  final VoidCallback onYearTap;

  const _MonthHeader({
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
    return Container(
      color: theme.primary,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      child: Row(
        children: [
          if (onPrev != null)
            _NavBtn(
                icon: Icons.chevron_left,
                color: theme.onPrimary,
                onTap: onPrev!)
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
                    textAlign: TextAlign.center,
                    style: (theme.headerTitleStyle ??
                            const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 16))
                        .copyWith(color: theme.onPrimary),
                  ),
                  const SizedBox(width: 4),
                  AnimatedRotation(
                    turns: showYearPicker ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(Icons.arrow_drop_down,
                        color: theme.onPrimary, size: 20),
                  ),
                ],
              ),
            ),
          ),
          if (onNext != null)
            _NavBtn(
                icon: Icons.chevron_right,
                color: theme.onPrimary,
                onTap: onNext!)
          else
            const SizedBox(width: 40),
        ],
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _NavBtn({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }
}

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
                              color: theme.onSurface.withValues(alpha: 0.45),
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

class _CalendarGrid extends StatelessWidget {
  final DateTime month;
  final DateTime selectedDate;
  final DatePickerConfig config;
  final PickerThemeData theme;
  final ValueChanged<DateTime> onDayTap;
  final bool Function(DateTime, DateTime) isSameDay;

  const _CalendarGrid({
    required this.month,
    required this.selectedDate,
    required this.config,
    required this.theme,
    required this.onDayTap,
    required this.isSameDay,
  });

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
        _buildDay(DateTime(month.year, month.month, d), today),
    ];

    return GridView(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisExtent: kPickerCellSize,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      children: cells,
    );
  }

  BoxDecoration _dayDeco(Color? color, {BoxBorder? border}) {
    final r = theme.selectedDayRadius;
    if (r == double.infinity) {
      return BoxDecoration(shape: BoxShape.circle, color: color, border: border);
    }
    return BoxDecoration(
        color: color, borderRadius: BorderRadius.circular(r), border: border);
  }

  Widget _buildDay(DateTime date, DateTime today) {
    final isSelected = isSameDay(date, selectedDate);
    final isToday = isSameDay(date, today);
    final isDisabled =
        date.isBefore(config.firstDate) || date.isAfter(config.lastDate);

    BoxDecoration? deco;
    TextStyle style;

    if (isSelected) {
      deco = theme.selectedDayDecoration ?? _dayDeco(theme.primary);
      style = (theme.selectedDayStyle ??
              TextStyle(color: theme.onPrimary, fontWeight: FontWeight.bold))
          .copyWith(fontSize: 13);
    } else if (isToday) {
      deco = _dayDeco(null,
          border: Border.all(color: theme.resolvedTodayBorderColor, width: 1.5));
      style = TextStyle(
          color: theme.primary, fontWeight: FontWeight.bold, fontSize: 13);
    } else {
      style = (theme.dayStyle ?? TextStyle(color: theme.onSurface)).copyWith(
          fontSize: 13,
          color: isDisabled ? theme.disabledColor : null);
    }

    return GestureDetector(
      onTap: isDisabled ? null : () => onDayTap(date),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: deco,
        child: Center(child: Text('${date.day}', style: style)),
      ),
    );
  }
}

// ── Year picker grid ──────────────────────────────────────────────────────────

class _YearGrid extends StatefulWidget {
  final int currentYear;
  final int firstYear;
  final int lastYear;
  final PickerThemeData theme;
  final ValueChanged<int> onYearSelected;

  const _YearGrid({
    required this.currentYear,
    required this.firstYear,
    required this.lastYear,
    required this.theme,
    required this.onYearSelected,
  });

  @override
  State<_YearGrid> createState() => _YearGridState();
}

class _YearGridState extends State<_YearGrid> {
  late final ScrollController _scrollCtrl;

  @override
  void initState() {
    super.initState();
    // Tính offset để scroll đến năm hiện tại
    const cols = 3;
    const itemH = 48.0;
    final rowIndex =
        ((widget.currentYear - widget.firstYear) ~/ cols);
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

Future<DateTime?> showCustomDatePicker({
  required BuildContext context,
  required DatePickerConfig config,
}) {
  return showDialog<DateTime>(
    context: context,
    builder: (ctx) {
      DateTime picked = config.initialDate ?? DateTime.now();

      return OrientationBuilder(
        builder: (ctx2, orientation) {
          final t = PickerThemeData.of(ctx2, override: config.theme);
          final isLandscape = orientation == Orientation.landscape;

          return Dialog(
            backgroundColor: t.surface,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(t.dialogBorderRadius)),
            clipBehavior: Clip.antiAlias,
            insetPadding: isLandscape
                ? const EdgeInsets.symmetric(horizontal: 24, vertical: 4)
                : const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isLandscape ? 520 : 360,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomDatePicker(
                    config: config,
                    onDateSelected: (d) => picked = d,
                  ),
                  PickerActionBar(
                    theme: t,
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
