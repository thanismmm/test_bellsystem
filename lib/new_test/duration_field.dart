import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DurationTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int min;
  final int max;

  const DurationTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.min,
    required this.max,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      trailing: SizedBox(
        width: 60,
        child: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            suffixText: 'sec',
          ),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            _RangeInputFormatter(min, max),
          ],
        ),
      ),
    );
  }
}

// Custom input formatter to enforce min/max range
class _RangeInputFormatter extends TextInputFormatter {
  final int min;
  final int max;

  _RangeInputFormatter(this.min, this.max);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    final value = int.tryParse(newValue.text);
    if (value == null) return oldValue;
    if (value < min || value > max) return oldValue;
    return newValue;
  }
}
