import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DoubleField extends StatefulWidget {
  const DoubleField({
    super.key,
    required this.value,
    required this.onChange,
    this.isEnabled = true,
  });

  final String value;
  final void Function(double value, String textValue) onChange;
  final bool isEnabled;

  @override
  State<StatefulWidget> createState() => _DoubleFieldState();
}

class _DoubleFieldState extends State<DoubleField> {
  late final TextEditingController textController;

  @override
  void initState() {
    super.initState();
    textController = TextEditingController(text: widget.value.toString());
  }

  @override
  void didUpdateWidget(covariant DoubleField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final String valueStr = widget.value.toString();
    textController.value = TextEditingValue(
      selection: TextSelection.collapsed(offset: valueStr.length),
      text: valueStr,
    );
  }

  void _onFieldUpdate(String value) {
    widget.onChange(double.tryParse(value) ?? 0, value);
  }

  void _updateValue(int delta) {
    final double currentValue = double.tryParse(textController.text) ?? 0;
    final newValue = currentValue + delta;
    final newValueStr = newValue.toString();
    textController.value = TextEditingValue(
      selection: TextSelection.collapsed(offset: newValueStr.length),
      text: newValueStr,
    );
    widget.onChange(newValue, newValueStr);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IntrinsicWidth(
          child: Focus(
            child: TextField(
              enabled: widget.isEnabled,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[0-9]+[,.]?[0-9]*')),
                TextInputFormatter.withFunction(
                  (oldValue, newValue) => newValue.copyWith(
                    text: newValue.text.replaceAll(',', '.'),
                  ),
                ),
              ],
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              controller: textController,
              onChanged: _onFieldUpdate,
            ),
          ),
        ),
        const SizedBox(width: 5.0),
        IconButton(
          onPressed: widget.isEnabled ? () => _updateValue(1) : null,
          icon: const Icon(Icons.arrow_upward),
        ),
        const SizedBox(width: 2.0),
        IconButton(
          onPressed: widget.isEnabled ? () => _updateValue(-1) : null,
          icon: const Icon(Icons.arrow_downward),
        ),
      ],
    );
  }
}
