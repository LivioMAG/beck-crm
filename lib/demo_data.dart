import 'package:flutter/foundation.dart';

const roles = [
  'Verkäufer',
  'Käufer',
  'Eigentümer',
  'Handwerker',
  'Netzwerk',
  'Netzwerkpartner',
  'GL-Kontakt',
];
const personTypes = [
  'Einzelperson',
  'Ehepaar / Partner',
  'Familie',
  'Juristische Person',
];
const cantons = [
  'AG',
  'AI',
  'AR',
  'BE',
  'BL',
  'BS',
  'FR',
  'GE',
  'GL',
  'GR',
  'JU',
  'LU',
  'NE',
  'NW',
  'OW',
  'SG',
  'SH',
  'SO',
  'SZ',
  'TG',
  'TI',
  'UR',
  'VD',
  'VS',
  'ZG',
  'ZH',
];
const origins = [
  'Empfehlung',
  'Website',
  'Inserat',
  'Messe',
  'Netzwerk',
  'Direktkontakt',
  'Social Media',
  'Off-Market',
  'Sonstiges',
];
const propertyTypes = [
  'Einfamilienhaus',
  'Wohnung',
  'Mehrfamilienhaus',
  'Bauland',
  'Gewerbe',
];
const projectTypes = [
  'Sanierung',
  'Umbau',
  'Neubau',
  'Erweiterung / Aufstockung',
  'Machbarkeitsstudie',
  'Energetische Sanierung',
];
const salePhases = [
  'Erstkontakt',
  'Bewertung',
  'Mandat',
  'In Vermarktung',
  'In Verhandlung',
];
const projectChecks = <String, List<String>>{
  'Anfrage': [
    'Erstgespräch',
    'Bestandsaufnahme',
    'Zonenplan',
    'Grobkostenschätzung ±25 %',
  ],
  'Machbarkeit': [
    'GEAK',
    'Grauenergie',
    'Varianten',
    'Wirtschaftlichkeit',
    'Honorarofferte SIA 102',
  ],
  'Vorprojekt': [
    'Pläne 1:200',
    'Minergie / MuKEn',
    'Fassadenkonzept',
    'Kostenschätzung ±15 % BKP',
  ],
  'Bauprojekt': [
    'Pläne 1:100',
    'Statik',
    'Brandschutz',
    'Schallschutz',
    'Kostenvoranschlag ±10 %',
  ],
  'Bewilligung': [
    'Baugesuch',
    'Nachbarzustimmung',
    'Einsprachen',
    'Baubewilligung',
  ],
  'Ausschreibung': [
    'NPK-Unterlagen',
    'Offertspiegel',
    'Werkverträge',
    'Versicherungen',
    'Baukredit',
  ],
  'Ausführung': [
    'Baubeginn-Anzeige',
    'Rohbau-Kontrollen',
    'Bausitzungen',
    'Kostenstand',
    'Mängelprotokoll',
  ],
  'Abnahme': [
    'Vorabnahme',
    'Schlussrechnung',
    'Garantiescheine',
    'GEAK-Zertifikat',
    'Übergabe',
  ],
  'Abgeschlossen': [
    'Honorar-Schlussrechnung',
    'Archivierung',
    'Garantiefristen',
    'Kundenzufriedenheit',
  ],
};
const dossierChecks = [
  'Grundbuchauszug',
  'Katasterplan',
  'Gebäudeversicherungsnachweis',
  'Energieausweis (GEAK)',
  'Grundrisspläne',
  'Fotos (Innen / Aussen)',
  'Exposé',
  'Schuldbrief-Auskunft',
  'Mietzinsübersicht',
  'Nebenkosten-Abrechnung',
];
const activityTypes = ['Anruf', 'E-Mail', 'Besichtigung', 'Notiz'];
const permissions = [
  'GL-Kontakte sehen',
  'Daten exportieren',
  'Berechtigungen verwalten',
  'Adressen drucken',
  'Kontakte löschen',
  'Gruppen-Mail senden',
];

typedef Fields = Map<String, String>;

