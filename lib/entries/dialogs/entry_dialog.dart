import 'package:flutter/material.dart';
import 'package:salary_calc/inputs/double_field.dart';

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

  final Widget title;
  final Widget confirmText;

  @override
  State<StatefulWidget> createState() => _EntryDialogState();
}

class _EntryDialogState extends State<EntryDialog> {
  String title = "";
  double hours = 0;
  String hoursStr = '0';

  @override
  void initState() {
    super.initState();

    title = widget.initialTitle;
    hours = widget.initialHours;
    hoursStr = hours.toString();
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
    return AlertDialog(
      title: widget.title,
      content: Form(
        key: _dialogFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              initialValue: title,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Title',
              ),
              onChanged: (value) {
                setState(() => title = value);
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Hours', style: Theme.of(context).textTheme.titleMedium),
                IntrinsicWidth(
                  child: DoubleField(
                    value: hoursStr,
                    onChange: (val, valStr) {
                      setState(() {
                        hours = val;
                        hoursStr = valStr;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _onConfirmPress,
          child: widget.confirmText,
        ),
        TextButton(
          onPressed: _onCancelPress,
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
