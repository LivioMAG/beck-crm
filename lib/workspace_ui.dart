part of 'main.dart';

class _Backdrop extends StatelessWidget {
  const _Backdrop({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      color: Color(0xfff1f6f9),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xffe1eef7), Color(0xfff3f7f9), Color(0xffe8f1ed)],
      ),
    ),
    child: Stack(
      fit: StackFit.expand,
      children: [
        const Positioned(
          top: -265,
          right: -100,
          child: _Glow(size: 760, color: Color(0x66a9d2ed)),
        ),
        const Positioned(
          bottom: -300,
          left: 110,
          child: _Glow(size: 710, color: Color(0x55beddd3)),
        ),
        child,
      ],
    ),
  );
}

class _Glow extends StatelessWidget {
  const _Glow({required this.size, required this.color});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
      ),
    ),
  );
}

class _Glass extends StatelessWidget {
  const _Glass({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(23);
    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: const [
          BoxShadow(
            color: Color(0x0d1c4665),
            blurRadius: 27,
            offset: Offset(0, 9),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 17, sigmaY: 17),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: radius,
              color: const Color(0xbdfbfeff),
              border: Border.all(color: Colors.white),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand();
  @override
  Widget build(BuildContext context) => const Row(
    children: [
      SizedBox.square(
        dimension: 43,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff204963), navy],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.all(Radius.circular(13)),
          ),
          child: Center(
            child: Text(
              'B',
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 25,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      SizedBox(width: 10),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BECK',
            style: TextStyle(
              fontFamily: 'Georgia',
              fontWeight: FontWeight.w700,
              fontSize: 21,
              height: 1.03,
            ),
          ),
          SizedBox(height: 3),
          Row(
            children: [
              SizedBox(
                width: 12,
                height: 2,
                child: ColoredBox(color: beckBlue),
              ),
              SizedBox(width: 4),
              Text(
                'REAL ESTATE',
                style: TextStyle(
                  color: muted,
                  fontSize: 7.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.05,
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow(this.text, {this.color = muted});
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(
      color: color,
      fontSize: 10,
      fontWeight: FontWeight.w800,
      letterSpacing: 1.6,
    ),
  );
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
    this.badge,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;
  final int? badge;
  @override
  Widget build(BuildContext context) => Material(
    color: selected ? const Color(0xffdef0fb) : Colors.transparent,
    borderRadius: BorderRadius.circular(12),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 11),
        child: Row(
          children: [
            Icon(icon, size: 19, color: selected ? accent : muted),
            const SizedBox(width: 11),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: selected ? accent : ink,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
            if ((badge ?? 0) > 0) _Pill('$badge', color: red),
            if (selected && (badge ?? 0) == 0)
              const Icon(Icons.chevron_right_rounded, color: accent, size: 17),
          ],
        ),
      ),
    ),
  );
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child, this.padding = const EdgeInsets.all(20)});
  final Widget child;
  final EdgeInsets padding;
  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: const Color(0xf9ffffff),
      borderRadius: BorderRadius.circular(19),
      border: Border.all(color: const Color(0xffe9f0f3)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x071b4463),
          blurRadius: 20,
          offset: Offset(0, 7),
        ),
      ],
    ),
    child: child,
  );
}

class _Pill extends StatelessWidget {
  const _Pill(this.label, {this.color = muted, this.icon});
  final String label;
  final Color color;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(
      horizontal: icon == null ? 8 : 9,
      vertical: 4,
    ),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(30),
      color: color.withValues(alpha: .085),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
        ],
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
        ),
      ],
    ),
  );
}

class _Avatar extends StatelessWidget {
  const _Avatar(this.name, {this.size = 37, this.color = accent, this.icon});
  final String name;
  final double size;
  final Color color;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: color.withValues(alpha: .10),
      borderRadius: BorderRadius.circular(size * .34),
    ),
    alignment: Alignment.center,
    child: icon == null
        ? Text(
            initials(name),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: size * .31,
            ),
          )
        : Icon(icon, color: color, size: size * .48),
  );
}

