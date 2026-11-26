[English](README.md) | [Français](README.fr.md) | [Deutsch](README.de.md) | [Español](README.es.md) | [Italiano](README.it.md) | [Polski](README.pl.md) | **Română** | [Lietuvių](README.lt.md)

# Money Converter

Convertor valutar bazat pe
[cursurile de schimb de referință ale euro publicate de Banca Centrală Europeană](https://www.ecb.europa.eu/stats/policy_and_exchange_rates/euro_reference_exchange_rates/html/index.ro.html),
puse la dispoziție ca date deschise în fiecare zi lucrătoare în jurul orei 16:00 CET.

Aplicație Flutter: Android, iOS, web, Windows și Linux dintr-o singură bază de cod.

## Funcționalități

- Conversie în timp real pe măsură ce tastezi, între toate valutele publicate de BCE (plus euro).
- Valute cu paritate fixă față de euro, pe care BCE nu le publică: escudo capverdian (CVE), francii CFA (XOF, XAF), francul comorian (KMF), francul CFP (XPF), marca convertibilă bosniacă (BAM) și dobra (STN). Cursurile lor provin din paritatea oficială și din cursurile BCE ale zilei (`lib/models/euro_pegs.dart`).
- Inversarea perechii, căutarea unei valute după cod sau după nume.
- Cursurile zilei și un grafic al valorilor anterioare (1 săptămână, 1 lună, 3 luni); atingerea graficului afișează valoarea dintr-o zi.
- Funcționează offline cu ultimele cursuri salvate.
- Steaguri în SVG (pachetul `country_flags`), vizibile pe toate platformele, inclusiv Windows și Linux.
- Engleză, franceză, germană, spaniolă, italiană, poloneză, română și lituaniană: implicit limba dispozitivului (engleză dacă nu este tradusă), modificabilă în aplicație și memorată; temă deschisă și întunecată.

Politica de confidențialitate (cerută de magazine): `site/privacy.html`, publicată la https://juadde.github.io/money_converter/privacy.html.

## De unde provin cursurile

1. **Direct de la BCE**: `eurofxref-hist-90d.xml` (90 de zile, deci cursurile zilei și istoricul într-o singură cerere).
2. **Rezervă**: `rates.json`, o copie JSON a aceluiași fișier, regenerată de workflow-ul `Deploy` și servită de GitHub Pages lângă aplicația web.
3. **Cache local**: ultimul răspuns, refolosit timp de o oră, apoi ca ultimă soluție când rețeaua nu este disponibilă.

Serverul BCE nu trimite antet CORS, deci un browser nu îi poate citi XML-ul. De aceea versiunea web citește direct `rates.json` (aceeași origine).

URL-ul de rezervă se poate schimba la compilare:

```sh
flutter run --dart-define=RATES_FALLBACK_URL=https://example.org/rates.json
```

## Dezvoltare

Folderele `android/`, `ios/`, `web/`, `windows/` și `linux/` nu sunt versionate: un script le generează cu `flutter create` și aplică setările necesare aplicației (permisiunea Internet, numele aplicației, pictogramele).

```sh
bash tool/bootstrap_platforms.sh
flutter pub get
flutter test
flutter run
```

Pentru a rula versiunea web local este nevoie de un `rates.json` lângă aplicație sau de un URL de rezervă:

```sh
python3 tool/ecb_to_json.py --output web/rates.json
flutter run -d chrome
```

## Pictogramă

Pictograma (o bancnotă verde) este desenată în SVG în `assets/icon/`. După o modificare, se regenerează fișierele PNG, apoi pictogramele platformelor:

```sh
rsvg-convert -w 1024 -h 1024 assets/icon/bill.svg -o assets/icon/icon.png
rsvg-convert -w 1024 -h 1024 assets/icon/bill_foreground.svg -o assets/icon/icon_foreground.png
dart run flutter_launcher_icons
```

## Organizarea codului

| Folder | Conținut |
| --- | --- |
| `lib/models` | Cursurile unei zile, instantaneu, istoricul unei perechi, parități cu euro |
| `lib/data` | Citirea XML-ului BCE și a JSON-ului, surse HTTP, cache, depozit cu rezervă |
| `lib/state` | Provideri Riverpod (cursuri, pereche, sumă și limbă memorate) |
| `lib/ui` | Ecranul principal, selectorul de valută, graficul, steagurile |
| `lib/l10n` | Textele în cele 8 limbi |
| `screenshots` | Generarea capturilor de ecran pentru magazine |
| `fastlane/metadata/android` | Fișa Google Play în cele 8 limbi |
| `site` | Pagina politicii de confidențialitate |
| `tool` | Generarea platformelor, XML BCE în JSON, grafica și verificările pentru magazine |
| `assets/icon` | Pictograma aplicației (surse SVG și PNG de 1024 px) |

## Integrare și livrare continuă

- **CI** (`.github/workflows/ci.yml`), la fiecare PR și fiecare push pe `main`: analiză, teste, verificarea fișei din magazin, build web. Build-ul APK este dezactivat deocamdată (`if: false`).
- **Desktop** (`.github/workflows/desktop.yml`): snap Linux și pachet MSIX Windows la fiecare push pe `main`, publicate în Snap Store și Microsoft Store după activare (vezi „Windows și Linux”).
- **Play Store** (`.github/workflows/play-store.yml`): bundle Android semnat și fișa din magazin, trimise la Google Play la fiecare push pe `main` după activare (vezi „Play Store”).
- **Deploy** (`.github/workflows/deploy.yml`):
  - la fiecare push pe `main`: aplicația web și politica de confidențialitate pe GitHub Pages. Build-ul iOS este dezactivat deocamdată (`if: false`);
  - în fiecare zi lucrătoare după publicarea BCE: o nouă livrare web cu un `rates.json` actualizat.
- **Release** (`.github/workflows/release.yml`), la fiecare push pe `main`: un release GitHub `v<versiune>-<rulare>` cu APK-ul Android semnat, o arhivă zip pentru Windows și tar.gz-ul și snap-ul pentru Linux.
- **Security** (`.github/workflows/security.yml`), la fiecare PR, la fiecare push pe `main` și în fiecare luni: scanarea vulnerabilităților dependențelor (vezi „Securitate și SBOM”).

### Setări unice pe GitHub

- **Pages**: Settings → Pages → Source: „GitHub Actions”. Pentru un depozit privat, Pages cere un abonament plătit; altfel depozitul trebuie să fie public.
- **Android**: APK-ul din release-urile GitHub este semnat cu cheia de încărcare, deci nu poate actualiza o versiune instalată din Google Play (dezinstaleaz-o mai întâi). Build-urile pentru Play Store sunt semnate cu cheia de încărcare (vezi mai jos).
- **iOS**: build-ul nu este semnat. O publicare în TestFlight sau App Store cere un cont Apple Developer și certificatele lui ca secrete.

## Securitate și SBOM

Pentru a raporta o vulnerabilitate, vezi [SECURITY.md](SECURITY.md) (raport privat pe GitHub, fără issue public).

- **SBOM**: fiecare build are lista de componente software în format SPDX, generată cu [Syft](https://github.com/anchore/syft) (pachetele Dart și Flutter din `pubspec.lock` și componentele găsite în build). Release-urile GitHub au câte una pentru fiecare fișier (`<fișier>.spdx.json`); aplicația web o publică pe a sa la [sbom.spdx.json](https://juadde.github.io/money_converter/sbom.spdx.json); build-urile pentru magazine o păstrează ca artefact al rulării.
- **Atestări**: fișierele release-urilor au o atestare de proveniență a build-ului și o atestare SBOM, semnate cu Sigstore. Pentru a verifica un fișier: `gh attestation verify money-converter-android.apk -R juadde/money_converter`.
- **Scanarea vulnerabilităților**: workflow-ul Security scanează SBOM-ul cu [Grype](https://github.com/anchore/grype). Un pull request eșuează la o vulnerabilitate ridicată sau critică pentru care există o corecție. Pe `main` și în fiecare luni, toate rezultatele ajung în fila Security (Code scanning), iar dependențele în graficul de dependențe.
- **Dependabot** (`.github/dependabot.yml`): în fiecare luni, un pull request pentru pachetele Dart și unul pentru GitHub Actions; actualizările de securitate imediat.

Setare unică: Settings → Code security → se activează „Private vulnerability reporting”, „Dependabot alerts” și „Dependabot security updates”.

## Play Store

Workflow-ul `Play Store` creează un Android App Bundle (`.aab`) semnat cu cheia de încărcare și îl publică pe Google Play cu [fastlane](https://docs.fastlane.tools/actions/upload_to_play_store/), împreună cu fișa completă din magazin: texte, noutăți, pictogramă, grafică de prezentare și capturi de ecran. `versionCode` este numărul de rulare al workflow-ului, deci crește la fiecare încărcare. ID-ul aplicației este `com.juadde.moneyconverter`; nu mai poate fi schimbat după crearea aplicației pe Google Play.

| Declanșator | Ce se întâmplă |
| --- | --- |
| Push pe `main` | Nimic cât timp variabila `PLAY_STORE_ENABLED` nu este `true`; apoi încărcare pe canalul `PLAY_TRACK` (implicit `internal`) |
| Rulare manuală (fila Actions) | Build și încărcare pe canalul ales; fără cont de serviciu, bundle-ul este disponibil doar ca artefact al rulării |
| PR care modifică workflow-ul, scriptul sau fișa | Probă cu o cheie de unică folosință, nu se încarcă nimic |

### Fișa din Play Store

Întreaga fișă se află în depozit și se publică odată cu fiecare versiune, pentru cele 8 limbi (`fastlane/metadata/android/<limbă>/`):

| Fișier | Conținut | Limită |
| --- | --- | --- |
| `title.txt` | Numele aplicației | 30 de caractere |
| `short_description.txt` | Descriere scurtă | 80 de caractere |
| `full_description.txt` | Descriere completă | 4.000 de caractere |
| `changelogs/default.txt` | Noutățile versiunii („What's new”) | 500 de caractere |
| `images/icon.png`, `images/featureGraphic.png` | Pictogramă de 512 px și grafică de prezentare 1024 × 500 (`tool/store_graphics.py`) | |
| `images/phoneScreenshots/` | 4 capturi de ecran 1080 × 1920, **generate** la fiecare publicare de `screenshots/screenshots_test.dart` cu cursurile BCE ale zilei | |

`tool/check_store_metadata.py` verifică limitele (rulat de CI). Pentru a vedea capturile local:

```sh
python3 tool/ecb_to_json.py --output screenshots/rates.json
flutter test --update-goldens screenshots/
```

### Configurare (o singură dată)

1. **Cheia de încărcare.** Pe calculatorul tău (cu Java instalat):

   ```sh
   keytool -genkeypair -v -keystore upload-keystore.jks -alias upload \
     -keyalg RSA -keysize 2048 -validity 10000
   base64 -w0 upload-keystore.jks   # macOS: base64 -i upload-keystore.jks
   ```

   Păstrează fișierul `.jks` și parolele lui într-un loc sigur, în afara depozitului. Evită barele oblice inverse în parole.

2. **Secrete GitHub** (Settings → Secrets and variables → Actions → Secrets):
   `ANDROID_KEYSTORE_BASE64` (rezultatul `base64`), `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS` (`upload`), `ANDROID_KEY_PASSWORD` (opțional dacă este identică cu parola keystore-ului).

3. **Aplicația în Play Console**: crearea aplicației, completarea fișei și a chestionarelor (conținut, confidențialitate…), apoi activarea semnării aplicațiilor de către Google Play.

4. **Prima încărcare manuală** (cerută de Google): rularea workflow-ului `Play Store` din fila Actions, descărcarea artefactului `moneyconverter-aab-…`, apoi încărcarea lui în Play Console pe canalul „Testare internă”.

5. **Cont de serviciu** pentru încărcările automate: în Google Cloud se creează un cont de serviciu și o cheie JSON, se activează Google Play Android Developer API, apoi se invită adresa contului de serviciu în Play Console (Utilizatori și permisiuni) cu dreptul de a publica pe canalele de testare. Conținutul JSON se pune în secretul `PLAY_SERVICE_ACCOUNT_JSON`.

6. **Activarea încărcărilor automate** (Settings → Secrets and variables → Actions → Variables):
   - `PLAY_STORE_ENABLED` = `true`
   - `PLAY_TRACK` (opțional): `internal`, `alpha` (testare închisă), `beta` (testare deschisă) sau `production`
   - `PLAY_RELEASE_STATUS` (opțional): implicit `completed`; se folosește `draft` cât timp aplicația nu a fost niciodată publicată, altfel Google respinge încărcarea.

### Bine de știut

- Pentru un cont personal de dezvoltator creat după 13 noiembrie 2023, Google cere, înainte de deschiderea producției, o testare închisă cu cel puțin 12 testeri înscriși timp de 14 zile consecutive. Testarea internă nu contează: folosește canalul `alpha` pentru această testare închisă.
- **„Semnat cu cheia greșită” în Play Console**: se compară amprentele keystore-ului tău, afișate pe calculatorul tău de `keytool -list -v -keystore upload-keystore.jks -alias upload` (jurnalele rulărilor sunt publice și nu le arată niciodată), cu Play Console → Testare și lansare → Integritatea aplicației → Certificatul cheii de încărcare. Se încarcă doar artefactele `moneyconverter-aab-…`: cele `dry-run-do-not-upload-aab-…` provin din pull requesturi și sunt semnate cu o cheie de unică folosință. Dacă la Google este înregistrată altă cheie decât a ta, cere acolo resetarea cheii de încărcare cu certificatul exportat prin `keytool -export -rfc -keystore upload-keystore.jks -alias upload -file upload_certificate.pem`.
- Build-urile Android din `ci.yml` și `deploy.yml` rămân dezactivate; acest workflow este independent.

## Windows și Linux

Workflow-ul `Desktop` creează, la fiecare push pe `main` (sau manual din fila Actions):

- **Linux**: un snap (`money-converter-ecb`, bază `core24`, extensia GNOME);
- **Windows**: un pachet MSIX pentru Microsoft Store.

Ambele pachete sunt mereu disponibile ca artefacte ale rulării. Publicarea urmează aceeași logică precum Play Store:

| Declanșator | Snap Store | Microsoft Store |
| --- | --- | --- |
| Push pe `main` | Dacă variabila `SNAP_STORE_ENABLED` este `true` | Dacă variabila `MSSTORE_ENABLED` este `true` |
| Rulare manuală (fila Actions) | Dacă datele de autentificare sunt configurate | Dacă datele de autentificare sunt configurate |
| PR care atinge împachetarea | Niciodată (doar build) | Niciodată (doar build) |

### Snap Store (o singură dată)

1. Se creează un cont pe [snapcraft.io](https://snapcraft.io) și se rezervă numele: `snapcraft register money-converter-ecb`. Dacă numele este ocupat, se alege altul și se schimbă în `snap/snapcraft.yaml` (câmpul `name`, numele aplicației și numele fișierului `.desktop` din `snap/gui/`).
2. Se generează date de autentificare pentru CI:

   ```sh
   snapcraft export-login --snaps=money-converter-ecb --acls=package_access,package_push,package_update,package_release -
   ```

3. Rezultatul se pune în secretul `SNAPCRAFT_STORE_CREDENTIALS`.
4. Se activează publicarea automată: variabila `SNAP_STORE_ENABLED` = `true`.
5. Opțional: variabila `SNAP_CHANNEL` alege canalul (implicit `edge`, apoi `beta`, `candidate` sau `stable`).

### Microsoft Store (o singură dată)

1. Este nevoie de un cont de dezvoltator în [Partner Center](https://partner.microsoft.com/dashboard), unde se rezervă numele aplicației.
2. Pe pagina aplicației, la „Identitatea produsului”, se copiază în **variabilele** GitHub:
   - `MSSTORE_IDENTITY_NAME` (Package/Identity/Name)
   - `MSSTORE_PUBLISHER` (Package/Identity/Publisher, de forma `CN=…`)
   - `MSSTORE_PUBLISHER_DISPLAY_NAME` (Package/Properties/PublisherDisplayName)
   - `MSSTORE_PRODUCT_ID` (Store ID, 12 caractere)
3. Se face **prima trimitere manual** (cerută de Microsoft): se rulează workflow-ul `Desktop`, se descarcă artefactul `moneyconverter-msix-…` și se încarcă într-o trimitere din Partner Center, împreună cu fișa, capturile de ecran și clasificarea pe vârste. Artefactul `windows-store-listing-…` al aceleiași rulări conține întreaga fișă pentru cele 8 limbi (texte, capturi desktop 1920 × 1080, sigle): se dezarhivează și se importă folderul `msstore-listing` în Fișe Store → Importă fișa. Este generat de `tool/msstore_listing.py` din textele Google Play și din `store/windows/listing_template.csv` (șablonul exportat din Partner Center).
4. Se asociază un director Microsoft Entra ID (Azure AD) cu contul Partner Center, se creează în el o aplicație cu rolul „Manager”, apoi se pun în **secretele** GitHub: `PARTNER_CENTER_TENANT_ID`, `PARTNER_CENTER_SELLER_ID`, `PARTNER_CENTER_CLIENT_ID`, `PARTNER_CENTER_CLIENT_SECRET`.
5. Se activează publicarea automată: variabila `MSSTORE_ENABLED` = `true`.

De atunci, fiecare push pe `main` creează și trimite o nouă trimitere (versiunea `2.0.<număr de rulare>.0`).

## Licență

Copyright (C) 2026 Julien Addé

Acest program este software liber: îl puteți redistribui și/sau modifica în condițiile Licenței Publice Generale GNU publicate de Free Software Foundation, fie versiunea 3 a licenței, fie (la alegerea dumneavoastră) orice versiune ulterioară (`GPL-3.0-or-later`).

Acest program este distribuit în speranța că va fi util, dar FĂRĂ NICIO GARANȚIE, chiar și fără garanția implicită de VANDABILITATE sau de ADECVARE PENTRU UN ANUMIT SCOP. Pentru detalii, consultați fișierul [LICENSE](LICENSE). Doar textul în limba engleză al licenței are valoare juridică.
