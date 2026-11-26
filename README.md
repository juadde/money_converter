**English** | [Français](README.fr.md) | [Deutsch](README.de.md) | [Español](README.es.md) | [Italiano](README.it.md) | [Polski](README.pl.md) | [Română](README.ro.md) | [Lietuvių](README.lt.md)

# Money Converter

Currency converter based on the
[euro foreign exchange reference rates of the European Central Bank](https://www.ecb.europa.eu/stats/policy_and_exchange_rates/euro_reference_exchange_rates/html/index.en.html),
published as open data every working day around 16:00 CET.

Flutter app: Android, iOS, web, Windows and Linux from a single code base.

## Features

- Live conversion while typing, between all the currencies published by the ECB (plus the euro).
- Currencies pegged to the euro, which the ECB does not publish: Cape Verdean escudo (CVE), CFA francs (XOF, XAF), Comorian franc (KMF), CFP franc (XPF), Bosnia-Herzegovina convertible mark (BAM) and dobra (STN). Their rates come from the official parity and the ECB rates of the day (`lib/models/euro_pegs.dart`).
- Swap the pair, search a currency by code or by name.
- Rates of the day and a chart of past values (1 week, 1 month, 3 months); touching the chart shows the value of a day.
- Works offline with the last saved rates.
- SVG flags (`country_flags` package), visible on every platform, Windows and Linux included.
- English, French, German, Spanish, Italian, Polish, Romanian and Lithuanian: device language by default (English when it is not translated), can be changed in the app and is remembered; light and dark theme.

Privacy policy (required by the stores): `site/privacy.html`, published at https://juadde.github.io/money_converter/privacy.html.

## Where the rates come from

1. **ECB, directly**: `eurofxref-hist-90d.xml` (90 days, so today's rates and the history in one request).
2. **Fallback**: `rates.json`, a JSON copy of the same file, rebuilt by the `Deploy` workflow and served by GitHub Pages next to the web app.
3. **Local cache**: the last response, reused for one hour, then as a last resort when the network is down.

The ECB server sends no CORS header, so a browser cannot read its XML. The web version therefore reads `rates.json` directly (same origin).

The fallback URL can be changed at build time:

```sh
flutter run --dart-define=RATES_FALLBACK_URL=https://example.org/rates.json
```

## Development

The `android/`, `ios/`, `web/`, `windows/` and `linux/` folders are not versioned: a script generates them with `flutter create` and applies the settings the app needs (Internet permission, app name, icons).

```sh
bash tool/bootstrap_platforms.sh
flutter pub get
flutter test
flutter run
```

To run the web version locally, it needs a `rates.json` next to the app, or a fallback URL:

```sh
python3 tool/ecb_to_json.py --output web/rates.json
flutter run -d chrome
```

## Icon

The icon (a green banknote) is drawn in SVG in `assets/icon/`. After a change, render the PNGs again, then the platform icons:

```sh
rsvg-convert -w 1024 -h 1024 assets/icon/bill.svg -o assets/icon/icon.png
rsvg-convert -w 1024 -h 1024 assets/icon/bill_foreground.svg -o assets/icon/icon_foreground.png
dart run flutter_launcher_icons
```

## Code layout

| Folder | Content |
| --- | --- |
| `lib/models` | Rates of a day, snapshot, history of a pair, euro parities |
| `lib/data` | ECB XML and JSON parsing, HTTP sources, cache, repository with fallback |
| `lib/state` | Riverpod providers (rates, remembered pair, amount and language) |
| `lib/ui` | Main screen, currency picker, chart, flags |
| `lib/l10n` | Texts in the 8 languages |
| `screenshots` | Store screenshot generator |
| `fastlane/metadata/android` | Google Play listing in the 8 languages |
| `site` | Privacy policy page |
| `tool` | Platform generation, ECB XML to JSON, store graphics and checks |
| `assets/icon` | App icon (SVG sources and 1024 px PNG) |

## Continuous integration and deployment

- **CI** (`.github/workflows/ci.yml`), on every PR and every push on `main`: analysis, tests, store listing check, web build. The APK build is disabled for now (`if: false`).
- **Desktop** (`.github/workflows/desktop.yml`): Linux snap and Windows MSIX package on every push on `main`, published to the Snap Store and the Microsoft Store once enabled (see "Windows and Linux").
- **Play Store** (`.github/workflows/play-store.yml`): signed Android bundle and store listing, sent to Google Play on every push on `main` once enabled (see "Play Store").
- **Deploy** (`.github/workflows/deploy.yml`):
  - on every push on `main`: web app and privacy policy on GitHub Pages. The iOS build is disabled for now (`if: false`);
  - every working day after the ECB publication: web redeployment with an up-to-date `rates.json`.
- **Release** (`.github/workflows/release.yml`), on every push on `main`: a GitHub release `v<version>-<run>` with the signed Android APK, a Windows zip and the Linux tar.gz and snap.

### One-time GitHub settings

- **Pages**: Settings → Pages → Source: "GitHub Actions". On a private repository, Pages needs a paid plan; otherwise the repository must be public.
- **Android**: the APK of the GitHub releases is signed with the upload key, so it cannot update a version installed from Google Play (uninstall it first). Play Store builds are signed with the upload key too (see below).
- **iOS**: the build is not signed. A TestFlight or App Store release needs an Apple Developer account and its certificates as secrets.

## Play Store

The `Play Store` workflow builds an Android App Bundle (`.aab`) signed with the upload key and publishes it to Google Play with [fastlane](https://docs.fastlane.tools/actions/upload_to_play_store/), together with the whole store listing: texts, release notes, icon, feature graphic and screenshots. The `versionCode` is the workflow run number, so it increases with every upload. The app ID is `com.juadde.moneyconverter`; it can no longer change once the app exists on Google Play.

| Trigger | What happens |
| --- | --- |
| Push on `main` | Nothing until the `PLAY_STORE_ENABLED` variable is `true`; then upload to the `PLAY_TRACK` track (`internal` by default) |
| Manual run (Actions tab) | Build and upload to the chosen track; without a service account, the bundle is only available as a run artifact |
| PR changing the workflow, the script or the listing | Dry run with a throwaway key, nothing is uploaded |

### Play Store listing

The whole listing lives in the repository and is published with every release, for the 8 languages (`fastlane/metadata/android/<locale>/`):

| File | Content | Limit |
| --- | --- | --- |
| `title.txt` | App name | 30 characters |
| `short_description.txt` | Short description | 80 characters |
| `full_description.txt` | Full description | 4,000 characters |
| `changelogs/default.txt` | Release notes ("What's new") | 500 characters |
| `images/icon.png`, `images/featureGraphic.png` | 512 px icon and 1024 × 500 feature graphic (`tool/store_graphics.py`) | |
| `images/phoneScreenshots/` | 4 screenshots, 1080 × 1920, **generated** on every publication by `screenshots/screenshots_test.dart` with the ECB rates of the day | |

`tool/check_store_metadata.py` checks the limits (run by the CI). To see the screenshots locally:

```sh
python3 tool/ecb_to_json.py --output screenshots/rates.json
flutter test --update-goldens screenshots/
```

### Setup (once)

1. **Upload key.** On your computer (with Java installed):

   ```sh
   keytool -genkeypair -v -keystore upload-keystore.jks -alias upload \
     -keyalg RSA -keysize 2048 -validity 10000
   base64 -w0 upload-keystore.jks   # macOS: base64 -i upload-keystore.jks
   ```

   Keep the `.jks` file and its passwords somewhere safe, outside the repository. Avoid backslashes in the passwords.

2. **GitHub secrets** (Settings → Secrets and variables → Actions → Secrets):
   `ANDROID_KEYSTORE_BASE64` (output of `base64`), `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS` (`upload`), `ANDROID_KEY_PASSWORD` (optional when it is the same as the keystore password).

3. **App in the Play Console**: create the app, fill in the listing and the questionnaires (content, privacy…), then enable Play App Signing.

4. **First upload by hand** (required by Google): run the `Play Store` workflow from the Actions tab, download the `moneyconverter-aab-…` artifact, then upload it in the Play Console to the "Internal testing" track.

5. **Service account** for automatic uploads: in Google Cloud, create a service account and a JSON key, enable the Google Play Android Developer API, then invite the service account address in the Play Console (Users and permissions) with permission to release to testing tracks. Put the JSON content in the `PLAY_SERVICE_ACCOUNT_JSON` secret.

6. **Enable automatic uploads** (Settings → Secrets and variables → Actions → Variables):
   - `PLAY_STORE_ENABLED` = `true`
   - `PLAY_TRACK` (optional): `internal`, `alpha` (closed testing), `beta` (open testing) or `production`
   - `PLAY_RELEASE_STATUS` (optional): `completed` by default; use `draft` as long as the app has never been published, otherwise Google rejects the upload.

### Good to know

- On a personal developer account created after November 13, 2023, Google requires a closed test with at least 12 testers opted in for 14 days in a row before opening production. Internal testing does not count: use the `alpha` track for this closed test.
- **"Signed with the wrong key" in the Play Console**: compare the fingerprints of your keystore, printed on your computer by `keytool -list -v -keystore upload-keystore.jks -alias upload` (the run logs are public, so they never show them), with Play Console → Test and release → App integrity → Upload key certificate. Only upload `moneyconverter-aab-…` artifacts: `dry-run-do-not-upload-aab-…` ones come from pull requests and are signed with a throwaway key. If the key registered with Google is not yours, request an upload key reset there with the certificate exported by `keytool -export -rfc -keystore upload-keystore.jks -alias upload -file upload_certificate.pem`.
- The Android builds of `ci.yml` and `deploy.yml` stay disabled; this workflow is independent.

## Windows and Linux

The `Desktop` workflow builds, on every push on `main` (or by hand from the Actions tab):

- **Linux**: a snap (`money-converter-ecb`, `core24` base, GNOME extension);
- **Windows**: an MSIX package for the Microsoft Store.

Both packages are always available as run artifacts. Publishing follows the same logic as the Play Store:

| Trigger | Snap Store | Microsoft Store |
| --- | --- | --- |
| Push on `main` | When the `SNAP_STORE_ENABLED` variable is `true` | When the `MSSTORE_ENABLED` variable is `true` |
| Manual run (Actions tab) | When the credentials are set | When the credentials are set |
| PR touching the packaging | Never (build only) | Never (build only) |

### Snap Store (once)

1. Create an account on [snapcraft.io](https://snapcraft.io) and register the name: `snapcraft register money-converter-ecb`. If the name is taken, pick another one and change it in `snap/snapcraft.yaml` (`name` field, app name and name of the `.desktop` file in `snap/gui/`).
2. Generate credentials for the CI:

   ```sh
   snapcraft export-login --snaps=money-converter-ecb --acls=package_access,package_push,package_update,package_release -
   ```

3. Put the output in the `SNAPCRAFT_STORE_CREDENTIALS` secret.
4. Enable automatic publishing: variable `SNAP_STORE_ENABLED` = `true`.
5. Optional: the `SNAP_CHANNEL` variable picks the channel (`edge` by default, then `beta`, `candidate` or `stable`).

### Microsoft Store (once)

1. Have a developer account in [Partner Center](https://partner.microsoft.com/dashboard) and reserve the app name there.
2. On the app page, "Product identity", copy into GitHub **variables**:
   - `MSSTORE_IDENTITY_NAME` (Package/Identity/Name)
   - `MSSTORE_PUBLISHER` (Package/Identity/Publisher, in the form `CN=…`)
   - `MSSTORE_PUBLISHER_DISPLAY_NAME` (Package/Properties/PublisherDisplayName)
   - `MSSTORE_PRODUCT_ID` (Store ID, 12 characters)
3. Make the **first submission by hand** (required by Microsoft): run the `Desktop` workflow, download the `moneyconverter-msix-…` artifact and upload it in a Partner Center submission, with the listing, the screenshots and the age rating. The `windows-store-listing-…` artifact of the same run holds the whole listing for the 8 languages (texts, desktop screenshots 1920 × 1080, logos): unzip it and import the `msstore-listing` folder in Store listings → Import listing. It is built by `tool/msstore_listing.py` from the Google Play texts and from `store/windows/listing_template.csv` (the layout exported from Partner Center).
4. Associate a Microsoft Entra ID (Azure AD) directory with the Partner Center account, create an application with the "Manager" role there, then put into GitHub **secrets**: `PARTNER_CENTER_TENANT_ID`, `PARTNER_CENTER_SELLER_ID`, `PARTNER_CENTER_CLIENT_ID`, `PARTNER_CENTER_CLIENT_SECRET`.
5. Enable automatic publishing: variable `MSSTORE_ENABLED` = `true`.

From then on, every push on `main` creates and sends a new submission (version `2.0.<run number>.0`).

## License

Copyright (C) 2026 Julien Addé

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version (`GPL-3.0-or-later`).

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the [LICENSE](LICENSE) file for more details.
