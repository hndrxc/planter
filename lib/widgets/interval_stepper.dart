import 'package:flutter/material.dart';

/// A form field for the watering interval, stepped with plus and minus
/// buttons and validated to be at least [min] days.
class IntervalStepper extends FormField<int> {
  IntervalStepper({
    super.key,
    required int value,
    required ValueChanged<int> onChanged,
    int min = 1,
    int max = 365,
  }) : super(
          initialValue: value,
          validator: (days) => days == null || days < min
              ? 'Must be at least $min ${min == 1 ? 'day' : 'days'}'
              : null,
          builder: (field) => _IntervalStepperBody(
            field: field,
            onChanged: onChanged,
            min: min,
            max: max,
          ),
        );
}

class _IntervalStepperBody extends StatelessWidget {
  const _IntervalStepperBody({
    required this.field,
    required this.onChanged,
    required this.min,
    required this.max,
  });

  final FormFieldState<int> field;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;

  void _set(int days) {
    field.didChange(days);
    onChanged(days);
  }

  @override
  Widget build(BuildContext context) {
    final days = field.value ?? min;
    return InputDecorator(
      decoration: InputDecoration(
        labelText: 'Water every',
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
        errorText: field.errorText,
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Decrease interval',
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: days > min ? () => _set(days - 1) : null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              days == 1 ? '1 day' : '$days days',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          IconButton(
            tooltip: 'Increase interval',
            icon: const Icon(Icons.add_circle_outline),
            onPressed: days < max ? () => _set(days + 1) : null,
          ),
        ],
      ),
    );
  }
}
