# BeckCRM – Zielaufbau und spätere Automatisierung

- **Grundlage** · [anweisung.txt](anweisung.txt) mit den 13 Funktionsbereichen.
- **CRM-Zielbild** · Gleicher Funktionsumfang, fünf Hauptbereiche, Aktionen am jeweiligen Datensatz.
- **Erste Ausbaustufe** · Klickbarer Flutter-Web-Prototyp mit fiktiven Daten. Anmeldung, Rollen, Versand, Import und Export als Demoabläufe.
- **Klammerhinweise** · Ideen für spätere Automatisierung. Die dafür nötigen Ergänzungen stehen am Ende unter «Spätere Erweiterungen».

## Navigation und Design

| Einstieg | Inhalt |
| --- | --- |
| **Übersicht** | Kennzahlen, meine Aufgaben, Erinnerungen, letzte Aktivitäten, Berichte |
| **Kontakte** | Kontaktliste, Kontaktrollen, Aktivitäten, Gruppen-Mail, Briefe, Vorlagen, Adressdruck |
| **Liegenschaften** | Objektliste, Dossier, Käufer-Matching, Verkaufs-Pipeline |
| **Architektur** | Projektliste, Phasenboard, Checklisten und PDF-Druck |
| **Aufgaben** | Aufgaben, Erinnerungen und Schnell-Erfassung |
| **Profilmenü** | Einstellungen, Benutzer, Datenschutz, Import, Export, Backup und Abmelden |

- **BECK-CI** · Logo mit blauer Linie, BECK-«B» als Favicon, Georgia für die Marke. Farben `#3a9fd1`, `#f7f6f4` und `#4a4a4a`.
- **Liquid Glass** · Dezente Transparenz für Navigation, Dialoge und schwebende Schnell-Erfassung. Ruhige Flächen für Tabellen und Formulare.
- **Bedienung** · Kurze Labels, erkennbare Icons, je Ansicht eine Hauptaktion. Weitere Aktionen am Datensatz oder im Menü «…».
- **Listen** · Suche und kompakte Filter-Chips. Auf schmalen Ansichten horizontal scrollbar. Rote Zähler für fällige Erinnerungen und überfällige Aufgaben.
- **Rückmeldung** · Kurze Bestätigungen unten rechts. Drucklayouts mit BECK-Briefkopf, bei Bedarf mit Adressblock und Fusszeile.
- **Von der Liste zum Detail** · Zeile öffnen → Detail mit den passenden Tabs ansehen → Aktion ausführen → zur vorherigen Liste mit Suche und Filtern zurückkehren.
- **Formulare** · Pflichtfelder direkt am Feld markieren. Nach «Speichern» aktualisieren sich die betroffenen Listen und Zähler. «Abbrechen» schliesst das Formular. Bei ungespeicherten Änderungen erscheint eine kurze Rückfrage.
- **Druck und Vorschau** · «Drucken» öffnet die Ausgabe mit BECK-Layout. Die Druckansicht zeigt den Inhalt und blendet Navigation und Bedienleiste aus.

## Übersicht

- Sechs kompakte Kennzahlen für Verkäufer, Käufer, aktive Objekte, Matches, offene Aufgaben und Eigentümer. Überfällige Aufgaben hervorheben.
- Die vier nächsten eigenen Aufgaben, Geburtstage und Termine der nächsten 14 Tage sowie die vier letzten Aktivitäten mit Zuständigkeit.
- **Berichte** · Kontaktherkunft, Aktivitäten nach Typ und Mitarbeiter, Objektstatus. Kennzahlen zu aktiven Mandaten, Verkäufen, Aktivitäten und Newsletter-Einwilligungen. Berechtigter Excel-Totalexport.

