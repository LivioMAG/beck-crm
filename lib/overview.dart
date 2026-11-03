part of 'main.dart';

extension _Overview on _WorkspaceState {
  Widget _overview() {
    final open = data.visibleTasks.where((t) => !t.flag('Erledigt')).toList();
    final own = open.where((t) => t['Zuständig'] == data.user!.id).toList()
      ..sort((a, b) => a['Datum'].compareTo(b['Datum']));
    final reminders = data
        .upcomingReminders()
        .where((r) => daysUntil(r['Datum']) <= 14)
        .toList();
    final activities = data.visibleActivities.toList().reversed.toList()
      ..sort((a, b) => b['Datum'].compareTo(a['Datum']));
    final urgent = open.where((t) => daysUntil(t['Datum']) < 0).length;
    final active = data.visibleProperties
        .where((p) => data.status(p) != 'Verkauft')
        .length;
    final matches = data.matches().where((match) => match.score >= 70).length;
    final today = day();
    const months = [
      'Januar',
      'Februar',
      'März',
      'April',
      'Mai',
      'Juni',
      'Juli',
      'August',
      'September',
      'Oktober',
      'November',
      'Dezember',
    ];
    const weekdays = [
      'Montag',
      'Dienstag',
      'Mittwoch',
      'Donnerstag',
      'Freitag',
      'Samstag',
      'Sonntag',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _OverviewHero(
          name: data.user!.name.split(' ').first,
          date:
              '${weekdays[today.weekday - 1]}, ${today.day}. ${months[today.month - 1]}',
          openReports: () => refreshPage(() => reportsOpen = true),
        ),
        const SizedBox(height: 23),
        const _Eyebrow('AUF EINEN BLICK'),
        const SizedBox(height: 10),
        _fitGrid(
          [
            _Kpi(
              'Verkäufer',
              contactsWith('Verkäufer').length,
              Icons.person_outline_rounded,
              accent,
              () => go(Section.contacts, tab: 'Kontakte', filter: 'Verkäufer'),
            ),
            _Kpi(
              'Käufer',
              contactsWith('Käufer').length,
              Icons.key_outlined,
              const Color(0xff6959a2),
              () => go(Section.contacts, tab: 'Kontakte', filter: 'Käufer'),
            ),
            _Kpi(
              'Aktive Objekte',
              active,
              Icons.apartment_rounded,
              accent,
              () => go(Section.properties, tab: 'Objekte', filter: 'Aktiv'),
            ),
            _Kpi(
              'Matches',
              matches,
              Icons.compare_arrows_rounded,
              green,
              () => _openMatching(),
            ),
            _Kpi(
              'Offene Aufgaben',
              open.length,
              Icons.task_alt_rounded,
              amber,
              () => go(Section.tasks, tab: 'Aufgaben', filter: 'Offen'),
              hint: urgent == 0 ? null : '$urgent überfällig',
            ),
            _Kpi(
              'Eigentümer',
              contactsWith('Eigentümer').length,
              Icons.people_outline_rounded,
              const Color(0xff527891),
              () => go(Section.contacts, tab: 'Kontakte', filter: 'Eigentümer'),
            ),
          ],
          minWidth: 135,
          columnCounts: const [1, 2, 3, 6],
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (_, size) {
            final tasksPanel = _Panel(
              child: Column(
                children: [
                  _panelTitle(
                    'Meine Aufgaben',
                    icon: Icons.task_alt_rounded,
                    action: TextButton(
                      onPressed: () =>
                          go(Section.tasks, tab: 'Aufgaben', filter: 'Offen'),
                      child: const Text('Alle ansehen'),
                    ),
                  ),
                  const SizedBox(height: 7),
                  _items([
                    for (final task in own.take(4)) _taskRow(task),
                  ], empty: 'Keine offenen Aufgaben'),
                ],
              ),
            );
            final remindersPanel = _Panel(
              child: Column(
                children: [
                  _panelTitle(
                    'Erinnerungen',
                    icon: Icons.notifications_none_rounded,
                    action: const _Pill('14 Tage'),
                  ),
                  const SizedBox(height: 7),
                  _items([
                    for (final reminder in reminders.take(4))
                      _reminderRow(reminder, compact: true),
                  ], empty: 'Keine fälligen Erinnerungen'),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () => go(Section.tasks, tab: 'Erinnerungen'),
                      child: const Text('Alle Erinnerungen'),
                    ),
                  ),
                ],
              ),
            );
            return size.maxWidth >= 750
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 6, child: tasksPanel),
                      const SizedBox(width: 15),
                      Expanded(flex: 5, child: remindersPanel),
                    ],
                  )
                : Column(
                    children: [
                      tasksPanel,
                      const SizedBox(height: 14),
                      remindersPanel,
                    ],
                  );
          },
        ),
        const SizedBox(height: 16),
        _Panel(
          child: Column(
            children: [
              _panelTitle(
                'Letzte Aktivitäten',
                icon: Icons.history_rounded,
                action: TextButton(
                  onPressed: () => go(Section.contacts, tab: 'Aktivitäten'),
                  child: const Text('Alle ansehen'),
                ),
              ),
              const SizedBox(height: 5),
              _items([
                for (final activity in activities.take(4))
                  _activityRow(activity),
              ]),
            ],
          ),
        ),
      ],
    );
  }

  Widget _reports() {
    final contacts = data.visibleContacts.toList();
    final properties = data.visibleProperties.toList();
    final activities = data.visibleActivities.toList();
    Map<String, int> counts(Iterable<String> labels) {
      final result = <String, int>{};
      for (final label in labels) {
        if (label.isNotEmpty)
          result.update(label, (count) => count + 1, ifAbsent: () => 1);
      }
      return result;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => refreshPage(() => reportsOpen = false),
            icon: const Icon(Icons.arrow_back_rounded, size: 17),
            label: const Text('Übersicht'),
          ),
        ),
        _PageTitle(
          'Berichte',
          action:
              data.allowed('Daten exportieren') &&
                  data.allowed('GL-Kontakte sehen')
              ? _newButton(
                  'Excel-Totalexport',
                  () => _exportPreview('Excel-Totalexport'),
                  icon: Icons.download_outlined,
                )
              : null,
        ),
        _fitGrid(
          [
            for (final item in <(String, int, IconData)>[
              (
                'Aktive Mandate',
                data.visibleMandates
                    .where((m) => m['Phase'] != 'Abgeschlossen')
                    .length,
                Icons.view_kanban_outlined,
              ),
              (
                'Verkauft',
                properties.where((p) => data.status(p) == 'Verkauft').length,
                Icons.verified_outlined,
              ),
              ('Aktivitäten', activities.length, Icons.history_rounded),
              (
                'Newsletter-Opt-ins',
                contacts.where((c) => c.flag('Newsletter')).length,
                Icons.mail_outline_rounded,
              ),
            ])
              _Panel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(item.$3, color: accent),
                    const SizedBox(height: 10),
                    Text(
                      '${item.$2}',
                      style: const TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(item.$1, style: const TextStyle(color: muted)),
                  ],
                ),
              ),
          ],
          minWidth: 158,
          maxColumns: 4,
        ),
        const SizedBox(height: 15),
        _fitGrid(
          [
            _Bars(
              'Kontaktherkunft',
              counts(contacts.map((c) => c['Herkunft'])),
            ),
            _Bars(
              'Aktivitäten nach Typ',
              counts(activities.map((a) => a['Typ'])),
            ),
            _Bars(
              'Aktivitäten nach Mitarbeiter',
              counts(activities.map((a) => data.staffName(a['Zuständig']))),
            ),
            _Bars(
              'Liegenschaften nach Status',
              counts(properties.map(data.status)),
            ),
          ],
          minWidth: 325,
          maxColumns: 2,
        ),
      ],
    );
  }
}

