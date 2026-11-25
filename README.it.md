[English](README.md) | [Français](README.fr.md) | [Deutsch](README.de.md) | [Español](README.es.md) | **Italiano** | [Polski](README.pl.md) | [Română](README.ro.md) | [Lietuvių](README.lt.md)

# Money Converter

Convertitore di valute basato sui
[tassi di cambio di riferimento dell'euro della Banca centrale europea](https://www.ecb.europa.eu/stats/policy_and_exchange_rates/euro_reference_exchange_rates/html/index.it.html),
pubblicati come open data ogni giorno lavorativo verso le 16:00 (CET).

App Flutter: Android, iOS, web, Windows e Linux con un unico codice sorgente.

## Funzionalità

- Conversione istantanea durante la digitazione, tra tutte le valute pubblicate dalla BCE (più l'euro).
- Valute a parità fissa con l'euro, che la BCE non pubblica: escudo capoverdiano (CVE), franchi CFA (XOF, XAF), franco delle Comore (KMF), franco CFP (XPF), marco convertibile bosniaco (BAM) e dobra (STN). I loro tassi derivano dalla parità ufficiale e dai tassi BCE del giorno (`lib/models/euro_pegs.dart`).
- Inversione della coppia, ricerca di una valuta per codice o per nome.
- Tassi del giorno e grafico dei valori passati (1 settimana, 1 mese, 3 mesi); toccando il grafico si vede il valore di un giorno.
- Funziona offline con gli ultimi tassi salvati.
- Bandiere in SVG (pacchetto `country_flags`), visibili su tutte le piattaforme, Windows e Linux compresi.
- Inglese, francese, tedesco, spagnolo, italiano, polacco, rumeno e lituano: lingua del dispositivo per impostazione predefinita (inglese se non è tradotta), modificabile nell'app e memorizzata; tema chiaro e scuro.

Informativa sulla privacy (richiesta dagli store): `site/privacy.html`, pubblicata su https://juadde.github.io/money_converter/privacy.html.

## Da dove vengono i tassi

1. **BCE, direttamente**: `eurofxref-hist-90d.xml` (90 giorni, quindi i tassi del giorno e lo storico in una sola richiesta).
2. **Riserva**: `rates.json`, una copia JSON dello stesso file, rigenerata dal workflow `Deploy` e servita da GitHub Pages accanto all'app web.
3. **Cache locale**: l'ultima risposta, riutilizzata per un'ora e poi come ultima risorsa se la rete non è disponibile.

Il server della BCE non invia l'intestazione CORS, quindi un browser non può leggerne l'XML. La versione web legge perciò direttamente `rates.json` (stessa origine).

L'URL di riserva si può cambiare in fase di build:

```sh
flutter run --dart-define=RATES_FALLBACK_URL=https://example.org/rates.json
```

## Sviluppo

Le cartelle `android/`, `ios/`, `web/`, `windows/` e `linux/` non sono versionate: uno script le genera con `flutter create` e applica le impostazioni necessarie all'app (permesso Internet, nome dell'app, icone).

```sh
bash tool/bootstrap_platforms.sh
flutter pub get
flutter test
flutter run
```

Per avviare la versione web in locale serve un `rates.json` accanto all'app, oppure un URL di riserva:

```sh
python3 tool/ecb_to_json.py --output web/rates.json
flutter run -d chrome
```

## Icona

L'icona (una banconota verde) è disegnata in SVG in `assets/icon/`. Dopo una modifica, rigenerare i PNG e poi le icone delle piattaforme:

```sh
rsvg-convert -w 1024 -h 1024 assets/icon/bill.svg -o assets/icon/icon.png
rsvg-convert -w 1024 -h 1024 assets/icon/bill_foreground.svg -o assets/icon/icon_foreground.png
dart run flutter_launcher_icons
```

## Organizzazione del codice

| Cartella | Contenuto |
| --- | --- |
| `lib/models` | Tassi di un giorno, istantanea, storico di una coppia, parità con l'euro |
| `lib/data` | Lettura dell'XML della BCE e del JSON, sorgenti HTTP, cache, repository con riserva |
| `lib/state` | Provider Riverpod (tassi, coppia, importo e lingua memorizzati) |
| `lib/ui` | Schermata principale, selettore di valuta, grafico, bandiere |
| `lib/l10n` | Testi nelle 8 lingue |
| `screenshots` | Generazione degli screenshot per gli store |
| `fastlane/metadata/android` | Scheda di Google Play nelle 8 lingue |
| `site` | Pagina dell'informativa sulla privacy |
| `tool` | Generazione delle piattaforme, XML della BCE in JSON, grafiche e controlli degli store |
| `assets/icon` | Icona dell'app (sorgenti SVG e PNG da 1024 px) |

## Integrazione e distribuzione continue

- **CI** (`.github/workflows/ci.yml`), a ogni PR e a ogni push su `main`: analisi, test, controllo della scheda dello store, build web. La build dell'APK è disattivata per ora (`if: false`).
- **Desktop** (`.github/workflows/desktop.yml`): snap Linux e pacchetto MSIX Windows a ogni push su `main`, pubblicati su Snap Store e Microsoft Store una volta attivati (vedi «Windows e Linux»).
- **Play Store** (`.github/workflows/play-store.yml`): bundle Android firmato e scheda dello store, inviati a Google Play a ogni push su `main` una volta attivato (vedi «Play Store»).
- **Deploy** (`.github/workflows/deploy.yml`):
  - a ogni push su `main`: app web e informativa sulla privacy su GitHub Pages. La release dell'APK e la build iOS sono disattivate per ora (`if: false`);
  - ogni giorno lavorativo dopo la pubblicazione della BCE: nuova distribuzione web con un `rates.json` aggiornato.

### Impostazioni una tantum su GitHub

- **Pages**: Settings → Pages → Source: «GitHub Actions». Su un repository privato, Pages richiede un piano a pagamento; altrimenti il repository deve essere pubblico.
- **Android**: l'APK della release `latest` (disattivata) è firmato con una chiave di debug. Le build del Play Store sono firmate con la chiave di caricamento (vedi sotto).
- **iOS**: la build non è firmata. Una pubblicazione su TestFlight o App Store richiede un account Apple Developer e i relativi certificati come secret.

## Play Store

Il workflow `Play Store` crea un Android App Bundle (`.aab`) firmato con la chiave di caricamento e lo pubblica su Google Play con [fastlane](https://docs.fastlane.tools/actions/upload_to_play_store/), insieme alla scheda completa: testi, novità, icona, grafica in primo piano e screenshot. Il `versionCode` è il numero di esecuzione del workflow, quindi aumenta a ogni caricamento. L'ID dell'app è `com.juadde.moneyconverter`; non può più cambiare una volta creata l'app su Google Play.

| Attivazione | Cosa succede |
| --- | --- |
| Push su `main` | Niente finché la variabile `PLAY_STORE_ENABLED` non vale `true`; poi caricamento sul canale `PLAY_TRACK` (`internal` per impostazione predefinita) |
| Avvio manuale (scheda Actions) | Build e caricamento sul canale scelto; senza account di servizio il bundle è disponibile solo come artefatto dell'esecuzione |
| PR che modifica il workflow, lo script o la scheda | Prova con una chiave usa e getta, non viene caricato nulla |

### Scheda del Play Store

L'intera scheda è nel repository e viene pubblicata con ogni versione, per le 8 lingue (`fastlane/metadata/android/<lingua>/`):

| File | Contenuto | Limite |
| --- | --- | --- |
| `title.txt` | Nome dell'app | 30 caratteri |
| `short_description.txt` | Descrizione breve | 80 caratteri |
| `full_description.txt` | Descrizione completa | 4000 caratteri |
| `changelogs/default.txt` | Novità della versione («What's new») | 500 caratteri |
| `images/icon.png`, `images/featureGraphic.png` | Icona da 512 px e grafica in primo piano 1024 × 500 (`tool/store_graphics.py`) | |
| `images/phoneScreenshots/` | 4 screenshot 1080 × 1920, **generati** a ogni pubblicazione da `screenshots/screenshots_test.dart` con i tassi BCE del giorno | |

`tool/check_store_metadata.py` controlla i limiti (eseguito dalla CI). Per vedere gli screenshot in locale:

```sh
python3 tool/ecb_to_json.py --output screenshots/rates.json
flutter test --update-goldens screenshots/
```

### Configurazione (una sola volta)

1. **Chiave di caricamento.** Sul tuo computer (con Java installato):

   ```sh
   keytool -genkeypair -v -keystore upload-keystore.jks -alias upload \
     -keyalg RSA -keysize 2048 -validity 10000
   base64 -w0 upload-keystore.jks   # macOS: base64 -i upload-keystore.jks
   ```

   Conserva il file `.jks` e le relative password in un luogo sicuro, fuori dal repository. Evita le barre rovesciate nelle password.

2. **Secret di GitHub** (Settings → Secrets and variables → Actions → Secrets):
   `ANDROID_KEYSTORE_BASE64` (output di `base64`), `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS` (`upload`), `ANDROID_KEY_PASSWORD` (facoltativo se coincide con la password del keystore).

3. **App in Play Console**: creare l'app, compilare la scheda e i questionari (contenuti, privacy…), poi attivare la firma delle app di Google Play.

4. **Primo caricamento a mano** (richiesto da Google): avviare il workflow `Play Store` dalla scheda Actions, scaricare l'artefatto `moneyconverter-aab-…` e caricarlo in Play Console sul canale «Test interno».

5. **Account di servizio** per i caricamenti automatici: in Google Cloud, creare un account di servizio e una chiave JSON, attivare l'API Google Play Android Developer, poi invitare l'indirizzo dell'account di servizio in Play Console (Utenti e autorizzazioni) con il permesso di pubblicare sui canali di test. Inserire il contenuto del JSON nel secret `PLAY_SERVICE_ACCOUNT_JSON`.

6. **Attivare i caricamenti automatici** (Settings → Secrets and variables → Actions → Variables):
   - `PLAY_STORE_ENABLED` = `true`
   - `PLAY_TRACK` (facoltativo): `internal`, `alpha` (test chiuso), `beta` (test aperto) o `production`
   - `PLAY_RELEASE_STATUS` (facoltativo): `completed` per impostazione predefinita; usare `draft` finché l'app non è mai stata pubblicata, altrimenti Google rifiuta il caricamento.

### Da sapere

- Su un account sviluppatore personale creato dopo il 13 novembre 2023, Google richiede un test chiuso con almeno 12 tester iscritti per 14 giorni consecutivi prima di aprire la produzione. I test interni non contano: usa il canale `alpha` per questo test chiuso.
- **«Firmato con la chiave sbagliata» in Play Console**: confrontare le impronte mostrate nel riepilogo dell'esecuzione («Android bundle signature») con Play Console → Test e release → Integrità dell'app → Certificato della chiave di caricamento. Caricare solo gli artefatti `moneyconverter-aab-…`: i `dry-run-do-not-upload-aab-…` provengono dalle pull request e sono firmati con una chiave usa e getta. Se la chiave registrata presso Google non è la tua, richiedi lì il ripristino della chiave di caricamento con il certificato esportato da `keytool -export -rfc -keystore upload-keystore.jks -alias upload -file upload_certificate.pem`.
- Le build Android di `ci.yml` e `deploy.yml` restano disattivate; questo workflow è indipendente.

## Windows e Linux

Il workflow `Desktop` crea, a ogni push su `main` (o a mano dalla scheda Actions):

- **Linux**: uno snap (`money-converter-ecb`, base `core24`, estensione GNOME);
- **Windows**: un pacchetto MSIX per il Microsoft Store.

Entrambi i pacchetti sono sempre disponibili come artefatti dell'esecuzione. La pubblicazione segue la stessa logica del Play Store:

| Attivazione | Snap Store | Microsoft Store |
| --- | --- | --- |
| Push su `main` | Se la variabile `SNAP_STORE_ENABLED` vale `true` | Se la variabile `MSSTORE_ENABLED` vale `true` |
| Avvio manuale (scheda Actions) | Se le credenziali sono impostate | Se le credenziali sono impostate |
| PR che riguarda il pacchetto | Mai (solo build) | Mai (solo build) |

### Snap Store (una sola volta)

1. Creare un account su [snapcraft.io](https://snapcraft.io) e registrare il nome: `snapcraft register money-converter-ecb`. Se il nome è occupato, sceglierne un altro e cambiarlo in `snap/snapcraft.yaml` (campo `name`, nome dell'app e nome del file `.desktop` in `snap/gui/`).
2. Generare le credenziali per la CI:

   ```sh
   snapcraft export-login --snaps=money-converter-ecb --acls=package_access,package_push,package_update,package_release -
   ```

3. Inserire l'output nel secret `SNAPCRAFT_STORE_CREDENTIALS`.
4. Attivare la pubblicazione automatica: variabile `SNAP_STORE_ENABLED` = `true`.
5. Facoltativo: la variabile `SNAP_CHANNEL` sceglie il canale (`edge` per impostazione predefinita, poi `beta`, `candidate` o `stable`).

### Microsoft Store (una sola volta)

1. Avere un account sviluppatore in [Partner Center](https://partner.microsoft.com/dashboard) e riservarvi il nome dell'app.
2. Nella pagina dell'app, «Identità del prodotto», copiare nelle **variabili** di GitHub:
   - `MSSTORE_IDENTITY_NAME` (Package/Identity/Name)
   - `MSSTORE_PUBLISHER` (Package/Identity/Publisher, nella forma `CN=…`)
   - `MSSTORE_PUBLISHER_DISPLAY_NAME` (Package/Properties/PublisherDisplayName)
   - `MSSTORE_PRODUCT_ID` (Store ID, 12 caratteri)
3. Fare il **primo invio a mano** (richiesto da Microsoft): avviare il workflow `Desktop`, scaricare l'artefatto `moneyconverter-msix-…` e caricarlo in un invio di Partner Center, con la scheda, gli screenshot e la classificazione per età.
4. Associare una directory Microsoft Entra ID (Azure AD) all'account Partner Center, crearvi un'applicazione con il ruolo «Manager» e poi inserire nei **secret** di GitHub: `PARTNER_CENTER_TENANT_ID`, `PARTNER_CENTER_SELLER_ID`, `PARTNER_CENTER_CLIENT_ID`, `PARTNER_CENTER_CLIENT_SECRET`.
5. Attivare la pubblicazione automatica: variabile `MSSTORE_ENABLED` = `true`.

Da quel momento, ogni push su `main` crea e invia un nuovo invio (versione `2.0.<numero di esecuzione>.0`).

## Licenza

Copyright (C) 2026 Julien Addé

Questo programma è software libero: è possibile ridistribuirlo e/o modificarlo secondo i termini della GNU General Public License pubblicata dalla Free Software Foundation, nella versione 3 della licenza o (a propria scelta) in qualsiasi versione successiva (`GPL-3.0-or-later`).

Questo programma è distribuito nella speranza che sia utile, ma SENZA ALCUNA GARANZIA, nemmeno la garanzia implicita di COMMERCIABILITÀ o IDONEITÀ PER UN PARTICOLARE SCOPO. Vedere il file [LICENSE](LICENSE) per maggiori dettagli. Fa fede solo il testo inglese della licenza.