| Einstieg | Bedienablauf und Ergebnis |
| --- | --- |
| **Kennzahl öffnen** | Verkäufer, Käufer oder Eigentümer → Kontaktliste mit gewählter Rolle. Aktive Objekte → gefilterte Objektliste. Matches → Matching-Ansicht. Offene Aufgaben → Aufgabenliste mit Filter «Offen». |
| **Meine Aufgaben** | Eine der vier nächsten offenen Aufgaben öffnen → Details und verknüpften Kontakt ansehen oder direkt abhaken → der Eintrag weicht der nächsten offenen Aufgabe. |
| **Erinnerungen** | Geburtstag oder Termin öffnen → zum Kontakt oder zur Erinnerung springen → bei Bedarf Quick-Mail oder einmalige Erinnerung abhaken. |
| **Letzte Aktivitäten** | Eintrag öffnen → Typ, Datum, Notiz, Kontakt und zuständigen Mitarbeiter sehen. |
| **Berichte** | «Berichte» öffnen → vier Balkendiagramme und Kennzahlen ansehen → mit der für den Totalexport vorgesehenen GL-Berechtigung Kontakte, Objekte und Aufgaben als mehrseitige Excel-Datei exportieren. |

- *(Später automatisierbar · Tagesübersicht priorisieren, blockierte Mandate zeigen, Fragen zum Bestand beantworten, Wochenberichte und Eigentümer-Updates mit Quellen vorbereiten.)*

## Kontakte und Kommunikation

- **Ein Kontakt, mehrere Rollen** · Verkäufer, Käufer, Eigentümer, Handwerker, Netzwerk, Netzwerkpartner oder GL-Kontakt. Gemeinsame Adresse und Historie. Rollenbezogene Felder wie Suchprofil, Mandat, Portfolio, Gewerke, Funktionen, Partnertyp oder GL-Budget im passenden Abschnitt.
- **Personentypen** · Einzelperson, Ehepaar oder Partner, Familie und juristische Person. Passende Namens- und Adressfelder, bei Firmen zusätzlich Rechtsform, UID und Kontaktperson.
- **Stammdaten** · Adresse mit 26 Schweizer Kantonen, E-Mail, Telefon, Herkunft, Zuständigkeit, Geburtstag, Erinnerungen, Newsletter-Einwilligung und Notizen.
- **Detailansicht** · Info, Aktivitäten und Aufgaben. Rollenabhängig Liegenschaften, Architektur oder Matching. Direktaktionen für Bearbeiten, Dokumentversand via Outlook, Adressdruck und bestätigungspflichtiges Löschen gemäss Berechtigung.
- **Aktivitäten** · Anrufe, E-Mails, Besichtigungen und Notizen in chronologischer Ansicht. Suche, Typfilter und Mitarbeiterzuordnung. Erfassen aus Kontakt, Aktivitätenliste oder Schnell-Erfassung.
- **Gruppen-Mail** · Gruppen nach Gewerk, Funktion, Partnertyp oder Kontaktrolle. Empfänger mit Opt-in, Outlook-Entwurf mit BCC, Vorlagen für Marktbericht, neues Objekt und Jahresende sowie Excel-Adressliste.
- **Briefe und Druck** · Neun Vorlagen aus der Anweisung, Empfängerauswahl, Adressvorschau je Personentyp, BECK-PDF und Outlook-Entwurf. Einzeladressen, fünf Etikettenformate mit Startposition sowie C4-, C5- und C6-Umschläge gemäss Berechtigung.

