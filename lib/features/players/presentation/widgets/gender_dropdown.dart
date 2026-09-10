import 'package:flutter/material.dart';

class GenderDropdown extends StatelessWidget {
  const GenderDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final String value;
  final ValueChanged<String?> onChanged;

  static const genders = <String>['Male', 'Female', 'Other'];

  @override
  Widget build(BuildContext context) {
    final selected = genders.contains(value) ? value : null;

    return DropdownButtonFormField<String>(
      initialValue: selected,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'Gender',
        prefixIcon: const Icon(Icons.person_outline),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: genders
          .map((gender) => DropdownMenuItem<String>(
                value: gender,
                child: Text(gender),
              ))
          .toList(),
      onChanged: onChanged,
      validator: (selected) => selected == null || selected.isEmpty
          ? 'Please select gender'
          : null,
    );
  }
}