class _PageTitle extends StatelessWidget {
  const _PageTitle(this.title, {this.subtitle, this.action});
  final String title;
  final String? subtitle;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 20, top: 3),
    child: Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 20,
      runSpacing: 14,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Georgia',
                fontSize: 38,
                letterSpacing: -.9,
                height: 1.13,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 7),
              Text(
                subtitle!,
                style: const TextStyle(color: muted, fontSize: 14),
              ),
            ],
          ],
        ),
        if (action != null) action!,
      ],
    ),
  );
}

Widget _newButton(
  String title,
  VoidCallback action, {
  IconData icon = Icons.add_rounded,
}) => FilledButton.icon(
  onPressed: action,
  icon: Icon(icon, size: 19),
  label: Text(title),
);

Widget _panelTitle(String title, {IconData? icon, Widget? action}) => Row(
  children: [
    if (icon != null) ...[
      _Avatar('', size: 34, icon: icon),
      const SizedBox(width: 9),
    ],
    Expanded(
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
      ),
    ),
    if (action != null) action,
  ],
);

Widget _tabs(
  List<String> items,
  String selected,
  ValueChanged<String> change,
) => SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: const Color(0xaef7fbfd),
      borderRadius: BorderRadius.circular(13),
      border: Border.all(color: Colors.white),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1),
            child: Material(
              color: selected == item ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(9),
              child: InkWell(
                onTap: () => change(item),
                borderRadius: BorderRadius.circular(9),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 9,
                  ),
                  child: Text(
                    item,
                    style: TextStyle(
                      color: selected == item ? accent : muted,
                      fontWeight: selected == item
                          ? FontWeight.w800
                          : FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  ),
);

Widget _filters(
  List<String> values,
  String current,
  ValueChanged<String> change,
) => Wrap(
  spacing: 7,
  runSpacing: 6,
  children: [
    for (final value in values)
      ChoiceChip(
        label: Text(value),
        selected: current == value,
        showCheckmark: false,
        onSelected: (_) => change(value),
        labelStyle: TextStyle(
          color: current == value ? accent : muted,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        selectedColor: blueWash,
        backgroundColor: Colors.white,
        side: BorderSide(
          color: current == value ? const Color(0xffc6e4f4) : line,
        ),
        shape: const StadiumBorder(),
        visualDensity: VisualDensity.compact,
      ),
  ],
);

Widget _search(String label, String value, ValueChanged<String> change) =>
    SizedBox(
      width: 292,
      child: TextFormField(
        key: ValueKey(label),
        initialValue: value,
        onChanged: change,
        decoration: InputDecoration(
          hintText: label,
          prefixIcon: const Icon(Icons.search_rounded, size: 21, color: muted),
        ),
      ),
    );

Widget _empty(String label, {IconData icon = Icons.inbox_outlined}) => Center(
  child: Padding(
    padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 12),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 29, color: const Color(0xff7695a6)),
        const SizedBox(height: 9),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(color: muted, fontWeight: FontWeight.w600),
        ),
      ],
    ),
  ),
);

Widget _items(List<Widget> rows, {String empty = 'Keine Einträge'}) {
  if (rows.isEmpty) return _empty(empty);
  return Column(
    children: [
      for (var i = 0; i < rows.length; i++) ...[
        if (i > 0) const Divider(height: 1),
        rows[i],
      ],
    ],
  );
}

Widget _row(
  String title, {
  String? subtitle,
  Widget? leading,
  Widget? trailing,
  VoidCallback? onTap,
}) => ListTile(
  contentPadding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
  leading: leading,
  trailing:
      trailing ??
      (onTap == null
          ? null
          : const Icon(Icons.chevron_right_rounded, color: muted, size: 18)),
  onTap: onTap,
  title: Text(
    title,
    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
  ),
  subtitle: subtitle == null || subtitle.isEmpty
      ? null
      : Text(subtitle, style: const TextStyle(fontSize: 12, color: muted)),
);

