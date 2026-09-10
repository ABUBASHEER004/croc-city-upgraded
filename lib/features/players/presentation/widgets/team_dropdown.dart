
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../teams/presentation/providers/team_provider.dart';

class TeamDropdown extends StatelessWidget {
  const TeamDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TeamProvider>();
    final theme = Theme.of(context);

    final activeTeams = provider.teams
        .where((team) => team.active && team.id.trim().isNotEmpty)
        .toList();

    // Prevent DropdownButtonFormField from receiving a value that
    // does not exist in the current list of active teams.
    final selectedValue = activeTeams.any((team) => team.id == value)
        ? value
        : null;

    final isLoading = provider.loading;
    final hasError = provider.error != null;
    final hasTeams = activeTeams.isNotEmpty;

    String hintText;

    if (isLoading) {
      hintText = 'Loading teams...';
    } else if (hasError) {
      hintText = 'Unable to load teams';
    } else if (!hasTeams) {
      hintText = 'No active teams available';
    } else {
      hintText = 'Select team';
    }

    return DropdownButtonFormField<String>(
      initialValue: selectedValue,
      isExpanded: true,
      icon: const Icon(Icons.keyboard_arrow_down_rounded),
      decoration: InputDecoration(
        labelText: 'Team',
        hintText: hintText,
        prefixIcon: const Icon(Icons.groups_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.error,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.error,
            width: 2,
          ),
        ),
      ),
      items: activeTeams.map((team) {
        final ageGroup = team.ageGroup.trim();

        final label = ageGroup.isEmpty
            ? team.name
            : '${team.name} ($ageGroup)';

        return DropdownMenuItem<String>(
          value: team.id,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: isLoading || hasError || !hasTeams ? null : onChanged,
      validator: (selected) {
        if (selected == null || selected.trim().isEmpty) {
          return 'Please select a team';
        }

        final exists = activeTeams.any(
          (team) => team.id == selected,
        );

        if (!exists) {
          return 'Please select a valid team';
        }

        return null;
      },
    );
  }
}

