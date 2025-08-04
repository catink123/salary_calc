import 'package:flutter/material.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:salary_calc/l10n/app_localizations.dart';

class EntryDialog extends StatefulWidget {
  const EntryDialog({
    super.key,
    this.initialTitle = "",
    this.initialHours = 1,
    required this.title,
    required this.confirmText,
  });

  final String initialTitle;
  final double initialHours;

  final String title;
  final String confirmText;

  @override
  State<StatefulWidget> createState() => _EntryDialogState();
}

class _EntryDialogState extends State<EntryDialog> {
  String title = "";
  double hours = 0;

  @override
  void initState() {
    super.initState();

    title = widget.initialTitle;
    hours = widget.initialHours;
  }

  final _dialogFormKey = GlobalKey<FormState>();

  void _onConfirmPress() {
    if (_dialogFormKey.currentState!.validate()) {
      Navigator.of(context).pop(MapEntry(title, hours));
    }
  }

  void _onCancelPress() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return BottomSheet(
      onClosing: _onCancelPress,
      enableDrag: false,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              widget.title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24.0),
            Form(
              key: _dialogFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: title,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: AppLocalizations.of(context)!.titleLabel,
                    ),
                    onChanged: (value) {
                      setState(() => title = value);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!
                            .titleFieldValidityFail;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10.0),
                  SpinBox(
                    min: 0.0,
                    max: 12.0,
                    step: 0.05,
                    decimals: 2,
                    onSubmitted: (value) => {
                      setState(() {
                        hours = value;
                      })
                    },
                    value: hours,
                    decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: AppLocalizations.of(context)!.hoursLabel),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OutlinedButton(
                  onPressed: _onCancelPress,
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                const SizedBox(height: 8.0),
                FilledButton(
                  onPressed: _onConfirmPress,
                  child: Text(widget.confirmText),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
