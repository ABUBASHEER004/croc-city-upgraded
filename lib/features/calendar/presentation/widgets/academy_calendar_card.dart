
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/academy_calendar_service.dart';
import '../../models/academy_calendar_event.dart';
import '../screens/academy_calendar_screen.dart';

class AcademyCalendarCard extends StatefulWidget {
  const AcademyCalendarCard({
    super.key,
    this.compact = false,
  });

  final bool compact;

  @override
  State<AcademyCalendarCard> createState() =>
      _AcademyCalendarCardState();
}

class _AcademyCalendarCardState
    extends State<AcademyCalendarCard> {
  final AcademyCalendarService _service =
      AcademyCalendarService();

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
    return StreamBuilder<List<AcademyCalendarEvent>>(
      stream: _service.watchPublished(),
      builder: (context, snapshot) {
        final List<AcademyCalendarEvent> events =
            snapshot.data ?? <AcademyCalendarEvent>[];

        final List<AcademyCalendarEvent> monthEvents =
            events
                .where(
                  (e) =>
                      e.startAt.year == _month.year &&
                      e.startAt.month == _month.month,
                )
                .toList();

        final List<AcademyCalendarEvent> selectedEvents =
            events
                .where(
                  (e) => _same(e.startAt, _selected),
                )
                .toList();

        return _buildCard(
          context,
          monthEvents,
          selectedEvents,
        );
      },
    );
  }

  Widget _buildCard(
    BuildContext context,
    List<AcademyCalendarEvent> monthEvents,
    List<AcademyCalendarEvent> selectedEvents,
  ) {
    final ColorScheme scheme =
        Theme.of(context).colorScheme;

    final DateTime first = DateTime(
      _month.year,
      _month.month,
      1,
    );

    final DateTime lastDay = DateTime(
      _month.year,
      _month.month + 1,
      0,
    );

    final int leading = first.weekday - 1;

    const List<String> weekdays = <String>[
      'M',
      'T',
      'W',
      'T',
      'F',
      'S',
      'S',
    ];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            scheme.primary,
            scheme.primary.withValues(alpha: .76),
          ],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: scheme.primary.withValues(alpha: .20),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: <Widget>[
            _buildHeader(context),
            const SizedBox(height: 14),
            _buildMonthNavigation(),
            const SizedBox(height: 4),
            _buildWeekdayHeader(weekdays),
            const SizedBox(height: 7),
            _buildCalendarGrid(
              context,
              scheme,
              monthEvents,
              leading,
              lastDay.day,
            ),
            const SizedBox(height: 12),
            _buildSelectedEvents(
              context,
              selectedEvents,
            ),
            const SizedBox(height: 4),
            _buildViewCalendarButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .16),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.calendar_month_rounded,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'CROC-CITY FOOTBALL ACADEMY',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .7,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Academy Calendar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Open full calendar',
          onPressed: () {
            _openCalendar(context);
          },
          icon: const Icon(
            Icons.open_in_new_rounded,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildMonthNavigation() {
    return Row(
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
            color: Colors.white,
          ),
        ),
        Expanded(
          child: Text(
            DateFormat('MMMM yyyy').format(_month),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
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
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildWeekdayHeader(
    List<String> weekdays,
  ) {
    return Row(
      children: weekdays
          .map<Widget>(
            (day) => Expanded(
              child: Center(
                child: Text(
                  day,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildCalendarGrid(
    BuildContext context,
    ColorScheme scheme,
    List<AcademyCalendarEvent> monthEvents,
    int leading,
    int numberOfDays,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(),
      itemCount: leading + numberOfDays,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 5,
        crossAxisSpacing: 5,
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

        final bool hasEvent = monthEvents.any(
          (e) => _same(e.startAt, date),
        );

        final bool selected = _same(
          _selected,
          date,
        );

        final bool today = _same(
          DateTime.now(),
          date,
        );

        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            setState(() {
              _selected = date;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(
              milliseconds: 180,
            ),
            decoration: BoxDecoration(
              color: selected
                  ? Colors.white
                  : today
                      ? Colors.white.withValues(
                          alpha: .18,
                        )
                      : Colors.transparent,
              borderRadius:
                  BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  '$day',
                  style: TextStyle(
                    color: selected
                        ? scheme.primary
                        : Colors.white,
                    fontWeight: selected || today
                        ? FontWeight.w900
                        : FontWeight.w600,
                  ),
                ),
                if (hasEvent)
                  Container(
                    width: 5,
                    height: 5,
                    margin:
                        const EdgeInsets.only(top: 3),
                    decoration:
                        BoxDecoration(
                      color: selected
                          ? scheme.primary
                          : Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectedEvents(
    BuildContext context,
    List<AcademyCalendarEvent> selectedEvents,
  ) {
    if (selectedEvents.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .10),
          borderRadius: BorderRadius.circular(17),
        ),
        child: Text(
          'No published events on '
          '${DateFormat('EEE, d MMM').format(_selected)}.',
          style: const TextStyle(
            color: Colors.white70,
          ),
        ),
      );
    }

    final int maxEvents = widget.compact ? 2 : 4;

    final List<AcademyCalendarEvent> visibleEvents =
        selectedEvents.take(maxEvents).toList();

    return Column(
      children: visibleEvents
          .map<Widget>(
            (e) => Container(
              margin: const EdgeInsets.only(
                bottom: 7,
              ),
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color:
                    Colors.white.withValues(alpha: .12),
                borderRadius:
                    BorderRadius.circular(15),
              ),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 8,
                    height: 8,
                    decoration:
                        const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      e.title,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('h:mm a')
                        .format(e.startAt),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildViewCalendarButton(
    BuildContext context,
  ) {
    return TextButton.icon(
      onPressed: () {
        _openCalendar(context);
      },
      icon: const Icon(
        Icons.arrow_forward_rounded,
        color: Colors.white,
      ),
      label: const Text(
        'View full academy calendar',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  void _openCalendar(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) =>
            const AcademyCalendarScreen(),
      ),
    );
  }
}
