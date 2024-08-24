import 'package:collection_providers/collection_providers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:salary_calc/entries/dialogs/entry_dialog.dart';
import 'package:salary_calc/entries/calendar_data.dart';
import 'package:salary_calc/settings/settings.dart';

class DayDataEntryTile extends StatelessWidget {
  const DayDataEntryTile({
    super.key,
    required this.title,
    required this.hours,
    required this.onEdit,
    required this.onRemove,
  });

  final String title;
  final double hours;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  Future<bool?> _onDismiss(DismissDirection direction) async {
    if (direction == DismissDirection.startToEnd) {
      onEdit();
      return false;
    } else if (direction == DismissDirection.endToStart) {
      onRemove();
      return true;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      dismissThresholds: const {
        DismissDirection.startToEnd: 0.5,
        DismissDirection.endToStart: 0.8,
      },
      confirmDismiss: _onDismiss,
      background: Container(color: Colors.green),
      secondaryBackground: Container(color: Colors.red),
      key: ValueKey(title),
      child: Card.outlined(
        margin: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Container(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              Text('$hours hours',
                  style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}

class DayDataPage extends StatelessWidget {
  const DayDataPage({
    super.key,
    required this.day,
  });

  final DateTime day;

  Future<void> showEditEntryDialog(
    BuildContext context, {
    required String title,
    required double hours,
  }) async {
    final MapEntry<String, double>? dialogResult = await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => EntryDialog(
        title: const Text('Edit an entry'),
        confirmText: const Text('Edit'),
        initialTitle: title,
        initialHours: hours,
      ),
    );

    if (dialogResult != null && context.mounted) {
      final calendarData = context.read<MapChangeNotifier<DateTime, DayData>>();

      calendarData.update(
        day,
        (dayData) => dayData.map(
          (key, value) {
            if (key == title) {
              return dialogResult;
            }
            return MapEntry(key, value);
          },
        ),
      );
    }
  }

  Widget buildEntryList(BuildContext context, DayData dayData) {
    void onEdit(String key) {
      showEditEntryDialog(context, title: key, hours: dayData[key]!);
    }

    void onRemove(String key) {
      final calendarData = context.read<MapChangeNotifier<DateTime, DayData>>();
      calendarData.update(
        day,
        (dayData) => Map.fromEntries(
          dayData.entries.where((entry) => entry.key != key),
        ),
      );
    }

    return ListView(
      children: dayData.entries
          .map<List<Widget>>(
            (entry) => [
              DayDataEntryTile(
                title: entry.key,
                hours: entry.value,
                onEdit: () => onEdit(entry.key),
                onRemove: () => onRemove(entry.key),
              ),
              const SizedBox(height: 10.0),
            ],
          )
          .expand<Widget>((element) => element)
          .toList(),
    );
  }

  Widget buildNormPercentageBar(BuildContext context, DayData dayData) {
    final settings = context.watch<Settings>();

    final normPercentage = dayData.values.fold(
          0.0,
          (previousValue, element) => previousValue + element,
        ) /
        settings.shiftNorm;

    final percentageValueStr = (normPercentage * 100).toStringAsFixed(2);

    return BottomAppBar(
      height: 50.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Norm Percentage',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text(
            '$percentageValueStr%',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Future<void> showNewEntryDialog(BuildContext context) async {
    final MapEntry<String, double>? newEntry = await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => const EntryDialog(
        title: Text('Add a new entry'),
        confirmText: Text('Add'),
      ),
    );

    if (newEntry != null && context.mounted) {
      final calendarData = context.read<MapChangeNotifier<DateTime, DayData>>();

      if (calendarData.containsKey(day)) {
        if (calendarData[day]!.containsKey(newEntry.key)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Entry with title "${newEntry.key}" already exists!'),
            ),
          );
        }
        calendarData.update(
          day,
          (value) => Map.fromEntries(
            value.entries.followedBy([newEntry]),
          ),
        );
      } else {
        calendarData[day] = Map.fromEntries([newEntry]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dayData =
        context.select<MapChangeNotifier<DateTime, DayData>, DayData?>(
            (value) => value[day]);

    const Widget noEntriesView = Center(
      child: Text(
        'No entries. Add new ones using the button in the corner.',
        textAlign: TextAlign.center,
      ),
    );

    final Widget view;
    if (dayData != null) {
      if (dayData.isEmpty) {
        view = noEntriesView;
      } else {
        view = Column(
          children: [
            Expanded(
              child: buildEntryList(context, dayData),
            ),
            // buildNormPercentagePanel(context, dayData),
          ],
        );
      }
    } else {
      view = noEntriesView;
    }

    return Scaffold(
      appBar: AppBar(title: Text(DateFormat.yMMMd().format(day))),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showNewEntryDialog(context),
        child: const Icon(Icons.add),
      ),
      body: view,
      bottomNavigationBar: dayData != null && dayData.isNotEmpty
          ? buildNormPercentageBar(context, dayData)
          : null,
    );
  }
}
