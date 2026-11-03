part of 'main.dart';

const _letterTemplates = [
  'Verkaufsangebot',
  'Besichtigungseinladung',
  'Mandatsbestätigung',
  'Bewertungsangebot',
  'Eigentümervertretung',
  'Machbarkeitsstudie',
  'Sanierungskonzept',
  'Baubegleitungs-Offerte',
  'Verkaufsabschluss',
];

extension _Contacts on _WorkspaceState {
  Widget _contactsPage() {
    final activityView = contactTab == 'Aktivitäten';
    final contactList = contactTab == 'Kontakte';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PageTitle(
          'Kontakte',
          subtitle: 'Beziehungen, Suchprofile und Aktivitäten',
          action: contactList
              ? _newButton('Neuer Kontakt', () => _contactForm())
              : activityView
              ? _newButton('Aktivität erfassen', () => _activityForm())
              : null,
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: _tabs(
            ['Kontakte', 'Aktivitäten', 'Kommunikation'],
            contactTab,
            (value) => refreshPage(() => contactTab = value),
          ),
        ),
        const SizedBox(height: 14),
        if (contactList) _contactList(),
        if (activityView) _activityList(),
        if (contactTab == 'Kommunikation') _communication(),
      ],
    );
  }

  Widget _contactList() {
    final groups = [
      'Alle',
      ...roles.where(
        (role) => role != 'GL-Kontakt' || data.allowed('GL-Kontakte sehen'),
      ),
    ];
    final facet = switch (contactRole) {
      'Handwerker' => 'Gewerke',
      'Netzwerk' => 'Funktionen',
      'Netzwerkpartner' => 'Partnertyp',
      _ => '',
    };
    final roleContacts = data.visibleContacts
        .where(
          (c) =>
              contactRole == 'Alle' || c.values('Rollen').contains(contactRole),
        )
        .toList();
    final facets = {
      for (final contact in roleContacts) ...contact.values(facet),
    }.toList()..sort();
    final visible =
        roleContacts
            .where(
              (c) =>
                  (contactTag == 'Alle' ||
                      c.values(facet).contains(contactTag)) &&
                  [c.name, c['Firma'], c['Ort'], c['Strasse'], c['E-Mail']]
                      .join(' ')
                      .toLowerCase()
                      .contains(contactQuery.toLowerCase()),
            )
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name));
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _search(
                'Kontakte suchen',
                contactQuery,
                (query) => refreshPage(() => contactQuery = query),
              ),
              _Pill('${visible.length} Kontakte', color: accent),
            ],
          ),
          const SizedBox(height: 11),
          _filters(groups, contactRole, (role) async {
            if (role == 'GL-Kontakt' && !data.glOpen && !await _unlockGl())
              return;
            if (mounted)
              refreshPage(() {
                contactRole = role;
                contactTag = 'Alle';
              });
          }),
          if (facets.isNotEmpty) ...[
            const SizedBox(height: 8),
            _filters(
              ['Alle', ...facets],
              contactTag,
              (tag) => refreshPage(() => contactTag = tag),
            ),
          ],
          const SizedBox(height: 14),
          const Divider(height: 1),
          _items([
            for (final contact in visible)
              _row(
                contact.name,
                leading: _Avatar(contact.name),
                subtitle: [
                  contact['Ort'],
                  contact['E-Mail'],
                ].where((part) => part.isNotEmpty).join(' · '),
                trailing: Wrap(
                  spacing: 5,
                  children: [
                    _Pill(
                      contact.values('Rollen').firstOrNull ?? 'Kontakt',
                      color: accent,
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: muted,
                      size: 18,
                    ),
                  ],
                ),
                onTap: () => _contactDetail(contact),
              ),
          ], empty: 'Keine passenden Kontakte'),
        ],
      ),
    );
  }

  Future<bool> _unlockGl() async {
    if (!data.allowed('GL-Kontakte sehen')) return false;
    if (data.glOpen) return true;
    final result = await form(
      'GL-Bereich entsperren',
      [const _Field('GL-Passwort', secret: true, required: true)],
      submit: 'Entsperren',
      compact: true,
      validate: (value) =>
          value['GL-Passwort'] == data.glPassword ? null : 'GL-Passwort prüfen',
    );
    if (result == null) return false;
    data.change(() => data.glOpen = true);
    return true;
  }

  Future<void> _contactForm({Record? contact}) async {
    final values = Fields.of(contact?.fields ?? {});
    final choice = await form(
      contact == null ? 'Neuer Kontakt' : 'Kontakt bearbeiten',
      [
        _Field.multi(
          'Rollen',
          _choices(
            roles.where(
              (r) => r != 'GL-Kontakt' || data.allowed('GL-Kontakte sehen'),
            ),
          ),
          required: true,
        ),
        _Field.select('Personentyp', _choices(personTypes), required: true),
      ],
      initial: {
        'Rollen': contactRole == 'Alle' ? '' : contactRole,
        'Personentyp': personTypes.first,
        ...values,
      },
      submit: 'Weiter',
    );
    if (choice == null || !mounted) return;
    final selected = Record('', choice).values('Rollen');
    if (selected.contains('GL-Kontakt') && !await _unlockGl()) return;
    if (!mounted) return;
    final type = choice['Personentyp'];
    final result = await form(
      contact == null ? 'Kontaktdaten' : 'Kontaktdaten bearbeiten',
      [
        _Field(
          'Name',
          label: switch (type) {
            'Juristische Person' => 'Firmenname',
            'Familie' => 'Familienname',
            'Ehepaar / Partner' => 'Person 1 · Vor- und Nachname',
            _ => 'Vor- und Nachname',
          },
          required: true,
        ),
        if (type != 'Juristische Person' && type != 'Familie')
          const _Field('Titel'),
        if (type == 'Ehepaar / Partner')
          const _Field('Person 2', label: 'Person 2 · Titel und Name'),
        if (type == 'Familie' || type == 'Juristische Person')
          const _Field('Kontaktperson'),
        if (type == 'Juristische Person') ...[
          const _Field('Rechtsform'),
          const _Field('UID'),
        ],
        if (type != 'Juristische Person' &&
            selected.any(
              (r) => ['Handwerker', 'Netzwerk', 'Netzwerkpartner'].contains(r),
            ))
          const _Field('Firma'),
        const _Field('Strasse'),
        const _Field('PLZ'),
        const _Field('Ort'),
        _Field.select('Kanton', _choices(cantons)),
        const _Field('E-Mail'),
        const _Field('Telefon'),
        _Field.select('Herkunft', _choices(origins)),
        staffField(),
        const _Field.date('Geburtstag'),
        const _Field.date('Erinnerung am'),
        const _Field.check('Erinnerung jährlich'),
        const _Field('Erinnerungsnotiz'),
        const _Field.check('Newsletter', label: 'Newsletter-Einwilligung'),
        if (selected.contains('Käufer')) ..._buyerFields(),
        if (selected.contains('Eigentümer')) ...[
          const _Field('Portfolio'),
          const _Field('Strategie'),
        ],
        if (selected.contains('Handwerker')) ...[
          const _Field('Hauptgewerk'),
          const _Field('Gewerke', label: 'Gewerke · durch Kommas trennen'),
        ],
        if (selected.contains('Netzwerk'))
          const _Field(
            'Funktionen',
            label: 'Funktionen · durch Kommas trennen',
          ),
        if (selected.contains('Netzwerkpartner')) const _Field('Partnertyp'),
        if (selected.contains('GL-Kontakt'))
          const _Field('GL-Budget', numeric: true),
        const _Field('Notiz', long: true),
      ],
      initial: {'Zuständig': data.user!.id, ...values, ...choice},
      validate: _validBuyer,
    );
    if (result == null || !mounted) return;
    data.change(() {
      if (contact == null) {
        data.add(data.contacts, result);
      } else {
        contact.update(result);
      }
    });
    toast('Kontakt gespeichert');
  }

  List<_Field> _buyerFields() => [
    const _Field('Budget von', numeric: true),
    const _Field('Budget bis', numeric: true),
    _Field.select(
      'Suchobjekt',
      _choices(propertyTypes),
      label: 'Gewünschter Objekttyp',
    ),
    const _Field('Zimmer ab', numeric: true),
    const _Field('Region'),
    const _Field('Such-PLZ', label: 'Such-PLZ · durch Kommas trennen'),
    _Field.multi('Suchkantone', _choices(cantons)),
  ];

  String? _validBuyer(Fields values) {
    if (number(values['Budget bis'] ?? '') > 0 &&
        number(values['Budget von'] ?? '') >
            number(values['Budget bis'] ?? '')) {
      return 'Das Budget bis muss mindestens dem Budget von entsprechen.';
    }
    return null;
  }

  Future<void> _buyerForm(Record contact) async {
    final result = await form(
      'Käuferprofil',
      _buyerFields(),
      initial: contact.fields,
      validate: _validBuyer,
    );
    if (result == null || !mounted) return;
    data.change(() => contact.update(result));
    toast('Suchprofil gespeichert');
  }

  Future<void> _contactDetail(Record contact) {
    var tab = 'Info';
    return detail(
      contact.name,
      () => StatefulBuilder(
        builder: (dialogContext, changeTab) {
          final kinds = contact.values('Rollen');
          final buyer = kinds.contains('Käufer');
          final seller = kinds.contains('Verkäufer');
          final owner = kinds.contains('Eigentümer');
          final tabs = [
            'Info',
            'Aktivitäten',
            'Aufgaben',
            if (seller || owner) 'Liegenschaften',
            if (owner) 'Architektur',
            if (buyer) 'Matching',
          ];
          if (!tabs.contains(tab)) tab = 'Info';
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final kind in kinds) _Pill(kind, color: accent),
                ],
              ),
              const SizedBox(height: 13),
              _tabs(tabs, tab, (value) => changeTab(() => tab = value)),
              const SizedBox(height: 13),
              if (tab == 'Info') ...[
                _Panel(
                  child: _facts({
                    for (final key in [
                      'Personentyp',
                      'Titel',
                      'Person 2',
                      'Firma',
                      'Rechtsform',
                      'UID',
                      'Kontaktperson',
                      'E-Mail',
                      'Telefon',
                      'Strasse',
                      'PLZ',
                      'Ort',
                      'Kanton',
                      'Herkunft',
                      'Geburtstag',
                      'Erinnerung am',
                      'Erinnerungsnotiz',
                      'Portfolio',
                      'Strategie',
                      'Hauptgewerk',
                      'Gewerke',
                      'Funktionen',
                      'Partnertyp',
                      if (kinds.contains('GL-Kontakt')) 'GL-Budget',
                      'Notiz',
                    ])
                      key: contact[key],
                    'Zuständig': data.staffName(contact['Zuständig']),
                    'Newsletter': contact.flag('Newsletter')
                        ? 'Einwilligung erteilt'
                        : 'Keine Einwilligung',
                  }),
                ),
                if (seller) ...[
                  const SizedBox(height: 12),
                  _Panel(
                    child: Column(
                      children: [
                        _panelTitle(
                          'Mandate',
                          action: TextButton.icon(
                            onPressed: () => _mandateForm(contact: contact),
                            icon: const Icon(Icons.add_rounded, size: 17),
                            label: const Text('Mandat erfassen'),
                          ),
                        ),
                        _items([
                          for (final mandate in data.visibleMandates.where(
                            (m) => m['Kontakt'] == contact.id,
                          ))
                            _row(
                              mandate.name,
                              subtitle: mandate['Phase'],
                              onTap: () => _mandateDetail(mandate),
                            ),
                        ]),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: [
                    _newButton(
                      'Bearbeiten',
                      () => _contactForm(contact: contact),
                      icon: Icons.edit_outlined,
                    ),
                    OutlinedButton(
                      onPressed: () =>
                          _mail(contact: contact, title: 'Dokument senden'),
                      child: const Text('Dokument senden'),
                    ),
                    if (data.allowed('Adressen drucken'))
                      OutlinedButton(
                        onPressed: () => _addressPrint(contact: contact),
                        child: const Text('Adresse drucken'),
                      ),
                    if (data.allowed('Kontakte löschen'))
                      TextButton(
                        onPressed: () async {
                          if (await confirm(
                                'Kontakt löschen?',
                                contact.name,
                                action: 'Löschen',
                              ) &&
                              dialogContext.mounted) {
                            data.change(() => data.deleteContact(contact));
                            Navigator.pop(dialogContext);
                            toast('Kontakt gelöscht');
                          }
                        },
                        child: const Text(
                          'Löschen',
                          style: TextStyle(color: red),
                        ),
                      ),
                  ],
                ),
              ],
              if (tab == 'Aktivitäten')
                _Panel(
                  child: Column(
                    children: [
                      _panelTitle(
                        'Aktivitäten',
                        action: TextButton(
                          onPressed: () => _activityForm(contact: contact),
                          child: const Text('Hinzufügen'),
                        ),
                      ),
                      _items([
                        for (final activity in _orderedActivities(
                          data.visibleActivities.where(
                            (a) => a['Kontakt'] == contact.id,
                          ),
                        ))
                          _activityRow(activity),
                      ]),
                    ],
                  ),
                ),
              if (tab == 'Aufgaben')
                _Panel(
                  child: Column(
                    children: [
                      _panelTitle(
                        'Aufgaben',
                        action: TextButton(
                          onPressed: () => _taskForm(contact: contact),
                          child: const Text('Hinzufügen'),
                        ),
                      ),
                      _items([
                        for (final task in data.visibleTasks.where(
                          (t) => t['Kontakt'] == contact.id,
                        ))
                          _taskRow(task),
                      ]),
                    ],
                  ),
                ),
              if (tab == 'Liegenschaften')
                _Panel(
                  child: Column(
                    children: [
                      _panelTitle(
                        'Liegenschaften',
                        action: TextButton(
                          onPressed: () => _propertyForm(contact: contact),
                          child: const Text('Neue Liegenschaft'),
                        ),
                      ),
                      _items([
                        for (final property in data.visibleProperties.where(
                          (p) =>
                              p['Eigentümer'] == contact.id ||
                              p['Verkäufer'] == contact.id,
                        ))
                          _row(
                            property.name,
                            subtitle:
                                '${francs(property['Preis'])} · ${data.status(property)}',
                            onTap: () => _propertyDetail(property),
                          ),
                      ]),
                    ],
                  ),
                ),
              if (tab == 'Architektur')
                _Panel(
                  child: Column(
                    children: [
                      _panelTitle(
                        'Architekturprojekte',
                        action: TextButton(
                          onPressed: () => _projectForm(owner: contact),
                          child: const Text('Neues Projekt'),
                        ),
                      ),
                      _items([
                        for (final project in data.visibleProjects.where(
                          (p) => p['Eigentümer'] == contact.id,
                        ))
                          _row(
                            project.name,
                            subtitle: project['Phase'],
                            onTap: () => _projectDetail(project),
                          ),
                      ]),
                    ],
                  ),
                ),
              if (tab == 'Matching') ...[
                _Panel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _panelTitle(
                        'Käuferprofil',
                        action: TextButton(
                          onPressed: () => _buyerForm(contact),
                          child: const Text('Bearbeiten'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _facts({
                        'Budget bis': francs(contact['Budget bis']),
                        'Objekttyp': contact['Suchobjekt'],
                        'Zimmer ab': contact['Zimmer ab'],
                        'Region': contact['Region'],
                        'PLZ': contact['Such-PLZ'],
                        'Kantone': contact['Suchkantone'],
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 11),
                _matchResults(
                  data.matches(buyerId: contact.id),
                  showBuyer: false,
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  List<Record> _orderedActivities(Iterable<Record> records) {
    final ordered = records.toList().reversed.indexed.toList();
    ordered.sort((a, b) {
      final compare = b.$2['Datum'].compareTo(a.$2['Datum']);
      return compare == 0 ? a.$1.compareTo(b.$1) : compare;
    });
    return ordered.map((item) => item.$2).toList();
  }

  Widget _activityList() {
    final activities = _orderedActivities(
      data.visibleActivities.where(
        (a) =>
            (activityType == 'Alle' || activityType == a['Typ']) &&
            '${a.name} ${a['Notiz']} ${data.contactName(a['Kontakt'])}'
                .toLowerCase()
                .contains(activityQuery.toLowerCase()),
      ),
    );
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _search(
            'Aktivitäten suchen',
            activityQuery,
            (query) => refreshPage(() => activityQuery = query),
          ),
          const SizedBox(height: 10),
          _filters(
            ['Alle', ...activityTypes],
            activityType,
            (type) => refreshPage(() => activityType = type),
          ),
          const SizedBox(height: 13),
          _items([
            for (final activity in activities) _activityRow(activity),
          ], empty: 'Keine passenden Aktivitäten'),
        ],
      ),
    );
  }

  Widget _activityRow(Record activity) => _row(
    activity.name,
    leading: _Avatar(
      '',
      icon: switch (activity['Typ']) {
        'Anruf' => Icons.call_outlined,
        'E-Mail' => Icons.mail_outline_rounded,
        'Besichtigung' => Icons.location_on_outlined,
        _ => Icons.notes_rounded,
      },
    ),
    subtitle:
        '${activity['Typ']} · ${data.contactName(activity['Kontakt'])} · ${data.staffName(activity['Zuständig'])}',
    trailing: _Pill(shortDate(activity['Datum'])),
    onTap: () => detail(
      activity.name,
      () => _Panel(
        child: _facts({
          'Typ': activity['Typ'],
          'Datum': shortDate(activity['Datum']),
          'Kontakt': data.contactName(activity['Kontakt']),
          'Erfasst von': data.staffName(activity['Zuständig']),
          'Notiz': activity['Notiz'],
        }),
      ),
    ),
  );

  Future<void> _activityForm({Record? contact, bool quick = false}) async {
    final fields = [
      _Field.select('Typ', _choices(activityTypes), required: true),
      const _Field.date('Datum', required: true),
      _Field.lookup('Kontakt', options(data.visibleContacts), required: true),
      const _Field('Notiz', long: true, required: true),
    ];
    final initial = {
      'Typ': 'Anruf',
      'Datum': iso(day()),
      'Kontakt': contact?.id ?? '',
    };
    final result = quick
        ? await showModalBottomSheet<Fields>(
            context: context,
            isScrollControlled: true,
            isDismissible: false,
            enableDrag: false,
            backgroundColor: Colors.transparent,
            builder: (context) => Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: _Editor(
                title: 'Schnell erfassen',
                fields: fields,
                initial: initial,
                submit: 'Speichern',
                sheet: true,
              ),
            ),
          )
        : await form('Aktivität erfassen', fields, initial: initial);
    if (result == null || !mounted) return;
    data.change(
      () => data.add(data.activities, {
        ...result,
        'Name': result['Notiz']!.split('\n').first,
        'Zuständig': data.user!.id,
      }),
    );
    toast('Aktivität gespeichert');
  }

  Widget _communication() => _fitGrid(
    [
      _actionCard(
        'Gruppen-Mail',
        'Empfänger und Outlook-Entwurf',
        Icons.forward_to_inbox_outlined,
        data.allowed('Gruppen-Mail senden') ? _groupMail : null,
      ),
      _actionCard(
        'Briefe & Vorlagen',
        'BECK-Brief und Versandvorschau',
        Icons.description_outlined,
        _letter,
      ),
      _actionCard(
        'Etiketten & Adressdruck',
        'Adressen, Etiketten und Umschläge',
        Icons.print_outlined,
        data.allowed('Adressen drucken') ? () => _addressPrint() : null,
      ),
    ],
    minWidth: 237,
    maxColumns: 3,
  );

  Future<void> _groupMail() async {
    final groups = [
      'Verkäufer',
      'Käufer',
      for (final c in data.visibleContacts) ...[
        ...c.values('Gewerke'),
        ...c.values('Funktionen'),
        ...c.values('Partnertyp'),
      ],
    ].toSet();
    final result = await form(
      'Gruppen-Mail',
      [
        _Field.select('Gruppe', _choices(groups), required: true),
        _Field.select(
          'Vorlage',
          _choices(['Marktbericht', 'Neues Objekt', 'Jahresende']),
          required: true,
        ),
        const _Field('Nachricht', long: true),
      ],
      initial: const {'Gruppe': 'Käufer', 'Vorlage': 'Marktbericht'},
      submit: 'Empfänger prüfen',
    );
    if (result == null || !mounted) return;
    final group = result['Gruppe']!;
    final recipients = data.visibleContacts
        .where(
          (c) =>
              c.flag('Newsletter') &&
              c['E-Mail'].isNotEmpty &&
              [
                'Rollen',
                'Gewerke',
                'Funktionen',
                'Partnertyp',
              ].any((key) => c.values(key).contains(group)),
        )
        .toList();
    await detail(
      'Gruppen-Mail · $group',
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Panel(
            child: _items([
              for (final c in recipients) _row(c.name, subtitle: c['E-Mail']),
            ], empty: 'Keine Empfänger mit Einwilligung'),
          ),
          if (recipients.isNotEmpty) ...[
            const SizedBox(height: 13),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                _newButton(
                  'Outlook-Vorschau',
                  () => _mail(
                    title: result['Vorlage']!,
                    bcc: recipients.map((c) => c['E-Mail']).join(', '),
                    body: result['Nachricht'],
                  ),
                  icon: Icons.mail_outline,
                ),
                if (data.allowed('Daten exportieren'))
                  OutlinedButton(
                    onPressed: () => _exportPreview(
                      'Excel-Adressliste',
                      rows: recipients.map((c) => c['E-Mail']).toList(),
                    ),
                    child: const Text('Excel-Adressliste'),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _letter() async {
    final recipients = data.visibleContacts.where(
      (c) => c
          .values('Rollen')
          .any((r) => ['Verkäufer', 'Käufer', 'Eigentümer'].contains(r)),
    );
    final result = await form(
      'Brief erstellen',
      [
        _Field.select('Vorlage', _choices(_letterTemplates), required: true),
        _Field.lookup(
          'Kontakt',
          options(recipients),
          label: 'Empfänger',
          required: true,
        ),
        const _Field('Inhalt', long: true),
      ],
      initial: {'Vorlage': _letterTemplates.first},
      submit: 'Vorschau',
    );
    if (result == null || !mounted) return;
    final contact = data.find(data.contacts, result['Kontakt']!);
    final input = result['Inhalt'] ?? '';
    final body = input.isNotEmpty
        ? input
        : 'Guten Tag\n\nGerne stehen wir für Rückfragen zur Verfügung.\n\nFreundliche Grüsse\nBECK Real Estate';
    await detail(
      'Briefvorschau',
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _paper(result['Vorlage']!, [
            Text(
              _address(contact),
              style: const TextStyle(fontSize: 13, color: muted),
            ),
            const SizedBox(height: 21),
            Text(body),
          ]),
          const SizedBox(height: 11),
          Wrap(
            spacing: 8,
            children: [
              _newButton(
                'PDF-Ausgabe simulieren',
                () => toast('PDF-Ausgabe · Demo'),
                icon: Icons.picture_as_pdf_outlined,
              ),
              OutlinedButton(
                onPressed: () => _mail(
                  contact: contact,
                  title: result['Vorlage']!,
                  body: body,
                ),
                child: const Text('Outlook-Vorschau'),
              ),
            ],
          ),
        ],
      ),
      subtitle: 'Demo',
    );
  }

  String _address(Record? contact) {
    if (contact == null) return '—';
    return [
      contact.name,
      if (contact['Personentyp'] == 'Juristische Person' &&
          contact['Kontaktperson'].isNotEmpty)
        'z. H. ${contact['Kontaktperson']}',
      contact['Strasse'],
      '${contact['PLZ']} ${contact['Ort']}'.trim(),
    ].where((line) => line.isNotEmpty).join('\n');
  }

  Future<void> _addressPrint({Record? contact}) async {
    final formats = [
      'Herma 4455',
      'Avery L7163',
      'Avery L7160',
      'Herma 4200',
      'Grossbrief',
      if (data.allowed('GL-Kontakte sehen')) ...['C4', 'C5', 'C6'],
    ];
    final result = await form(
      'Adressdruck',
      [
        if (contact == null)
          _Field.select('Gruppe', _choices(['Alle', ...roles]), required: true),
        _Field.select('Format', _choices(formats), required: true),
        const _Field('Startposition', numeric: true),
      ],
      initial: const {
        'Gruppe': 'Alle',
        'Format': 'Herma 4455',
        'Startposition': '1',
      },
      submit: 'Vorschau',
      validate: (values) {
        final position = int.tryParse(values['Startposition'] ?? '');
        return position == null || position < 1
            ? 'Startposition ab 1 eingeben.'
            : null;
      },
    );
    if (result == null || !mounted) return;
    if (['C4', 'C5', 'C6'].contains(result['Format']) && !await _unlockGl())
      return;
    if (!mounted) return;
    final recipients = contact == null
        ? data.visibleContacts
              .where(
                (c) =>
                    result['Gruppe'] == 'Alle' ||
                    c.values('Rollen').contains(result['Gruppe']),
              )
              .toList()
        : [contact];
    await detail(
      'Druckvorschau',
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _paper('${result['Format']} · ab ${result['Startposition']}', [
            _fitGrid(
              [for (final c in recipients) Text(_address(c))],
              minWidth: 155,
              maxColumns: 3,
            ),
            if (recipients.isEmpty) _empty('Keine Adressen'),
          ]),
          const SizedBox(height: 11),
          _newButton(
            'Drucken simulieren',
            () => toast('Druckausgabe · Demo'),
            icon: Icons.print_outlined,
          ),
        ],
      ),
      subtitle: 'Demo',
    );
  }

  Future<void> _mail({
    Record? contact,
    required String title,
    String? body,
    String? bcc,
    String? document,
  }) async {
    final defaultText =
        body ??
        (document == null
            ? 'Guten Tag\n\n'
            : 'Guten Tag\n\nGerne senden wir Ihnen das Exposé.\n\nFreundliche Grüsse\nBECK Real Estate');
    await form(
      'Outlook-Vorschau · Demo',
      [
        if (bcc == null) const _Field('An', required: true),
        if (bcc != null) const _Field('BCC', required: true),
        const _Field('Betreff', required: true),
        if (document != null)
          const _Field('Anhang')
        else
          const _Field('Anhang', label: 'Dokument / Anhang'),
        const _Field('Nachricht', long: true),
      ],
      initial: {
        'An': contact?['E-Mail'] ?? '',
        'BCC': bcc ?? '',
        'Betreff': title,
        'Nachricht': defaultText,
        'Anhang': document ?? '',
      },
      submit: 'Entwurf vorbereiten',
    ).then((result) {
      if (result != null) toast('Outlook-Entwurf vorbereitet · Demo');
    });
  }
}
