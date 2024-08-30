import 'package:collection_providers/collection_providers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:salary_calc/entries/calendar_data.dart';
import 'package:table_calendar/table_calendar.dart';

class ShiftCalendar extends StatefulWidget {
  const ShiftCalendar({
    super.key,
    required this.shiftDuration,
    required this.shiftOffset,
    required this.focusedDay,
    this.onDaySelected,
    this.onPageChanged,
    this.weekendDuration,
  });

  final DateTime focusedDay;
  final int shiftDuration;
  final int shiftOffset;
  final int? weekendDuration;
  final void Function(DateTime selectedDay, DateTime focusedDay)? onDaySelected;
  final void Function(DateTime focusedDay)? onPageChanged;

  @override
  State<StatefulWidget> createState() => _ShiftCalendarState();
}

class _ShiftCalendarState extends State<ShiftCalendar> {
  List<DayEntry> _eventLoader(
    DateTime day,
    Map<DateTime, DayData> calendarData,
  ) =>
      calendarData[day]?.entries.toList() ?? [];

  bool _shiftDaysPredicate(DateTime day) {
    final dayFromYearStart = DateTimeRange(
      start: DateTime.utc(day.year, 1, 1),
      end: day,
    ).duration.inDays;

    final shiftCycle =
        widget.shiftDuration + (widget.weekendDuration ?? widget.shiftDuration);

    return (dayFromYearStart - widget.shiftOffset) % shiftCycle <
        widget.shiftDuration;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final firstDay = DateTime.utc(now.year - 10, 1, 1);
    final lastDay = DateTime.utc(now.year + 10, 12, 31);
    final calendarData = context.watch<MapChangeNotifier<DateTime, DayData>>();

    return TableCalendar(
      focusedDay: widget.focusedDay,
      firstDay: firstDay,
      lastDay: lastDay,
      shouldFillViewport: true,
      eventLoader: (day) => _eventLoader(day, calendarData),
      locale: Intl.systemLocale,
      availableCalendarFormats: const {CalendarFormat.month: 'Месяц'},
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, day, events) {
          if (events.isEmpty) {
            return null;
          }

          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              color:
                  Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey,
            ),
            width: 15.0,
            height: 3.0,
          );
        },
        defaultBuilder: (context, day, focusedDay) => Container(
          margin: const EdgeInsets.all(5.0),
          child: SizedBox.expand(
            child: FilledButton.tonal(
              onPressed: widget.onDaySelected != null
                  ? () => widget.onDaySelected!(day, focusedDay)
                  : null,
              style: FilledButton.styleFrom(padding: EdgeInsets.zero),
              child: Text(day.day.toString()),
            ),
          ),
        ),
        todayBuilder: (context, day, focusedDay) => Container(
          margin: const EdgeInsets.all(5.0),
          child: SizedBox.expand(
            child: FilledButton(
              onPressed: widget.onDaySelected != null
                  ? () => widget.onDaySelected!(day, focusedDay)
                  : null,
              style: FilledButton.styleFrom(padding: EdgeInsets.zero),
              child: Text(day.day.toString()),
            ),
          ),
        ),
      ),
      weekendDays: const [],
      enabledDayPredicate: _shiftDaysPredicate,
      holidayPredicate: (day) => false,
      startingDayOfWeek: StartingDayOfWeek.monday,
      onPageChanged: widget.onPageChanged,
    );
  }
}