| Vorgang | Bedienablauf und Ergebnis |
| --- | --- |
| **Kontakt finden** | In der Kontaktliste nach Name, Firma oder Adresse suchen → nach Rolle filtern. Bei Handwerkern nach Gewerk, im Netzwerk nach Funktion und bei Partnern nach Partnertyp eingrenzen. |
| **Kontakt erfassen** | «Neuer Kontakt» → Rolle und passenden Personentyp wählen → Stamm- und Rollenfelder erfassen → speichern → Kontakt erscheint in jeder zugewiesenen Rollenliste. Eine weitere Rolle lässt sich im vorhandenen Kontakt ergänzen. |
| **Person oder Firma erfassen** | Einzelperson mit Titel und Name. Ehepaar oder Partner mit zwei Personen und optional abweichendem Nachnamen. Familie mit Familienname und Hauptkontakt. Juristische Person mit Firma, Rechtsform, UID und Kontaktperson. |
| **Käuferprofil pflegen** | Kontakt → Käuferprofil → Budget von/bis, Objekttyp, Zimmer, Region, PLZ und Kantone erfassen → speichern → «Matching» öffnen. |
| **Verkäufer und Eigentümer öffnen** | «Liegenschaften» zeigt verknüpfte Objekte mit Preis und Status. Über «Neue Liegenschaft» ist der Kontakt im passenden Feld vorausgewählt. Eigentümer sehen unter «Architektur» zusätzlich ihre Projekte und deren aktuelle Phasen. |
| **Aktivität oder Aufgabe erfassen** | Im Kontaktdetail den passenden Tab öffnen → «Hinzufügen» → speichern. Der Kontakt ist vorausgewählt. Der Eintrag erscheint in der Kontakthistorie oder Aufgabenliste und gemäss Sichtbarkeit in der entsprechenden Gesamtansicht. |
| **Dokument senden** | Kontakt öffnen → «Dokument senden» → gewünschtes Dokument wählen → vorbereitete Nachricht in Outlook öffnen. |
| **Gruppen-Mail vorbereiten** | Gruppe wählen → Empfängerliste mit gültigem Opt-in prüfen → Vorlage und Inhalt wählen → Outlook-Entwurf mit BCC öffnen oder die Adressen für ein Versandtool als Excel exportieren. |
| **Brief erstellen** | Vorlage und Empfänger wählen → Adressblock prüfen, bei Firmen mit «z. H.» → Inhalt bearbeiten → als BECK-PDF ausgeben oder mit demselben Inhalt in Outlook öffnen. |
| **Adresse drucken** | Einzelkontakt oder Gruppe wählen → Etikettenformat und Startposition oder Umschlagformat wählen → Vorschau prüfen → drucken. Umschläge mit BECK-Absender sind zusätzlich GL-geschützt. |

- **Briefvorlagen** · Verkaufsangebot, Besichtigungseinladung, Mandatsbestätigung, Bewertungsangebot, Eigentümervertretung, Machbarkeitsstudie, Sanierungskonzept, Baubegleitungs-Offerte und Verkaufsabschluss.
- **Druckformate** · Herma 4455, Avery L7163, Avery L7160, Herma 4200 und Grossbrief. Umschläge C4, C5 und C6.
- *(Später automatisierbar · Kontakte aus Mails, Visitenkarten oder Diktaten vorerfassen, Dubletten erkennen, Käuferwünsche strukturieren, Korrespondenz zuordnen und zusammenfassen, Antwortentwürfe und personalisierte Serienbriefe vorbereiten.)*

## Liegenschaften, Mandate und Matching

- **Objekt** · Adresse, Typ, Zimmer, Fläche, Grundstück, Preis und Preisobergrenze, Beschreibung, Kaufdatum, Eigentümer- und Verkäuferverknüpfung. Statusfilter, NEU- und Off-Market-Badges, berechtigtes Löschen mit Bestätigung.
- **Dossier** · Zehn Prüfpunkte mit Fortschritt in der Objektliste. Grundbuchauszug, Katasterplan, Gebäudeversicherung, GEAK, Grundriss, Innen- und Aussenfotos, Exposé, Schuldbrief-Auskunft, Mietzinsübersicht bei MFH und Nebenkosten.
- **Verkaufs-Pipeline** · Kanban mit Erstkontakt, Bewertung, Mandat, In Vermarktung und In Verhandlung. Karte mit Kontakt, Objekt und Zuständigkeit. Zähler je Spalte.
- **Statusführung** · Verkaufsphase am Mandat pflegen. Objektstatus «Neu», «In Vermarktung», «In Verhandlung» und «Verkauft» daraus und aus dem bestätigten Abschluss ableiten. Bei mehreren Mandaten die Anzeige aus dem aktuell massgebenden Mandat bestimmen.
- **Matching** · Ansichten nach Käufer und nach Objekt, Kriterien-Tags, Ampelfarben, Hinweis auf neue Treffer und Exposé-Mail via Outlook. Treffer zusätzlich im Käuferprofil anzeigen.

