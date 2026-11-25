[English](README.md) | [Français](README.fr.md) | [Deutsch](README.de.md) | [Español](README.es.md) | [Italiano](README.it.md) | [Polski](README.pl.md) | [Română](README.ro.md) | **Lietuvių**

# Money Converter

Valiutų keitiklis, pagrįstas
[Europos Centrinio Banko euro orientaciniais valiutų kursais](https://www.ecb.europa.eu/stats/policy_and_exchange_rates/euro_reference_exchange_rates/html/index.lt.html),
kurie kaip atvirieji duomenys skelbiami kiekvieną darbo dieną apie 16:00 CET.

„Flutter“ programa: „Android“, „iOS“, žiniatinklis, „Windows“ ir „Linux“ iš vieno kodo.

## Funkcijos

- Konvertavimas realiuoju laiku vedant sumą, tarp visų ECB skelbiamų valiutų (ir euro).
- Valiutos su fiksuotu kursu euro atžvilgiu, kurių ECB neskelbia: Žaliojo Kyšulio eskudas (CVE), CFA frankai (XOF, XAF), Komorų frankas (KMF), CFP frankas (XPF), Bosnijos ir Hercegovinos konvertuojamoji markė (BAM) ir dobra (STN). Jų kursai apskaičiuojami pagal oficialų paritetą ir tos dienos ECB kursus (`lib/models/euro_pegs.dart`).
- Poros sukeitimas, valiutos paieška pagal kodą ar pavadinimą.
- Dienos kursai ir ankstesnių reikšmių grafikas (1 savaitė, 1 mėnuo, 3 mėnesiai); palietus grafiką rodoma dienos reikšmė.
- Veikia be ryšio su paskutiniais išsaugotais kursais.
- SVG vėliavos (paketas `country_flags`), matomos visose platformose, įskaitant „Windows“ ir „Linux“.
- Anglų, prancūzų, vokiečių, ispanų, italų, lenkų, rumunų ir lietuvių kalbos: pagal numatytuosius nustatymus įrenginio kalba (anglų, jei ji neišversta), keičiama programoje ir įsimenama; šviesi ir tamsi tema.

Privatumo politika (reikalaujama parduotuvių): `site/privacy.html`, paskelbta adresu https://juadde.github.io/money_converter/privacy.html.

## Iš kur gaunami kursai

1. **Tiesiogiai iš ECB**: `eurofxref-hist-90d.xml` (90 dienų, t. y. dienos kursai ir istorija viena užklausa).
2. **Atsarginė kopija**: `rates.json`, to paties failo JSON kopija, kurią atnaujina `Deploy` darbo eiga ir kurią „GitHub Pages“ pateikia šalia žiniatinklio programos.
3. **Vietinė talpykla**: paskutinis atsakymas, naudojamas valandą, o vėliau kaip paskutinė išeitis, kai nėra ryšio.

ECB serveris nesiunčia CORS antraštės, todėl naršyklė negali perskaityti jo XML. Dėl to žiniatinklio versija tiesiogiai skaito `rates.json` (ta pati kilmė).

Atsarginį URL galima pakeisti kompiliuojant:

```sh
flutter run --dart-define=RATES_FALLBACK_URL=https://example.org/rates.json
```

## Kūrimas

Aplankai `android/`, `ios/`, `web/`, `windows/` ir `linux/` nėra versijuojami: scenarijus juos sukuria su `flutter create` ir pritaiko programai reikalingus nustatymus (interneto leidimą, programos pavadinimą, piktogramas).

```sh
bash tool/bootstrap_platforms.sh
flutter pub get
flutter test
flutter run
```

Norint vietoje paleisti žiniatinklio versiją, reikia `rates.json` šalia programos arba atsarginio URL:

```sh
python3 tool/ecb_to_json.py --output web/rates.json
flutter run -d chrome
```

## Piktograma

Piktograma (žalias banknotas) nupiešta SVG formatu `assets/icon/` aplanke. Pakeitus reikia iš naujo sugeneruoti PNG, o tada platformų piktogramas:

```sh
rsvg-convert -w 1024 -h 1024 assets/icon/bill.svg -o assets/icon/icon.png
rsvg-convert -w 1024 -h 1024 assets/icon/bill_foreground.svg -o assets/icon/icon_foreground.png
dart run flutter_launcher_icons
```

## Kodo struktūra

| Aplankas | Turinys |
| --- | --- |
| `lib/models` | Dienos kursai, momentinė kopija, poros istorija, paritetai su euru |
| `lib/data` | ECB XML ir JSON skaitymas, HTTP šaltiniai, talpykla, saugykla su atsargine kopija |
| `lib/state` | „Riverpod“ teikėjai (kursai, įsiminta pora, suma ir kalba) |
| `lib/ui` | Pagrindinis ekranas, valiutos pasirinkimas, grafikas, vėliavos |
| `lib/l10n` | Tekstai 8 kalbomis |
| `screenshots` | Ekrano kopijų parduotuvėms generavimas |
| `fastlane/metadata/android` | „Google Play“ aprašas 8 kalbomis |
| `site` | Privatumo politikos puslapis |
| `tool` | Platformų generavimas, ECB XML į JSON, parduotuvių grafika ir patikros |
| `assets/icon` | Programos piktograma (SVG šaltiniai ir 1024 px PNG) |

## Nuolatinė integracija ir diegimas

- **CI** (`.github/workflows/ci.yml`), kiekvienam PR ir kiekvienam `main` pakeitimui: analizė, testai, parduotuvės aprašo patikra, žiniatinklio kompiliavimas. APK kompiliavimas kol kas išjungtas (`if: false`).
- **Desktop** (`.github/workflows/desktop.yml`): „Linux“ snap ir „Windows“ MSIX paketas kiekvienam `main` pakeitimui, įjungus skelbiami „Snap Store“ ir „Microsoft Store“ (žr. „Windows ir Linux“).
- **Play Store** (`.github/workflows/play-store.yml`): pasirašytas „Android“ paketas ir parduotuvės aprašas, įjungus siunčiami į „Google Play“ kiekvienam `main` pakeitimui (žr. „Play Store“).
- **Deploy** (`.github/workflows/deploy.yml`):
  - kiekvienam `main` pakeitimui: žiniatinklio programa ir privatumo politika „GitHub Pages“. „iOS“ kompiliavimas kol kas išjungtas (`if: false`);
  - kiekvieną darbo dieną po ECB paskelbimo: žiniatinklio programa iš naujo įdiegiama su atnaujintu `rates.json`.
- **Release** (`.github/workflows/release.yml`), kiekvienam `main` pakeitimui: „GitHub“ leidimas `v<versija>-<paleidimas>` su pasirašytu „Android“ APK, „Windows“ zip ir „Linux“ tar.gz bei snap paketais.

### Vienkartiniai „GitHub“ nustatymai

- **Pages**: Settings → Pages → Source: „GitHub Actions“. Privačiai saugyklai „Pages“ reikalingas mokamas planas; kitu atveju saugykla turi būti vieša.
- **Android**: „GitHub“ leidimų APK pasirašytas įkėlimo raktu, todėl juo negalima atnaujinti iš „Google Play“ įdiegtos versijos (pirmiausia ją pašalinkite). „Play Store“ paketai pasirašomi įkėlimo raktu (žr. toliau).
- **iOS**: paketas nepasirašytas. Norint skelbti „TestFlight“ ar „App Store“, reikia „Apple Developer“ paskyros ir jos sertifikatų kaip slaptųjų reikšmių.

## Play Store

Darbo eiga `Play Store` sukuria įkėlimo raktu pasirašytą „Android App Bundle“ (`.aab`) ir su [fastlane](https://docs.fastlane.tools/actions/upload_to_play_store/) paskelbia jį „Google Play“ kartu su visu parduotuvės aprašu: tekstais, naujovėmis, piktograma, reklamine grafika ir ekrano kopijomis. `versionCode` yra darbo eigos paleidimo numeris, todėl jis didėja su kiekvienu įkėlimu. Programos ID yra `com.juadde.moneyconverter`; sukūrus programą „Google Play“, jo pakeisti nebegalima.

| Paleidiklis | Kas vyksta |
| --- | --- |
| `main` pakeitimas | Nieko, kol kintamasis `PLAY_STORE_ENABLED` nėra `true`; vėliau įkeliama į kanalą `PLAY_TRACK` (numatytasis `internal`) |
| Paleidimas rankiniu būdu (skirtukas „Actions“) | Kompiliavimas ir įkėlimas į pasirinktą kanalą; be paslaugos paskyros paketas pasiekiamas tik kaip paleidimo artefaktas |
| PR, keičiantis darbo eigą, scenarijų ar aprašą | Bandomasis paleidimas su vienkartiniu raktu, niekas neįkeliama |

### „Play Store“ aprašas

Visas aprašas laikomas saugykloje ir skelbiamas su kiekviena versija, 8 kalbomis (`fastlane/metadata/android/<kalba>/`):

| Failas | Turinys | Riba |
| --- | --- | --- |
| `title.txt` | Programos pavadinimas | 30 simbolių |
| `short_description.txt` | Trumpas aprašas | 80 simbolių |
| `full_description.txt` | Visas aprašas | 4000 simbolių |
| `changelogs/default.txt` | Versijos naujovės („What's new“) | 500 simbolių |
| `images/icon.png`, `images/featureGraphic.png` | 512 px piktograma ir 1024 × 500 reklaminė grafika (`tool/store_graphics.py`) | |
| `images/phoneScreenshots/` | 4 ekrano kopijos 1080 × 1920, **generuojamos** kiekvieno paskelbimo metu su `screenshots/screenshots_test.dart` ir tos dienos ECB kursais | |

`tool/check_store_metadata.py` tikrina ribas (paleidžia CI). Norint pamatyti ekrano kopijas vietoje:

```sh
python3 tool/ecb_to_json.py --output screenshots/rates.json
flutter test --update-goldens screenshots/
```

### Parengimas (vieną kartą)

1. **Įkėlimo raktas.** Savo kompiuteryje (su įdiegta „Java“):

   ```sh
   keytool -genkeypair -v -keystore upload-keystore.jks -alias upload \
     -keyalg RSA -keysize 2048 -validity 10000
   base64 -w0 upload-keystore.jks   # macOS: base64 -i upload-keystore.jks
   ```

   `.jks` failą ir jo slaptažodžius laikykite saugioje vietoje, ne saugykloje. Slaptažodžiuose venkite atvirkštinių pasvirųjų brūkšnių.

2. **„GitHub“ slaptosios reikšmės** (Settings → Secrets and variables → Actions → Secrets):
   `ANDROID_KEYSTORE_BASE64` (`base64` rezultatas), `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS` (`upload`), `ANDROID_KEY_PASSWORD` (neprivaloma, jei sutampa su raktų saugyklos slaptažodžiu).

3. **Programa „Play Console“**: sukurti programą, užpildyti aprašą ir klausimynus (turinys, privatumas…), tada įjungti „Google Play“ programų pasirašymą.

4. **Pirmasis įkėlimas rankiniu būdu** (reikalauja „Google“): skirtuke „Actions“ paleisti darbo eigą `Play Store`, atsisiųsti artefaktą `moneyconverter-aab-…` ir įkelti jį „Play Console“ į kanalą „Vidinis testavimas“.

5. **Paslaugos paskyra** automatiniams įkėlimams: „Google Cloud“ sukurti paslaugos paskyrą ir JSON raktą, įjungti „Google Play Android Developer API“, tada „Play Console“ (Naudotojai ir leidimai) pakviesti paslaugos paskyros adresą su teise skelbti testavimo kanaluose. JSON turinį įrašyti į slaptąją reikšmę `PLAY_SERVICE_ACCOUNT_JSON`.

6. **Įjungti automatinius įkėlimus** (Settings → Secrets and variables → Actions → Variables):
   - `PLAY_STORE_ENABLED` = `true`
   - `PLAY_TRACK` (neprivaloma): `internal`, `alpha` (uždaras testavimas), `beta` (atviras testavimas) arba `production`
   - `PLAY_RELEASE_STATUS` (neprivaloma): numatytoji `completed`; naudoti `draft`, kol programa dar niekada nebuvo paskelbta, kitaip „Google“ atmes įkėlimą.

### Verta žinoti

- Asmeninėje kūrėjo paskyroje, sukurtoje po 2023 m. lapkričio 13 d., „Google“ prieš atveriant gamybinę versiją reikalauja uždaro testavimo su bent 12 testuotojų, užsiregistravusių 14 dienų iš eilės. Vidinis testavimas neįskaitomas: šiam uždaram testavimui naudokite kanalą `alpha`.
- **„Pasirašyta netinkamu raktu“ „Play Console“**: palyginti savo raktų saugyklos kontrolinius kodus, kuriuos jūsų kompiuteryje parodo `keytool -list -v -keystore upload-keystore.jks -alias upload` (paleidimų žurnalai vieši ir jų niekada nerodo), su „Play Console“ → Testavimas ir leidimas → Programos vientisumas → Įkėlimo rakto sertifikatas. Įkelti tik `moneyconverter-aab-…` artefaktus: `dry-run-do-not-upload-aab-…` gaunami iš pull request ir pasirašyti vienkartiniu raktu. Jei „Google“ užregistruotas ne jūsų raktas, ten paprašykite iš naujo nustatyti įkėlimo raktą, naudodami sertifikatą, eksportuotą komanda `keytool -export -rfc -keystore upload-keystore.jks -alias upload -file upload_certificate.pem`.
- „Android“ kompiliavimas `ci.yml` ir `deploy.yml` lieka išjungtas; ši darbo eiga nuo jų nepriklauso.

## Windows ir Linux

Darbo eiga `Desktop` kiekvienam `main` pakeitimui (arba rankiniu būdu skirtuke „Actions“) sukuria:

- **Linux**: snap paketą (`money-converter-ecb`, bazė `core24`, GNOME plėtinys);
- **Windows**: MSIX paketą „Microsoft Store“.

Abu paketai visada pasiekiami kaip paleidimo artefaktai. Skelbimas vyksta pagal tą pačią logiką kaip „Play Store“:

| Paleidiklis | Snap Store | Microsoft Store |
| --- | --- | --- |
| `main` pakeitimas | Kai kintamasis `SNAP_STORE_ENABLED` yra `true` | Kai kintamasis `MSSTORE_ENABLED` yra `true` |
| Paleidimas rankiniu būdu (skirtukas „Actions“) | Kai nustatyti prisijungimo duomenys | Kai nustatyti prisijungimo duomenys |
| PR, liečiantis pakavimą | Niekada (tik kompiliavimas) | Niekada (tik kompiliavimas) |

### Snap Store (vieną kartą)

1. Susikurti paskyrą [snapcraft.io](https://snapcraft.io) ir užregistruoti pavadinimą: `snapcraft register money-converter-ecb`. Jei pavadinimas užimtas, pasirinkti kitą ir pakeisti jį `snap/snapcraft.yaml` (laukas `name`, programos pavadinimas ir `.desktop` failo pavadinimas `snap/gui/` aplanke).
2. Sugeneruoti prisijungimo duomenis CI:

   ```sh
   snapcraft export-login --snaps=money-converter-ecb --acls=package_access,package_push,package_update,package_release -
   ```

3. Rezultatą įrašyti į slaptąją reikšmę `SNAPCRAFT_STORE_CREDENTIALS`.
4. Įjungti automatinį skelbimą: kintamasis `SNAP_STORE_ENABLED` = `true`.
5. Neprivaloma: kintamasis `SNAP_CHANNEL` parenka kanalą (numatytasis `edge`, toliau `beta`, `candidate` arba `stable`).

### Microsoft Store (vieną kartą)

1. Turėti kūrėjo paskyrą [Partner Center](https://partner.microsoft.com/dashboard) ir ten rezervuoti programos pavadinimą.
2. Programos puslapyje, skiltyje „Produkto tapatybė“, nukopijuoti į „GitHub“ **kintamuosius**:
   - `MSSTORE_IDENTITY_NAME` (Package/Identity/Name)
   - `MSSTORE_PUBLISHER` (Package/Identity/Publisher, formatu `CN=…`)
   - `MSSTORE_PUBLISHER_DISPLAY_NAME` (Package/Properties/PublisherDisplayName)
   - `MSSTORE_PRODUCT_ID` (Store ID, 12 simbolių)
3. **Pirmąjį pateikimą atlikti rankiniu būdu** (reikalauja „Microsoft“): paleisti darbo eigą `Desktop`, atsisiųsti artefaktą `moneyconverter-msix-…` ir įkelti jį į „Partner Center“ pateikimą kartu su aprašu, ekrano kopijomis ir amžiaus klasifikacija. To paties paleidimo artefakte `windows-store-listing-…` yra visas aprašas 8 kalbomis (tekstai, kompiuterio ekrano kopijos 1920 × 1080, logotipai): išarchyvuokite jį ir importuokite aplanką `msstore-listing` skiltyje „Store“ aprašai → Importuoti aprašą. Jį sukuria `tool/msstore_listing.py` iš „Google Play“ tekstų ir `store/windows/listing_template.csv` (iš „Partner Center“ eksportuoto šablono).
4. Susieti „Microsoft Entra ID“ („Azure AD“) katalogą su „Partner Center“ paskyra, jame sukurti programą su vaidmeniu „Manager“, tada įrašyti į „GitHub“ **slaptąsias reikšmes**: `PARTNER_CENTER_TENANT_ID`, `PARTNER_CENTER_SELLER_ID`, `PARTNER_CENTER_CLIENT_ID`, `PARTNER_CENTER_CLIENT_SECRET`.
5. Įjungti automatinį skelbimą: kintamasis `MSSTORE_ENABLED` = `true`.

Nuo tada kiekvienas `main` pakeitimas sukuria ir išsiunčia naują pateikimą (versija `2.0.<paleidimo numeris>.0`).

## Licencija

Copyright (C) 2026 Julien Addé

Ši programa yra laisvoji programinė įranga: galite ją platinti ir (arba) keisti pagal „Free Software Foundation“ paskelbtos GNU bendrosios viešosios licencijos sąlygas – 3 licencijos versiją arba (savo pasirinkimu) bet kurią vėlesnę versiją (`GPL-3.0-or-later`).

Ši programa platinama tikintis, kad ji bus naudinga, tačiau BE JOKIOS GARANTIJOS, net be numanomos TINKAMUMO PREKIAUTI ar TINKAMUMO KONKREČIAM TIKSLUI garantijos. Daugiau informacijos rasite faile [LICENSE](LICENSE). Teisinę galią turi tik licencijos tekstas anglų kalba.
