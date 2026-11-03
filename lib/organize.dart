part of 'main.dart';

extension _Organize on _WorkspaceState {
  Widget _tasksPage() {
    final reminders = taskTab == 'Erinnerungen';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PageTitle(
          'Aufgaben',
          subtitle: 'Fälligkeiten und Wiedervorlagen',
          action: reminders
              ? _newButton('Neue Erinnerung', _reminderForm)
              : _newButton('Neue Aufgabe', () => _taskForm()),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: _tabs(
            ['Aufgaben', 'Erinnerungen'],
            taskTab,
            (tab) => refreshPage(() => taskTab = tab),
          ),
        ),
        const SizedBox(height: 14),
        if (reminders)
          _Panel(
            child: _items([
              for (final reminder in data.upcomingReminders())
                _reminderRow(reminder),
            ], empty: 'Keine Erinnerungen'),
          )
        else
          _taskList(),
      ],
    );
  }

  Widget _taskList() {
    final records = data.visibleTasks.where((task) {
      final visible = switch (taskStatus) {
        'Offen' => !task.flag('Erledigt'),
        'Überfällig' => !task.flag('Erledigt') && daysUntil(task['Datum']) < 0,
        'Erledigt' => task.flag('Erledigt'),
        _ => true,
      };
      return visible &&
          (!data.admin ||
              taskStaff == 'Alle' ||
              task['Zuständig'] == taskStaff);
    }).toList()..sort((a, b) => a['Datum'].compareTo(b['Datum']));
    final owners = staff();
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _filters(
                ['Alle', 'Offen', 'Überfällig', 'Erledigt'],
                taskStatus,
                (value) => refreshPage(() => taskStatus = value),
              ),
              if (data.admin)
                SizedBox(
                  width: 190,
                  child: DropdownButtonFormField<String>(
                    initialValue: owners.containsKey(taskStaff)
                        ? taskStaff
                        : 'Alle',
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Mitarbeiter'),
                    items: [
                      const DropdownMenuItem(
                        value: 'Alle',
                        child: Text('Alle'),
                      ),
                      for (final owner in owners.entries)
                        DropdownMenuItem(
                          value: owner.key,
                          child: Text(owner.value),
                        ),
                    ],
                    onChanged: (value) =>
                        refreshPage(() => taskStaff = value ?? 'Alle'),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 11),
          _items([
            for (final record in records) _taskRow(record),
          ], empty: 'Keine passenden Aufgaben'),
        ],
      ),
    );
  }

  Widget _taskRow(Record task) {
    final completed = task.flag('Erledigt');
    final due = daysUntil(task['Datum']);
    return _row(
      task.name,
      leading: Checkbox(
        value: completed,
        semanticLabel: '${task.name} als erledigt markieren',
        onChanged: (_) => data.change(() => task.toggle('Erledigt')),
      ),
      subtitle: [
        data.contactName(task['Kontakt']),
        data.staffName(task['Zuständig']),
      ].where((part) => part != '—').join(' · '),
      trailing: _Pill(
        completed
            ? 'Erledigt'
            : due == 0
            ? 'Heute'
            : shortDate(task['Datum']),
        color: completed
            ? green
            : due < 0
            ? red
            : due <= 1
            ? amber
            : muted,
      ),
      onTap: () => _taskDetail(task),
    );
  }

  Future<void> _taskDetail(Record task) => detail(
    task.name,
    () => Builder(
      builder: (context) {
        final contact = data.find(data.contacts, task['Kontakt']);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Panel(
              child: _facts({
                'Status': task.flag('Erledigt')
                    ? 'Erledigt'
                    : daysUntil(task['Datum']) < 0
                    ? 'Überfällig'
                    : 'Offen',
                'Fällig': shortDate(task['Datum']),
                'Priorität': task['Priorität'],
                'Zuständig': data.staffName(task['Zuständig']),
                'Kontakt': contact?.name ?? '—',
                'Notiz': task['Notiz'],
              }),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                _newButton(
                  task.flag('Erledigt') ? 'Wieder öffnen' : 'Erledigen',
                  () => data.change(() => task.toggle('Erledigt')),
                  icon: Icons.check_rounded,
                ),
                OutlinedButton(
                  onPressed: () => _taskForm(task: task),
                  child: const Text('Bearbeiten'),
                ),
                if (contact != null && data.canSeeContact(contact))
                  OutlinedButton(
                    onPressed: () => _contactDetail(contact),
                    child: const Text('Kontakt öffnen'),
                  ),
                if (data.allowed('Kontakte löschen'))
                  TextButton(
                    onPressed: () async {
                      if (!await confirm(
                            'Aufgabe löschen?',
                            task.name,
                            action: 'Löschen',
                          ) ||
                          !context.mounted)
                        return;
                      data.change(() => data.tasks.remove(task));
                      Navigator.pop(context);
                      toast('Aufgabe gelöscht');
                    },
                    child: const Text('Löschen', style: TextStyle(color: red)),
                  ),
              ],
            ),
          ],
        );
      },
    ),
  );

  Future<void> _taskForm({
    Record? contact,
    Record? task,
    String title = '',
  }) async {
    final result = await form(
      task == null ? 'Neue Aufgabe' : 'Aufgabe bearbeiten',
      [
        const _Field('Name', label: 'Titel', required: true),
        const _Field.date('Datum', label: 'Fälligkeit', required: true),
        _Field.select(
          'Priorität',
          _choices(['Normal', 'Hoch']),
          required: true,
        ),
        staffField(),
        _Field.lookup('Kontakt', options(data.visibleContacts)),
        const _Field('Notiz', long: true),
      ],
      initial: {
        'Name': title,
        'Datum': iso(day(1)),
        'Priorität': 'Normal',
        'Zuständig': data.user!.id,
        'Kontakt': contact?.id ?? '',
        ...?task?.fields,
      },
    );
    if (result == null || !mounted) return;
    data.change(() {
      if (task == null) {
        data.add(data.tasks, result);
      } else {
        task.update(result);
      }
    });
    toast('Aufgabe gespeichert');
  }

  Future<void> _reminderForm() async {
    final result = await form(
      'Neue Erinnerung',
      [
        const _Field('Name', label: 'Titel', required: true),
        const _Field.date('Datum', required: true),
        _Field.select(
          'Typ',
          _choices(['Einmalig', 'Jährlich']),
          required: true,
        ),
        _Field.lookup('Kontakt', options(data.visibleContacts)),
      ],
      initial: {'Datum': iso(day(1)), 'Typ': 'Einmalig'},
    );
    if (result == null || !mounted) return;
    data.change(
      () => data.add(data.reminders, {...result, 'Zuständig': data.user!.id}),
    );
    toast('Erinnerung gespeichert');
  }

  Widget _reminderRow(Record reminder, {bool compact = false}) {
    final contact = data.find(data.contacts, reminder['Kontakt']);
    final due = daysUntil(reminder['Datum']);
    final color = due <= 7
        ? red
        : due <= 14
        ? amber
        : green;
    final type = reminder['Typ'];
    return _row(
      reminder.name,
      leading: _Avatar(
        '',
        size: 35,
        color: color,
        icon: switch (type) {
          'Geburtstag' => Icons.cake_outlined,
          'Jährlich' => Icons.event_repeat_rounded,
          _ => Icons.event_outlined,
        },
      ),
      subtitle: '$type · ${shortDate(reminder['Datum'])}',
      trailing: compact
          ? _Pill(
              due < 0
                  ? 'Überfällig'
                  : due == 0
                  ? 'Heute'
                  : 'In $due T.',
              color: color,
            )
          : Wrap(
              spacing: 3,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (contact != null)
                  IconButton(
                    tooltip: 'Quick-Mail',
                    icon: const Icon(Icons.mail_outline, size: 18),
                    onPressed: () =>
                        _mail(contact: contact, title: reminder.name),
                  ),
                if (type == 'Einmalig')
                  IconButton(
                    tooltip: 'Erinnerung erledigen',
                    icon: const Icon(Icons.check_circle_outline, size: 19),
                    onPressed: () => data.change(
                      () => data.completedReminders.add(reminder.id),
                    ),
                  ),
              ],
            ),
      onTap: () => detail(
        reminder.name,
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Panel(
              child: _facts({
                'Datum': shortDate(reminder['Datum']),
                'Typ': type,
                'Kontakt': contact?.name ?? '—',
              }),
            ),
            const SizedBox(height: 9),
            Wrap(
              spacing: 7,
              children: [
                if (contact != null) ...[
                  OutlinedButton(
                    onPressed: () => _contactDetail(contact),
                    child: const Text('Kontakt öffnen'),
                  ),
                  TextButton(
                    onPressed: () =>
                        _mail(contact: contact, title: reminder.name),
                    child: const Text('Quick-Mail'),
                  ),
                ],
                if (type == 'Einmalig' &&
                    !data.completedReminders.contains(reminder.id))
                  _newButton(
                    'Erledigen',
                    () => data.change(
                      () => data.completedReminders.add(reminder.id),
                    ),
                    icon: Icons.check_rounded,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _settings({String initial = 'Einstellungen'}) {
    var tab = initial;
    return detail(
      'Einstellungen',
      () => StatefulBuilder(
        builder: (_, refresh) {
          final tabs = [
            'Einstellungen',
            if (data.allowed('Berechtigungen verwalten')) 'Benutzer',
            'Datenschutz',
            'Import & Export',
          ];
          if (!tabs.contains(tab)) tab = tabs.first;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _tabs(tabs, tab, (name) => refresh(() => tab = name)),
              const SizedBox(height: 13),
              switch (tab) {
                'Benutzer' => _accounts(),
                'Datenschutz' => _privacy(),
                'Import & Export' => _imports(),
                _ => _preferences(),
              },
            ],
          );
        },
      ),
      subtitle: 'Demo-Arbeitsbereich',
    );
  }

  Widget _preferences() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _panelTitle(
              'Firmendaten',
              action: data.allowed('Berechtigungen verwalten')
                  ? TextButton(
                      onPressed: _companyForm,
                      child: const Text('Bearbeiten'),
                    )
                  : null,
            ),
            const SizedBox(height: 9),
            _facts(data.company),
          ],
        ),
      ),
      const SizedBox(height: 12),
      if (data.admin)
        _Panel(
          child: _items([
            _row(
              'GL-Passwort ändern',
              leading: const _Avatar('', icon: Icons.lock_outline),
              onTap: _glPasswordForm,
            ),
            _row(
              'Demo-Daten zurücksetzen',
              subtitle: 'Ersetzt den aktuellen Demo-Datenbestand',
              leading: const _Avatar(
                '',
                icon: Icons.restart_alt_rounded,
                color: red,
              ),
              onTap: _reset,
            ),
          ]),
        ),
    ],
  );

  Future<void> _companyForm() async {
    final result = await form('Firmendaten', [
      const _Field('Firma', required: true),
      const _Field('Adresse'),
      const _Field('Telefon'),
      const _Field('E-Mail'),
    ], initial: data.company);
    if (result == null || !mounted) return;
    data.change(() => data.company.addAll(result));
    toast('Firmendaten gespeichert');
  }

  Future<void> _glPasswordForm() async {
    final result = await form('GL-Passwort ändern', [
      const _Field('Neues Passwort', secret: true, required: true),
    ]);
    if (result == null || !mounted) return;
    data.change(() {
      data.glPassword = result['Neues Passwort']!;
      data.glOpen = false;
    });
    if (contactRole == 'GL-Kontakt') refreshPage(() => contactRole = 'Alle');
    toast('GL-Passwort gespeichert · Demo');
  }

  Future<void> _reset() async {
    if (!await confirm(
          'Demo-Daten zurücksetzen?',
          'Änderungen in dieser Sitzung werden durch Demo-Daten ersetzt.',
          action: 'Zurücksetzen',
        ) ||
        !mounted)
      return;
    data.reset();
    refreshPage(() {
      contactRole = 'Alle';
      contactTag = 'Alle';
      taskStaff = 'Alle';
    });
    toast('Demo-Daten geladen');
  }

  Widget _accounts() => _Panel(
    child: Column(
      children: [
        _panelTitle(
          'Benutzer',
          action: TextButton.icon(
            onPressed: () => _accountForm(),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Neuer Benutzer'),
          ),
        ),
        _items([
          for (final user in data.accounts)
            _row(
              user.name,
              leading: _Avatar(user.name),
              subtitle: user['Rolle'],
              trailing: _Pill(
                user.flag('Deaktiviert') ? 'Deaktiviert' : 'Aktiv',
                color: user.flag('Deaktiviert') ? muted : green,
              ),
              onTap: () => _accountForm(user: user),
            ),
        ]),
      ],
    ),
  );

  Future<void> _accountForm({Record? user}) async {
    final first = await form(
      user == null ? 'Neuer Benutzer' : 'Benutzer bearbeiten',
      [
        const _Field('Name', required: true),
        _Field.select(
          'Rolle',
          _choices(['Admin', 'Manager', 'Mitarbeiter']),
          required: true,
        ),
      ],
      initial: {'Rolle': 'Mitarbeiter', ...?user?.fields},
      submit: 'Weiter',
      validate: (fields) =>
          user?.id == data.user?.id && fields['Rolle'] != user?['Rolle']
          ? 'Die eigene Rolle bleibt für diese Sitzung gesetzt.'
          : null,
    );
    if (first == null || !mounted) return;
    final useDefaults = user == null || user['Rolle'] != first['Rolle'];
    final result = await form(
      'Zugriff und Passwort',
      [
        const _Field('Passwort', required: true, secret: true),
        if (user?.id != data.user?.id) const _Field.check('Deaktiviert'),
        for (final permission in permissions) _Field.check(permission),
      ],
      initial: {
        'Passwort': 'beck',
        ...first,
        if (useDefaults)
          for (final permission in permissions)
            permission:
                first['Rolle'] == 'Admin' ||
                    (first['Rolle'] == 'Manager' &&
                        [
                          'Adressen drucken',
                          'Gruppen-Mail senden',
                        ].contains(permission))
                ? 'ja'
                : '',
      },
      validate: (fields) =>
          user?.id == data.user?.id &&
              fields['Berechtigungen verwalten'] != 'ja'
          ? 'Die eigene Benutzerverwaltung muss aktiviert bleiben.'
          : null,
    );
    if (result == null || !mounted) return;
    data.change(() {
      if (user == null) {
        data.add(data.accounts, result);
      } else {
        user.update(result);
      }
    });
    toast('Benutzer gespeichert');
  }

  Widget _privacy() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Wrap(
        spacing: 7,
        runSpacing: 7,
        children: [
          if (data.allowed('Daten exportieren'))
            _newButton(
              'Auskunft exportieren',
              () => _personalData(),
              icon: Icons.download_outlined,
            ),
          if (data.allowed('Kontakte löschen'))
            OutlinedButton(
              onPressed: () => _personalData(delete: true),
              child: const Text('Personendaten löschen'),
            ),
        ],
      ),
      const SizedBox(height: 12),
      _Panel(
        child: Column(
          children: [
            _panelTitle('Newsletter-Einwilligungen'),
            const SizedBox(height: 5),
            _items([
              for (final contact in data.visibleContacts)
                _row(
                  contact.name,
                  subtitle: contact['E-Mail'],
                  trailing: Switch(
                    value: contact.flag('Newsletter'),
                    onChanged: (_) =>
                        data.change(() => contact.toggle('Newsletter')),
                  ),
                ),
            ]),
          ],
        ),
      ),
    ],
  );

  Future<void> _personalData({bool delete = false}) async {
    final fields = await form(
      delete ? 'Löschung vorbereiten' : 'Auskunft vorbereiten',
      [const _Field('E-Mail', required: true)],
      submit: 'Suchen',
    );
    if (fields == null || !mounted) return;
    final contacts = data.visibleContacts
        .where(
          (c) => c['E-Mail'].toLowerCase() == fields['E-Mail']!.toLowerCase(),
        )
        .toList();
    final ids = contacts.map((c) => c.id).toSet();
    final activities = data.visibleActivities
        .where((a) => ids.contains(a['Kontakt']))
        .toList();
    final tasks = data.visibleTasks
        .where((t) => ids.contains(t['Kontakt']))
        .toList();
    final reminders = data.reminders
        .where((r) => data.canSeeLinked(r) && ids.contains(r['Kontakt']))
        .toList();
    await detail(
      delete ? 'Löschvorschau' : 'Auskunftsvorschau',
      () => Builder(
        builder: (context) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Panel(
              child: _items([
                for (final c in contacts) _row(c.name, subtitle: c['E-Mail']),
              ], empty: 'Keine passenden Daten'),
            ),
            if (contacts.isNotEmpty) ...[
              const SizedBox(height: 8),
              _facts({
                'Aktivitäten': '${activities.length}',
                'Aufgaben': '${tasks.length}',
                'Erinnerungen': '${reminders.length}',
              }),
              const SizedBox(height: 12),
              if (delete)
                FilledButton(
                  onPressed: () async {
                    if (!await confirm(
                          'Personendaten löschen?',
                          'Kontakte und zugehörige Aktivitäten, Aufgaben und Erinnerungen werden entfernt.',
                          action: 'Löschen',
                        ) ||
                        !context.mounted)
                      return;
                    data.change(() {
                      data.activities.removeWhere(activities.contains);
                      data.tasks.removeWhere(tasks.contains);
                      data.reminders.removeWhere(reminders.contains);
                      for (final contact in contacts)
                        data.deleteContact(contact);
                    });
                    Navigator.pop(context);
                    toast('Demo-Personendaten gelöscht');
                  },
                  child: const Text('Löschen'),
                )
              else
                _newButton(
                  'JSON kopieren',
                  () => _copyJson({
                    'kontakte': contacts.map((item) => item.fields).toList(),
                    'aktivitaeten': activities
                        .map((item) => item.fields)
                        .toList(),
                    'aufgaben': tasks.map((item) => item.fields).toList(),
                    'erinnerungen': reminders
                        .map((item) => item.fields)
                        .toList(),
                  }),
                  icon: Icons.copy_rounded,
                ),
            ],
          ],
        ),
      ),
      subtitle: 'Demo',
    );
  }

  Widget _imports() => _fitGrid(
    [
      _actionCard(
        'Kontakte importieren',
        'Excel- oder CSV-Beispiel mit Vorschau',
        Icons.upload_file_outlined,
        _importDemo,
      ),
      _actionCard(
        'Importvorlage',
        'Spalten und Beispieldatensatz',
        Icons.table_view_outlined,
        _importTemplate,
      ),
      if (data.allowed('Daten exportieren') &&
          data.allowed('GL-Kontakte sehen'))
        _actionCard(
          'Excel-Totalexport',
          'Kontakte, Liegenschaften und Aufgaben',
          Icons.download_outlined,
          () => _exportPreview('Excel-Totalexport'),
        ),
      if (data.admin) ...[
        _actionCard(
          'Backup erstellen',
          'JSON-Vorschau und Sicherung in der Sitzung',
          Icons.save_alt_rounded,
          _backup,
        ),
        _actionCard(
          'Backup wiederherstellen',
          'Sicherung dieser Sitzung einspielen',
          Icons.restore_rounded,
          _restore,
        ),
        _actionCard(
          'Migration',
          'Altbestand prüfen und übernehmen',
          Icons.swap_horiz_rounded,
          _migration,
        ),
      ],
    ],
    minWidth: 220,
    maxColumns: 2,
  );

  Future<void> _importTemplate() => detail(
    'Importvorlage',
    () => _Panel(
      child: _items([
        _row('Name, E-Mail, Ort, Kanton, Rolle'),
        _row('Sophie Graf, sophie.graf@example.ch, Luzern, LU, Käufer'),
      ]),
    ),
    subtitle: 'Excel-Vorschau · Demo',
  );

  Future<void> _importDemo() async {
    final input = await form(
      'Import vorbereiten · Demo',
      [
        _Field.select(
          'Datei',
          _choices(['Beispielkontakte.xlsx', 'Beispielkontakte.csv']),
          required: true,
        ),
        _Field.select(
          'Rolle',
          _choices(roles.where((r) => r != 'GL-Kontakt' || data.glOpen)),
          label: 'Kontakttyp',
          required: true,
        ),
      ],
      initial: const {'Datei': 'Beispielkontakte.xlsx', 'Rolle': 'Käufer'},
      submit: 'Vorschau',
    );
    if (input == null || !mounted) return;
    await _importPreview(input['Datei']!, input['Rolle']!);
  }

  Future<void> _importPreview(
    String source,
    String role, {
    bool legacy = false,
  }) {
    final rows = legacy
        ? [('Jan Koch', 'jan.koch@example.ch', 'Kriens')]
        : [
            ('Sophie Graf', 'sophie.graf@example.ch', 'Luzern'),
            ('Nils Peter', 'nils.peter@example.ch', 'Horw'),
          ];
    return detail(
      'Importvorschau',
      () => Builder(
        builder: (context) {
          final pending = rows
              .where((row) => !data.contacts.any((c) => c['E-Mail'] == row.$2))
              .toList();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Panel(
                child: _items([
                  for (final row in rows)
                    _row(
                      row.$1,
                      subtitle: '${row.$2} · ${row.$3}',
                      trailing: _Pill(
                        pending.contains(row) ? role : 'Bereits vorhanden',
                      ),
                    ),
                ]),
              ),
              const SizedBox(height: 11),
              FilledButton(
                onPressed: pending.isEmpty
                    ? null
                    : () {
                        data.change(() {
                          for (final row in pending) {
                            data.add(data.contacts, {
                              'Name': row.$1,
                              'E-Mail': row.$2,
                              'Ort': row.$3,
                              'Kanton': 'LU',
                              'Personentyp': 'Einzelperson',
                              'Zuständig': data.user!.id,
                              'Rollen': role,
                            });
                          }
                        });
                        Navigator.pop(context);
                        toast('${pending.length} Kontakte importiert · Demo');
                      },
                child: Text('${pending.length} Kontakte übernehmen'),
              ),
            ],
          );
        },
      ),
      subtitle: '$source · Demo',
    );
  }

  Future<void> _migration() => detail(
    'Migration',
    () => _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: _Pill('Altbestand erkannt · beck4_', color: amber),
          ),
          const SizedBox(height: 11),
          _newButton(
            'Migration prüfen',
            () => _importPreview('beck4_', 'Verkäufer', legacy: true),
            icon: Icons.swap_horiz_rounded,
          ),
        ],
      ),
    ),
    subtitle: 'Demo',
  );

  Future<void> _exportPreview(String title, {List<String>? rows}) {
    final sections = rows == null
        ? {
            'Kontakte': data.visibleContacts.toList(),
            'Liegenschaften': data.visibleProperties.toList(),
            'Aufgaben': data.visibleTasks.toList(),
          }
        : null;
    return detail(
      title,
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Panel(
            child: _items([
              if (sections != null)
                for (final entry in sections.entries)
                  _row(
                    entry.key,
                    subtitle: '${entry.value.length} Datensätze',
                    leading: const _Avatar('', icon: Icons.table_view_outlined),
                  ),
              if (rows != null)
                for (final row in rows) _row(row),
            ]),
          ),
          const SizedBox(height: 11),
          _newButton(
            'Export simulieren',
            () => toast('Excel-Export vorbereitet · Demo'),
            icon: Icons.download_outlined,
          ),
        ],
      ),
      subtitle: 'Vorschau · Demo',
    );
  }

  Future<void> _backup() => detail(
    'Backup erstellen',
    () => Builder(
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Panel(
            child: _items([
              for (final collection in data.collections.entries)
                _row(
                  collection.key,
                  trailing: _Pill('${collection.value.length}'),
                ),
            ]),
          ),
          const SizedBox(height: 11),
          _newButton('Sicherung erstellen', () {
            demoBackup = data.snapshot();
            Navigator.pop(context);
            toast('Sicherung erstellt · Demo');
          }, icon: Icons.save_alt_rounded),
        ],
      ),
    ),
    subtitle: 'JSON-Vorschau · Demo',
  );

  Future<void> _restore() async {
    final snapshot = demoBackup;
    if (snapshot == null) {
      await detail(
        'Backup wiederherstellen',
        () => _Panel(
          child: _empty('Erstelle zuerst eine Sicherung in dieser Sitzung'),
        ),
      );
      return;
    }
    if (!await confirm(
          'Backup wiederherstellen?',
          'Die Sicherung ersetzt die aktuellen Demo-Datensätze.',
          action: 'Wiederherstellen',
        ) ||
        !mounted)
      return;
    data.change(() => data.restore(snapshot));
    toast('Sicherung wiederhergestellt · Demo');
  }

  Future<void> _copyJson(Map<String, Object> values) async {
    try {
      await Clipboard.setData(
        ClipboardData(text: const JsonEncoder.withIndent('  ').convert(values)),
      );
      toast('JSON kopiert · Demo');
    } on PlatformException {
      toast('Zwischenablage nicht verfügbar');
    }
  }

  Widget _paper(String title, List<Widget> children) => _Panel(
    padding: const EdgeInsets.all(25),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _Brand(),
        const SizedBox(height: 15),
        const Divider(thickness: 2, color: beckBlue),
        const SizedBox(height: 11),
        Text(
          title,
          style: const TextStyle(fontFamily: 'Georgia', fontSize: 25),
        ),
        const SizedBox(height: 11),
        ...children,
        const SizedBox(height: 16),
        const Divider(),
        Text(
          ['Firma', 'Adresse', 'Telefon', 'E-Mail']
              .map((key) => data.company[key] ?? '')
              .where((part) => part.isNotEmpty)
              .join(' · '),
          style: const TextStyle(fontSize: 10, color: muted),
        ),
      ],
    ),
  );
}

Widget _actionCard(
  String title,
  String subtitle,
  IconData icon,
  VoidCallback? action,
) => _Panel(
  padding: const EdgeInsets.all(12),
  child: _row(
    title,
    subtitle: subtitle,
    leading: _Avatar('', icon: icon),
    onTap: action,
    trailing: action == null
        ? const Icon(Icons.lock_outline, size: 18, color: muted)
        : null,
  ),
);
