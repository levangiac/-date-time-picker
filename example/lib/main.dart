import 'package:flutter/material.dart';
import 'package:vn_date_time_picker/vn_date_time_picker.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Date Time Picker Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const DemoPage(),
    );
  }
}

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  DateTime? _date;
  TimeOfDay? _time;
  DateTimePickerResult? _dateTime;
  DateRange? _range;

  // Tiếng Việt mặc định
  static final _viDateConfig = DatePickerConfig(
    firstDate: DateTime(2020),
    lastDate: DateTime(2030),
    weekStartDay: WeekStartDay.monday,
    dateFormatPattern: DateFormatPattern.ddMMMyyyy,
    locale: PickerLocale.vi,
  );

  // Tiếng Anh
  static final _enDateConfig = DatePickerConfig(
    firstDate: DateTime(2020),
    lastDate: DateTime(2030),
    weekStartDay: WeekStartDay.sunday,
    dateFormatPattern: DateFormatPattern.MMMddyyyy,
    locale: PickerLocale.en,
  );

  static final _viTimeConfig = TimePickerConfig(
    use24HourFormat: false,
    locale: PickerLocale.vi,
  );

  static final _enTimeConfig = TimePickerConfig(
    use24HourFormat: true,
    locale: PickerLocale.en,
  );

  // Custom theme tím
  static final _purpleTheme = PickerThemeData.fromSeed(Colors.deepPurple);

  // Range picker config
  static final _viRangeConfig = DateRangePickerConfig(
    firstDate: DateTime(2020),
    lastDate: DateTime(2030),
    weekStartDay: WeekStartDay.monday,
    dateFormatPattern: DateFormatPattern.ddMMMyyyy,
    locale: PickerLocale.vi,
  );

  static final _enRangeConfig = DateRangePickerConfig(
    firstDate: DateTime(2020),
    lastDate: DateTime(2030),
    weekStartDay: WeekStartDay.sunday,
    dateFormatPattern: DateFormatPattern.MMMddyyyy,
    locale: PickerLocale.en,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Date Time Picker Demo'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _section('Tiếng Việt', [
            _tile(
              icon: Icons.calendar_month,
              label: 'Chọn ngày (VI)',
              subtitle: _date != null ? _viDateConfig.formatDate(_date!) : 'Chưa chọn',
              onTap: () async {
                final d = await showCustomDatePicker(
                  context: context,
                  config: _viDateConfig,
                );
                if (d != null) setState(() => _date = d);
              },
            ),
            _tile(
              icon: Icons.access_time,
              label: 'Chọn giờ (VI - 12h)',
              subtitle: _time != null ? _time!.format(context) : 'Chưa chọn',
              onTap: () async {
                final t = await showCustomTimePicker(
                  context: context,
                  config: _viTimeConfig,
                );
                if (t != null) setState(() => _time = t);
              },
            ),
            _tile(
              icon: Icons.event,
              label: 'Chọn ngày & giờ (VI)',
              subtitle: _dateTime != null
                  ? '${_viDateConfig.formatDate(_dateTime!.date)}  ${_dateTime!.time.format(context)}'
                  : 'Chưa chọn',
              onTap: () async {
                final r = await showCustomDateTimePicker(
                  context: context,
                  dateConfig: _viDateConfig,
                  timeConfig: _viTimeConfig,
                );
                if (r != null) setState(() => _dateTime = r);
              },
            ),
            _tile(
              icon: Icons.date_range,
              label: 'Chọn khoảng ngày (VI)',
              subtitle: _range != null
                  ? '${_viRangeConfig.formatDate(_range!.start)} → ${_viRangeConfig.formatDate(_range!.end)}'
                  : 'Chưa chọn',
              onTap: () async {
                final r = await showCustomDateRangePicker(
                  context: context,
                  config: _viRangeConfig,
                );
                if (r != null) setState(() => _range = r);
              },
            ),
          ]),
          const SizedBox(height: 16),
          _section('English', [
            _tile(
              icon: Icons.calendar_month,
              label: 'Select Date (EN)',
              subtitle: _date != null ? _enDateConfig.formatDate(_date!) : 'Not selected',
              onTap: () async {
                final d = await showCustomDatePicker(
                  context: context,
                  config: _enDateConfig,
                );
                if (d != null) setState(() => _date = d);
              },
            ),
            _tile(
              icon: Icons.access_time,
              label: 'Select Time (EN - 24h)',
              subtitle: _time != null ? _time!.format(context) : 'Not selected',
              onTap: () async {
                final t = await showCustomTimePicker(
                  context: context,
                  config: _enTimeConfig,
                );
                if (t != null) setState(() => _time = t);
              },
            ),
            _tile(
              icon: Icons.date_range,
              label: 'Select Date Range (EN)',
              subtitle: _range != null
                  ? '${_enRangeConfig.formatDate(_range!.start)} → ${_enRangeConfig.formatDate(_range!.end)}'
                  : 'Not selected',
              onTap: () async {
                final r = await showCustomDateRangePicker(
                  context: context,
                  config: _enRangeConfig,
                );
                if (r != null) setState(() => _range = r);
              },
            ),
          ]),
          const SizedBox(height: 16),
          _section('Custom Theme', [
            _tile(
              icon: Icons.palette,
              label: 'Màu tím — fromSeed',
              subtitle: 'primary, onPrimary tự suy',
              onTap: () async {
                final d = await showCustomDatePicker(
                  context: context,
                  config: DatePickerConfig(
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                    locale: PickerLocale.vi,
                    theme: _purpleTheme,
                  ),
                );
                if (d != null) setState(() => _date = d);
              },
            ),
            _tile(
              icon: Icons.dark_mode,
              label: 'Dark theme',
              subtitle: 'surface tối, onSurface sáng',
              onTap: () async {
                final d = await showCustomDatePicker(
                  context: context,
                  config: DatePickerConfig(
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                    locale: PickerLocale.vi,
                    theme: const PickerThemeData(
                      primary: Color(0xFF90CAF9),   // blue 200
                      onPrimary: Color(0xFF0D1B2A),
                      surface: Color(0xFF1E1E2E),
                      onSurface: Color(0xFFE0E0E0),
                      disabledColor: Color(0xFF4A4A5A),
                    ),
                  ),
                );
                if (d != null) setState(() => _date = d);
              },
            ),
            _tile(
              icon: Icons.eco,
              label: 'Custom band & weekday',
              subtitle: 'rangeBandColor, weekdayRowColor, todayBorderColor',
              onTap: () async {
                final r = await showCustomDateRangePicker(
                  context: context,
                  config: DateRangePickerConfig(
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                    locale: PickerLocale.vi,
                    theme: PickerThemeData(
                      primary: const Color(0xFF2E7D32),       // green 800
                      onPrimary: Colors.white,
                      rangeBandColor: const Color(0xFFC8E6C9), // green 100
                      weekdayRowColor: const Color(0xFFE8F5E9),
                      todayBorderColor: Colors.orange,
                      selectedDayRadius: 8,
                    ),
                  ),
                );
                if (r != null) setState(() => _range = r);
              },
            ),
            _tile(
              icon: Icons.star,
              label: 'Custom TextStyle',
              subtitle: 'headerTitleStyle, dayStyle, weekdayStyle',
              onTap: () async {
                final d = await showCustomDatePicker(
                  context: context,
                  config: DatePickerConfig(
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                    locale: PickerLocale.en,
                    theme: PickerThemeData(
                      primary: Colors.orange.shade700,
                      onPrimary: Colors.white,
                      selectedDayRadius: 6,
                      todayBorderColor: Colors.deepOrange,
                      headerTitleStyle: const TextStyle(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                      weekdayStyle: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                      dayStyle: const TextStyle(fontSize: 12),
                    ),
                  ),
                );
                if (d != null) setState(() => _date = d);
              },
            ),
          ]),
        ],
      ),
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.grey)),
        ),
        Card(
          margin: EdgeInsets.zero,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _tile({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.indigo),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle,
          style: const TextStyle(color: Colors.grey, fontSize: 12)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}