class Record {
  Record(this.id, this.fields);
  final String id;
  final Fields fields;
  String operator [](String key) => fields[key] ?? '';
  bool flag(String key) => this[key] == 'ja';
  void update(Fields values) => fields.addAll(values);
  void toggle(String key) => fields[key] = flag(key) ? '' : 'ja';
  List<String> values(String key) => this[key]
      .split(',')
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty)
      .toList();
  String get name => this['Name'];
}

class Match {
  const Match(this.buyer, this.property, this.score, this.reasons);
  final Record buyer;
  final Record property;
  final int score;
  final List<String> reasons;
}

class DemoData extends ChangeNotifier {
  DemoData() {
    reset();
  }

  final contacts = <Record>[];
  final properties = <Record>[];
  final mandates = <Record>[];
  final projects = <Record>[];
  final tasks = <Record>[];
  final activities = <Record>[];
  final reminders = <Record>[];
  final accounts = <Record>[];
  final company = <String, String>{};
  final completedReminders = <String>{};
  var glPassword = 'beck';
  var _id = 0;
  var _user = '';
  bool glOpen = false;

  Record? find(List<Record> records, String id) {
    for (final record in records) {
      if (record.id == id) return record;
    }
    return null;
  }

  Record? get user => find(accounts, _user);
  bool get admin => user?['Rolle'] == 'Admin';
  bool allowed(String permission) => user?.flag(permission) ?? false;
  bool owns(Record record) => admin || record['Zuständig'] == _user;
  bool canSeeContact(Record record) =>
      owns(record) &&
      (!record.values('Rollen').contains('GL-Kontakt') ||
          (glOpen && allowed('GL-Kontakte sehen')));
  bool canSeeLinked(Record record) {
    final contact = find(contacts, record['Kontakt']);
    return owns(record) && (contact == null || canSeeContact(contact));
  }

  Iterable<Record> get visibleContacts => contacts.where(canSeeContact);
  Iterable<Record> get visibleTasks => tasks.where(canSeeLinked);
  Iterable<Record> get visibleActivities => activities.where(canSeeLinked);
  Iterable<Record> get visibleMandates => mandates.where(canSeeLinked);
  Iterable<Record> get visibleProperties => properties.where(
    (record) =>
        owns(record) &&
        ['Eigentümer', 'Verkäufer'].every((key) {
          final linked = find(contacts, record[key]);
          return linked == null || canSeeContact(linked);
        }),
  );
  Iterable<Record> get visibleProjects => projects.where((record) {
    final linked = find(contacts, record['Eigentümer']);
    return owns(record) && (linked == null || canSeeContact(linked));
  });

  String contactName(String id) => find(contacts, id)?.name ?? '—';
  String staffName(String id) => find(accounts, id)?.name ?? '—';

  bool login(String id, String password) {
    final account = find(accounts, id);
    if (account == null ||
        account.flag('Deaktiviert') ||
        account['Passwort'] != password)
      return false;
    _user = id;
    glOpen = false;
    notifyListeners();
    return true;
  }

  void logout() {
    _user = '';
    glOpen = false;
    notifyListeners();
  }

  void change(VoidCallback action) {
    action();
    notifyListeners();
  }

  Record add(List<Record> records, Fields values, {String? id}) {
    final record = Record(id ?? 'demo-${_id++}', values);
    records.add(record);
    return record;
  }

  Record? mandateFor(Record property) {
    final linked = mandates
        .where((record) => record['Objekt'] == property.id)
        .toList();
    if (linked.isEmpty) return null;
    final selected = find(linked, property['Massgebendes Mandat']);
    if (selected != null) return selected;
    return linked
            .where((record) => record['Phase'] != 'Abgeschlossen')
            .lastOrNull ??
        linked.last;
  }

  String status(Record property) => switch (mandateFor(property)?['Phase']) {
    'In Vermarktung' => 'In Vermarktung',
    'In Verhandlung' => 'In Verhandlung',
    'Abgeschlossen' => 'Verkauft',
    _ => 'Neu',
  };

  List<String> propertyChecklist(Record property) => dossierChecks
      .where(
        (item) =>
            item != 'Mietzinsübersicht' ||
            property['Typ'] == 'Mehrfamilienhaus',
      )
      .toList();

