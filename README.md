# BeckCRM

[Web-Demo auf GitHub Pages](https://liviomag.github.io/beck-crm/)

Klickbarer Flutter-Web-Prototyp mit fiktiven Daten. Änderungen gelten für die
aktuelle Browsersitzung bis zum Neuladen. Versand, Druck und Excel-Abläufe
verwenden Demo-Vorschauen.

```sh
flutter pub get
flutter run -d chrome
```

Die Demo startet in der Übersicht als Livio Beck (Admin). Im Profilmenü unter
«Abmelden» kann man auch Mara Keller (Manager) oder Noah Frei (Mitarbeiter)
ausprobieren. Das Demo-Passwort für die Startkonten und den GL-Bereich ist
`beck`.

- **Verkauf** · Jonas Schmid öffnen, Mandat bearbeiten und den Objektstatus im Dossier prüfen.
- **Matching** · Anna Meier öffnen, «Matching» wählen und das Exposé der Wohnung am Lindenweg mit Outlook-Vorschau und Nachfassaufgabe durchspielen.
- **Architektur** · Villa Seehof öffnen, Checkliste und Phase ändern und die Druckvorschau ansehen.
- **Schnell-Erfassung** · Einen Anruf erfassen und im Kontaktverlauf prüfen.

Für die Veröffentlichung unter **Settings → Pages → Source** einmalig
**GitHub Actions** auswählen. Der Workflow **Deploy BeckCRM to GitHub Pages**
baut und veröffentlicht die Demo bei Änderungen auf `main` und lässt sich
unter **Actions** auch manuell starten.
