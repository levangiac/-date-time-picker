import 'package:flutter/material.dart';
import 'date_picker.dart';
import 'time_picker.dart';
import 'models/picker_config.dart';
import 'picker_constants.dart';
import 'shared_widgets.dart';

class DateTimePickerResult {
  final DateTime date;
  final TimeOfDay time;

  const DateTimePickerResult({required this.date, required this.time});

  DateTime toDateTime() =>
      DateTime(date.year, date.month, date.day, time.hour, time.minute);
}

/// Widget kết hợp chọn ngày + giờ theo tab, responsive portrait/landscape.
class CustomDateTimePicker extends StatefulWidget {
  final DatePickerConfig dateConfig;
  final TimePickerConfig timeConfig;
  final ValueChanged<DateTimePickerResult> onChanged;

  const CustomDateTimePicker({
    super.key,
    required this.dateConfig,
    required this.timeConfig,
    required this.onChanged,
  });

  @override
  State<CustomDateTimePicker> createState() => _CustomDateTimePickerState();
}

class _CustomDateTimePickerState extends State<CustomDateTimePicker>
    with SingleTickerProviderStateMixin {
  late DateTime _date;
  late TimeOfDay _time;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _date = widget.dateConfig.initialDate ?? DateTime.now();
    _time = widget.timeConfig.initialTime ?? TimeOfDay.now();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _notify() {
    widget.onChanged(DateTimePickerResult(date: _date, time: _time));
  }

  @override
  Widget build(BuildContext context) {
    final t = PickerThemeData.of(context, override: widget.dateConfig.theme);
    final locale = widget.dateConfig.locale;
    // orientationOf — Flutter 3.13+
    final isLandscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildTabBar(t, locale),
        _buildTabContent(t, isLandscape),
      ],
    );
  }

  Widget _buildTabBar(PickerThemeData t, PickerLocale locale) {
    return Container(
      color: t.primary,
      child: TabBar(
        controller: _tabController,
        labelColor: t.onPrimary,
        // withValues thay withOpacity — Flutter 3.27+
        unselectedLabelColor: t.onPrimary.withValues(alpha: 0.55),
        indicatorColor: t.onPrimary,
        indicatorWeight: 3,
        dividerColor: Colors.transparent,
        labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        unselectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
        tabs: [
          Tab(
            icon: const Icon(Icons.calendar_today_outlined, size: 18),
            text: locale.dateTabLabel,
            iconMargin: const EdgeInsets.only(bottom: 2),
          ),
          Tab(
            icon: const Icon(Icons.access_time_outlined, size: 18),
            text: locale.timeTabLabel,
            iconMargin: const EdgeInsets.only(bottom: 2),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(PickerThemeData t, bool isLandscape) {
    // Landscape: cần đủ chỗ cho time picker landscape (264px).
    // Portrait: 380px đủ cho cả date (320px) và time (354px) với scroll.
    return SizedBox(
      height: isLandscape ? kPickerTimeLandscapeHeight : 380,
      child: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          SingleChildScrollView(
            child: CustomDatePicker(
              config: widget.dateConfig,
              onDateSelected: (d) {
                _date = d;
                _notify();
                Future.delayed(const Duration(milliseconds: 200), () {
                  if (mounted && _tabController.index == 0) {
                    _tabController.animateTo(1);
                  }
                });
              },
            ),
          ),
          CustomTimePicker(
            config: widget.timeConfig,
            onTimeSelected: (time) {
              _time = time;
              _notify();
            },
          ),
        ],
      ),
    );
  }
}

// ── Dialog helper ─────────────────────────────────────────────────────────────

Future<DateTimePickerResult?> showCustomDateTimePicker({
  required BuildContext context,
  required DatePickerConfig dateConfig,
  required TimePickerConfig timeConfig,
}) {
  return showDialog<DateTimePickerResult>(
    context: context,
    builder: (ctx) {
      DateTimePickerResult? result;
      final locale = dateConfig.locale;

      return OrientationBuilder(
        builder: (ctx2, orientation) {
          final t2 = PickerThemeData.of(ctx2, override: dateConfig.theme);
          final isLandscape = orientation == Orientation.landscape;

          return Dialog(
            backgroundColor: t2.surface,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(t2.dialogBorderRadius)),
            clipBehavior: Clip.antiAlias,
            insetPadding: isLandscape
                ? const EdgeInsets.symmetric(horizontal: 24, vertical: 0)
                : const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isLandscape ? 520 : 400,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomDateTimePicker(
                    dateConfig: dateConfig,
                    timeConfig: timeConfig,
                    onChanged: (r) => result = r,
                  ),
                  PickerActionBar(
                    theme: t2,
                    locale: locale,
                    onCancel: () => Navigator.pop(ctx),
                    onConfirm: () => Navigator.pop(ctx, result),
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