  List<Match> matches({String? buyerId, String? propertyId}) {
    final results = <Match>[];
    for (final buyer in visibleContacts.where(
      (c) =>
          c.values('Rollen').contains('Käufer') &&
          (buyerId == null || c.id == buyerId),
    )) {
      for (final property in visibleProperties.where(
        (p) =>
            status(p) != 'Verkauft' &&
            (propertyId == null || p.id == propertyId),
      )) {
        final price = number(property['Preis']);
        final budget = number(buyer['Budget bis']);
        final lower = number(buyer['Budget von']);
        final priceFits =
            price > 0 && budget > 0 && price <= budget && price >= lower;
        final cantonFits = buyer
            .values('Suchkantone')
            .contains(property['Kanton']);
        final areaFits =
            buyer.values('Such-PLZ').contains(property['PLZ']) ||
            (buyer['Region'].isNotEmpty &&
                buyer['Region'].toLowerCase() == property['Ort'].toLowerCase());
        final roomsFit =
            number(buyer['Zimmer ab']) > 0 &&
            number(property['Zimmer']) >= number(buyer['Zimmer ab']);
        final newProperty = property.flag('Neu');
        final raw =
            (priceFits ? 35 : 0) +
            (cantonFits ? 20 : 0) +
            (areaFits ? 20 : 0) +
            (roomsFit ? 15 : 0) +
            (newProperty ? 5 : 0);
        results.add(
          Match(buyer, property, (raw / 95 * 100).round(), [
            if (priceFits)
              'Preis passt'
            else if (budget > 0 && price > budget)
              'Über Budget',
            if (cantonFits) 'Kt. ${property['Kanton']}',
            if (areaFits) 'Region passt',
            if (roomsFit) 'Zimmer passen',
            if (buyer['Suchobjekt'].isNotEmpty &&
                buyer['Suchobjekt'] != property['Typ'])
              'Anderer Objekttyp',
            if (newProperty) 'Neu',
          ]),
        );
      }
    }
    return results..sort((a, b) => b.score.compareTo(a.score));
  }

  List<Record> upcomingReminders() {
    Record yearly(
      String id,
      String title,
      String value,
      String contact,
      String staff,
      String kind,
    ) => Record(id, {
      'Name': title,
      'Datum': iso(nextAnniversary(parseDate(value))),
      'Kontakt': contact,
      'Zuständig': staff,
      'Typ': kind,
    });
    return [
      for (final r in reminders.where(canSeeLinked))
        if (r['Typ'] == 'Jährlich')
          yearly(
            r.id,
            r.name,
            r['Datum'],
            r['Kontakt'],
            r['Zuständig'],
            r['Typ'],
          )
        else if (!completedReminders.contains(r.id))
          r,
      for (final c in visibleContacts.where(
        (c) => parseDate(c['Geburtstag']) != null,
      ))
        yearly(
          'birthday-${c.id}',
          'Geburtstag · ${c.name}',
          c['Geburtstag'],
          c.id,
          c['Zuständig'],
          'Geburtstag',
        ),
      for (final c in visibleContacts.where(
        (c) =>
            parseDate(c['Erinnerung am']) != null &&
            (c.flag('Erinnerung jährlich') ||
                !completedReminders.contains(
                  'contact-${c.id}-${c['Erinnerung am']}',
                )),
      ))
        if (c.flag('Erinnerung jährlich'))
          yearly(
            'contact-${c.id}-${c['Erinnerung am']}',
            c['Erinnerungsnotiz'].isEmpty ? c.name : c['Erinnerungsnotiz'],
            c['Erinnerung am'],
            c.id,
            c['Zuständig'],
            'Jährlich',
          )
        else
          Record('contact-${c.id}-${c['Erinnerung am']}', {
            'Name': c['Erinnerungsnotiz'].isEmpty
                ? c.name
                : c['Erinnerungsnotiz'],
            'Datum': c['Erinnerung am'],
            'Kontakt': c.id,
            'Zuständig': c['Zuständig'],
            'Typ': 'Einmalig',
          }),
      for (final p in visibleProperties.where(
        (p) => parseDate(p['Kaufdatum']) != null,
      ))
        yearly(
          'purchase-${p.id}',
          'Kaufjahrestag · ${p.name}',
          p['Kaufdatum'],
          p['Eigentümer'],
          p['Zuständig'],
          'Jährlich',
        ),
    ]..sort((a, b) => a['Datum'].compareTo(b['Datum']));
  }

