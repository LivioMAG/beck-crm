part of 'main.dart';

extension _RealEstate on _WorkspaceState {
  Widget _propertiesPage() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _PageTitle(
        'Liegenschaften',
        subtitle: 'Objekte, Dossiers und Verkaufsmandate',
        action: switch (propertyTab) {
          'Pipeline' => _newButton('Neues Mandat', () => _mandateForm()),
          'Objekte' => _newButton('Neue Liegenschaft', () => _propertyForm()),
          _ => null,
        },
      ),
      Align(
        alignment: Alignment.centerLeft,
        child: _tabs(
          ['Objekte', 'Matching', 'Pipeline'],
          propertyTab,
          (tab) => refreshPage(() => propertyTab = tab),
        ),
      ),
      const SizedBox(height: 14),
      switch (propertyTab) {
        'Matching' => _matching(),
        'Pipeline' => _saleBoard(),
        _ => _properties(),
      },
    ],
  );

  Widget _properties() {
    final visible = data.visibleProperties.where((p) {
      final status = data.status(p);
      final showStatus =
          propertyStatus == 'Alle' ||
          propertyStatus == status ||
          (propertyStatus == 'Aktiv' && status != 'Verkauft');
      final search = [
        p.name,
        p['Strasse'],
        p['Ort'],
        p['PLZ'],
      ].join(' ').toLowerCase();
      return showStatus && search.contains(propertyQuery.toLowerCase());
    }).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _search(
                'Liegenschaften suchen',
                propertyQuery,
                (query) => refreshPage(() => propertyQuery = query),
              ),
              const SizedBox(height: 8),
              _filters(
                [
                  'Alle',
                  'Aktiv',
                  'Neu',
                  'In Vermarktung',
                  'In Verhandlung',
                  'Verkauft',
                ],
                propertyStatus,
                (value) => refreshPage(() => propertyStatus = value),
              ),
            ],
          ),
        ),
        const SizedBox(height: 13),
        if (visible.isEmpty)
          _Panel(child: _empty('Keine passenden Liegenschaften')),
        _fitGrid(
          [for (final property in visible) _propertyCard(property)],
          minWidth: 283,
          maxColumns: 3,
        ),
      ],
    );
  }

  Widget _propertyCard(Record property) {
    final checklist = data.propertyChecklist(property);
    final done = checklist
        .where((item) => property.flag('Dossier/$item'))
        .length;
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _Avatar(
                '',
                size: 41,
                icon: property['Typ'] == 'Wohnung'
                    ? Icons.apartment_rounded
                    : Icons.home_work_outlined,
              ),
              const Spacer(),
              _Pill(
                data.status(property),
                color: data.status(property) == 'Verkauft' ? green : accent,
              ),
            ],
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => _propertyDetail(property),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${property['Typ']} · ${property['Ort']}',
                    style: const TextStyle(fontSize: 12, color: muted),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 7),
          Wrap(
            spacing: 7,
            runSpacing: 6,
            children: [
              _Pill(francs(property['Preis']), color: accent),
              if (property['Zimmer'].isNotEmpty)
                _Pill('${property['Zimmer']} Zi.'),
              if (property.flag('Neu')) const _Pill('NEU', color: green),
              if (property.flag('Off-Market'))
                const _Pill('Off-Market', color: navy),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(),
          InkWell(
            onTap: () => _propertyDetail(property, initial: 'Dossier'),
            borderRadius: BorderRadius.circular(9),
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  const Text(
                    'Dossier',
                    style: TextStyle(
                      color: muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: _progress(done, checklist.length)),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 17,
                    color: muted,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _propertyForm({Record? property, Record? contact}) async {
    final result = await form(
      property == null ? 'Neue Liegenschaft' : 'Liegenschaft bearbeiten',
      [
        const _Field('Name', label: 'Objektname', required: true),
        _Field.select('Typ', _choices(propertyTypes), required: true),
        const _Field('Strasse'),
        const _Field('PLZ'),
        const _Field('Ort', required: true),
        _Field.select('Kanton', _choices(cantons), required: true),
        const _Field('Zimmer', numeric: true),
        const _Field('Fläche', label: 'Wohnfläche in m²', numeric: true),
        const _Field('Grundstück', label: 'Grundstück in m²', numeric: true),
        const _Field('Preis', label: 'Preis in CHF', numeric: true),
        const _Field('Preis max.', numeric: true),
        _Field.lookup('Eigentümer', options(contactsWith('Eigentümer'))),
        _Field.lookup('Verkäufer', options(contactsWith('Verkäufer'))),
        staffField(),
        const _Field.check('Neu', label: 'Als neu markieren'),
        const _Field.check('Off-Market'),
        const _Field.date('Kaufdatum'),
        const _Field('Beschreibung', long: true),
      ],
      initial: {
        'Zuständig': data.user!.id,
        'Typ': 'Wohnung',
        'Neu': 'ja',
        if (contact?.values('Rollen').contains('Eigentümer') ?? false)
          'Eigentümer': contact!.id,
        if (contact?.values('Rollen').contains('Verkäufer') ?? false)
          'Verkäufer': contact!.id,
        ...?property?.fields,
      },
    );
    if (result == null || !mounted) return;
    data.change(() {
      if (property == null) {
        data.add(data.properties, result);
      } else {
        property.update(result);
      }
    });
    toast('Liegenschaft gespeichert');
  }

  Future<void> _propertyDetail(
    Record property, {
    String initial = 'Objekt',
    Record? buyer,
  }) {
    var tab = initial;
    return detail(
      property.name,
      () => StatefulBuilder(
        builder: (context, refresh) {
          final checks = data.propertyChecklist(property);
          final owner = data.find(data.contacts, property['Eigentümer']);
          final seller = data.find(data.contacts, property['Verkäufer']);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _Pill(data.status(property), color: accent),
                  if (property.flag('Neu')) const _Pill('NEU', color: green),
                  if (property.flag('Off-Market'))
                    const _Pill('Off-Market', color: navy),
                ],
              ),
              const SizedBox(height: 11),
              _tabs(
                ['Objekt', 'Dossier', 'Matching', 'Mandate'],
                tab,
                (value) => refresh(() => tab = value),
              ),
              const SizedBox(height: 13),
              if (tab == 'Objekt') ...[
                _Panel(
                  child: _facts({
                    'Adresse': [
                      property['Strasse'],
                      '${property['PLZ']} ${property['Ort']}'.trim(),
                    ].where((part) => part.isNotEmpty).join(', '),
                    'Kanton': property['Kanton'],
                    'Typ': property['Typ'],
                    'Zimmer': property['Zimmer'],
                    'Fläche': property['Fläche'].isEmpty
                        ? ''
                        : '${property['Fläche']} m²',
                    'Grundstück': property['Grundstück'].isEmpty
                        ? ''
                        : '${property['Grundstück']} m²',
                    'Preis': francs(property['Preis']),
                    'Preis max.': property['Preis max.'].isEmpty
                        ? ''
                        : francs(property['Preis max.']),
                    'Kaufdatum': property['Kaufdatum'].isEmpty
                        ? ''
                        : shortDate(property['Kaufdatum']),
                    'Zuständig': data.staffName(property['Zuständig']),
                    'Beschreibung': property['Beschreibung'],
                  }),
                ),
                const SizedBox(height: 12),
                if (owner != null || seller != null)
                  _Panel(
                    child: _items([
                      if (owner != null && data.canSeeContact(owner))
                        _row(
                          owner.name,
                          subtitle: 'Eigentümer',
                          onTap: () => _contactDetail(owner),
                        ),
                      if (seller != null && data.canSeeContact(seller))
                        _row(
                          seller.name,
                          subtitle: 'Verkäufer',
                          onTap: () => _contactDetail(seller),
                        ),
                    ]),
                  ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: [
                    _newButton(
                      'Bearbeiten',
                      () => _propertyForm(property: property),
                      icon: Icons.edit_outlined,
                    ),
                    if (buyer != null)
                      OutlinedButton(
                        onPressed: () => _expose(property, buyer),
                        child: const Text('Exposé senden'),
                      ),
                    if (data.allowed('Kontakte löschen'))
                      TextButton(
                        onPressed: () async {
                          if (!await confirm(
                                'Liegenschaft löschen?',
                                property.name,
                                action: 'Löschen',
                              ) ||
                              !context.mounted)
                            return;
                          data.change(() {
                            data.properties.remove(property);
                            for (final m in data.mandates.where(
                              (m) => m['Objekt'] == property.id,
                            )) {
                              m.fields.remove('Objekt');
                            }
                          });
                          Navigator.pop(context);
                          toast('Liegenschaft gelöscht');
                        },
                        child: const Text(
                          'Löschen',
                          style: TextStyle(color: red),
                        ),
                      ),
                  ],
                ),
              ],
              if (tab == 'Dossier')
                _Panel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _panelTitle('Dossier', icon: Icons.folder_open_outlined),
                      const SizedBox(height: 12),
                      _progress(
                        checks
                            .where((item) => property.flag('Dossier/$item'))
                            .length,
                        checks.length,
                      ),
                      const SizedBox(height: 9),
                      for (final item in checks)
                        Row(
                          children: [
                            Expanded(
                              child: CheckboxListTile(
                                contentPadding: EdgeInsets.zero,
                                dense: true,
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                title: Text(item),
                                value: property.flag('Dossier/$item'),
                                subtitle: property['Datei/$item'].isEmpty
                                    ? null
                                    : Text(property['Datei/$item']),
                                onChanged: (_) => data.change(
                                  () => property.toggle('Dossier/$item'),
                                ),
                              ),
                            ),
                            IconButton(
                              tooltip: 'Demo-Datei zuordnen · $item',
                              icon: const Icon(
                                Icons.attach_file_rounded,
                                size: 18,
                              ),
                              onPressed: () => _attach(property, item),
                            ),
                          ],
                        ),
                      if (buyer != null)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: _newButton(
                            'Exposé senden',
                            () => _expose(property, buyer),
                            icon: Icons.mail_outline,
                          ),
                        ),
                    ],
                  ),
                ),
              if (tab == 'Matching')
                _matchResults(
                  data.matches(propertyId: property.id),
                  showBuyer: true,
                ),
              if (tab == 'Mandate')
                _Panel(
                  child: Column(
                    children: [
                      _panelTitle(
                        'Mandate',
                        action: TextButton(
                          onPressed: () =>
                              _mandateForm(property: property, contact: seller),
                          child: const Text('Mandat erfassen'),
                        ),
                      ),
                      _items([
                        for (final record in data.visibleMandates.where(
                          (m) => m['Objekt'] == property.id,
                        ))
                          _row(
                            record.name,
                            subtitle: record['Phase'],
                            onTap: () => _mandateDetail(record),
                          ),
                      ]),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
      subtitle: '${property['Typ']} · ${property['Ort']}',
    );
  }

  Future<void> _attach(Record property, String item) async {
    final result = await form(
      'Demo-Datei zuordnen',
      [const _Field('Dateiname', required: true)],
      initial: {
        'Dateiname': property['Datei/$item'].isEmpty
            ? '$item.pdf'
            : property['Datei/$item'],
      },
      submit: 'Zuordnen',
    );
    if (result == null || !mounted) return;
    data.change(
      () => property.update({
        'Datei/$item': result['Dateiname']!,
        'Dossier/$item': 'ja',
      }),
    );
    toast('Datei zugeordnet · Demo');
  }

  Widget _saleBoard() => _Board(
    columns: {
      for (final phase in salePhases)
        phase: [
          for (final record in data.visibleMandates.where(
            (m) => m['Phase'] == phase,
          ))
            _boardCard(
              record.name,
              data.contactName(record['Kontakt']),
              '${data.find(data.properties, record['Objekt'])?.name ?? 'Objekt offen'}\n${data.staffName(record['Zuständig'])}',
              () => _mandateDetail(record),
            ),
        ],
    },
  );

  Future<void> _mandateForm({
    Record? contact,
    Record? property,
    Record? mandate,
  }) async {
    final result = await form(
      mandate == null ? 'Neues Mandat' : 'Mandat bearbeiten',
      [
        const _Field('Name', label: 'Mandatsname', required: true),
        _Field.lookup(
          'Kontakt',
          options(contactsWith('Verkäufer')),
          label: 'Verkäufer',
          required: true,
        ),
        _Field.lookup(
          'Objekt',
          options(data.visibleProperties),
          label: 'Liegenschaft',
        ),
        staffField(),
        _Field.select(
          'Phase',
          _choices([
            ...salePhases,
            if (mandate?['Phase'] == 'Abgeschlossen') 'Abgeschlossen',
          ]),
          required: true,
        ),
      ],
      initial: {
        'Name': property?.name ?? '',
        'Zuständig': data.user!.id,
        'Kontakt': contact?.id ?? '',
        'Objekt': property?.id ?? '',
        'Phase': salePhases.first,
        ...?mandate?.fields,
      },
    );
    if (result == null || !mounted) return;
    data.change(() {
      final record = mandate ?? data.add(data.mandates, result);
      if (mandate != null) record.update(result);
      data.find(data.properties, record['Objekt'])?.update({
        'Massgebendes Mandat': record.id,
      });
    });
    toast('Mandat gespeichert');
  }

  Future<void> _mandateDetail(Record mandate) => detail(mandate.name, () {
    final property = data.find(data.properties, mandate['Objekt']);
    final contact = data.find(data.contacts, mandate['Kontakt']);
    final completed = mandate['Phase'] == 'Abgeschlossen';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _facts({
                'Verkäufer': data.contactName(mandate['Kontakt']),
                'Zuständig': data.staffName(mandate['Zuständig']),
                'Objekt': property?.name ?? '—',
                if (completed) 'Phase': 'Abgeschlossen',
              }),
              if (!completed) ...[
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  key: ValueKey(mandate['Phase']),
                  initialValue: mandate['Phase'],
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Verkaufsphase'),
                  items: [
                    for (final phase in salePhases)
                      DropdownMenuItem(value: phase, child: Text(phase)),
                  ],
                  onChanged: (phase) {
                    if (phase == null) return;
                    data.change(() {
                      mandate.update({'Phase': phase});
                      property?.update({'Massgebendes Mandat': mandate.id});
                    });
                    toast('Verkaufsphase aktualisiert');
                  },
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 13),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: [
            _newButton(
              'Bearbeiten',
              () => _mandateForm(mandate: mandate),
              icon: Icons.edit_outlined,
            ),
            if (property != null && data.visibleProperties.contains(property))
              OutlinedButton(
                onPressed: () => _propertyDetail(property),
                child: const Text('Liegenschaft öffnen'),
              ),
            if (contact != null && data.canSeeContact(contact))
              OutlinedButton(
                onPressed: () => _contactDetail(contact),
                child: const Text('Kontakt öffnen'),
              ),
            if (!completed &&
                property != null &&
                data.visibleProperties.contains(property))
              OutlinedButton(
                onPressed: () => _completeSale(mandate, property),
                child: const Text('Verkauf abschliessen'),
              ),
          ],
        ),
      ],
    );
  });

  Future<void> _completeSale(Record mandate, Record property) async {
    final result = await form(
      'Verkauf abschliessen',
      [const _Field.date('Kaufdatum', required: true)],
      initial: {'Kaufdatum': iso(day())},
      submit: 'Abschliessen',
    );
    if (result == null || !mounted) return;
    data.change(() {
      mandate.update({'Phase': 'Abgeschlossen'});
      property.update({
        'Kaufdatum': result['Kaufdatum']!,
        'Massgebendes Mandat': mandate.id,
      });
    });
    toast('Verkauf abgeschlossen');
  }

  void _openMatching() {
    go(Section.properties, tab: 'Matching');
    refreshPage(() => matchSelection = '');
  }

  Widget _matching() {
    final choices = options(
      matchByBuyer ? contactsWith('Käufer') : data.visibleProperties,
    );
    final current = choices.containsKey(matchSelection) ? matchSelection : '';
    final matches = data.matches(
      buyerId: matchByBuyer && current.isNotEmpty ? current : null,
      propertyId: !matchByBuyer && current.isNotEmpty ? current : null,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Panel(
          child: Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _tabs(
                ['Nach Käufer', 'Nach Objekt'],
                matchByBuyer ? 'Nach Käufer' : 'Nach Objekt',
                (mode) => refreshPage(() {
                  matchByBuyer = mode == 'Nach Käufer';
                  matchSelection = '';
                }),
              ),
              SizedBox(
                width: 263,
                child: DropdownButtonFormField<String>(
                  key: ValueKey((matchByBuyer, current)),
                  initialValue: current,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: matchByBuyer ? 'Käufer' : 'Liegenschaft',
                  ),
                  items: [
                    const DropdownMenuItem(value: '', child: Text('Alle')),
                    for (final item in choices.entries)
                      DropdownMenuItem(
                        value: item.key,
                        child: Text(
                          item.value,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: (id) =>
                      refreshPage(() => matchSelection = id ?? ''),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 13),
        if (matches.any(
          (match) => match.property.flag('Neu') && match.score >= 70,
        ))
          const Padding(
            padding: EdgeInsets.only(bottom: 11),
            child: Align(
              alignment: Alignment.centerLeft,
              child: _Pill(
                'Neue Objekte mit Matching-Potenzial',
                color: green,
                icon: Icons.notifications_none_rounded,
              ),
            ),
          ),
        _matchResults(matches, showBuyer: !matchByBuyer),
      ],
    );
  }

  Widget _matchResults(List<Match> matches, {required bool showBuyer}) {
    if (matches.isEmpty) return _Panel(child: _empty('Keine Treffer'));
    return _fitGrid(
      [
        for (final match in matches)
          _Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _panelTitle(
                  showBuyer ? match.buyer.name : match.property.name,
                  action: _Pill(
                    '${match.score} %',
                    color: match.score >= 70
                        ? green
                        : match.score >= 40
                        ? amber
                        : red,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  showBuyer ? match.property.name : match.buyer.name,
                  style: const TextStyle(color: muted, fontSize: 13),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 5,
                  runSpacing: 5,
                  children: [
                    for (final reason in match.reasons)
                      _Pill(
                        reason,
                        color: reason == 'Über Budget' ? red : muted,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 3,
                  runSpacing: 2,
                  children: [
                    TextButton(
                      onPressed: () =>
                          _propertyDetail(match.property, buyer: match.buyer),
                      child: const Text('Objekt öffnen'),
                    ),
                    if (match.property.flag('Dossier/Exposé'))
                      TextButton(
                        onPressed: () => _expose(match.property, match.buyer),
                        child: const Text('Exposé senden'),
                      ),
                    if (showBuyer)
                      TextButton(
                        onPressed: () => _contactDetail(match.buyer),
                        child: const Text('Kontakt öffnen'),
                      ),
                  ],
                ),
              ],
            ),
          ),
      ],
      minWidth: 271,
      maxColumns: 3,
    );
  }

  Future<void> _expose(Record property, Record buyer) async {
    if (!property.flag('Dossier/Exposé')) {
      toast('Im Dossier fehlt ein Exposé');
      return;
    }
    final document = property['Datei/Exposé'].isEmpty
        ? 'Exposé · ${property.name}.pdf'
        : property['Datei/Exposé'];
    await detail(
      'Exposé · ${property.name}',
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _paper(property.name, [
            Text(
              '${property['Strasse']}, ${property['PLZ']} ${property['Ort']}',
            ),
            const SizedBox(height: 12),
            _facts({
              'Preis': francs(property['Preis']),
              'Zimmer': property['Zimmer'],
              'Wohnfläche': property['Fläche'].isEmpty
                  ? ''
                  : '${property['Fläche']} m²',
            }),
            const SizedBox(height: 12),
            Text(property['Beschreibung']),
          ]),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _newButton(
                'Outlook-Vorschau',
                () => _mail(
                  contact: buyer,
                  title: 'Exposé · ${property.name}',
                  document: document,
                ),
                icon: Icons.mail_outline,
              ),
              OutlinedButton(
                onPressed: () => _taskForm(
                  contact: buyer,
                  title: 'Zu ${property.name} nachfassen',
                ),
                child: const Text('Aufgabe zum Nachfassen'),
              ),
            ],
          ),
        ],
      ),
      subtitle: '$document · ${buyer.name}',
    );
  }

  Widget _architecturePage() {
    final projects = data.visibleProjects.toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PageTitle(
          'Architektur',
          subtitle: 'Projekte und Phasen',
          action: _newButton('Neues Projekt', () => _projectForm()),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: _tabs(
            ['Phasenboard', 'Projektliste'],
            architectureTab,
            (tab) => refreshPage(() => architectureTab = tab),
          ),
        ),
        const SizedBox(height: 14),
        if (architectureTab == 'Phasenboard')
          _Board(
            columns: {
              for (final phase in projectChecks.keys)
                phase: [
                  for (final project in projects.where(
                    (p) => p['Phase'] == phase,
                  ))
                    _boardCard(
                      project.name,
                      project['Typ'],
                      data.contactName(project['Eigentümer']),
                      () => _projectDetail(project),
                      footer: _projectProgress(project, phase),
                    ),
                ],
            },
          )
        else
          _Panel(
            child: _items([
              for (final project in projects)
                _row(
                  project.name,
                  subtitle:
                      '${project['Typ']} · ${data.contactName(project['Eigentümer'])}',
                  leading: const _Avatar('', icon: Icons.architecture_rounded),
                  trailing: _Pill(project['Phase'], color: accent),
                  onTap: () => _projectDetail(project),
                ),
            ], empty: 'Keine Projekte'),
          ),
      ],
    );
  }

  Widget _projectProgress(Record project, String phase) {
    final items = projectChecks[phase] ?? [];
    return _progress(
      items.where((item) => project.flag('$phase/$item')).length,
      items.length,
    );
  }

  Future<void> _projectForm({Record? owner, Record? project}) async {
    final result = await form(
      project == null ? 'Neues Projekt' : 'Projekt bearbeiten',
      [
        const _Field('Name', label: 'Projektname', required: true),
        _Field.select('Typ', _choices(projectTypes), required: true),
        _Field.lookup(
          'Eigentümer',
          options(contactsWith('Eigentümer')),
          required: true,
        ),
        staffField(),
        const _Field('Budget', label: 'Budget in CHF', numeric: true),
        const _Field('GEAK', label: 'GEAK-Stand / Ziel'),
        _Field.select('Phase', _choices(projectChecks.keys), required: true),
      ],
      initial: {
        'Eigentümer': owner?.id ?? '',
        'Zuständig': data.user!.id,
        'Typ': projectTypes.first,
        'Phase': projectChecks.keys.first,
        ...?project?.fields,
      },
    );
    if (result == null || !mounted) return;
    data.change(() {
      if (project == null) {
        data.add(data.projects, result);
      } else {
        project.update(result);
      }
    });
    toast('Projekt gespeichert');
  }

  Future<void> _projectDetail(Record project) {
    var selected = project['Phase'];
    return detail(
      project.name,
      () => StatefulBuilder(
        builder: (context, refresh) {
          final owner = data.find(data.contacts, project['Eigentümer']);
          final checks = projectChecks[selected] ?? [];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Panel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _facts({
                      'Projekttyp': project['Typ'],
                      'Eigentümer': data.contactName(project['Eigentümer']),
                      'Budget': francs(project['Budget']),
                      'GEAK': project['GEAK'],
                      'Zuständig': data.staffName(project['Zuständig']),
                    }),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      key: ValueKey(project['Phase']),
                      initialValue: project['Phase'],
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Aktuelle Phase',
                      ),
                      items: [
                        for (final phase in projectChecks.keys)
                          DropdownMenuItem(value: phase, child: Text(phase)),
                      ],
                      onChanged: (phase) {
                        if (phase == null) return;
                        data.change(() => project.update({'Phase': phase}));
                        refresh(() => selected = phase);
                        toast('Projektphase aktualisiert');
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _Panel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _panelTitle(
                      'Phasen-Checkliste',
                      action: selected == project['Phase']
                          ? const _Pill('Aktuell', color: accent)
                          : null,
                    ),
                    const SizedBox(height: 9),
                    _tabs(
                      projectChecks.keys.toList(),
                      selected,
                      (phase) => refresh(() => selected = phase),
                    ),
                    const SizedBox(height: 11),
                    _projectProgress(project, selected),
                    for (final item in checks)
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        dense: true,
                        title: Text(item),
                        value: project.flag('$selected/$item'),
                        onChanged: (_) => data.change(
                          () => project.toggle('$selected/$item'),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  _newButton(
                    'Checkliste drucken',
                    () => _projectPrint(project, selected),
                    icon: Icons.print_outlined,
                  ),
                  OutlinedButton(
                    onPressed: () => _projectForm(project: project),
                    child: const Text('Bearbeiten'),
                  ),
                  if (owner != null && data.canSeeContact(owner))
                    OutlinedButton(
                      onPressed: () => _contactDetail(owner),
                      child: const Text('Eigentümer öffnen'),
                    ),
                  if (data.allowed('Kontakte löschen'))
                    TextButton(
                      onPressed: () async {
                        if (!await confirm(
                              'Projekt löschen?',
                              project.name,
                              action: 'Löschen',
                            ) ||
                            !context.mounted)
                          return;
                        data.change(() => data.projects.remove(project));
                        Navigator.pop(context);
                        toast('Projekt gelöscht');
                      },
                      child: const Text(
                        'Löschen',
                        style: TextStyle(color: red),
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _projectPrint(Record project, String phase) => detail(
    'PDF-Vorschau',
    () => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _paper(project.name, [
          Text(
            'Checkliste · $phase',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          for (final item in projectChecks[phase] ?? <String>[])
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Text('${project.flag('$phase/$item') ? '✓' : '○'}  $item'),
            ),
        ]),
        const SizedBox(height: 11),
        _newButton(
          'PDF-Ausgabe simulieren',
          () => toast('PDF-Ausgabe · Demo'),
          icon: Icons.picture_as_pdf_outlined,
        ),
      ],
    ),
    subtitle: 'Demo',
  );
}

Widget _boardCard(
  String title,
  String subtitle,
  String summary,
  VoidCallback open, {
  Widget? footer,
}) => Semantics(
  button: true,
  excludeSemantics: true,
  label: '$title, $subtitle, $summary',
  onTap: open,
  child: Material(
    borderRadius: BorderRadius.circular(12),
    color: Colors.white,
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: open,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 12, color: accent)),
            const SizedBox(height: 5),
            Text(summary, style: const TextStyle(fontSize: 11, color: muted)),
            if (footer != null) ...[const SizedBox(height: 9), footer],
          ],
        ),
      ),
    ),
  ),
);