| Vorgang | Bedienablauf und Ergebnis |
| --- | --- |
| **Liegenschaft erfassen** | «Neue Liegenschaft» aus der Objektliste oder aus einem Verkäufer- oder Eigentümerkontakt öffnen → Typ wählen (EFH, Wohnung, MFH, Bauland oder Gewerbe) → Objektdaten erfassen → bestehende Kontakte als Eigentümer und Verkäufer zuordnen → speichern. Das Objekt ist in der Liste und bei den verknüpften Kontakten sichtbar. |
| **Dossier pflegen** | Fortschritt in der Objektliste anklicken → Dossier öffnen → vorhandene Nachweise den Prüfpunkten zuordnen und Punkte abhaken → Fortschrittsbalken aktualisiert sich. Beim Punkt «Mietzinsübersicht» die Anwendbarkeit auf MFH berücksichtigen. |
| **Verkaufsmandat führen** | Verkäufer öffnen → Mandat mit zuständigem Mitarbeiter und, sobald bekannt, Objekt verknüpfen → Verkaufsphase im Mandatsbereich setzen → Karte erscheint in der passenden Spalte. Das Objekt zeigt den daraus abgeleiteten Status. |
| **Verkauf abschliessen** | Abschluss am Mandat bestätigen und Kaufdatum erfassen → Objekt erhält den Status «Verkauft» → das Kaufdatum dient als Grundlage für die jährliche Erinnerung. Das abgeschlossene Mandat bleibt bei Kontakt und Objekt einsehbar. |
| **Treffer prüfen** | Vom Käuferprofil oder Objekt ins Matching → zwischen «Nach Käufer» und «Nach Objekt» wechseln → Treffer nach Score prüfen → anhand der Tags sehen, welche Kriterien passen oder abweichen. Neue Objekte mit Trefferpotenzial sind hervorgehoben. |
| **Exposé versenden** | Treffer öffnen → vorhandenes Exposé auswählen → «Exposé senden» → vorbereitete Mail an den Käufer in Outlook öffnen. |

- **Matching laut Anweisung** · Preis 35, Kanton 20, PLZ oder Region 20, Zimmer 15 und NEU-Bonus 5 Punkte. Angezeigter Score grün ab 70 %, amber von 40 bis unter 70 %, rot unter 40 %.
- **Offene Matching-Regel** · Die Gewichte ergeben 95 Punkte. Vor der produktiven Berechnung die Skalierung auf 100, Muss-Kriterien und den Umgang mit fehlenden Angaben festlegen. Objekttyp als möglicher Pflichtfilter. Im Prototyp dienen Beispielwerte zur Darstellung.
- *(Später automatisierbar · Objektangaben aus Unterlagen extrahieren, Dossierbelege erkennen, fehlende Nachweise zur Anforderung vorbereiten, Mandatsphasen bei eindeutigem Nachweis vorschlagen, Treffer erklären und Exposé-Mails vorbereiten.)*
- *(Später automatisierbar · Originalfotos sortieren, bearbeiten oder anonymisieren. Virtuelle Möblierung und Umbauvarianten als gekennzeichnete Visualisierungen erstellen. Grundrisse für die Ausgabe aufbereiten. Mehrsprachiges Exposé, Inserat, Webfassung, Video aus Aufnahmen, animierten Teaser, Besichtigungsmappe und Off-Market-Version aus demselben Dossier erstellen.)*
- *(Später automatisierbar · Freigegebene Fassungen über angebundene Kanäle publizieren, aktualisieren und nach Abschluss deaktivieren. Rückmeldungen dem Objekt zuordnen, Standardfragen aus dem Dossier beantworten und der Eigentümerschaft über Anfragen, Besichtigungen und Angebote berichten.)*