  void deleteContact(Record record) {
    contacts.remove(record);
    for (final entry in [...properties, ...projects]) {
      for (final key in ['Eigentümer', 'Verkäufer']) {
        if (entry[key] == record.id) entry.fields.remove(key);
      }
    }
    mandates.removeWhere((entry) => entry['Kontakt'] == record.id);
    for (final entry in [...tasks, ...activities, ...reminders]) {
      if (entry['Kontakt'] == record.id) entry.fields.remove('Kontakt');
    }
  }

  Map<String, List<Record>> get collections => {
    'Kontakte': contacts,
    'Liegenschaften': properties,
    'Mandate': mandates,
    'Projekte': projects,
    'Aufgaben': tasks,
    'Aktivitäten': activities,
    'Erinnerungen': reminders,
  };

  Map<String, Object> snapshot() => {
    'records': {
      for (final entry in collections.entries)
        entry.key: [
          for (final record in entry.value)
            (record.id, Fields.of(record.fields)),
        ],
    },
    'company': Fields.of(company),
    'completedReminders': {...completedReminders},
    'counter': _id,
  };

  void restore(Map<String, Object> snapshot) {
    final stored = snapshot['records'] as Map<String, List<(String, Fields)>>;
    for (final entry in collections.entries) {
      entry.value
        ..clear()
        ..addAll(
          stored[entry.key]!.map(
            (record) => Record(record.$1, Fields.of(record.$2)),
          ),
        );
    }
    company
      ..clear()
      ..addAll(snapshot['company']! as Fields);
    completedReminders
      ..clear()
      ..addAll(snapshot['completedReminders']! as Set<String>);
    final counter = snapshot['counter']! as int;
    if (counter > _id) _id = counter;
  }

