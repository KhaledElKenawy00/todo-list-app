import 'package:flutter/material.dart';

class DateTimeSelector extends StatelessWidget {
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final Function(DateTime, TimeOfDay) onDateTimeChanged;

  const DateTimeSelector({
    required this.selectedDate,
    required this.selectedTime,
    required this.onDateTimeChanged,
  });

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      onDateTimeChanged(pickedDate, selectedTime);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );

    if (pickedTime != null && pickedTime != selectedTime) {
      onDateTimeChanged(selectedDate, pickedTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _selectDate(context),
            label: Text(
              "Date:${selectedDate.toLocal().toString().split(" ")[0]}",
            ),
            icon: Icon(Icons.calendar_view_day_rounded),
          ),
        ),
        Expanded(
          child: ListTile(
            title: const Text('Time'),
            subtitle: Text('${selectedTime.format(context)}'),
            onTap: () => _selectTime(context),
          ),
        ),
        SizedBox(width: 12),
      ],
    );
  }
}