## Architektur

- Projekttypen für Sanierung, Umbau, Neubau, Erweiterung oder Aufstockung, Machbarkeitsstudie und energetische Sanierung. Eigentümer, Budget in CHF und GEAK-Entwicklung.
- Neun Projektphasen im Kanban. Anfrage → Machbarkeit → Vorprojekt → Bauprojekt → Bewilligung → Ausschreibung → Ausführung → Abnahme → Abgeschlossen.
- Checkliste und Fortschritt je Phase, aktuelle Phase blau hervorgehoben, BECK-PDF und berechtigtes Löschen. Die Anweisung enthält Phasenzahlen und Beispiele. Vollständige Prüfpunkte vor der fachlichen Abnahme ergänzen.

1. **Projekt erfassen** · «Neues Projekt» öffnen → Projekttyp, Eigentümer, Budget in CHF und GEAK-Stand oder Ziel erfassen → speichern. Das Projekt erscheint im Phasenboard und im Eigentümerkontakt.
2. **Phase bearbeiten** · Projektkarte öffnen → aktuelle Phase und Prüfpunkte ansehen → erledigte Punkte abhaken → Fortschritt im Detail und auf der Karte aktualisieren.
3. **Phase wechseln** · Nächste Phase im Projekt wählen → Karte wechselt die Spalte → die neue Phase ist blau markiert. Frühere Checklisten bleiben im Projekt einsehbar.
4. **Stand ausgeben** · «Checkliste drucken» → Vorschau mit Phase, Fortschritt und BECK-Briefkopf → als PDF ausgeben.

| Phase | Prüfpunkte laut Anweisung | Beispiele |
| --- | ---: | --- |
| Anfrage | 8 | Erstgespräch, Bestandsaufnahme, Zonenplan |
| Machbarkeit | 10 | GEAK, Varianten, Wirtschaftlichkeit, Honorarofferte |
| Vorprojekt | 9 | Pläne 1:200, Fassadenkonzept, Kostenschätzung |
| Bauprojekt | 10 | Pläne 1:100, Statik, Brandschutz, Kostenvoranschlag |
| Bewilligung | 8 | Baugesuch, Einsprachen, Baubewilligung |
| Ausschreibung | 8 | Offertspiegel, Werkverträge, Versicherungen |
| Ausführung | 12 | Baubeginn, Bausitzungen, Kostenstand, Mängel |
| Abnahme | 11 | Vorabnahme, Schlussrechnung, Garantien, Übergabe |
| Abgeschlossen | 4 | Honorar-Schlussrechnung, Archivierung, Garantiefristen |

- *(Später automatisierbar · Projekt aus einer Anfrage vorerfassen, Sitzungsnotizen in Beschlüsse und Aufgaben umwandeln, Offerten vergleichen, Belege mit Checklistenpunkten verknüpfen, Fristen erkennen und Projektstand oder Varianten visualisieren.)*

## Aufgaben und Erinnerungen

- Aufgaben mit Titel, Fälligkeit, Priorität, Zuständigkeit, Kontakt und Notiz. Filter für alle, offene, überfällige und erledigte Aufgaben. Erledigen per Checkbox, Löschen gemäss Berechtigung, Mitarbeiterfilter für Admins und rollenabhängige Sichtbarkeit.
- Geburtstage und Kaufjahrestage jährlich, freie Erinnerungen einmalig oder jährlich. Einmalige Erinnerungen abhaken, Kontakt optional, Quick-Mail und zeitabhängige Farbcodes.
- Schnell-Erfassung für Anruf, Mail, Besichtigung oder Notiz. Datum, Kontakt und Kurztext. Kontakt bei Namensgleichheit explizit aus der Trefferliste wählen.

