[English](README.md) | [Français](README.fr.md) | **Deutsch** | [Español](README.es.md) | [Italiano](README.it.md) | [Polski](README.pl.md) | [Română](README.ro.md) | [Lietuvių](README.lt.md)

# Money Converter

Währungsrechner auf Grundlage der
[Euro-Referenzkurse der Europäischen Zentralbank](https://www.ecb.europa.eu/stats/policy_and_exchange_rates/euro_reference_exchange_rates/html/index.de.html),
die an jedem Arbeitstag gegen 16:00 Uhr MEZ als Open Data veröffentlicht werden.

Flutter-App: Android, iOS, Web, Windows und Linux aus einer einzigen Codebasis.

## Funktionen

- Live-Umrechnung während der Eingabe zwischen allen von der EZB veröffentlichten Währungen (plus Euro).
- Währungen mit festem Kurs zum Euro, die die EZB nicht veröffentlicht: Kap-Verde-Escudo (CVE), CFA-Franc (XOF, XAF), Komoren-Franc (KMF), CFP-Franc (XPF), Konvertible Mark (BAM) und Dobra (STN). Ihre Kurse ergeben sich aus der offiziellen Parität und den EZB-Kursen des Tages (`lib/models/euro_pegs.dart`).
- Währungspaar tauschen, Währung nach Code oder Name suchen.
- Kurse des Tages und ein Diagramm der vergangenen Werte (1 Woche, 1 Monat, 3 Monate); ein Tippen auf das Diagramm zeigt den Wert eines Tages.
- Funktioniert offline mit den zuletzt gespeicherten Kursen.
- SVG-Flaggen (Paket `country_flags`), auf allen Plattformen sichtbar, auch unter Windows und Linux.
- Englisch, Französisch, Deutsch, Spanisch, Italienisch, Polnisch, Rumänisch und Litauisch: standardmäßig die Gerätesprache (Englisch, wenn sie nicht übersetzt ist), in der App änderbar und gespeichert; helles und dunkles Design.

Datenschutzerklärung (von den Stores verlangt): `site/privacy.html`, veröffentlicht unter https://juadde.github.io/money_converter/privacy.html.

## Woher die Kurse kommen

1. **Direkt von der EZB**: `eurofxref-hist-90d.xml` (90 Tage, also die Kurse des Tages und der Verlauf in einer Anfrage).
2. **Ersatz**: `rates.json`, eine JSON-Kopie derselben Datei, vom Workflow `Deploy` neu erstellt und von GitHub Pages neben der Web-App bereitgestellt.
3. **Lokaler Cache**: die letzte Antwort, eine Stunde lang wiederverwendet, danach als letzter Ausweg, wenn kein Netz verfügbar ist.

Der EZB-Server sendet keinen CORS-Header, daher kann ein Browser das XML nicht lesen. Die Web-Version liest deshalb direkt `rates.json` (gleicher Ursprung).

Die Ersatz-URL lässt sich beim Build ändern:

```sh
flutter run --dart-define=RATES_FALLBACK_URL=https://example.org/rates.json
```

## Entwicklung

Die Ordner `android/`, `ios/`, `web/`, `windows/` und `linux/` sind nicht versioniert: Ein Skript erzeugt sie mit `flutter create` und wendet die nötigen Einstellungen an (Internet-Berechtigung, App-Name, Symbole).

```sh
bash tool/bootstrap_platforms.sh
flutter pub get
flutter test
flutter run
```

Für die Web-Version lokal braucht es eine `rates.json` neben der App oder eine Ersatz-URL:

```sh
python3 tool/ecb_to_json.py --output web/rates.json
flutter run -d chrome
```

## Symbol

Das Symbol (ein grüner Geldschein) ist als SVG in `assets/icon/` gezeichnet. Nach einer Änderung die PNGs und danach die Plattform-Symbole neu erzeugen:

```sh
rsvg-convert -w 1024 -h 1024 assets/icon/bill.svg -o assets/icon/icon.png
rsvg-convert -w 1024 -h 1024 assets/icon/bill_foreground.svg -o assets/icon/icon_foreground.png
dart run flutter_launcher_icons
```

## Aufbau des Codes

| Ordner | Inhalt |
| --- | --- |
| `lib/models` | Kurse eines Tages, Momentaufnahme, Verlauf eines Paares, Euro-Paritäten |
| `lib/data` | Einlesen des EZB-XML und des JSON, HTTP-Quellen, Cache, Repository mit Ersatz |
| `lib/state` | Riverpod-Provider (Kurse, gespeichertes Paar, Betrag und Sprache) |
| `lib/ui` | Hauptbildschirm, Währungsauswahl, Diagramm, Flaggen |
| `lib/l10n` | Texte in den 8 Sprachen |
| `screenshots` | Erzeugung der Store-Screenshots |
| `fastlane/metadata/android` | Google-Play-Eintrag in den 8 Sprachen |
| `site` | Seite der Datenschutzerklärung |
| `tool` | Erzeugung der Plattformen, EZB-XML zu JSON, Store-Grafiken und -Prüfungen |
| `assets/icon` | App-Symbol (SVG-Quellen und PNG mit 1024 px) |

## Kontinuierliche Integration und Bereitstellung

- **CI** (`.github/workflows/ci.yml`), bei jedem PR und jedem Push auf `main`: Analyse, Tests, Prüfung des Store-Eintrags, Web-Build. Der APK-Build ist vorerst deaktiviert (`if: false`).
- **Desktop** (`.github/workflows/desktop.yml`): Linux-Snap und Windows-MSIX-Paket bei jedem Push auf `main`, nach Aktivierung im Snap Store und im Microsoft Store veröffentlicht (siehe „Windows und Linux“).
- **Play Store** (`.github/workflows/play-store.yml`): signiertes Android-Bundle und Store-Eintrag, nach Aktivierung bei jedem Push auf `main` an Google Play gesendet (siehe „Play Store“).
- **Deploy** (`.github/workflows/deploy.yml`):
  - bei jedem Push auf `main`: Web-App und Datenschutzerklärung auf GitHub Pages. Das APK-Release und der iOS-Build sind vorerst deaktiviert (`if: false`);
  - an jedem Arbeitstag nach der EZB-Veröffentlichung: erneute Web-Bereitstellung mit aktueller `rates.json`.

### Einmalige Einstellungen auf GitHub

- **Pages**: Settings → Pages → Source: „GitHub Actions“. Bei einem privaten Repository erfordert Pages ein kostenpflichtiges Abo; sonst muss das Repository öffentlich sein.
- **Android**: Das APK des Release `latest` (deaktiviert) ist mit einem Debug-Schlüssel signiert. Die Play-Store-Builds werden mit dem Upload-Schlüssel signiert (siehe unten).
- **iOS**: Der Build ist nicht signiert. Eine Veröffentlichung über TestFlight oder den App Store erfordert ein Apple-Developer-Konto und dessen Zertifikate als Secrets.

## Play Store

Der Workflow `Play Store` erstellt ein mit dem Upload-Schlüssel signiertes Android App Bundle (`.aab`) und veröffentlicht es mit [fastlane](https://docs.fastlane.tools/actions/upload_to_play_store/) bei Google Play, zusammen mit dem vollständigen Store-Eintrag: Texte, Neuerungen, Symbol, Vorstellungsgrafik und Screenshots. Der `versionCode` ist die Laufnummer des Workflows und steigt daher bei jedem Upload. Die App-ID ist `com.juadde.moneyconverter`; sie lässt sich nicht mehr ändern, sobald die App bei Google Play angelegt ist.

| Auslöser | Was passiert |
| --- | --- |
| Push auf `main` | Nichts, solange die Variable `PLAY_STORE_ENABLED` nicht `true` ist; danach Upload in den Track `PLAY_TRACK` (standardmäßig `internal`) |
| Manueller Start (Tab Actions) | Build und Upload in den gewählten Track; ohne Dienstkonto steht das Bundle nur als Artefakt des Laufs bereit |
| PR, der den Workflow, das Skript oder den Eintrag ändert | Testlauf mit Wegwerfschlüssel, nichts wird hochgeladen |

### Eintrag im Play Store

Der gesamte Eintrag liegt im Repository und wird mit jeder Version veröffentlicht, für die 8 Sprachen (`fastlane/metadata/android/<sprache>/`):

| Datei | Inhalt | Grenze |
| --- | --- | --- |
| `title.txt` | App-Name | 30 Zeichen |
| `short_description.txt` | Kurzbeschreibung | 80 Zeichen |
| `full_description.txt` | Vollständige Beschreibung | 4.000 Zeichen |
| `changelogs/default.txt` | Neuerungen der Version („What's new“) | 500 Zeichen |
| `images/icon.png`, `images/featureGraphic.png` | Symbol mit 512 px und Vorstellungsgrafik 1024 × 500 (`tool/store_graphics.py`) | |
| `images/phoneScreenshots/` | 4 Screenshots 1080 × 1920, bei jeder Veröffentlichung von `screenshots/screenshots_test.dart` mit den EZB-Kursen des Tages **erzeugt** | |

`tool/check_store_metadata.py` prüft die Grenzen (von der CI ausgeführt). Screenshots lokal ansehen:

```sh
python3 tool/ecb_to_json.py --output screenshots/rates.json
flutter test --update-goldens screenshots/
```

### Einrichtung (einmalig)

1. **Upload-Schlüssel.** Auf Ihrem Computer (mit installiertem Java):

   ```sh
   keytool -genkeypair -v -keystore upload-keystore.jks -alias upload \
     -keyalg RSA -keysize 2048 -validity 10000
   base64 -w0 upload-keystore.jks   # macOS: base64 -i upload-keystore.jks
   ```

   Bewahren Sie die `.jks`-Datei und ihre Passwörter sicher außerhalb des Repositorys auf. Vermeiden Sie Backslashes in den Passwörtern.

2. **GitHub-Secrets** (Settings → Secrets and variables → Actions → Secrets):
   `ANDROID_KEYSTORE_BASE64` (Ausgabe von `base64`), `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS` (`upload`), `ANDROID_KEY_PASSWORD` (optional, wenn identisch mit dem Keystore-Passwort).

3. **App in der Play Console**: App anlegen, Eintrag und Fragebögen ausfüllen (Inhalt, Datenschutz …), dann die App-Signatur durch Google Play aktivieren.

4. **Erster Upload von Hand** (von Google verlangt): den Workflow `Play Store` im Tab Actions starten, das Artefakt `moneyconverter-aab-…` herunterladen und in der Play Console im Track „Interner Test“ hochladen.

5. **Dienstkonto** für automatische Uploads: in Google Cloud ein Dienstkonto und einen JSON-Schlüssel erstellen, die Google Play Android Developer API aktivieren und die Adresse des Dienstkontos in der Play Console (Nutzer und Berechtigungen) mit dem Recht einladen, in Test-Tracks zu veröffentlichen. Den JSON-Inhalt im Secret `PLAY_SERVICE_ACCOUNT_JSON` speichern.

6. **Automatische Uploads aktivieren** (Settings → Secrets and variables → Actions → Variables):
   - `PLAY_STORE_ENABLED` = `true`
   - `PLAY_TRACK` (optional): `internal`, `alpha` (geschlossener Test), `beta` (offener Test) oder `production`
   - `PLAY_RELEASE_STATUS` (optional): standardmäßig `completed`; `draft` verwenden, solange die App nie veröffentlicht wurde, sonst lehnt Google den Upload ab.

### Gut zu wissen

- Bei einem privaten Entwicklerkonto, das nach dem 13. November 2023 erstellt wurde, verlangt Google vor der Freigabe der Produktion einen geschlossenen Test mit mindestens 12 Testern, die 14 Tage am Stück angemeldet sind. Interne Tests zählen nicht: Verwenden Sie für diesen geschlossenen Test den Track `alpha`.
- Die Android-Builds in `ci.yml` und `deploy.yml` bleiben deaktiviert; dieser Workflow ist davon unabhängig.

## Windows und Linux

Der Workflow `Desktop` erstellt bei jedem Push auf `main` (oder manuell im Tab Actions):

- **Linux**: einen Snap (`money-converter-ecb`, Basis `core24`, GNOME-Erweiterung);
- **Windows**: ein MSIX-Paket für den Microsoft Store.

Beide Pakete stehen immer als Artefakte des Laufs bereit. Die Veröffentlichung folgt derselben Logik wie beim Play Store:

| Auslöser | Snap Store | Microsoft Store |
| --- | --- | --- |
| Push auf `main` | Wenn die Variable `SNAP_STORE_ENABLED` `true` ist | Wenn die Variable `MSSTORE_ENABLED` `true` ist |
| Manueller Start (Tab Actions) | Wenn die Zugangsdaten hinterlegt sind | Wenn die Zugangsdaten hinterlegt sind |
| PR, der die Paketierung betrifft | Nie (nur Build) | Nie (nur Build) |

### Snap Store (einmalig)

1. Ein Konto auf [snapcraft.io](https://snapcraft.io) anlegen und den Namen registrieren: `snapcraft register money-converter-ecb`. Ist der Name vergeben, einen anderen wählen und ihn in `snap/snapcraft.yaml` ändern (Feld `name`, App-Name und Name der `.desktop`-Datei in `snap/gui/`).
2. Zugangsdaten für die CI erzeugen:

   ```sh
   snapcraft export-login --snaps=money-converter-ecb --acls=package_access,package_push,package_update,package_release -
   ```

3. Die Ausgabe im Secret `SNAPCRAFT_STORE_CREDENTIALS` speichern.
4. Automatische Veröffentlichung aktivieren: Variable `SNAP_STORE_ENABLED` = `true`.
5. Optional: Die Variable `SNAP_CHANNEL` wählt den Kanal (standardmäßig `edge`, dann `beta`, `candidate` oder `stable`).

### Microsoft Store (einmalig)

1. Ein Entwicklerkonto im [Partner Center](https://partner.microsoft.com/dashboard) haben und dort den App-Namen reservieren.
2. Auf der Seite der App unter „Produktidentität“ in GitHub-**Variablen** übernehmen:
   - `MSSTORE_IDENTITY_NAME` (Package/Identity/Name)
   - `MSSTORE_PUBLISHER` (Package/Identity/Publisher, in der Form `CN=…`)
   - `MSSTORE_PUBLISHER_DISPLAY_NAME` (Package/Properties/PublisherDisplayName)
   - `MSSTORE_PRODUCT_ID` (Store-ID, 12 Zeichen)
3. Die **erste Einreichung von Hand** vornehmen (von Microsoft verlangt): den Workflow `Desktop` starten, das Artefakt `moneyconverter-msix-…` herunterladen und in einer Partner-Center-Einreichung hochladen, mit Eintrag, Screenshots und Altersfreigabe.
4. Ein Microsoft-Entra-ID-Verzeichnis (Azure AD) mit dem Partner-Center-Konto verknüpfen, dort eine Anwendung mit der Rolle „Manager“ erstellen und dann in GitHub-**Secrets** speichern: `PARTNER_CENTER_TENANT_ID`, `PARTNER_CENTER_SELLER_ID`, `PARTNER_CENTER_CLIENT_ID`, `PARTNER_CENTER_CLIENT_SECRET`.
5. Automatische Veröffentlichung aktivieren: Variable `MSSTORE_ENABLED` = `true`.

Danach erstellt und sendet jeder Push auf `main` eine neue Einreichung (Version `2.0.<Laufnummer>.0`).

## Lizenz

Copyright (C) 2026 Julien Addé

Dieses Programm ist freie Software: Sie können es unter den Bedingungen der GNU General Public License, wie von der Free Software Foundation veröffentlicht, weitergeben und/oder verändern, entweder gemäß Version 3 der Lizenz oder (nach Ihrer Wahl) jeder späteren Version (`GPL-3.0-or-later`).

Dieses Programm wird in der Hoffnung verbreitet, dass es nützlich ist, aber OHNE JEDE GEWÄHRLEISTUNG, sogar ohne die implizite Gewährleistung der MARKTREIFE oder der EIGNUNG FÜR EINEN BESTIMMTEN ZWECK. Weitere Einzelheiten in der Datei [LICENSE](LICENSE). Rechtlich verbindlich ist allein der englische Lizenztext.
