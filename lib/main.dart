import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'demo_data.dart';

part 'workspace_ui.dart';
part 'overview.dart';
part 'contacts.dart';
part 'real_estate.dart';
part 'organize.dart';

void main() => runApp(const BeckCrmApp());

const ink = Color(0xff172b39);
const muted = Color(0xff536b7a);
const accent = Color(0xff176b94);
const beckBlue = Color(0xff3a9fd1);
const line = Color(0xffe0eaf0);
const blueWash = Color(0xffe5f2fb);
const red = Color(0xffa43a42);
const amber = Color(0xff856019);
const green = Color(0xff24745d);
const navy = Color(0xff132b40);

class BeckCrmApp extends StatelessWidget {
  const BeckCrmApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(seedColor: beckBlue).copyWith(
      primary: accent,
      onPrimary: Colors.white,
      surface: const Color(0xfff9fcfd),
      onSurface: ink,
      error: red,
    );
    return MaterialApp(
      title: 'BECK CRM',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: scheme,
        scaffoldBackgroundColor: Colors.transparent,
        visualDensity: VisualDensity.standard,
        textTheme: ThemeData.light().textTheme.apply(
          bodyColor: ink,
          displayColor: ink,
        ),
        inputDecorationTheme: InputDecorationThemeData(
          filled: true,
          fillColor: const Color(0xfff7fafc),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: line),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: line),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 13,
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(11),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: line),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(11),
            ),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: navy,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        dividerTheme: const DividerThemeData(color: line),
      ),
      home: const Workspace(),
    );
  }
}

enum Section {
  overview('Übersicht', Icons.space_dashboard_outlined),
  contacts('Kontakte', Icons.people_outline_rounded),
  properties('Liegenschaften', Icons.apartment_rounded),
  architecture('Architektur', Icons.architecture_rounded),
  tasks('Aufgaben', Icons.task_alt_rounded);

  const Section(this.label, this.icon);
  final String label;
  final IconData icon;
}

class Workspace extends StatefulWidget {
  const Workspace({super.key});

  @override
  State<Workspace> createState() => _WorkspaceState();
}

class _WorkspaceState extends State<Workspace> {
  final data = DemoData();
  Section section = Section.overview;
  String contactRole = 'Alle';
  String contactTag = 'Alle';
  String contactQuery = '';
  String contactTab = 'Kontakte';
  String propertyTab = 'Objekte';
  String propertyStatus = 'Alle';
  String propertyQuery = '';
  String architectureTab = 'Phasenboard';
  String taskTab = 'Aufgaben';
  String taskStatus = 'Alle';
  String taskStaff = 'Alle';
  String activityType = 'Alle';
  String activityQuery = '';
  bool matchByBuyer = true;
  String matchSelection = '';
  bool reportsOpen = false;
  Map<String, Object>? demoBackup;

  @override
  void dispose() {
    data.dispose();
    super.dispose();
  }

  void go(Section target, {String? tab, String? filter}) => setState(() {
    section = target;
    reportsOpen = false;
    switch (target) {
      case Section.overview:
        break;
      case Section.contacts:
        if (tab != null) contactTab = tab;
        if (filter != null) {
          contactRole = filter;
          contactTag = 'Alle';
          contactQuery = '';
        }
      case Section.properties:
        if (tab != null) propertyTab = tab;
        if (filter != null) propertyStatus = filter;
      case Section.architecture:
        if (tab != null) architectureTab = tab;
      case Section.tasks:
        if (tab != null) taskTab = tab;
        if (filter != null) taskStatus = filter;
    }
  });

