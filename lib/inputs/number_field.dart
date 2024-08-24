import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NumberField extends StatefulWidget {
  const NumberField({
    super.key,
    required this.value,
    required this.onChange,
    this.isEnabled = true,
  });

  final int value;
  final void Function(int value) onChange;
  final bool isEnabled;

  @override
  State<StatefulWidget> createState() => _NumberFieldState();
}

class _NumberFieldState extends State<NumberField> {
  late final TextEditingController textController;

  @override
  void initState() {
    super.initState();
    textController = TextEditingController(text: widget.value.toString());
  }

  @override
  void didUpdateWidget(covariant NumberField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final String valueStr = widget.value.toString();
    textController.value = TextEditingValue(
      selection: TextSelection.collapsed(offset: valueStr.length),
      text: valueStr,
    );
  }

  void _onFieldUpdate(String value) {
    widget.onChange(int.tryParse(value) ?? 0);
  }

  void _updateValue(int delta) {
    final int currentValue = int.tryParse(textController.text) ?? 0;
    final newValue = currentValue + delta;
    final newValueStr = newValue.toString();
    textController.value = TextEditingValue(
      selection: TextSelection.collapsed(offset: newValueStr.length),
      text: newValueStr,
    );
    widget.onChange(newValue);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IntrinsicWidth(
          child: TextField(
            enabled: widget.isEnabled,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            controller: textController,
            onChanged: _onFieldUpdate,
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