| Vorgang | Bedienablauf und Ergebnis |
| --- | --- |
| **Aufgabe anlegen** | Unter «Aufgaben» oder beim Kontakt «Neue Aufgabe» wählen → Titel, Datum, Priorität (Normal/Hoch) und zuständigen Mitarbeiter setzen → Kontakt per Suche zuordnen und optional Notiz ergänzen → speichern. Die Aufgabe erscheint für den zuständigen Mitarbeiter. |
| **Aufgaben abarbeiten** | Nach «Alle», «Offen», «Überfällig» oder «Erledigt» filtern. Admins können zusätzlich nach Mitarbeitenden filtern. Checkbox umschalten → Status, Dashboard und Zähler aktualisieren sich. |
| **Erinnerung anlegen** | Unter «Erinnerungen» Datum, einmalig oder jährlich und bei Bedarf einen Kontakt wählen → speichern. Geburtstage und Kaufjahrestage erscheinen aus den hinterlegten Daten automatisch jährlich. |
| **Erinnerung bearbeiten** | Liste nach Fälligkeit ansehen. Rot bis 7 Tage, amber von 8 bis 14 Tagen, grün darüber. Einmalige Erinnerung abhaken oder bei einem Kontakt eine Quick-Mail öffnen. |
| **Schnell-Erfassung** | Schnellaktion auf der aktuellen Seite öffnen → Typ und Datum wählen → Kontakt aus der Vorschlagsliste auswählen → Kurznotiz speichern. Das Panel schliesst sich und der Eintrag ist im Kontaktverlauf sichtbar. |

- *(Später automatisierbar · Aus Mail oder Diktat Aufgaben und Fristen ableiten, Zuständige vorschlagen, Nachfassen vorbereiten, verfügbare Termine prüfen, Besichtigungen nach Bestätigung eintragen und Erinnerungen auslösen.)*

## Benutzer, Daten und Einstellungen

- **Login und Rollen** · BECK-Login mit Benutzerauswahl und Passwort. Admin mit Vollzugriff, Manager mit eingeschränktem Zugriff, Mitarbeiter mit Zugriff auf eigene Daten. Konten anlegen, aktivieren, deaktivieren und Passwörter setzen. Manager-Sichtbarkeit vor produktiver Umsetzung festlegen.
- **Berechtigungen** · GL-Kontakte sehen, Daten exportieren, Berechtigungen verwalten, Adressen drucken, Kontakte löschen und Gruppen-Mail senden. GL-Zugriff zusätzlich mit separatem Passwort. Abmelden über das Profilmenü.
- **Import und Export** · Excel- und CSV-Import mit Vorschau, Typzuordnung und Vorlage. Excel-Totalexport mit Berechtigung, JSON-Backup und Wiederherstellung, Erkennung früherer Datenbestände und Migrationshinweis.
- **Datenschutz** · Auskunftsexport, personenbezogene Löschung und Übersicht der Newsletter-Einwilligungen mit Erteilen und Widerrufen.
- **Einstellungen** · Firmendaten für Briefkopf und Absender, GL-Passwort, Backup und Migration sowie Demo-Reset für Admins.
- **Offene Betriebsfrage** · Einzelplatz mit lokaler Browserspeicherung oder gemeinsamer Datenbestand für mehrere Mitarbeitende. Daraus folgen Speicherung, Zugriffsprüfung und Betrieb späterer Hintergrundaufträge.