Widget _fitGrid(
  List<Widget> children, {
  required double minWidth,
  int maxColumns = 6,
  double gap = 13,
  List<int>? columnCounts,
}) => LayoutBuilder(
  builder: (_, limits) {
    final available = ((limits.maxWidth + gap) / (minWidth + gap))
        .floor()
        .clamp(1, maxColumns);
    final count =
        columnCounts?.lastWhere((count) => count <= available) ?? available;
    final width = (limits.maxWidth - (count - 1) * gap) / count;
    return Wrap(
      spacing: gap,
      runSpacing: gap,
      children: [
        for (final child in children) SizedBox(width: width, child: child),
      ],
    );
  },
);

Widget _facts(Map<String, String> facts, {int maxColumns = 3}) => _fitGrid(
  [
    for (final entry in facts.entries)
      if (entry.value.isNotEmpty)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.key,
              style: const TextStyle(
                color: muted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              entry.value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
  ],
  minWidth: 142,
  maxColumns: maxColumns,
  gap: 15,
);

class _Board extends StatefulWidget {
  const _Board({required this.columns});
  final Map<String, List<Widget>> columns;
  @override
  State<_Board> createState() => _BoardState();
}

class _BoardState extends State<_Board> {
  final scroll = ScrollController();
  @override
  void dispose() {
    scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scrollbar(
    controller: scroll,
    thumbVisibility: true,
    child: SingleChildScrollView(
      controller: scroll,
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final column in widget.columns.entries)
            Container(
              width: 218,
              constraints: const BoxConstraints(minHeight: 191),
              margin: const EdgeInsets.only(right: 11),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0x9bf6fbfd),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          column.key,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      _Pill('${column.value.length}', color: accent),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (column.value.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(10),
                      child: Text('—', style: TextStyle(color: muted)),
                    ),
                  for (final card in column.value)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: card,
                    ),
                ],
              ),
            ),
        ],
      ),
    ),
  );
}

Widget _progress(int done, int total) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    LinearProgressIndicator(
      value: total == 0 ? 0 : done / total,
      minHeight: 5,
      borderRadius: BorderRadius.circular(7),
      color: beckBlue,
      backgroundColor: blueWash,
    ),
    const SizedBox(height: 5),
    Text(
      '$done von $total',
      style: const TextStyle(
        color: muted,
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
    ),
  ],
);

class _Subpage extends StatelessWidget {
  const _Subpage({
    required this.area,
    required this.title,
    required this.child,
    this.subtitle,
    this.footer,
    this.onBack,
    this.maxWidth = 1120,
  });