  void toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message), width: 330));
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: data,
    builder: (context, _) {
      if (data.user == null) return _Login(data: data);
      final urgent = data.visibleTasks
          .where((t) => !t.flag('Erledigt') && daysUntil(t['Datum']) < 0)
          .length;
      final reminders = data
          .upcomingReminders()
          .where((r) => daysUntil(r['Datum']) <= 14)
          .length;
      return LayoutBuilder(
        builder: (context, size) {
          final desktop = size.maxWidth >= 960;
          final compact = size.maxWidth < 660;
          return Scaffold(
            drawer: desktop
                ? null
                : Drawer(
                    width: 268,
                    backgroundColor: const Color(0xfff8fcfd),
                    child: _sidebar(urgent, reminders, closeDrawer: true),
                  ),
            body: _Backdrop(
              child: SafeArea(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (desktop)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 19, 0, 19),
                        child: SizedBox(
                          width: 222,
                          child: _Glass(child: _sidebar(urgent, reminders)),
                        ),
                      ),
                    Expanded(
                      child: Column(
                        children: [
                          _topbar(desktop, compact),
                          Expanded(
                            child: SingleChildScrollView(
                              key: ValueKey((section, reportsOpen)),
                              padding: EdgeInsets.fromLTRB(
                                compact ? 16 : 31,
                                8,
                                compact ? 16 : 32,
                                86,
                              ),
                              child: Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 1360,
                                  ),
                                  child: switch (section) {
                                    Section.overview =>
                                      reportsOpen ? _reports() : _overview(),
                                    Section.contacts => _contactsPage(),
                                    Section.properties => _propertiesPage(),
                                    Section.architecture => _architecturePage(),
                                    Section.tasks => _tasksPage(),
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            floatingActionButton: compact
                ? FloatingActionButton(
                    tooltip: 'Schnell erfassen',
                    onPressed: () => _activityForm(quick: true),
                    backgroundColor: navy,
                    foregroundColor: Colors.white,
                    child: const Icon(Icons.bolt_rounded),
                  )
                : FloatingActionButton.extended(
                    onPressed: () => _activityForm(quick: true),
                    backgroundColor: navy,
                    foregroundColor: Colors.white,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    icon: const Icon(Icons.bolt_rounded),
                    label: const Text('Schnell erfassen'),
                  ),
          );
        },
      );
    },
  );

  Widget _sidebar(int urgent, int reminders, {bool closeDrawer = false}) =>
      LayoutBuilder(
        builder: (_, size) {
          final menu = _sidebarContents(
            urgent,
            reminders,
            closeDrawer: closeDrawer,
          );
          return size.maxHeight >= 505
              ? menu
              : SingleChildScrollView(
                  child: SizedBox(height: 505, child: menu),
                );
        },
      );

  Widget _sidebarContents(
    int urgent,
    int reminders, {
    required bool closeDrawer,
  }) => Builder(
    builder: (context) => Padding(
      padding: const EdgeInsets.fromLTRB(13, 23, 13, 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(padding: EdgeInsets.only(left: 10), child: _Brand()),
          const SizedBox(height: 36),
          const Padding(
            padding: EdgeInsets.only(left: 11),
            child: _Eyebrow('ARBEITSBEREICH'),
          ),
          const SizedBox(height: 10),
          for (final target in Section.values)
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: _NavTile(
                icon: target.icon,
                label: target.label,
                selected: section == target,
                badge: target == Section.tasks ? urgent : null,
                onTap: () {
                  if (closeDrawer) Navigator.pop(context);
                  go(target);
                },
              ),
            ),
          const SizedBox(height: 12),
          const Divider(indent: 9, endIndent: 9),
          _NavTile(
            icon: Icons.notifications_none_rounded,
            label: 'Erinnerungen',
            badge: reminders,
            onTap: () {
              if (closeDrawer) Navigator.pop(context);
              go(Section.tasks, tab: 'Erinnerungen');
            },
          ),
          const Spacer(),
          _NavTile(
            icon: Icons.settings_outlined,
            label: 'Einstellungen',
            onTap: () {
              if (closeDrawer) Navigator.pop(context);
              _settings();
            },
          ),
          const SizedBox(height: 9),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 11, 10, 11),
            decoration: BoxDecoration(
              color: const Color(0xffeaf4f8),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Row(
              children: [
                Icon(Icons.circle, color: green, size: 8),
                SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'Demo-Arbeitsbereich',
                    style: TextStyle(
                      color: muted,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _topbar(bool desktop, bool compact) => Padding(
    padding: EdgeInsets.fromLTRB(compact ? 14 : 32, 15, compact ? 13 : 33, 14),
    child: Row(
      children: [
        if (!desktop) ...[
          Builder(
            builder: (context) => IconButton(
              tooltip: 'Navigation öffnen',
              onPressed: Scaffold.of(context).openDrawer,
              icon: const Icon(Icons.menu_rounded),
            ),
          ),
          const SizedBox(width: 5),
        ],
        if (compact)
          const _Eyebrow('BECK CRM')
        else ...[
          const Icon(Icons.grid_view_rounded, size: 15, color: muted),
          const SizedBox(width: 9),
          Text(
            desktop ? 'Arbeitsbereich' : 'BECK CRM',
            style: const TextStyle(color: muted, fontSize: 13),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 7),
            child: Icon(Icons.chevron_right_rounded, size: 16, color: muted),
          ),
          Text(
            section.label,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
        ],
        const Spacer(),
        const _Pill('Demo', color: accent, icon: Icons.science_outlined),
        const SizedBox(width: 10),
        PopupMenuButton<String>(
          tooltip: 'Profilmenü',
          position: PopupMenuPosition.under,
          onSelected: (value) {
            if (value == 'Abmelden') {
              go(Section.overview);
              contactRole = 'Alle';
              contactTag = 'Alle';
              contactQuery = '';
              taskStaff = 'Alle';
              matchSelection = '';
              data.logout();
            } else {
              _settings(initial: value);
            }
          },
          itemBuilder: (_) => [
            for (final value in [
              'Einstellungen',
              if (data.allowed('Berechtigungen verwalten')) 'Benutzer',
              'Datenschutz',
              'Import & Export',
              'Abmelden',
            ])
              PopupMenuItem(value: value, child: Text(value)),
          ],
          child: Container(
            padding: EdgeInsets.fromLTRB(4, 4, compact ? 4 : 9, 4),
            decoration: BoxDecoration(
              color: Colors.white70,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Avatar(data.user!.name, size: 31),
                if (!compact) ...[
                  const SizedBox(width: 8),
                  Text(
                    data.user!.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: muted,
                    size: 17,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    ),
  );

  Future<void> detail(
    String title,
    Widget Function() content, {
    String? subtitle,
  }) => Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (_) => _Subpage(
        area: section.label,
        title: title,
        subtitle: subtitle,
        child: ListenableBuilder(
          listenable: data,
          builder: (_, _) => content(),
        ),
      ),
    ),
  );

  Future<Fields?> form(
    String title,
    List<_Field> fields, {
    Fields initial = const {},
    String submit = 'Speichern',
    String? Function(Fields)? validate,
    bool compact = false,
  }) {
    final editor = _Editor(
      title: title,
      fields: fields,
      initial: initial,
      submit: submit,
      validate: validate,
      area: compact ? null : section.label,
    );
    return compact
        ? showDialog<Fields>(
            context: context,
            barrierDismissible: false,
            builder: (_) => editor,
          )
        : Navigator.of(context)
              .push<Fields>(MaterialPageRoute(builder: (_) => editor));
  }

  Future<bool> confirm(
    String title,
    String message, {
    String action = 'Bestätigen',
  }) async =>
      await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Abbrechen'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(action),
            ),
          ],
        ),
      ) ??
      false;

  void refreshPage(VoidCallback change) => setState(change);

  Map<String, String> options(Iterable<Record> records) {
    final entries = records.toList();
    final names = <String, int>{};
    for (final record in entries) {
      names.update(record.name, (count) => count + 1, ifAbsent: () => 1);
    }
    return {
      for (final record in entries)
        record.id: names[record.name] == 1
            ? record.name
            : '${record.name} · ${record['E-Mail'].isEmpty ? record.id : record['E-Mail']}',
    };
  }

  Map<String, String> staff() => options(
    data.admin || data.allowed('Berechtigungen verwalten')
        ? data.accounts.where((u) => !u.flag('Deaktiviert'))
        : [data.user!],
  );
  _Field staffField() => _Field.select('Zuständig', staff(), required: true);
  Iterable<Record> contactsWith(String role) =>
      data.visibleContacts.where((r) => r.values('Rollen').contains(role));
}
