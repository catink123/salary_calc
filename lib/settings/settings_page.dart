import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salary_calc/inputs/number_field.dart';
import 'package:salary_calc/settings/settings.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TitledPane extends StatelessWidget {
  const TitledPane({
    super.key,
    required this.title,
    this.direction = Axis.horizontal,
    this.child,
  });

  final String title;
  final Axis direction;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final additionalChild = child != null ? [child!] : [];

    final crossAlignment = direction == Axis.vertical
        ? CrossAxisAlignment.start
        : CrossAxisAlignment.center;

    return Card.outlined(
      margin: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.all(10.0),
        child: Flex(
          direction: direction,
          crossAxisAlignment: crossAlignment,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            ...additionalChild
          ],
        ),
      ),
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isWeekendDurationEnabled = false;
  TextEditingController currencyController = TextEditingController(text: "");

  @override
  void initState() {
    super.initState();
    final settings = context.read<Settings>();

    currencyController.text = settings.currency;
  }

  Widget buildSectionTitle(BuildContext context, {required String text}) {
    return Container(
      // padding: Theme.of(context).cardTheme.margin,
      padding: const EdgeInsets.all(10.0),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<Settings>();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          buildSectionTitle(context, text: AppLocalizations.of(context)!.dayConfiguration),
          const SizedBox(height: 8.0),
          TitledPane(
            title: AppLocalizations.of(context)!.shiftDuration,
            child: IntrinsicWidth(
              child: NumberField(
                value: settings.shiftDuration,
                onChange: (value) => settings.shiftDuration = value,
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          TitledPane(
            title: AppLocalizations.of(context)!.shiftOffset,
            child: IntrinsicWidth(
              child: NumberField(
                value: settings.shiftOffset,
                onChange: (value) => settings.shiftOffset = value,
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          TitledPane(
            direction: Axis.vertical,
            title: AppLocalizations.of(context)!.weekendDuration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Checkbox(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      value: settings.weekendDuration == null,
                      onChanged: (value) => settings.weekendDuration =
                          (value ?? false) ? null : settings.shiftDuration,
                    ),
                    Text(AppLocalizations.of(context)!.useShiftDuration,
                        style: Theme.of(context).textTheme.labelMedium),
                    const Spacer(),
                    IntrinsicWidth(
                      child: NumberField(
                        value: settings.weekendDuration ?? 0,
                        onChange: (value) => settings.weekendDuration = value,
                        isEnabled: settings.weekendDuration != null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8.0),
          buildSectionTitle(context, text: AppLocalizations.of(context)!.normConfiguration),
          const SizedBox(height: 8.0),
          TitledPane(
            title: AppLocalizations.of(context)!.shiftNorm,
            child: IntrinsicWidth(
              child: NumberField(
                value: settings.shiftNorm,
                onChange: (value) => settings.shiftNorm = value,
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          buildSectionTitle(context, text: AppLocalizations.of(context)!.miscellaneous),
          const SizedBox(height: 8.0),
          TitledPane(
            title: AppLocalizations.of(context)!.currency,
            child: IntrinsicWidth(
              child: TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'BYN, RUB..',
                ),
                controller: currencyController,
                onChanged: (value) => settings.currency = value,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