  final String area;
  final String title;
  final Widget child;
  final String? subtitle;
  final Widget? footer;
  final VoidCallback? onBack;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final margin = MediaQuery.sizeOf(context).width < 660 ? 16.0 : 32.0;
    final back =
        onBack ??
        () {
          Navigator.maybePop(context);
        };
    return Scaffold(
      body: _Backdrop(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(margin, 12, margin, 8),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: Row(
                      children: [
                        TextButton.icon(
                          onPressed: back,
                          icon: const Icon(Icons.arrow_back_rounded, size: 18),
                          label: const Text('Zurück'),
                        ),
                        const SizedBox(width: 10),
                        Flexible(child: _Eyebrow(area.toUpperCase())),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(margin, 10, margin, 30),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxWidth),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _PageTitle(title, subtitle: subtitle),
                          child,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (footer != null)
                DecoratedBox(
                  decoration: const BoxDecoration(
                    color: Color(0xeef7fbfd),
                    border: Border(top: BorderSide(color: line)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(margin, 9, margin, 9),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxWidth),
                        child: footer,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DialogFrame extends StatelessWidget {
  const _DialogFrame({
    required this.title,
    required this.child,
    this.footer,
    this.onClose,
    this.sheet = false,
  });
  final String title;
  final Widget child;
  final Widget? footer;
  final VoidCallback? onClose;
  final bool sheet;
  @override
  Widget build(BuildContext context) {
    final body = ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: sheet ? 720 : 450,
        maxHeight: MediaQuery.sizeOf(context).height * .88,
      ),
      child: _Glass(
        child: SizedBox(
          width: sheet ? 720 : 450,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(23, 17, 11, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 26,
                          height: 1.16,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Schliessen',
                      onPressed: onClose ?? () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded, color: muted),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(22),
                  child: child,
                ),
              ),
              if (footer != null) ...[
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 13),
                  child: footer!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
    return sheet
        ? SafeArea(
            child: Padding(padding: const EdgeInsets.all(12), child: body),
          )
        : Dialog(
            elevation: 0,
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 20,
            ),
            child: body,
          );
  }
}

enum _FieldKind { text, select, multi, check, date, lookup, section }

class _Field {
  const _Field.section(this.key)
    : kind = _FieldKind.section,
      label = null,
      required = false,
      long = true,
      numeric = false,
      secret = false,
      options = const {};

  const _Field(
    this.key, {
    this.label,
    this.required = false,
    this.long = false,
    this.numeric = false,
    this.secret = false,
  }) : kind = _FieldKind.text,
       options = const {};
  const _Field.select(
    this.key,
    this.options, {
    this.label,
    this.required = false,
  }) : kind = _FieldKind.select,
       long = false,
       numeric = false,
       secret = false;
  const _Field.lookup(
    this.key,
    this.options, {
    this.label,
    this.required = false,
  }) : kind = _FieldKind.lookup,
       long = false,
       numeric = false,
       secret = false;
  const _Field.multi(this.key, this.options, {this.required = false})
    : kind = _FieldKind.multi,
      label = null,
      long = false,
      numeric = false,
      secret = false;
  const _Field.check(this.key, {this.label})
    : kind = _FieldKind.check,
      required = false,
      long = false,
      numeric = false,
      secret = false,
      options = const {};
  const _Field.date(this.key, {this.label, this.required = false})
    : kind = _FieldKind.date,
      long = false,
      numeric = false,
      secret = false,
      options = const {};
  final String key;
  final String? label;
  final bool required;
  final bool long;
  final bool numeric;
  final bool secret;
  final Map<String, String> options;
  final _FieldKind kind;
}

Map<String, String> _choices(Iterable<String> values) => {
  for (final item in values) item: item,
};

class _Editor extends StatefulWidget {
  const _Editor({
    required this.title,
    required this.fields,
    required this.initial,
    required this.submit,
    this.validate,
    this.showField,
    this.area,
    this.sheet = false,
  });
  final String title;
  final List<_Field> fields;
  final Fields initial;
  final String submit;
  final String? Function(Fields)? validate;
  final bool Function(_Field, Fields)? showField;
  final String? area;
  final bool sheet;
  @override
  State<_Editor> createState() => _EditorState();
}

class _EditorState extends State<_Editor> {
  late final values = Fields.of(widget.initial);
  final formKey = GlobalKey<FormState>();
  final lookups = <String, TextEditingController>{};
  String? error;
  bool get changed => widget.fields.any(
    (f) => (values[f.key] ?? '') != (widget.initial[f.key] ?? ''),
  );

  @override
  void dispose() {
    for (final controller in lookups.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> close() async {
    if (changed) {
      final leave = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Änderungen verwerfen?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Weiter bearbeiten'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Verwerfen'),
            ),
          ],
        ),
      );
      if (leave != true) return;
    }
    if (mounted) Navigator.pop(context);
  }

  void save() {
    if (!(formKey.currentState?.validate() ?? false)) return;
    final issue = widget.validate?.call(values);
    if (issue != null) {
      setState(() => error = issue);
      return;
    }
    Navigator.pop(context, values);
  }

  String? validate(_Field field, String? value) {
    if (field.required && (value ?? '').trim().isEmpty) return 'Pflichtfeld';
    if (field.kind == _FieldKind.date &&
        (value ?? '').isNotEmpty &&
        parseDate(value!) == null)
      return 'Datum als JJJJ-MM-TT eingeben';
    if (field.numeric &&
        (value ?? '').isNotEmpty &&
        !RegExp(r"^\d[\d ’']*([.,]\d+)?$").hasMatch(value!))
      return 'Zahl eingeben';
    return null;
  }

  Widget input(_Field field) {
    final title = field.label ?? field.key;
    final value = values[field.key] ?? '';
    switch (field.kind) {
      case _FieldKind.section:
        return Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 2),
          child: _panelTitle(title),
        );
      case _FieldKind.select:
        return DropdownButtonFormField<String>(
          initialValue: field.options.containsKey(value) || !field.required
              ? (field.options.containsKey(value) ? value : '')
              : null,
          isExpanded: true,
          decoration: InputDecoration(labelText: title),
          items: [
            if (!field.required)
              const DropdownMenuItem(value: '', child: Text('—')),
            for (final option in field.options.entries)
              DropdownMenuItem(
                value: option.key,
                child: Text(option.value, overflow: TextOverflow.ellipsis),
              ),
          ],
          onChanged: (entry) {
            values[field.key] = entry ?? '';
            if (widget.showField != null) setState(() => error = null);
          },
          validator: (entry) => validate(field, entry),
        );
      case _FieldKind.lookup:
        final controller = lookups.putIfAbsent(
          field.key,
          () => TextEditingController(text: field.options[value] ?? ''),
        );
        return FormField<String>(
          initialValue: value,
          validator: (entry) {
            final input = controller.text.trim();
            if (input.isEmpty || (!field.required && input == '—')) {
              if (field.required) return 'Pflichtfeld';
              values[field.key] = '';
              return null;
            }
            return input == field.options[entry]
                ? null
                : 'Eintrag aus der Liste wählen';
          },
          builder: (state) => DropdownMenu<String>(
            controller: controller,
            expandedInsets: EdgeInsets.zero,
            label: Text(title),
            enableFilter: true,
            requestFocusOnTap: true,
            initialSelection: field.options.containsKey(value) ? value : null,
            errorText: state.errorText,
            dropdownMenuEntries: [
              if (!field.required)
                const DropdownMenuEntry(value: '', label: '—'),
              for (final item in field.options.entries)
                DropdownMenuEntry(value: item.key, label: item.value),
            ],
            onSelected: (entry) {
              values[field.key] = entry ?? '';
              state.didChange(entry);
            },
          ),
        );
      case _FieldKind.multi:
        return FormField<String>(
          initialValue: value,
          validator: (value) => validate(field, value),
          builder: (state) {
            final selected = (state.value ?? '')
                .split(',')
                .map((part) => part.trim())
                .toSet();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: muted,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 5,
                  runSpacing: 5,
                  children: [
                    for (final item in field.options.entries)
                      FilterChip(
                        label: Text(item.value),
                        selected: selected.contains(item.key),
                        onSelected: (on) {
                          if (on) {
                            selected.add(item.key);
                          } else {
                            selected.remove(item.key);
                          }
                          final result = selected
                              .where((x) => x.isNotEmpty)
                              .join(', ');
                          values[field.key] = result;
                          state.didChange(result);
                        },
                      ),
                  ],
                ),
                if (state.hasError)
                  Text(
                    state.errorText!,
                    style: const TextStyle(color: red, fontSize: 12),
                  ),
              ],
            );
          },
        );
      case _FieldKind.check:
        return StatefulBuilder(
          builder: (_, refresh) => CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            dense: true,
            title: Text(title),
            value: values[field.key] == 'ja',
            onChanged: (selected) =>
                refresh(() => values[field.key] = selected == true ? 'ja' : ''),
          ),
        );
      case _FieldKind.date:
        return StatefulBuilder(
          builder: (context, refresh) => TextFormField(
            key: ValueKey((field.key, values[field.key])),
            initialValue: values[field.key] ?? '',
            onChanged: (entry) => values[field.key] = entry.trim(),
            validator: (entry) => validate(field, entry),
            decoration: InputDecoration(
              labelText: title,
              hintText: 'JJJJ-MM-TT',
              suffixIcon: IconButton(
                tooltip: 'Datum wählen',
                icon: const Icon(Icons.calendar_today_outlined, size: 18),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: parseDate(values[field.key] ?? '') ?? day(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2150),
                  );
                  if (picked != null && mounted && context.mounted)
                    refresh(() => values[field.key] = iso(picked));
                },
              ),
            ),
          ),
        );
      case _FieldKind.text:
        return TextFormField(
          initialValue: value,
          obscureText: field.secret,
          maxLines: field.long ? 3 : 1,
          keyboardType: field.numeric
              ? const TextInputType.numberWithOptions(decimal: true)
              : null,
          decoration: InputDecoration(labelText: title),
          onChanged: (entry) => values[field.key] = entry.trim(),
          validator: (entry) => validate(field, entry),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final area = widget.area;
    final footer = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(onPressed: close, child: const Text('Abbrechen')),
        const SizedBox(width: 7),
        FilledButton(onPressed: save, child: Text(widget.submit)),
      ],
    );
    final fields = Form(
      key: formKey,
      child: LayoutBuilder(
        builder: (_, size) {
          const gap = 14.0;
          final wide =
              area != null && size.maxWidth >= 630 && widget.fields.length > 3;
          return Wrap(
            spacing: gap,
            runSpacing: 12,
            children: [
              for (final field in widget.fields)
                if (widget.showField?.call(field, values) ?? true)
                  SizedBox(
                    key: ValueKey(field.key),
                    width: wide && !field.long && field.kind != _FieldKind.multi
                        ? (size.maxWidth - gap) / 2
                        : size.maxWidth,
                    child: input(field),
                  ),
              if (error != null)
                SizedBox(
                  width: size.maxWidth,
                  child: Text(error!, style: const TextStyle(color: red)),
                ),
            ],
          );
        },
      ),
    );
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (popped, _) {
        if (!popped) close();
      },
      child: area == null
          ? _DialogFrame(
              title: widget.title,
              onClose: close,
              sheet: widget.sheet,
              footer: footer,
              child: fields,
            )
          : _Subpage(
              area: area,
              title: widget.title,
              maxWidth: 880,
              onBack: close,
              footer: footer,
              child: _Panel(child: fields),
            ),
    );
  }
}

