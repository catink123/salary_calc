import 'package:collection_providers/collection_providers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:salary_calc/entries/dialogs/entry_dialog.dart';
import 'package:salary_calc/entries/calendar_data.dart';
import 'package:salary_calc/settings/settings.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          onRemove();
        }
      },
      background: Container(
        color: Colors.green,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: const Align(
          alignment: Alignment.centerLeft,
          child: Icon(Icons.edit),
        ),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: const Align(
          alignment: Alignment.centerRight,
          child: Icon(Icons.delete),
        ),
      ),
      key: ValueKey(title),
      child: ListTile(
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        trailing: Text(AppLocalizations.of(context)!.hours(hours),
            style: Theme.of(context).textTheme.bodyMedium),
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
        title: Text(AppLocalizations.of(context)!.editAnEntry),
        confirmText: Text(AppLocalizations.of(context)!.edit),
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

    return ListView.separated(
      itemCount: dayData.length,
      itemBuilder: (context, index) {
        final entry = dayData.entries.elementAt(index);
        return DayDataEntryTile(
          title: entry.key,
          hours: entry.value,
          onEdit: () => onEdit(entry.key),
          onRemove: () => onRemove(entry.key),
        );
      },
      separatorBuilder: (context, index) => const Divider(
        height: 0,
      ),
    );
  }

  Widget buildNormPercentageBar(BuildContext context, DayData dayData) {
    final settings = context.watch<Settings>();

    final totalHours = dayData.values.fold(
      0.0,
      (previousValue, element) => previousValue + element,
    );

    final normPercentage = totalHours / settings.shiftNorm;

    final percentageValueStr = (normPercentage * 100).toStringAsFixed(2);

    return BottomAppBar(
      height: 96.0,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.normPercentage,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                '$percentageValueStr%',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
          const SizedBox(height: 20.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.totalHours,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                AppLocalizations.of(context)!.hours(totalHours),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> showNewEntryDialog(BuildContext context) async {
    final MapEntry<String, double>? newEntry = await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => EntryDialog(
        title: Text(AppLocalizations.of(context)!.addANewEntry),
        confirmText: Text(AppLocalizations.of(context)!.add),
      ),
    );

    if (newEntry != null && context.mounted) {
      final calendarData = context.read<MapChangeNotifier<DateTime, DayData>>();

      if (calendarData.containsKey(day)) {
        if (calendarData[day]!.containsKey(newEntry.key)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!
                  .entryAlreadyExists(newEntry.key)),
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

    Widget noEntriesView = Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Text(
          AppLocalizations.of(context)!.noEntries,
          textAlign: TextAlign.center,
        ),
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
