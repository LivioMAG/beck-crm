part of 'demo_data.dart';

const propertyFeatures = [
  'Balkon',
  'Terrasse',
  'Garten',
  'Parkplatz',
  'Lift',
  'Stufenloser Zugang',
  'Baurecht',
];
const propertyConditions = ['Neubau', 'Bezugsbereit', 'Renovationsbedürftig'];
const buyerSearchStatuses = ['Aktiv', 'Pausiert', 'Fündig geworden'];
const financingStatuses = ['Offen', 'In Abklärung', 'Bestätigt'];
const feedbackStatuses = [
  'Exposé gesendet',
  'Besichtigt',
  'Interesse',
  'Abgelehnt',
];

String buyerSearchStatus(Record buyer) =>
    buyerSearchStatuses.contains(buyer['Suchstatus'])
    ? buyer['Suchstatus']
    : 'Aktiv';

enum MatchState { eligible, review, excluded, declined }

class MatchFeedback {
  const MatchFeedback(this.status, this.reason, this.date);
  final String status;
  final String reason;
  final String date;

  Map<String, String> toJson() => {
    'status': status,
    'reason': reason,
    'date': date,
  };
}

class Match {
  const Match(
    this.buyer,
    this.property,
    this.score,
    this.reasons,
    this.review,
    this.exclusions,
    this.feedback,
  );

  final Record buyer;
  final Record property;
  final int score;
  final List<String> reasons;
  final List<String> review;
  final List<String> exclusions;
  final List<MatchFeedback> feedback;

  MatchState get state {
    if (feedback.firstOrNull?.status == 'Abgelehnt') return MatchState.declined;
    if (exclusions.isNotEmpty) return MatchState.excluded;
    return review.isEmpty ? MatchState.eligible : MatchState.review;
  }

  bool get strong => state == MatchState.eligible && score >= 70;
}

List<MatchFeedback> readMatchFeedback(Record buyer, Record property) {
  final value = buyer['Objektverlauf/${property.id}'];
  if (value.isEmpty) return const [];
  final events = jsonDecode(value) as List<dynamic>;
  return [
    for (final event in events)
      MatchFeedback(
        event['status'] as String,
        event['reason'] as String,
        event['date'] as String,
      ),
  ];
}

void addMatchFeedback(
  Record buyer,
  Record property,
  String status,
  String reason,
) {
  buyer.update({
    'Objektverlauf/${property.id}': jsonEncode([
      MatchFeedback(status, reason, iso(day())),
      ...readMatchFeedback(buyer, property),
    ]),
  });
}

String _place(String value) => value.trim().toLowerCase();

Match _evaluateMatch(
  Record buyer,
  Record property,
  List<MatchFeedback> feedback, {
  required bool sold,
}) {
  final reasons = <String>[];
  final review = <String>[];
  final exclusions = <String>[if (sold) 'Verkauft'];
  var points = 0;

  // Missing property information stays unknown until someone verifies it.
  bool minimum(String buyerField, String propertyField, String label) {
    if (buyer[buyerField].isEmpty) return false;
    if (property[propertyField].isEmpty) {
      review.add('$label offen');
      return false;
    }
    final target = number(buyer[buyerField]);
    final actual = number(property[propertyField]);
    if (actual < target) {
      exclusions.add('$label zu tief');
      return false;
    }
    return true;
  }

  final budget = number(buyer['Budget bis']);
  final preferredBudget = number(buyer['Wunschbudget']);
  final extraCosts = [
    if (buyer.flag('Parkplatz im Budget')) 'Parkplatzkosten',
    if (buyer.flag('Renovation im Budget')) 'Renovationskosten',
  ];
  final hasPrice = number(property['Preis']) > 0;
  final price =
      number(property['Preis']) +
      extraCosts.fold(0.0, (sum, key) => sum + number(property[key]));
  final priceKnown =
      hasPrice && extraCosts.every((key) => property[key].isNotEmpty);
  if (budget > 0 && hasPrice && price > budget) {
    exclusions.add('Über Budget');
  } else if ((budget > 0 || preferredBudget > 0) && !priceKnown) {
    review.add('Gesamtpreis offen');
  } else if (budget > 0 && priceKnown && price >= number(buyer['Budget von'])) {
    points += 35;
    reasons.add('Preis passt');
  }
  if (preferredBudget > 0 && priceKnown && price <= preferredBudget) {
    points += 5;
    reasons.add('Im Wunschbudget');
  }

  final town = _place(property['Ort']);
  if (buyer.values('Suchkantone').contains(property['Kanton'])) {
    points += 20;
    reasons.add('Kt. ${property['Kanton']}');
  }
  if (town.isNotEmpty && _place(buyer['Region']) == town) {
    points += 20;
    reasons.add('Region passt');
  }

  if (buyer['Suchobjekt'].isNotEmpty &&
      buyer['Suchobjekt'] != property['Typ']) {
    if (property['Typ'].isEmpty) {
      review.add('Objekttyp offen');
    } else {
      exclusions.add('Anderer Objekttyp');
    }
  }
  if (minimum('Zimmer ab', 'Zimmer', 'Zimmerzahl')) {
    points += 15;
    reasons.add('Zimmer passen');
  }
  if (minimum('Wohnfläche ab', 'Fläche', 'Wohnfläche'))
    reasons.add('Wohnfläche passt');
  final target = parseDate(buyer['Bezug bis']);
  if (target != null) {
    final availability = parseDate(property['Verfügbar ab']);
    if (availability == null) {
      review.add('Bezugstermin offen');
    } else if (availability.isAfter(target)) {
      exclusions.add('Zu spät verfügbar');
    } else {
      reasons.add('Bezugstermin passt');
    }
  }

  if (property.flag('Neu')) {
    points += 5;
    reasons.add('Neu');
  }

  return Match(
    buyer,
    property,
    (points / (preferredBudget > 0 ? 100 : 95) * 100).round(),
    reasons,
    review,
    exclusions,
    feedback,
  );
}
