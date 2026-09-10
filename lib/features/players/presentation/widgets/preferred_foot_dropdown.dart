import 'package:flutter/material.dart';

class PreferredFootDropdown extends StatelessWidget {
  const PreferredFootDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final String value;
  final ValueChanged<String?> onChanged;

  static const feet = <String>['Right', 'Left', 'Both'];

  @override
  Widget build(BuildContext context) {
    final selected = feet.contains(value) ? value : null;

    return DropdownButtonFormField<String>(
      initialValue: selected,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'Preferred Foot',
        prefixIcon: const Icon(Icons.directions_run_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: feet
          .map((foot) => DropdownMenuItem<String>(
                value: foot,
                child: Text(foot),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }
}