| Vorgang | Bedienablauf und Ergebnis |
| --- | --- |
| **Anmelden und abmelden** | Benutzer wählen → Passwort eingeben → Übersicht mit den für die Rolle sichtbaren Daten öffnen. Bei falscher Eingabe bleibt die Anmeldung geöffnet und zeigt eine kurze Meldung. «Abmelden» führt zurück zur Anmeldung. |
| **Benutzer verwalten** | Berechtigter Benutzer öffnet «Benutzer» → Konto anlegen oder öffnen → Rolle als Voreinstellung wählen → einzelne Berechtigungen setzen → Konto und Passwort speichern. Deaktivierte Konten können sich nicht anmelden. |
| **GL-Kontakte öffnen** | Ein berechtigter Benutzer öffnet den GL-Bereich → separates Passwort eingeben → vertrauliche Daten werden angezeigt. |
| **Kontakte importieren** | Excel- oder CSV-Datei wählen oder hineinziehen → Vorschau öffnen → Kontakttyp zuordnen → Datensätze prüfen und Import bestätigen → importierte Einträge in der Kontaktliste ansehen. Eine Excel-Vorlage steht beim Import bereit. |
| **Backup und Migration** | «Backup exportieren» lädt den Datenbestand als JSON herunter. Beim Wiederherstellen die JSON-Datei wählen und vor dem Einspielen prüfen. Erkannte Altbestände mit `beck_`, `beck3_` oder `beck4_` zeigen den Migrationshinweis. |
| **Auskunft oder Löschung** | Unter «Datenschutz» E-Mail-Adresse eingeben → betroffene Daten prüfen → JSON-Auskunft exportieren oder Löschung bestätigen. |
| **Einwilligung pflegen** | Kontakt in der Einwilligungsübersicht suchen → Newsletter-Einwilligung erteilen oder widerrufen → die Auswahl für Gruppen-Mails berücksichtigt den neuen Stand. |
| **Firmendaten und Reset** | Firmenname, Adresse, Telefon und E-Mail speichern → die Angaben stehen für Briefkopf und Absender bereit. Demo-Reset als Admin auswählen und bestätigen → der vorhandene Datenbestand wird durch Demo-Daten ersetzt. |

- *(Später automatisierbar · Rollenvorlagen und Übergaben vorschlagen, Importspalten zuordnen, Konflikte und Dubletten markieren, Auskunfts- und Löschanfragen zusammentragen und Regeln aus einer kurzen Anweisung vorbereiten.)*

## Durchgängige Abläufe für den Prototyp

| Fall | Weg durch das CRM | Sichtbares Ergebnis |
| --- | --- | --- |
| **Verkauf vom Erstkontakt bis zur Vermarktung** | Verkäufer anlegen → Mandat in «Erstkontakt» erfassen → Liegenschaft verknüpfen → über «Bewertung» und «Mandat» weiterführen → Dossier prüfen → Phase «In Vermarktung» setzen. | Mandatskarte und Objektstatus stimmen überein. Offene Dossierpunkte sind sichtbar. |
| **Passendes Objekt für einen Käufer** | Käuferprofil erfassen → Matching öffnen → Treffer mit Kriterien prüfen → Objektdetail öffnen → Exposé-Mail vorbereiten → Aufgabe zum Nachfassen anlegen. | Käufer, Objekt und Aufgabe sind auffindbar. Die Aufgabe erscheint für die zuständige Person. |
| **Architekturprojekt eines Eigentümers** | Eigentümer öffnen → Projekt anlegen → Prüfpunkte der aktuellen Phase bearbeiten → Phase wechseln → Checkliste als PDF ansehen. | Der Eigentümerkontakt zeigt das Projekt. Board und Checkliste zeigen den jeweiligen Stand. |
| **Anruf während der Arbeit erfassen** | Auf der aktuellen Seite Schnell-Erfassung öffnen → Anruf und Kontakt wählen → Kurznotiz speichern → im Kontaktverlauf prüfen. | Die ursprüngliche Seite bleibt offen. Der Anruf erscheint in der Historie und bei entsprechender Sichtbarkeit in den letzten Aktivitäten. |

## Spätere Erweiterungen

### Wenige zusätzliche Bedienelemente

| Ort | Ergänzung | Anzeige oder Ergebnis |
| --- | --- | --- |
| **Übersicht** | Eine Befehlszeile «Auftrag eingeben» | Kleine Liste mit «Läuft», «Erledigt» und «Zu prüfen». Klick führt direkt zur Vorschau oder zum Datensatz. |
| **Liegenschaft → Dossier** | Ein Menü «Erstellen» mit «Exposé erstellen» und «Unterlagenpaket erstellen» | Blätterbare Vorschau, Bildvergleich und markierte Lücken. Das Unterlagenpaket bündelt vorhandene Belege und neu erstellbare Unterlagen. Fehlende Nachweise erscheinen als offene Punkte. |
| **Einstellungen** | Ein Fenster «Automationen» | Verbindungen, Vorlagen, Auslöser und Regeln je Aktion. Einstellbar als Vorschlag, Ausführung nach Freigabe oder automatische Ausführung nach Regel. |

