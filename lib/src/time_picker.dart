import 'package:flutter/material.dart';
import 'models/picker_config.dart';
import 'picker_constants.dart';
import 'shared_widgets.dart';

const _kItemH = 48.0;
const _kVisible = 5;
const _kWheelH = _kItemH * _kVisible;

class CustomTimePicker extends StatefulWidget {
  final TimePickerConfig config;
  final ValueChanged<TimeOfDay> onTimeSelected;

  const CustomTimePicker({
    super.key,
    required this.config,
    required this.onTimeSelected,
  });

  @override
  State<CustomTimePicker> createState() => _CustomTimePickerState();
}

class _CustomTimePickerState extends State<CustomTimePicker> {
  late int _hour;
  late int _minute;
  late final FixedExtentScrollController _hourCtrl;
  late final FixedExtentScrollController _minCtrl;

  @override
  void initState() {
    super.initState();
    final init = widget.config.initialTime ?? TimeOfDay.now();
    _hour = init.hour;
    _minute = init.minute;
    _hourCtrl = FixedExtentScrollController(
        initialItem: widget.config.use24HourFormat ? _hour : _hour % 12);
    _minCtrl = FixedExtentScrollController(initialItem: _minute);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Orientation change → cấu trúc widget tree thay đổi (Column ↔ Row)
    // → ListWheelScrollView unmount rồi remount với initialItem từ initState.
    // Dùng postFrameCallback để jump về vị trí đúng sau khi frame hoàn tất.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final targetH =
          widget.config.use24HourFormat ? _hour : _hour % 12;
      if (_hourCtrl.hasClients) _hourCtrl.jumpToItem(targetH);
      if (_minCtrl.hasClients) _minCtrl.jumpToItem(_minute);
    });
  }

  @override
  void dispose() {
    _hourCtrl.dispose();
    _minCtrl.dispose();
    super.dispose();
  }

  void _haptic() => triggerTimeHaptic(widget.config.haptic);

  void _notify() =>
      widget.onTimeSelected(TimeOfDay(hour: _hour, minute: _minute));

  bool get _isPm => _hour >= 12;

  String get _displayHour {
    if (widget.config.use24HourFormat) {
      return _hour.toString().padLeft(2, '0');
    }
    final h = _hour % 12 == 0 ? 12 : _hour % 12;
    return h.toString().padLeft(2, '0');
  }

  String get _displayMinute => _minute.toString().padLeft(2, '0');

  String get _period =>
      _isPm ? widget.config.locale.pmLabel : widget.config.locale.amLabel;

  @override
  Widget build(BuildContext context) {
    final t = PickerThemeData.of(context, override: widget.config.theme);
    // orientationOf — Flutter 3.13+
    final isLandscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;

    return isLandscape ? _buildLandscape(t) : _buildPortrait(t);
  }

  Widget _buildPortrait(PickerThemeData t) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(t, horizontal: true),
        _buildWheels(t),
      ],
    );
  }

  Widget _buildLandscape(PickerThemeData t) {
    // SizedBox thay IntrinsicHeight — header (Container) không thể
    // tính intrinsic height khi có Expanded bên trong
    return SizedBox(
      height: kPickerTimeLandscapeHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(width: 140, child: _buildHeader(t, horizontal: false)),
          Expanded(child: _buildWheels(t)),
        ],
      ),
    );
  }

  Widget _buildHeader(PickerThemeData t, {required bool horizontal}) {
    final timeStr = '$_displayHour:$_displayMinute'
        '${widget.config.use24HourFormat ? '' : ' $_period'}';

    return Container(
      color: t.primary,
      padding: EdgeInsets.symmetric(
        vertical: horizontal ? 20 : 24,
        horizontal: 16,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: horizontal
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          Text(
            timeStr,
            style: (t.headerTitleStyle ??
                    const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 2))
                .copyWith(color: t.onPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            widget.config.locale.selectTimeTitle,
            style: (t.headerSubtitleStyle ?? const TextStyle(fontSize: 13))
                // withValues thay withOpacity — Flutter 3.27+
                .copyWith(color: t.onPrimary.withValues(alpha: 0.75)),
          ),
        ],
      ),
    );
  }

  Widget _buildWheels(PickerThemeData t) {
    final maxHour = widget.config.use24HourFormat ? 24 : 12;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Giờ
          _WheelColumn(
            controller: _hourCtrl,
            itemCount: maxHour,
            theme: t,
            labelBuilder: (i) {
              if (widget.config.use24HourFormat) {
                return i.toString().padLeft(2, '0');
              }
              final h = i == 0 ? 12 : i;
              return h.toString().padLeft(2, '0');
            },
            onChanged: (i) {
              _haptic();
              setState(() {
                if (widget.config.use24HourFormat) {
                  _hour = i;
                } else {
                  _hour = _isPm ? (i == 0 ? 12 : i + 12) : (i == 0 ? 0 : i);
                }
              });
              _notify();
            },
          ),
          // Dấu :
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              ':',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w200,
                color: t.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ),
          // Phút
          _WheelColumn(
            controller: _minCtrl,
            itemCount: 60,
            theme: t,
            labelBuilder: (i) => i.toString().padLeft(2, '0'),
            onChanged: (i) {
              _haptic();
              setState(() => _minute = i);
              _notify();
            },
          ),
          // AM/PM
          if (!widget.config.use24HourFormat) ...[
            const SizedBox(width: 16),
            _AmPmToggle(
              amLabel: widget.config.locale.amLabel,
              pmLabel: widget.config.locale.pmLabel,
              isPm: _isPm,
              theme: t,
              onChanged: (pm) {
                setState(() {
                  if (pm && _hour < 12) _hour += 12;
                  if (!pm && _hour >= 12) _hour -= 12;
                });
                _hourCtrl.jumpToItem(_hour % 12);
                _notify();
              },
            ),
          ],
        ],
      ),
    );
  }
}

