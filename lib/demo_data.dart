import 'dart:convert';

import 'package:flutter/foundation.dart';

part 'buyer_matching.dart';

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

const reminderTypes = ['Einmalig', 'Wöchentlich', 'Monatlich', 'Jährlich'];
const reminderWeekdays = [
  'Montag',
  'Dienstag',
  'Mittwoch',
  'Donnerstag',
  'Freitag',
  'Samstag',
  'Sonntag',
];
const reminderMonths = [
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
    final buyers = visibleContacts.where(
      (contact) =>
          contact.values('Rollen').contains('Käufer') &&
          (buyerId == null
              ? buyerSearchStatus(contact) == 'Aktiv'
              : contact.id == buyerId),
    );
    final objects = visibleProperties
        .where((object) => propertyId == null || object.id == propertyId)
        .map((object) => (object, status(object) == 'Verkauft'))
        .toList();
    final results = <Match>[];
    for (final buyer in buyers) {
      for (final (object, sold) in objects) {
        final feedback = readMatchFeedback(buyer, object);
        if (!sold || feedback.isNotEmpty) {
          results.add(_evaluateMatch(buyer, object, feedback, sold: sold));
        }
      }
    }
    return results..sort((a, b) {
      final byStatus = a.state.index.compareTo(b.state.index);
      return byStatus == 0 ? b.score.compareTo(a.score) : byStatus;
    });
  }

  List<Record> upcomingReminders({bool includeCompleted = false}) {
    bool include(Record reminder) =>
        includeCompleted || !completedReminders.contains(reminder.id);

    Record scheduled(Record reminder) {
      final date = parseDate(reminder['Datum']);
      final nextDate = nextReminderDate(reminder, day());
      return Record(reminder.id, {
        ...reminder.fields,
        if (reminder['Typ'] == 'Jährlich' && date != null) ...{
          'Tag': '${date.day}',
          'Monat': '${date.month}',
        },
        'Datum': iso(nextDate),
      });
    }

    return [
      for (final r in reminders.where(canSeeLinked))
        if (reminderTypes.contains(r['Typ']) && include(r)) scheduled(r),
      for (final c in visibleContacts.where(
        (c) =>
            parseDate(c['Erinnerung am']) != null &&
            (includeCompleted ||
                c.flag('Erinnerung jährlich') ||
                !completedReminders.contains(
                  'contact-${c.id}-${c['Erinnerung am']}',
                )),
      ))
        scheduled(
          Record('contact-${c.id}-${c['Erinnerung am']}', {
            'Name': c['Erinnerungsnotiz'].isEmpty
                ? c.name
                : c['Erinnerungsnotiz'],
            'Datum': c['Erinnerung am'],
            'Kontakt': c.id,
            'Zuständig': c['Zuständig'],
            'Typ': c.flag('Erinnerung jährlich') ? 'Jährlich' : 'Einmalig',
            'Quelle': 'Kontakt',
          }),
        ),
      for (final p in visibleProperties.where(
        (p) => parseDate(p['Kaufdatum']) != null,
      ))
        scheduled(
          Record('purchase-${p.id}', {
            'Name': 'Kaufjahrestag · ${p.name}',
            'Datum': p['Kaufdatum'],
            'Ereignisdatum': p['Kaufdatum'],
            'Kontakt': p['Eigentümer'],
            'Zuständig': p['Zuständig'],
            'Typ': 'Jährlich',
            'Objekt': p.id,
          }),
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
    reminders.removeWhere((entry) {
      if (entry['Kontakt'] != record.id) return false;
      completedReminders.remove(entry.id);
      return true;
    });
    for (final entry in [...tasks, ...activities]) {
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
      'Wunschbudget': '1020000',
      'Parkplatz im Budget': 'ja',
      'Finanzierungsstatus': 'Bestätigt',
      'Suchstatus': 'Aktiv',
      'Bezug bis': iso(day(150)),
      'Suchobjekt': 'Wohnung',
      'Zimmer ab': '3.5',
      'Wohnfläche ab': '85',
      'Region': 'Luzern',
      'Suchkantone': 'LU, NW',
      'Lage und Erreichbarkeit':
          'Am liebsten in Luzern (6003 oder 6005), Horw ist auch möglich. '
          'Emmen kommt nicht infrage. Maximal 25 Minuten zum Bahnhof Luzern '
          'und 10 Minuten zu Fuss zur nächsten ÖV-Haltestelle.',
      'Weitere Kriterien':
          'Die Wohnung sollte bezugsbereit sein und braucht einen Lift. '
          'Ein Balkon wäre schön. Baurecht kommt nicht infrage.',
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
      'Finanzierungsstatus': 'In Abklärung',
      'Zimmer ab': '4.5',
      'Suchkantone': 'LU, NW',
      'Suchobjekt': 'Einfamilienhaus',
      'Region': 'Stans',
      'Lage und Erreichbarkeit': 'Möglichst in Stans (6370).',
      'Weitere Kriterien': 'Mindestens 400 m² Grundstück. Ein Garten und ein Parkplatz wären schön.',
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
      'Suchstatus': 'Pausiert',
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
      'Zustand': 'Bezugsbereit',
      'Etage': '2',
      'Verfügbar ab': iso(day(45)),
      'Parkplatzkosten': '25000',
      'Renovationskosten': '0',
      'Pendelziel': 'Luzern Bahnhof',
      'Pendelminuten': '14',
      'ÖV Gehminuten': '5',
      'Schule Gehminuten': '8',
      'Merkmale vorhanden': 'Balkon, Parkplatz, Lift, Stufenloser Zugang',
      'Merkmale fehlen': 'Garten, Baurecht',
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
      'Zustand': 'Renovationsbedürftig',
      'Renovationskosten': '90000',
      'Merkmale vorhanden': 'Terrasse, Garten, Parkplatz',
      'Merkmale fehlen': 'Lift, Baurecht',
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
      'Merkmale vorhanden': 'Balkon',
      'Merkmale fehlen': 'Baurecht',
      'Verfügbar ab': iso(day(75)),
      'Parkplatzkosten': '0',
      'Pendelziel': 'Luzern Bahnhof',
      'Pendelminuten': '11',
      'ÖV Gehminuten': '3',
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

DateTime? nextReminderDate(Record reminder, DateTime today) {
  final date = parseDate(reminder['Datum']);
  final weekday = int.tryParse(reminder['Wochentag']);
  final targetDay = int.tryParse(reminder['Tag']);
  final targetMonth = int.tryParse(reminder['Monat']);

  DateTime occurrence(int year, int month, int dayOfMonth) {
    final lastDay = DateTime(year, month + 1, 0).day;
    return DateTime(year, month, dayOfMonth.clamp(1, lastDay));
  }

  switch (reminder['Typ']) {
    case 'Wöchentlich' when weekday != null:
      final offset = (weekday - today.weekday) % DateTime.daysPerWeek;
      return DateTime(today.year, today.month, today.day + offset);
    case 'Monatlich' when targetDay != null:
      final current = occurrence(today.year, today.month, targetDay);
      return current.isBefore(today)
          ? occurrence(today.year, today.month + 1, targetDay)
          : current;
    case 'Jährlich':
      if (date != null && !date.isBefore(today)) return date;
      final month = targetMonth ?? date?.month;
      final dayOfMonth = targetDay ?? date?.day;
      if (month == null || dayOfMonth == null) return null;
      final current = occurrence(today.year, month, dayOfMonth);
      return current.isBefore(today)
          ? occurrence(today.year + 1, month, dayOfMonth)
          : current;
    default:
      return date;
  }
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
