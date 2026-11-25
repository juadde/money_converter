[English](README.md) | [Français](README.fr.md) | [Deutsch](README.de.md) | [Español](README.es.md) | [Italiano](README.it.md) | **Polski** | [Română](README.ro.md) | [Lietuvių](README.lt.md)

# Money Converter

Przelicznik walut oparty na
[referencyjnych kursach walut euro Europejskiego Banku Centralnego](https://www.ecb.europa.eu/stats/policy_and_exchange_rates/euro_reference_exchange_rates/html/index.pl.html),
publikowanych jako otwarte dane w każdy dzień roboczy około 16:00 CET.

Aplikacja Flutter: Android, iOS, web, Windows i Linux z jednego kodu źródłowego.

## Funkcje

- Przeliczanie na bieżąco podczas wpisywania, między wszystkimi walutami publikowanymi przez EBC (plus euro).
- Waluty o stałym kursie do euro, których EBC nie publikuje: escudo Zielonego Przylądka (CVE), franki CFA (XOF, XAF), frank Komorów (KMF), frank CFP (XPF), marka zamienna Bośni i Hercegowiny (BAM) i dobra (STN). Ich kursy wynikają z oficjalnego parytetu i kursów EBC z danego dnia (`lib/models/euro_pegs.dart`).
- Zamiana pary, wyszukiwanie waluty po kodzie lub nazwie.
- Kursy z danego dnia i wykres wcześniejszych wartości (1 tydzień, 1 miesiąc, 3 miesiące); dotknięcie wykresu pokazuje wartość z danego dnia.
- Działa offline z ostatnio zapisanymi kursami.
- Flagi w SVG (pakiet `country_flags`), widoczne na wszystkich platformach, także w Windows i Linuksie.
- Angielski, francuski, niemiecki, hiszpański, włoski, polski, rumuński i litewski: domyślnie język urządzenia (angielski, jeśli nie ma tłumaczenia), zmienialny w aplikacji i zapamiętywany; jasny i ciemny motyw.

Polityka prywatności (wymagana przez sklepy): `site/privacy.html`, opublikowana pod adresem https://juadde.github.io/money_converter/privacy.html.

## Skąd pochodzą kursy

1. **Bezpośrednio z EBC**: `eurofxref-hist-90d.xml` (90 dni, czyli bieżące kursy i historia w jednym zapytaniu).
2. **Kopia zapasowa**: `rates.json`, kopia tego samego pliku w formacie JSON, odtwarzana przez workflow `Deploy` i udostępniana przez GitHub Pages obok aplikacji web.
3. **Lokalna pamięć podręczna**: ostatnia odpowiedź, używana ponownie przez godzinę, a potem w ostateczności, gdy brak sieci.

Serwer EBC nie wysyła nagłówka CORS, więc przeglądarka nie może odczytać jego XML. Wersja web czyta więc bezpośrednio `rates.json` (to samo źródło).

Zapasowy adres URL można zmienić przy kompilacji:

```sh
flutter run --dart-define=RATES_FALLBACK_URL=https://example.org/rates.json
```

## Rozwój

Foldery `android/`, `ios/`, `web/`, `windows/` i `linux/` nie są wersjonowane: skrypt tworzy je za pomocą `flutter create` i stosuje ustawienia potrzebne aplikacji (uprawnienie do Internetu, nazwa aplikacji, ikony).

```sh
bash tool/bootstrap_platforms.sh
flutter pub get
flutter test
flutter run
```

Aby uruchomić wersję web lokalnie, potrzebny jest plik `rates.json` obok aplikacji albo zapasowy adres URL:

```sh
python3 tool/ecb_to_json.py --output web/rates.json
flutter run -d chrome
```

## Ikona

Ikona (zielony banknot) jest narysowana w SVG w `assets/icon/`. Po zmianie należy ponownie wygenerować pliki PNG, a potem ikony platform:

```sh
rsvg-convert -w 1024 -h 1024 assets/icon/bill.svg -o assets/icon/icon.png
rsvg-convert -w 1024 -h 1024 assets/icon/bill_foreground.svg -o assets/icon/icon_foreground.png
dart run flutter_launcher_icons
```

## Struktura kodu

| Folder | Zawartość |
| --- | --- |
| `lib/models` | Kursy z jednego dnia, migawka, historia pary, parytety z euro |
| `lib/data` | Odczyt XML EBC i JSON, źródła HTTP, pamięć podręczna, repozytorium z kopią zapasową |
| `lib/state` | Providery Riverpod (kursy, zapamiętana para, kwota i język) |
| `lib/ui` | Ekran główny, wybór waluty, wykres, flagi |
| `lib/l10n` | Teksty w 8 językach |
| `screenshots` | Generowanie zrzutów ekranu do sklepów |
| `fastlane/metadata/android` | Strona w Google Play w 8 językach |
| `site` | Strona polityki prywatności |
| `tool` | Generowanie platform, XML EBC do JSON, grafiki i kontrole sklepów |
| `assets/icon` | Ikona aplikacji (źródła SVG i PNG 1024 px) |

## Ciągła integracja i wdrażanie

- **CI** (`.github/workflows/ci.yml`), przy każdym PR i każdym pushu na `main`: analiza, testy, sprawdzenie strony w sklepie, build web. Build APK jest na razie wyłączony (`if: false`).
- **Desktop** (`.github/workflows/desktop.yml`): snap dla Linuksa i pakiet MSIX dla Windows przy każdym pushu na `main`, publikowane w Snap Store i Microsoft Store po włączeniu (zob. „Windows i Linux”).
- **Play Store** (`.github/workflows/play-store.yml`): podpisany pakiet Android i strona w sklepie, wysyłane do Google Play przy każdym pushu na `main` po włączeniu (zob. „Play Store”).
- **Deploy** (`.github/workflows/deploy.yml`):
  - przy każdym pushu na `main`: aplikacja web i polityka prywatności na GitHub Pages. Wydanie APK i build iOS są na razie wyłączone (`if: false`);
  - w każdy dzień roboczy po publikacji EBC: ponowne wdrożenie web z aktualnym `rates.json`.

### Jednorazowe ustawienia w GitHubie

- **Pages**: Settings → Pages → Source: „GitHub Actions”. W prywatnym repozytorium Pages wymaga płatnego planu; w przeciwnym razie repozytorium musi być publiczne.
- **Android**: APK z wydania `latest` (wyłączonego) jest podpisany kluczem debugowania. Buildy dla Play Store są podpisywane kluczem przesyłania (zob. niżej).
- **iOS**: build nie jest podpisany. Publikacja w TestFlight lub App Store wymaga konta Apple Developer i jego certyfikatów jako sekretów.

## Play Store

Workflow `Play Store` tworzy Android App Bundle (`.aab`) podpisany kluczem przesyłania i publikuje go w Google Play za pomocą [fastlane](https://docs.fastlane.tools/actions/upload_to_play_store/), razem z pełną stroną w sklepie: tekstami, nowościami, ikoną, grafiką promocyjną i zrzutami ekranu. `versionCode` to numer uruchomienia workflow, więc rośnie przy każdym przesłaniu. Identyfikator aplikacji to `com.juadde.moneyconverter`; nie można go zmienić po utworzeniu aplikacji w Google Play.

| Wyzwalacz | Co się dzieje |
| --- | --- |
| Push na `main` | Nic, dopóki zmienna `PLAY_STORE_ENABLED` nie ma wartości `true`; potem przesłanie na ścieżkę `PLAY_TRACK` (domyślnie `internal`) |
| Uruchomienie ręczne (karta Actions) | Build i przesłanie na wybraną ścieżkę; bez konta usługi pakiet jest dostępny tylko jako artefakt uruchomienia |
| PR zmieniający workflow, skrypt lub stronę w sklepie | Próba z jednorazowym kluczem, nic nie jest przesyłane |

### Strona w Play Store

Cała strona jest w repozytorium i publikowana z każdą wersją, dla 8 języków (`fastlane/metadata/android/<język>/`):

| Plik | Zawartość | Limit |
| --- | --- | --- |
| `title.txt` | Nazwa aplikacji | 30 znaków |
| `short_description.txt` | Krótki opis | 80 znaków |
| `full_description.txt` | Pełny opis | 4000 znaków |
| `changelogs/default.txt` | Nowości w wersji („What's new”) | 500 znaków |
| `images/icon.png`, `images/featureGraphic.png` | Ikona 512 px i grafika promocyjna 1024 × 500 (`tool/store_graphics.py`) | |
| `images/phoneScreenshots/` | 4 zrzuty ekranu 1080 × 1920, **generowane** przy każdej publikacji przez `screenshots/screenshots_test.dart` z kursami EBC z danego dnia | |

`tool/check_store_metadata.py` sprawdza limity (uruchamiany przez CI). Aby zobaczyć zrzuty ekranu lokalnie:

```sh
python3 tool/ecb_to_json.py --output screenshots/rates.json
flutter test --update-goldens screenshots/
```

### Konfiguracja (jednorazowo)

1. **Klucz przesyłania.** Na swoim komputerze (z zainstalowaną Javą):

   ```sh
   keytool -genkeypair -v -keystore upload-keystore.jks -alias upload \
     -keyalg RSA -keysize 2048 -validity 10000
   base64 -w0 upload-keystore.jks   # macOS: base64 -i upload-keystore.jks
   ```

   Przechowuj plik `.jks` i jego hasła w bezpiecznym miejscu, poza repozytorium. Unikaj ukośników wstecznych w hasłach.

2. **Sekrety GitHuba** (Settings → Secrets and variables → Actions → Secrets):
   `ANDROID_KEYSTORE_BASE64` (wynik `base64`), `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS` (`upload`), `ANDROID_KEY_PASSWORD` (opcjonalny, jeśli jest taki sam jak hasło keystore).

3. **Aplikacja w Play Console**: utworzyć aplikację, wypełnić stronę i kwestionariusze (treść, prywatność…), a potem włączyć podpisywanie aplikacji przez Google Play.

4. **Pierwsze przesłanie ręcznie** (wymagane przez Google): uruchomić workflow `Play Store` z karty Actions, pobrać artefakt `moneyconverter-aab-…` i przesłać go w Play Console na ścieżkę „Testy wewnętrzne”.

5. **Konto usługi** do automatycznych przesłań: w Google Cloud utworzyć konto usługi i klucz JSON, włączyć Google Play Android Developer API, a następnie zaprosić adres konta usługi w Play Console (Użytkownicy i uprawnienia) z prawem publikowania na ścieżkach testowych. Zawartość JSON zapisać w sekrecie `PLAY_SERVICE_ACCOUNT_JSON`.

6. **Włączyć automatyczne przesłania** (Settings → Secrets and variables → Actions → Variables):
   - `PLAY_STORE_ENABLED` = `true`
   - `PLAY_TRACK` (opcjonalnie): `internal`, `alpha` (test zamknięty), `beta` (test otwarty) lub `production`
   - `PLAY_RELEASE_STATUS` (opcjonalnie): domyślnie `completed`; użyć `draft`, dopóki aplikacja nie została nigdy opublikowana, w przeciwnym razie Google odrzuci przesłanie.

### Warto wiedzieć

- Na osobistym koncie dewelopera utworzonym po 13 listopada 2023 r. Google wymaga przed otwarciem produkcji testu zamkniętego z co najmniej 12 testerami zapisanymi przez 14 dni z rzędu. Testy wewnętrzne się nie liczą: do tego testu zamkniętego użyj ścieżki `alpha`.
- **„Podpisany niewłaściwym kluczem” w Play Console**: porównać odciski widoczne w podsumowaniu uruchomienia („Android bundle signature”) z Play Console → Testowanie i publikowanie → Integralność aplikacji → Certyfikat klucza przesyłania. Przesyłać tylko artefakty `moneyconverter-aab-…`: `dry-run-do-not-upload-aab-…` pochodzą z pull requestów i są podpisane jednorazowym kluczem. Jeśli klucz zarejestrowany w Google nie jest Twój, poproś tam o zresetowanie klucza przesyłania, używając certyfikatu wyeksportowanego przez `keytool -export -rfc -keystore upload-keystore.jks -alias upload -file upload_certificate.pem`.
- Buildy Androida w `ci.yml` i `deploy.yml` pozostają wyłączone; ten workflow jest od nich niezależny.

## Windows i Linux

Workflow `Desktop` tworzy przy każdym pushu na `main` (lub ręcznie z karty Actions):

- **Linux**: snap (`money-converter-ecb`, baza `core24`, rozszerzenie GNOME);
- **Windows**: pakiet MSIX dla Microsoft Store.

Oba pakiety są zawsze dostępne jako artefakty uruchomienia. Publikacja działa tak samo jak w Play Store:

| Wyzwalacz | Snap Store | Microsoft Store |
| --- | --- | --- |
| Push na `main` | Gdy zmienna `SNAP_STORE_ENABLED` ma wartość `true` | Gdy zmienna `MSSTORE_ENABLED` ma wartość `true` |
| Uruchomienie ręczne (karta Actions) | Gdy dane logowania są ustawione | Gdy dane logowania są ustawione |
| PR dotyczący pakowania | Nigdy (tylko build) | Nigdy (tylko build) |

### Snap Store (jednorazowo)

1. Założyć konto na [snapcraft.io](https://snapcraft.io) i zarejestrować nazwę: `snapcraft register money-converter-ecb`. Jeśli nazwa jest zajęta, wybrać inną i zmienić ją w `snap/snapcraft.yaml` (pole `name`, nazwa aplikacji i nazwa pliku `.desktop` w `snap/gui/`).
2. Wygenerować dane logowania dla CI:

   ```sh
   snapcraft export-login --snaps=money-converter-ecb --acls=package_access,package_push,package_update,package_release -
   ```

3. Zapisać wynik w sekrecie `SNAPCRAFT_STORE_CREDENTIALS`.
4. Włączyć automatyczną publikację: zmienna `SNAP_STORE_ENABLED` = `true`.
5. Opcjonalnie: zmienna `SNAP_CHANNEL` wybiera kanał (domyślnie `edge`, dalej `beta`, `candidate` lub `stable`).

### Microsoft Store (jednorazowo)

1. Mieć konto dewelopera w [Partner Center](https://partner.microsoft.com/dashboard) i zarezerwować tam nazwę aplikacji.
2. Na stronie aplikacji, w sekcji „Tożsamość produktu”, skopiować do **zmiennych** GitHuba:
   - `MSSTORE_IDENTITY_NAME` (Package/Identity/Name)
   - `MSSTORE_PUBLISHER` (Package/Identity/Publisher, w postaci `CN=…`)
   - `MSSTORE_PUBLISHER_DISPLAY_NAME` (Package/Properties/PublisherDisplayName)
   - `MSSTORE_PRODUCT_ID` (Store ID, 12 znaków)
3. Wykonać **pierwsze zgłoszenie ręcznie** (wymagane przez Microsoft): uruchomić workflow `Desktop`, pobrać artefakt `moneyconverter-msix-…` i przesłać go w zgłoszeniu w Partner Center, razem ze stroną, zrzutami ekranu i klasyfikacją wiekową.
4. Powiązać katalog Microsoft Entra ID (Azure AD) z kontem Partner Center, utworzyć w nim aplikację z rolą „Manager”, a następnie zapisać w **sekretach** GitHuba: `PARTNER_CENTER_TENANT_ID`, `PARTNER_CENTER_SELLER_ID`, `PARTNER_CENTER_CLIENT_ID`, `PARTNER_CENTER_CLIENT_SECRET`.
5. Włączyć automatyczną publikację: zmienna `MSSTORE_ENABLED` = `true`.

Od tej pory każdy push na `main` tworzy i wysyła nowe zgłoszenie (wersja `2.0.<numer uruchomienia>.0`).

## Licencja

Copyright (C) 2026 Julien Addé

Ten program jest wolnym oprogramowaniem: możesz go rozpowszechniać i/lub modyfikować na warunkach Powszechnej Licencji Publicznej GNU opublikowanej przez Free Software Foundation, w wersji 3 tej licencji lub (według własnego wyboru) dowolnej późniejszej wersji (`GPL-3.0-or-later`).

Ten program jest rozpowszechniany w nadziei, że będzie użyteczny, ale BEZ JAKIEJKOLWIEK GWARANCJI, nawet domyślnej gwarancji PRZYDATNOŚCI HANDLOWEJ lub PRZYDATNOŚCI DO OKREŚLONEGO CELU. Szczegóły w pliku [LICENSE](LICENSE). Wiążący prawnie jest wyłącznie angielski tekst licencji.
