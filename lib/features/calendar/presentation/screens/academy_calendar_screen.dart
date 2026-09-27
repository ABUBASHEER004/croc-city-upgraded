
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../models/app_user.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../dashboard/presentation/widgets/premium_ui.dart';
import '../../data/academy_calendar_service.dart';
import '../../models/academy_calendar_event.dart';

class AcademyCalendarScreen extends StatefulWidget {
  const AcademyCalendarScreen({super.key});

  @override
  State<AcademyCalendarScreen> createState() =>
      _AcademyCalendarScreenState();
}

class _AcademyCalendarScreenState extends State<AcademyCalendarScreen> {
  final AcademyCalendarService _service = AcademyCalendarService();

  DateTime _month = DateTime(
    DateTime.now().year,
    DateTime.now().month,
  );

  DateTime _selected = DateTime.now();

  bool _same(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final bool admin = user?.isAdmin == true;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'CROC-CITY FOOTBALL ACADEMY Calendar',
        ),
        actions: [
          if (admin)
            IconButton(
              tooltip: 'Add event',
              onPressed: () {
                if (user != null) {
                  _edit(context, user, null);
                }
              },
              icon: const Icon(
                Icons.add_circle_outline_rounded,
              ),
            ),
        ],
      ),
      body: StreamBuilder<List<AcademyCalendarEvent>>(
        stream: admin
            ? _service.watchAllForAdmin()
            : _service.watchPublished(),
        builder: (context, snapshot) {
          final List<AcademyCalendarEvent> events =
              snapshot.data ?? <AcademyCalendarEvent>[];

          if (snapshot.hasError) {
            return PremiumDashboardBackground(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 52,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Unable to load the academy calendar.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return PremiumDashboardBackground(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                18,
                12,
                18,
                40,
              ),
              children: <Widget>[
                PremiumHero(
                  eyebrow: 'CROC-CITY FOOTBALL ACADEMY',
                  title: 'One calendar. Every milestone.',
                  subtitle: admin
                      ? 'Plan, edit and publish the academy schedule from one command centre.'
                      : 'Training, matchdays, tournaments, education and academy events in one place.',
                  image: 'assets/images/stadium.jpg',
                  icon: Icons.calendar_month_rounded,
                ),
                const SizedBox(height: 18),
                _grid(context, events),
                const SizedBox(height: 20),
                _dayEvents(
                  context,
                  events,
                  admin,
                  user,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _grid(
    BuildContext context,
    List<AcademyCalendarEvent> events,
  ) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    final DateTime first = DateTime(
      _month.year,
      _month.month,
      1,
    );

    final int leading = first.weekday - 1;

    final int days = DateTime(
      _month.year,
      _month.month + 1,
      0,
    ).day;

    final List<AcademyCalendarEvent> monthEvents = events
        .where(
          (e) =>
              e.startAt.year == _month.year &&
              e.startAt.month == _month.month,
        )
        .toList();

    const List<String> weekdays = <String>[
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                IconButton(
                  tooltip: 'Previous month',
                  onPressed: () {
                    setState(() {
                      _month = DateTime(
                        _month.year,
                        _month.month - 1,
                      );
                    });
                  },
                  icon: const Icon(
                    Icons.chevron_left_rounded,
                  ),
                ),
                Expanded(
                  child: Text(
                    DateFormat('MMMM yyyy').format(_month),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Next month',
                  onPressed: () {
                    setState(() {
                      _month = DateTime(
                        _month.year,
                        _month.month + 1,
                      );
                    });
                  },
                  icon: const Icon(
                    Icons.chevron_right_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: weekdays
                  .map<Widget>(
                    (day) => Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: leading + days,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                if (index < leading) {
                  return const SizedBox.shrink();
                }

                final int day = index - leading + 1;

                final DateTime date = DateTime(
                  _month.year,
                  _month.month,
                  day,
                );

                final List<AcademyCalendarEvent> dayEvents =
                    monthEvents
                        .where(
                          (e) => _same(e.startAt, date),
                        )
                        .toList();

                final bool selected = _same(
                  _selected,
                  date,
                );

                final bool today = _same(
                  DateTime.now(),
                  date,
                );

                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    setState(() {
                      _selected = date;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(
                      milliseconds: 180,
                    ),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: selected
                          ? scheme.primary.withValues(alpha: .12)
                          : today
                              ? scheme.primary.withValues(alpha: .06)
                              : null,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selected
                            ? scheme.primary
                            : Theme.of(context)
                                .dividerColor
                                .withValues(alpha: .5),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '$day',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: selected
                                ? scheme.primary
                                : null,
                          ),
                        ),
                        const Spacer(),
                        if (dayEvents.isNotEmpty)
                          Wrap(
                            spacing: 3,
                            children: dayEvents
                                .take(3)
                                .map<Widget>(
                                  (_) => Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: scheme.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        if (dayEvents.length > 3)
                          Text(
                            '+${dayEvents.length - 3}',
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _dayEvents(
    BuildContext context,
    List<AcademyCalendarEvent> events,
    bool admin,
    AppUser? user,
  ) {
    final List<AcademyCalendarEvent> list = events
        .where(
          (e) => _same(e.startAt, _selected),
        )
        .toList();

    return PremiumSection(
      title:
          'Events on ${DateFormat('EEEE, d MMMM yyyy').format(_selected)}',
      child: Column(
        children: <Widget>[
          if (list.isEmpty)
            const Padding(
              padding: EdgeInsets.all(18),
              child: Text(
                'No calendar events for this day.',
              ),
            ),
          ...list.map<Widget>(
            (e) => Card(
              margin: const EdgeInsets.only(
                bottom: 10,
              ),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: .08),
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                  child: Icon(
                    _icon(e.category),
                    color: Theme.of(context)
                        .colorScheme
                        .primary,
                  ),
                ),
                title: Text(
                  e.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                subtitle: Text(
                  '${e.category} · '
                  '${DateFormat('h:mm a').format(e.startAt)}–'
                  '${DateFormat('h:mm a').format(e.endAt)}'
                  '${e.venue.isEmpty ? '' : ' · ${e.venue}'}\n'
                  '${e.description}',
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: admin
                    ? PopupMenuButton<String>(
                        tooltip: 'Event options',
                        onSelected: (value) async {
                          if (value == 'edit') {
                            if (user != null) {
                              await _edit(
                                context,
                                user,
                                e,
                              );
                            }
                          }

                          if (value == 'toggle') {
                            await _service.setPublished(
                              e.id,
                              !e.published,
                            );
                          }

                          if (value == 'delete') {
                            await _delete(
                              context,
                              e,
                            );
                          }
                        },
                        itemBuilder: (_) => <PopupMenuEntry<String>>[
                          const PopupMenuItem<String>(
                            value: 'edit',
                            child: Text('Edit'),
                          ),
                          PopupMenuItem<String>(
                            value: 'toggle',
                            child: Text(
                              e.published
                                  ? 'Unpublish'
                                  : 'Publish',
                            ),
                          ),
                          const PopupMenuItem<String>(
                            value: 'delete',
                            child: Text('Delete'),
                          ),
                        ],
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _edit(
    BuildContext context,
    AppUser user,
    AcademyCalendarEvent? e,
  ) async {
    final TextEditingController title =
        TextEditingController(
      text: e?.title ?? '',
    );

    final TextEditingController desc =
        TextEditingController(
      text: e?.description ?? '',
    );

    final TextEditingController venue =
        TextEditingController(
      text: e?.venue ?? '',
    );

    DateTime start = e?.startAt ??
        DateTime.now().add(
          const Duration(hours: 1),
        );

    DateTime end = e?.endAt ??
        DateTime.now().add(
          const Duration(hours: 2),
        );

    String category = e?.category ?? 'Training';
    bool published = e?.published ?? true;

    const List<String> categories = <String>[
      'Training',
      'Match',
      'Tournament',
      'Education',
      'Meeting',
      'Holiday',
      'Announcement',
      'General',
    ];

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                e == null
                    ? 'Create academy event'
                    : 'Edit academy event',
              ),
              content: SizedBox(
                width: 560,
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      TextField(
                        controller: title,
                        decoration:
                            const InputDecoration(
                          labelText: 'Event title',
                          prefixIcon: Icon(
                            Icons.title_rounded,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        initialValue: category,
                        decoration:
                            const InputDecoration(
                          labelText: 'Category',
                          prefixIcon: Icon(
                            Icons.category_rounded,
                          ),
                        ),
                        items: categories
                            .map<DropdownMenuItem<String>>(
                              (categoryName) =>
                                  DropdownMenuItem<String>(
                                value: categoryName,
                                child: Text(
                                  categoryName,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            category =
                                value ?? category;
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: venue,
                        decoration:
                            const InputDecoration(
                          labelText: 'Venue',
                          prefixIcon: Icon(
                            Icons.location_on_outlined,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: desc,
                        maxLines: 3,
                        decoration:
                            const InputDecoration(
                          labelText: 'Description',
                          prefixIcon: Icon(
                            Icons.notes_rounded,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ListTile(
                        contentPadding:
                            EdgeInsets.zero,
                        leading: const Icon(
                          Icons.event,
                        ),
                        title: const Text(
                          'Start date',
                        ),
                        subtitle: Text(
                          DateFormat(
                            'EEE, d MMM yyyy',
                          ).format(start),
                        ),
                        onTap: () async {
                          final DateTime? date =
                              await showDatePicker(
                            context: context,
                            initialDate: start,
                            firstDate:
                                DateTime(2020),
                            lastDate:
                                DateTime(2035),
                          );

                          if (date != null) {
                            setDialogState(() {
                              start = DateTime(
                                date.year,
                                date.month,
                                date.day,
                                start.hour,
                                start.minute,
                              );
                            });
                          }
                        },
                      ),
                      ListTile(
                        contentPadding:
                            EdgeInsets.zero,
                        leading: const Icon(
                          Icons.schedule,
                        ),
                        title: const Text(
                          'Start time',
                        ),
                        subtitle: Text(
                          DateFormat(
                            'h:mm a',
                          ).format(start),
                        ),
                        onTap: () async {
                          final TimeOfDay? time =
                              await showTimePicker(
                            context: context,
                            initialTime:
                                TimeOfDay.fromDateTime(
                              start,
                            ),
                          );

                          if (time != null) {
                            setDialogState(() {
                              start = DateTime(
                                start.year,
                                start.month,
                                start.day,
                                time.hour,
                                time.minute,
                              );
                            });
                          }
                        },
                      ),
                      ListTile(
                        contentPadding:
                            EdgeInsets.zero,
                        leading: const Icon(
                          Icons.event_available,
                        ),
                        title: const Text(
                          'End date',
                        ),
                        subtitle: Text(
                          DateFormat(
                            'EEE, d MMM yyyy',
                          ).format(end),
                        ),
                        onTap: () async {
                          final DateTime? date =
                              await showDatePicker(
                            context: context,
                            initialDate: end,
                            firstDate:
                                DateTime(2020),
                            lastDate:
                                DateTime(2035),
                          );

                          if (date != null) {
                            setDialogState(() {
                              end = DateTime(
                                date.year,
                                date.month,
                                date.day,
                                end.hour,
                                end.minute,
                              );
                            });
                          }
                        },
                      ),
                      ListTile(
                        contentPadding:
                            EdgeInsets.zero,
                        leading: const Icon(
                          Icons.schedule,
                        ),
                        title: const Text(
                          'End time',
                        ),
                        subtitle: Text(
                          DateFormat(
                            'h:mm a',
                          ).format(end),
                        ),
                        onTap: () async {
                          final TimeOfDay? time =
                              await showTimePicker(
                            context: context,
                            initialTime:
                                TimeOfDay.fromDateTime(
                              end,
                            ),
                          );

                          if (time != null) {
                            setDialogState(() {
                              end = DateTime(
                                end.year,
                                end.month,
                                end.day,
                                time.hour,
                                time.minute,
                              );
                            });
                          }
                        },
                      ),
                      SwitchListTile(
                        contentPadding:
                            EdgeInsets.zero,
                        value: published,
                        onChanged: (value) {
                          setDialogState(() {
                            published = value;
                          });
                        },
                        title: const Text(
                          'Publish to dashboards',
                        ),
                        subtitle: const Text(
                          'Off keeps the event as an admin draft.',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    final String eventTitle =
                        title.text.trim();

                    if (eventTitle.isEmpty) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please enter an event title.',
                          ),
                        ),
                      );
                      return;
                    }

                    if (!end.isAfter(start)) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            'End time must be after start time.',
                          ),
                        ),
                      );
                      return;
                    }

                    try {
                      if (e == null) {
                        await _service.create(
                          title: eventTitle,
                          description: desc.text.trim(),
                          category: category,
                          startAt: start,
                          endAt: end,
                          venue: venue.text.trim(),
                          published: published,
                          createdBy: user.uid,
                          createdByName: user.fullName,
                        );
                      } else {
                        await _service.update(
                          id: e.id,
                          title: eventTitle,
                          description: desc.text.trim(),
                          category: category,
                          startAt: start,
                          endAt: end,
                          venue: venue.text.trim(),
                          published: published,
                        );
                      }

                      if (dialogContext.mounted) {
                        Navigator.pop(dialogContext);
                      }
                    } catch (error) {
                      if (!context.mounted) {
                        return;
                      }

                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        SnackBar(
                          content: Text(
                            'Unable to save event: $error',
                          ),
                        ),
                      );
                    }
                  },
                  child: Text(
                    e == null
                        ? 'Create event'
                        : 'Save changes',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    title.dispose();
    desc.dispose();
    venue.dispose();
  }

  Future<void> _delete(
    BuildContext context,
    AcademyCalendarEvent e,
  ) async {
    final bool? yes = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Delete calendar event?',
          ),
          content: Text(
            'Remove “${e.title}” from the academy calendar?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (yes == true) {
      await _service.delete(e.id);
    }
  }

  IconData _icon(String category) {
    switch (category) {
      case 'Training':
        return Icons.fitness_center_rounded;

      case 'Match':
        return Icons.sports_soccer_rounded;

      case 'Tournament':
        return Icons.emoji_events_rounded;

      case 'Education':
        return Icons.school_rounded;

      case 'Meeting':
        return Icons.groups_rounded;

      case 'Holiday':
        return Icons.beach_access_rounded;

      case 'Announcement':
        return Icons.campaign_rounded;

      default:
        return Icons.event_rounded;
    }
  }
}