  void reset() {
    final previousUser = _user;
    for (final records in [
      contacts,
      properties,
      mandates,
      projects,
      tasks,
      activities,
      reminders,
      accounts,
    ]) {
      records.clear();
    }
    completedReminders.clear();
    _id = 0;
    glOpen = false;
    glPassword = 'beck';
    company
      ..clear()
      ..addAll({
        'Firma': 'Beck Real Estate',
        'Adresse': 'Hirschengraben 12, 6003 Luzern',
        'Telefon': '+41 41 000 00 00',
        'E-Mail': 'team@beck.example',
      });
    add(accounts, {
      'Name': 'Livio Beck',
      'Rolle': 'Admin',
      'Passwort': 'beck',
      for (final permission in permissions) permission: 'ja',
    }, id: 'livio');
    add(accounts, {
      'Name': 'Mara Keller',
      'Rolle': 'Manager',
      'Passwort': 'beck',
      'Adressen drucken': 'ja',
      'Gruppen-Mail senden': 'ja',
    }, id: 'mara');
    add(accounts, {
      'Name': 'Noah Frei',
      'Rolle': 'Mitarbeiter',
      'Passwort': 'beck',
    }, id: 'noah');
    _user = find(accounts, previousUser)?.id ?? 'livio';

    add(contacts, {
      'Name': 'Anna Meier',
      'Rollen': 'Käufer',
      'Personentyp': 'Einzelperson',
      'E-Mail': 'anna.meier@example.ch',
      'Ort': 'Luzern',
      'PLZ': '6003',
      'Kanton': 'LU',
      'Zuständig': 'livio',
      'Herkunft': 'Empfehlung',
      'Budget von': '700000',
      'Budget bis': '1150000',
      'Suchobjekt': 'Wohnung',
      'Zimmer ab': '3.5',
      'Region': 'Luzern',
      'Such-PLZ': '6003, 6005',
      'Suchkantone': 'LU, NW',
      'Newsletter': 'ja',
      'Notiz': 'Sucht eine helle Wohnung mit Balkon und guter ÖV-Anbindung.',
    }, id: 'anna');
    add(contacts, {
      'Name': 'Jonas Schmid',
      'Rollen': 'Verkäufer, Eigentümer',
      'Personentyp': 'Einzelperson',
      'E-Mail': 'jonas.schmid@example.ch',
      'Strasse': 'Lindenweg 8',
      'PLZ': '6003',
      'Ort': 'Luzern',
      'Kanton': 'LU',
      'Zuständig': 'livio',
      'Herkunft': 'Direktkontakt',
      'Newsletter': 'ja',
      'Geburtstag': iso(day(8).copyWith(year: 1978)),
      'Portfolio': 'Wohnung und Wohnhaus',
    }, id: 'jonas');
    add(contacts, {
      'Name': 'Clara Baumann',
      'Rollen': 'Verkäufer, Eigentümer',
      'Personentyp': 'Einzelperson',
      'E-Mail': 'clara.baumann@example.ch',
      'Ort': 'Horw',
      'PLZ': '6048',
      'Kanton': 'LU',
      'Zuständig': 'livio',
      'Herkunft': 'Website',
      'Strategie': 'Bestand energetisch erneuern',
    }, id: 'clara');
    add(contacts, {
      'Name': 'Luca und Nora Weber',
      'Rollen': 'Käufer',
      'Personentyp': 'Ehepaar / Partner',
      'E-Mail': 'weber@example.ch',
      'Ort': 'Stans',
      'Kanton': 'NW',
      'Zuständig': 'mara',
      'Herkunft': 'Inserat',
      'Budget bis': '1650000',
      'Zimmer ab': '4.5',
      'Suchkantone': 'LU, NW',
      'Suchobjekt': 'Einfamilienhaus',
      'Such-PLZ': '6370',
      'Newsletter': 'ja',
    }, id: 'weber');
    add(contacts, {
      'Name': 'Vera Roth',
      'Rollen': 'Verkäufer',
      'E-Mail': 'vera.roth@example.ch',
      'Ort': 'Kriens',
      'Kanton': 'LU',
      'Zuständig': 'noah',
      'Herkunft': 'Netzwerk',
    }, id: 'vera');
    add(contacts, {
      'Name': 'Miriam Huber',
      'Rollen': 'Käufer',
      'Ort': 'Zug',
      'Kanton': 'ZG',
      'E-Mail': 'miriam@example.ch',
      'Zuständig': 'livio',
      'Herkunft': 'Website',
      'Budget bis': '1450000',
      'Zimmer ab': '4',
      'Suchkantone': 'ZG, LU',
      'Suchobjekt': 'Wohnung',
    }, id: 'miriam');
    add(contacts, {
      'Name': 'Werkraum Holz GmbH',
      'Rollen': 'Handwerker',
      'Personentyp': 'Juristische Person',
      'Gewerke': 'Schreinerei, Innenausbau',
      'Hauptgewerk': 'Schreinerei',
      'Zuständig': 'livio',
      'E-Mail': 'holz@example.ch',
      'Ort': 'Emmen',
      'Newsletter': 'ja',
    }, id: 'holz');
    add(contacts, {
      'Name': 'Nina Wyss',
      'Rollen': 'Netzwerk',
      'Funktionen': 'Fotografie',
      'Zuständig': 'livio',
      'E-Mail': 'nina@example.ch',
      'Ort': 'Luzern',
    }, id: 'nina');
    add(contacts, {
      'Name': 'Atelier Nord AG',
      'Rollen': 'Netzwerkpartner',
      'Partnertyp': 'Planung',
      'Zuständig': 'livio',
      'E-Mail': 'atelier@example.ch',
      'Ort': 'Zug',
    }, id: 'nord');
    add(contacts, {
      'Name': 'GL Beispielkontakt',
      'Rollen': 'GL-Kontakt',
      'Zuständig': 'livio',
      'GL-Budget': '3500000',
      'E-Mail': 'gl@example.ch',
    }, id: 'gl');

    add(properties, {
      'Name': 'Wohnung am Lindenweg',
      'Strasse': 'Lindenweg 8',
      'PLZ': '6003',
      'Ort': 'Luzern',
      'Kanton': 'LU',
      'Typ': 'Wohnung',
      'Zimmer': '4.5',
      'Fläche': '112',
      'Preis': '980000',
      'Eigentümer': 'jonas',
      'Verkäufer': 'jonas',
      'Zuständig': 'livio',
      'Neu': 'ja',
      'Beschreibung':
          'Helle Wohnung mit Loggia in einem ruhigen Luzerner Quartier.',
      for (final item in dossierChecks.take(7)) 'Dossier/$item': 'ja',
    }, id: 'linden');
    add(properties, {
      'Name': 'Haus am Sonnenhang',
      'Strasse': 'Sonnenrain 4',
      'PLZ': '6370',
      'Ort': 'Stans',
      'Kanton': 'NW',
      'Typ': 'Einfamilienhaus',
      'Zimmer': '5.5',
      'Fläche': '168',
      'Grundstück': '560',
      'Preis': '1480000',
      'Eigentümer': 'clara',
      'Zuständig': 'livio',
      'Off-Market': 'ja',
      'Dossier/Grundbuchauszug': 'ja',
    }, id: 'sonne');
    add(properties, {
      'Name': 'Stadtwohnung im Pilatusquartier',
      'Strasse': 'Pilatusstrasse 30',
      'PLZ': '6003',
      'Ort': 'Luzern',
      'Kanton': 'LU',
      'Typ': 'Wohnung',
      'Zimmer': '3.5',
      'Fläche': '86',
      'Preis': '785000',
      'Verkäufer': 'vera',
      'Zuständig': 'noah',
      'Dossier/Exposé': 'ja',
    }, id: 'pilatus');
    add(properties, {
      'Name': 'Wohnhaus am Bach',
      'Strasse': 'Bachweg 3',
      'PLZ': '6048',
      'Ort': 'Horw',
      'Kanton': 'LU',
      'Typ': 'Mehrfamilienhaus',
      'Zimmer': '10',
      'Fläche': '286',
      'Preis': '2200000',
      'Eigentümer': 'clara',
      'Zuständig': 'livio',
    }, id: 'bach');
    add(mandates, {
      'Name': 'Lindenweg',
      'Kontakt': 'jonas',
      'Objekt': 'linden',
      'Zuständig': 'livio',
      'Phase': 'In Vermarktung',
    }, id: 'm-linden');
    add(mandates, {
      'Name': 'Sonnenhang',
      'Kontakt': 'clara',
      'Objekt': 'sonne',
      'Zuständig': 'livio',
      'Phase': 'Bewertung',
    }, id: 'm-sonne');
    add(mandates, {
      'Name': 'Pilatusquartier',
      'Kontakt': 'vera',
      'Objekt': 'pilatus',
      'Zuständig': 'noah',
      'Phase': 'In Verhandlung',
    }, id: 'm-pilatus');

    add(projects, {
      'Name': 'Sanierung Villa Seehof',
      'Typ': 'Energetische Sanierung',
      'Eigentümer': 'clara',
      'Zuständig': 'livio',
      'Budget': '420000',
      'GEAK': 'D → B',
      'Phase': 'Machbarkeit',
      'Machbarkeit/GEAK': 'ja',
      'Machbarkeit/Varianten': 'ja',
    }, id: 'villa');
    add(projects, {
      'Name': 'Umbau am Lindenweg',
      'Typ': 'Umbau',
      'Eigentümer': 'jonas',
      'Zuständig': 'livio',
      'Budget': '185000',
      'GEAK': 'C → B',
      'Phase': 'Vorprojekt',
    }, id: 'umbau');

    add(tasks, {
      'Name': 'Exposé Lindenweg prüfen',
      'Datum': iso(day(-1)),
      'Priorität': 'Hoch',
      'Zuständig': 'livio',
      'Kontakt': 'jonas',
      'Notiz': 'Grundriss mit dem aktuellen Stand abgleichen.',
    }, id: 't1');
    add(tasks, {
      'Name': 'Anna Meier zurückrufen',
      'Datum': iso(day(0)),
      'Priorität': 'Normal',
      'Zuständig': 'livio',
      'Kontakt': 'anna',
    }, id: 't2');
    add(tasks, {
      'Name': 'Dossier Sonnenhang ergänzen',
      'Datum': iso(day(2)),
      'Priorität': 'Normal',
      'Zuständig': 'livio',
      'Kontakt': 'clara',
    }, id: 't3');
    add(tasks, {
      'Name': 'Offerte Villa Seehof besprechen',
      'Datum': iso(day(4)),
      'Priorität': 'Normal',
      'Zuständig': 'livio',
      'Kontakt': 'clara',
    }, id: 't4');
    add(tasks, {
      'Name': 'Besichtigung bestätigen',
      'Datum': iso(day(1)),
      'Priorität': 'Hoch',
      'Zuständig': 'mara',
      'Kontakt': 'weber',
    }, id: 't5');

    add(activities, {
      'Name': 'Suchprofil besprochen',
      'Typ': 'Anruf',
      'Datum': iso(day(0)),
      'Kontakt': 'anna',
      'Zuständig': 'livio',
      'Notiz': 'Anna möchte die Wohnung am Lindenweg besichtigen.',
    });
    add(activities, {
      'Name': 'Grundriss erhalten',
      'Typ': 'E-Mail',
      'Datum': iso(day(-1)),
      'Kontakt': 'jonas',
      'Zuständig': 'livio',
      'Notiz': 'Die überarbeitete Fassung liegt zur Prüfung vor.',
    });
    add(activities, {
      'Name': 'Villa Seehof besichtigt',
      'Typ': 'Besichtigung',
      'Datum': iso(day(-2)),
      'Kontakt': 'clara',
      'Zuständig': 'livio',
      'Notiz': 'Bestandsaufnahme vor Ort.',
    });
    add(activities, {
      'Name': 'Anforderungen notiert',
      'Typ': 'Notiz',
      'Datum': iso(day(-3)),
      'Kontakt': 'weber',
      'Zuständig': 'mara',
      'Notiz': 'Garten und ruhige Lage sind wichtig.',
    });
    add(reminders, {
      'Name': 'Besichtigung am Lindenweg',
      'Datum': iso(day(3)),
      'Typ': 'Einmalig',
      'Kontakt': 'anna',
      'Zuständig': 'livio',
    });
    add(reminders, {
      'Name': 'Projektbesprechung Seehof',
      'Datum': iso(day(11)),
      'Typ': 'Einmalig',
      'Kontakt': 'clara',
      'Zuständig': 'livio',
    });
    notifyListeners();
  }
}

