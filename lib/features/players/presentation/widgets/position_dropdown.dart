import 'package:flutter/material.dart';

class PositionDropdown extends StatelessWidget {
  const PositionDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final String value;
  final ValueChanged<String?> onChanged;

  static const positions = <String>[
    'Goalkeeper',
    'Defender',
    'Centre Back',
    'Left Back',
    'Right Back',
    'Midfielder',
    'Defensive Midfielder',
    'Attacking Midfielder',
    'Winger',
    'Forward',
    'Striker',
  ];

  @override
  Widget build(BuildContext context) {
    final selected = positions.contains(value) ? value : null;

    return DropdownButtonFormField<String>(
      initialValue: selected,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'Position',
        prefixIcon: const Icon(Icons.sports_soccer_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: positions
          .map((position) => DropdownMenuItem<String>(
                value: position,
                child: Text(position),
              ))
          .toList(),
      onChanged: onChanged,
      validator: (selected) => selected == null || selected.isEmpty
          ? 'Please select a position'
          : null,
    );
  }
}
