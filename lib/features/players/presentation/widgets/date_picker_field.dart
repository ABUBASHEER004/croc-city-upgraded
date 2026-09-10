import 'package:flutter/material.dart';

class DatePickerField extends StatelessWidget {
  const DatePickerField({super.key, required this.label, required this.value, required this.onChanged, this.validator});
  final String label; final DateTime? value; final ValueChanged<DateTime> onChanged; final String? Function(DateTime?)? validator;
  String _format(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  @override
  Widget build(BuildContext context) => FormField<DateTime>(
    initialValue: value,
    validator: validator,
    builder: (state) => InkWell(
      onTap: () async { final now=DateTime.now(); final picked=await showDatePicker(context: context, initialDate: value ?? DateTime(now.year-12), firstDate: DateTime(1950), lastDate: now); if(picked!=null){state.didChange(picked); onChanged(picked);} },
      child: InputDecorator(decoration: InputDecoration(labelText: label, prefixIcon: const Icon(Icons.calendar_today_outlined), errorText: state.errorText, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), child: Text(value == null ? 'Select date' : _format(value!))),
    ),
  );
}