class _Login extends StatefulWidget {
  const _Login({required this.data});
  final DemoData data;
  @override
  State<_Login> createState() => _LoginState();
}

class _LoginState extends State<_Login> {
  late String account = widget.data.accounts
      .firstWhere((item) => !item.flag('Deaktiviert'))
      .id;
  final password = TextEditingController();
  bool error = false;
  @override
  void dispose() {
    password.dispose();
    super.dispose();
  }

  void submit() {
    if (!widget.data.login(account, password.text))
      setState(() => error = true);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: _Backdrop(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: SizedBox(
            width: 422,
            child: _Glass(
              child: Padding(
                padding: const EdgeInsets.all(29),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _Brand(),
                    const SizedBox(height: 24),
                    const Text(
                      'Anmelden',
                      style: TextStyle(fontFamily: 'Georgia', fontSize: 32),
                    ),
                    const SizedBox(height: 19),
                    DropdownButtonFormField(
                      initialValue: account,
                      decoration: const InputDecoration(labelText: 'Benutzer'),
                      isExpanded: true,
                      items: [
                        for (final user in widget.data.accounts.where(
                          (item) => !item.flag('Deaktiviert'),
                        ))
                          DropdownMenuItem(
                            value: user.id,
                            child: Text('${user.name} · ${user['Rolle']}'),
                          ),
                      ],
                      onChanged: (id) => setState(() {
                        account = id!;
                        error = false;
                      }),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: password,
                      obscureText: true,
                      onSubmitted: (_) => submit(),
                      decoration: InputDecoration(
                        labelText: 'Passwort',
                        helperText: 'Demo-Passwort: beck',
                        errorText: error ? 'Passwort prüfen' : null,
                      ),
                    ),
                    const SizedBox(height: 18),
                    FilledButton(
                      onPressed: submit,
                      child: const Text('Anmelden'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
