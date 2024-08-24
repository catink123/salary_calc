import 'package:collection_providers/collection_providers.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:salary_calc/entries/calendar_data.dart';
import 'package:salary_calc/entries/day_data_page.dart';
import 'package:salary_calc/settings/settings_page.dart';
import 'package:salary_calc/settings/settings.dart';
import 'package:salary_calc/shift_calendar.dart';

void main() {
  initializeDateFormatting().then((_) => runApp(MainApp()));
}

class MainApp extends StatelessWidget {
  MainApp({super.key});

  final calendarData = CalendarData();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => Settings()),
        CollectionProvider.value(value: calendarData.data),
      ],
      child: MaterialApp(
        home: const MainPage(),
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.purpleAccent,
        ),
        darkTheme: ThemeData.dark(),
        themeMode: ThemeMode.system,
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<StatefulWidget> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  DateTime focusedDate = DateTime.now();

  Widget buildMonthlyNormPercentagePanel(BuildContext context) {
    final settings = context.read<Settings>();
    final dayDataForMonth = context.select<MapChangeNotifier<DateTime, DayData>,
        Iterable<MapEntry<DateTime, DayData>>>(
      (map) =>
          map.entries.where((entry) => entry.key.month == focusedDate.month),
    );
    final hoursInMonth = dayDataForMonth
        .map((entry) => entry.value)
        .map((dayData) => dayData.values.fold(0.0, (prev, cur) => prev + cur))
        .fold(0.0, (prev, cur) => prev + cur);

    final monthlyNorm = getMonthlyNorm(
      shiftDuration: settings.shiftDuration,
      shiftOffset: settings.shiftOffset,
      weekendDuration: settings.weekendDuration,
      shiftNorm: settings.shiftNorm,
    );

    final monthlyPercent = hoursInMonth / monthlyNorm;
    final monthlyPercentStr = '${(monthlyPercent * 100).toStringAsFixed(2)}%';

    final payPerHour = settings.ptpMap.entries
        .firstWhere((entry) => monthlyPercent <= entry.key)
        .value;

    final pay = payPerHour * hoursInMonth;
    final payStr = pay.toStringAsFixed(2) +
        (settings.currency.isNotEmpty ? ' ${settings.currency}' : '');

    return BottomAppBar(
      height: 110.0,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Monthly Norm Percentage',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    'for ${DateFormat.MMMM().format(focusedDate)}',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
              Text(
                monthlyPercentStr,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
          const SizedBox(height: 20.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Estimated Pay',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                payStr,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ],
      ),
    );
  }

  int getMonthlyNorm({
    required int shiftDuration,
    required int shiftOffset,
    required int shiftNorm,
    int? weekendDuration,
  }) {
    final daysInAMonth = DateTimeRange(
      start: DateTime.utc(focusedDate.year, focusedDate.month, 1),
      end: DateTime.utc(focusedDate.year, focusedDate.month + 1, 1),
    ).duration.inDays;
    final shiftCycle = shiftDuration + (weekendDuration ?? shiftDuration);
    return (daysInAMonth / shiftCycle * shiftDuration).ceil() * shiftNorm;
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<Settings>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Salary Calculator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SettingsPage(),
              ),
            ),
          )
        ],
      ),
      body: Center(
        child: ShiftCalendar(
          focusedDay: focusedDate,
          shiftDuration: settings.shiftDuration,
          shiftOffset: settings.shiftOffset,
          weekendDuration: settings.weekendDuration,
          onDaySelected: (selectedDay, focusedDay) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DayDataPage(day: selectedDay),
              ),
            );
          },
          onPageChanged: (newMonthDate) =>
              setState(() => focusedDate = newMonthDate),
        ),
      ),
      bottomNavigationBar: buildMonthlyNormPercentagePanel(context),
    );
  }
}