DateTime day([int offset = 0]) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day + offset);
}

String iso(DateTime? date) =>
    date == null ? '' : date.toIso8601String().substring(0, 10);
DateTime? parseDate(String value) {
  final date = DateTime.tryParse(value);
  return date != null && iso(date) == value ? date : null;
}

String shortDate(String value) {
  final date = parseDate(value);
  if (date == null) return '—';
  return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
}

int daysUntil(String value) {
  final date = parseDate(value);
  if (date == null) return 999;
  final today = day();
  return DateTime.utc(
    date.year,
    date.month,
    date.day,
  ).difference(DateTime.utc(today.year, today.month, today.day)).inDays;
}

DateTime? nextAnniversary(DateTime? date) {
  if (date == null) return null;
  final today = day();
  final current = DateTime(today.year, date.month, date.day);
  return current.isBefore(today)
      ? DateTime(today.year + 1, date.month, date.day)
      : current;
}

double number(String value) =>
    double.tryParse(
      value.replaceAll(RegExp("[ ’']"), '').replaceAll(',', '.'),
    ) ??
    0;
String francs(String value) {
  if (value.isEmpty) return '—';
  final formatted = number(value)
      .round()
      .toString()
      .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '’');
  return 'CHF $formatted';
}

String initials(String name) => name
    .trim()
    .split(RegExp(r'\s+'))
    .where((word) => word.isNotEmpty)
    .take(2)
    .map((word) => word[0].toUpperCase())
    .join();