// ── Wheel column ──────────────────────────────────────────────────────────────

class _WheelColumn extends StatelessWidget {
  final FixedExtentScrollController controller;
  final int itemCount;
  final PickerThemeData theme;
  final String Function(int) labelBuilder;
  final ValueChanged<int> onChanged;

  const _WheelColumn({
    required this.controller,
    required this.itemCount,
    required this.theme,
    required this.labelBuilder,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 62,
      height: _kWheelH,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Highlight band
          Positioned(
            top: _kItemH * (_kVisible ~/ 2),
            left: 0,
            right: 0,
            height: _kItemH,
            child: Container(
              decoration: BoxDecoration(
                color: theme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: theme.primary.withValues(alpha: 0.35),
                  width: 1,
                ),
              ),
            ),
          ),
          _FadedWheel(
            controller: controller,
            itemCount: itemCount,
            theme: theme,
            labelBuilder: labelBuilder,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _FadedWheel extends StatelessWidget {
  final FixedExtentScrollController controller;
  final int itemCount;
  final PickerThemeData theme;
  final String Function(int) labelBuilder;
  final ValueChanged<int> onChanged;

  const _FadedWheel({
    required this.controller,
    required this.itemCount,
    required this.theme,
    required this.labelBuilder,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Dùng gradient overlay thay ShaderMask+BlendMode.dstOut.
    // ShaderMask mất compositing layer sau khi orientation thay đổi
    // khiến wheel render transparent cho đến khi có pointer event.
    const fadeH = _kItemH * 1.5;
    final bg = theme.surface;

    return Stack(
      children: [
        ListWheelScrollView.useDelegate(
          controller: controller,
          itemExtent: _kItemH,
          physics: const FixedExtentScrollPhysics(),
          perspective: 0.003,
          diameterRatio: 2.2,
          onSelectedItemChanged: onChanged,
          childDelegate: ListWheelChildBuilderDelegate(
            childCount: itemCount,
            builder: (ctx, i) {
              final isSel = i == controller.selectedItem;
              return Center(
                child: Text(
                  labelBuilder(i),
                  style: isSel
                      ? (theme.timeSelectedStyle ??
                          TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: theme.primary,
                          ))
                      : (theme.timeWheelStyle ??
                          TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w300,
                            color: theme.onSurface.withValues(alpha: 0.35),
                          )),
                ),
              );
            },
          ),
        ),
        // Fade trên — IgnorePointer để không chặn scroll
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: fadeH,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [bg, bg.withValues(alpha: 0)],
                ),
              ),
            ),
          ),
        ),
        // Fade dưới
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: fadeH,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [bg, bg.withValues(alpha: 0)],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── AM/PM toggle ──────────────────────────────────────────────────────────────

class _AmPmToggle extends StatelessWidget {
  final String amLabel;
  final String pmLabel;
  final bool isPm;
  final PickerThemeData theme;
  final ValueChanged<bool> onChanged;

  const _AmPmToggle({
    required this.amLabel,
    required this.pmLabel,
    required this.isPm,
    required this.theme,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.primary.withValues(alpha: 0.4)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _btn(amLabel, !isPm,
              const BorderRadius.vertical(top: Radius.circular(9))),
          Divider(height: 1, color: theme.primary.withValues(alpha: 0.3)),
          _btn(pmLabel, isPm,
              const BorderRadius.vertical(bottom: Radius.circular(9))),
        ],
      ),
    );
  }

  Widget _btn(String label, bool active, BorderRadius radius) {
    return GestureDetector(
      onTap: () => onChanged(label == pmLabel),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: active ? theme.primary : Colors.transparent,
          borderRadius: radius,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: active ? theme.onPrimary : theme.primary,
          ),
        ),
      ),
    );
  }
}

// ── Dialog helper ─────────────────────────────────────────────────────────────

Future<TimeOfDay?> showCustomTimePicker({
  required BuildContext context,
  required TimePickerConfig config,
}) {
  return showDialog<TimeOfDay>(
    context: context,
    builder: (ctx) {
      // picked được khai báo ngoài OrientationBuilder để không reset khi xoay
      TimeOfDay picked = config.initialTime ?? TimeOfDay.now();

      return OrientationBuilder(
        builder: (ctx2, orientation) {
          final t = PickerThemeData.of(ctx2, override: config.theme);
          final isLandscape = orientation == Orientation.landscape;

          return Dialog(
            backgroundColor: t.surface,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(t.dialogBorderRadius)),
            clipBehavior: Clip.antiAlias,
            // OrientationBuilder → insetPadding reactive khi xoay
            insetPadding: isLandscape
                ? const EdgeInsets.symmetric(horizontal: 24, vertical: 4)
                : const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isLandscape ? 480 : 360,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Không dùng SingleChildScrollView — tránh nested scrollable
                  // với ListWheelScrollView (gây mất render sau xoay)
                  CustomTimePicker(
                    config: config,
                    onTimeSelected: (time) => picked = time,
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