class _OverviewHero extends StatelessWidget {
  const _OverviewHero({
    required this.name,
    required this.date,
    required this.openReports,
  });
  final String name;
  final String date;
  final VoidCallback openReports;
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(23),
    child: LayoutBuilder(
      builder: (_, size) {
        final compact = size.maxWidth < 550;
        return DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white),
            borderRadius: BorderRadius.circular(23),
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xfff9fdff), Color(0xffdceef8), Color(0xffcfe5eb)],
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(painter: _HeroLines(compact)),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  compact ? 21 : 31,
                  24,
                  compact ? 18 : 28,
                  23,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Eyebrow(date.toUpperCase(), color: accent),
                    const SizedBox(height: 9),
                    Text(
                      'Willkommen, $name',
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: compact ? 32 : 43,
                        height: 1.12,
                        letterSpacing: -1.2,
                        color: navy,
                      ),
                    ),
                    const SizedBox(height: 9),
                    const Text(
                      'Dein Überblick für heute',
                      style: TextStyle(color: muted, fontSize: 14),
                    ),
                    const SizedBox(height: 17),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white70,
                        side: const BorderSide(color: Colors.white),
                      ),
                      onPressed: openReports,
                      icon: const Icon(Icons.bar_chart_rounded, size: 19),
                      label: const Text('Berichte'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}