- **Vorschau im bestehenden Detailfenster** · Quelle, Änderung und Ergebnis nebeneinander. Freigeben, anpassen oder verwerfen. Bei Exposés die Seiten durchblättern und bei Bildern zwischen Original, Bearbeitung und gekennzeichneter Visualisierung wechseln.
- **Freigaben je Aktion** · Eindeutige Zuordnungen und interne Erinnerungen als Kandidaten für automatische Ausführung. Regeln für Standardmails gesondert festlegen. Publikation, Preisänderungen, verbindliche Zusagen, Massenversand, Löschungen und neue Zugriffsrechte zur Prüfung vorlegen.

| Spätere Aktion | Eingabe | Ablauf in der bestehenden Oberfläche |
| --- | --- | --- |
| **Exposé erstellen** | Liegenschaft, Sprache und BECK-Vorlage | Auftrag im Dossier starten → Vorschau der Seiten öffnen → fehlende Angaben ergänzen und Bildvarianten prüfen → Fassung freigeben. Das Exposé erscheint beim Objekt für den regulären Versand. |
| **Unterlagenpaket erstellen** | Liegenschaft und Zweck, etwa Besichtigung oder Off-Market-Versand | Vorhandene Dokumente und erstellbare Unterlagen im Dossier sichten → fehlende Nachweise als offene Punkte anzeigen → Ausgabe auswählen und freigeben. |
| **Posteingang aufarbeiten** | Ein Auftrag im Dashboard oder eine später eingerichtete Regel | Zuordnungen, interne Aufgaben und Entwürfe im bestehenden Verlauf anzeigen → uneindeutige Fälle unter «Zu prüfen» öffnen → vorgeschlagene Änderung am betreffenden Datensatz prüfen. |

### Voraussetzungen im CRM

- **Verknüpfte Datensätze** · Stabile IDs für Kontakt, Suchprofil, Mandat, Liegenschaft, Projekt, Aufgabe, Aktivität und Dokument. Eindeutige Zuständigkeit und nachvollziehbare Rollen und Beziehungen.
- **Objektdaten und Medien** · Bestätigte Fakten mit Quelle, Originaldateien, getrennte Bildvarianten und Kennzeichnung von Visualisierungen. Flächen, Masse und Zustand aus Belegen übernehmen. Exposés, Inserate und Publikationen nach Fassung und Kanal speichern.
- **Vorlagen und Vorschau** · BECK-Layouts, Platzhalter, Sprachfassungen und Ausgaben je Kanal. Fehlende Felder markieren. Freigegebene Fassungen nachvollziehbar halten, wenn sich Objektdaten ändern.
- **Gemeinsame Aktionen** · Funktionen wie «Aufgabe anlegen», «Dokument zuordnen» und «Mandatsphase ändern» aus Formularen und späteren Aufträgen gleich aufrufen. Eingaben, Berechtigungen und Freigaben bei der Ausführung prüfen. Zugriffsschutz auch bei Suche und Zusammenfassungen anwenden.
- **Hintergrundaufträge** · Auslöser durch Befehl, Zeitplan oder Ereignis. Quelle, Ziel, Status und Ergebnis im Verlauf speichern. Wiederholungen so erkennen, dass Aufgaben, Mails und Publikationen nur einmal ausgelöst werden.
- **Anbindungen je Ablauf** · Autorisierter Zugriff auf Outlook und Kalender, Ablage für Originale und Fassungen, später bei Bedarf Dienste für Dokument-, Sprach- oder Medienverarbeitung und freigegebene Publikationskanäle. Speicherort und Datenzugriff vor der produktiven Anbindung klären.