class _HeroLines extends CustomPainter {
  _HeroLines(this.compact);
  final bool compact;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(
      size.width * (compact ? 1.14 : .85),
      size.height * .64,
    );
    final glow = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0x9af5fdff), Color(0x0083b4d4)],
      ).createShader(Rect.fromCircle(center: center, radius: 242));
    canvas.drawCircle(center, 242, glow);
    for (var i = 0; i < 6; i++) {
      final ring = Rect.fromCenter(
        center: center + Offset(i * 8, i * -4),
        width: 200 + i * 37,
        height: 135 + i * 30,
      );
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = i == 1 ? 2.4 : 1
        ..shader = const LinearGradient(
          colors: [Color(0xcffffffF), Color(0x49719fb7)],
        ).createShader(ring);
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(-.45);
      canvas.translate(-center.dx, -center.dy);
      canvas.drawOval(ring, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _HeroLines oldDelegate) =>
      oldDelegate.compact != compact;
}

class _Kpi extends StatelessWidget {
  const _Kpi(
    this.label,
    this.count,
    this.icon,
    this.color,
    this.action, {
    this.hint,
  });
  final String label;
  final int count;
  final IconData icon;
  final Color color;
  final VoidCallback action;
  final String? hint;
  @override
  Widget build(BuildContext context) => Material(
    borderRadius: BorderRadius.circular(17),
    color: Colors.white,
    child: InkWell(
      onTap: action,
      borderRadius: BorderRadius.circular(17),
      child: Container(
        height: 126,
        padding: const EdgeInsets.fromLTRB(13, 13, 11, 11),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: const Color(0xffe9f0f3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _Avatar('', icon: icon, color: color, size: 31),
                const Spacer(),
                const Icon(
                  Icons.north_east_rounded,
                  size: 13,
                  color: Color(0xff7891a2),
                ),
              ],
            ),
            const SizedBox(height: 7),
            Text(
              '$count',
              style: const TextStyle(
                fontSize: 25,
                height: 1,
                letterSpacing: -.55,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: muted,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (hint != null)
              Text(
                hint!,
                maxLines: 1,
                style: const TextStyle(
                  color: red,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

class _Bars extends StatelessWidget {
  const _Bars(this.title, this.values);
  final String title;
  final Map<String, int> values;
  @override
  Widget build(BuildContext context) {
    final max = values.values.fold(
      1,
      (current, next) => current > next ? current : next,
    );
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _panelTitle(title, icon: Icons.bar_chart_rounded),
          const SizedBox(height: 14),
          if (values.isEmpty) _empty('Keine Daten'),
          for (final entry in values.entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.key,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      Text('${entry.value}'),
                    ],
                  ),
                  const SizedBox(height: 5),
                  LinearProgressIndicator(
                    value: entry.value / max,
                    minHeight: 6,
                    backgroundColor: blueWash,
                    color: beckBlue,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
