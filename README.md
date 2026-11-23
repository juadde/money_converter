# Money Converter

Convertisseur de devises basé sur les
[taux de référence de la Banque centrale européenne](https://www.ecb.europa.eu/stats/policy_and_exchange_rates/euro_reference_exchange_rates/html/index.fr.html),
publiés en open data chaque jour ouvré vers 16 h (CET).

Application Flutter : Android, iOS, web, Windows et Linux avec une seule base de code.

## Fonctionnalités

- Conversion en direct pendant la frappe, entre toutes les devises publiées par la BCE (plus l'euro).
- Inversion de la paire, recherche de devise par code ou par nom.
- Taux du jour et graphique des valeurs passées (1 semaine, 1 mois, 3 mois) ; toucher le graphique affiche la valeur d'un jour.
- Fonctionne hors ligne avec les derniers taux enregistrés.
- Français et anglais (langue de l'appareil), thème clair et sombre.

## D'où viennent les taux

1. **BCE en direct** : `eurofxref-hist-90d.xml` (90 jours, donc le taux du jour et l'historique en une requête).
2. **Secours** : `rates.json`, une copie JSON du même fichier, régénérée par le workflow `Deploy` et servie par GitHub Pages à côté de l'appli web.
3. **Cache local** : la dernière réponse, réutilisée pendant une heure puis en dernier recours si le réseau est indisponible.

Le serveur de la BCE n'envoie pas d'en-tête CORS : un navigateur ne peut pas lire son XML. La version web utilise donc directement `rates.json` (même origine).

L'URL de secours se change à la compilation :

```sh
flutter run --dart-define=RATES_FALLBACK_URL=https://exemple.org/rates.json
```

## Développement

Les dossiers `android/`, `ios/`, `web/`, `windows/` et `linux/` ne sont pas versionnés : un script les génère avec `flutter create` et y applique les réglages nécessaires (permission Internet, nom de l'appli).

```sh
bash tool/bootstrap_platforms.sh
flutter pub get
flutter test
flutter run
```

Pour la version web en local, il faut un `rates.json` à côté de l'appli, ou une URL de secours :

```sh
python3 tool/ecb_to_json.py --output web/rates.json
flutter run -d chrome
```

## Icône

L'icône (billet vert) est dessinée en SVG dans `assets/icon/`. Après modification, régénérer les PNG puis les icônes des plateformes :

```sh
rsvg-convert -w 1024 -h 1024 assets/icon/bill.svg -o assets/icon/icon.png
rsvg-convert -w 1024 -h 1024 assets/icon/bill_foreground.svg -o assets/icon/icon_foreground.png
dart run flutter_launcher_icons
```

## Organisation du code

| Dossier | Contenu |
| --- | --- |
| `lib/models` | Taux d'un jour, instantané, historique d'une paire |
| `lib/data` | Lecture du XML BCE et du JSON, sources HTTP, cache, dépôt avec repli |
| `lib/state` | Providers Riverpod (taux, paire et montant mémorisés) |
| `lib/ui` | Écran principal, sélecteur de devise, graphique |
| `lib/l10n` | Textes français et anglais |
| `tool` | Génération des plateformes, conversion XML BCE vers JSON |
| `assets/icon` | Icône de l'appli (sources SVG et PNG 1024 px) |

## Intégration et déploiement continus

- **CI** (`.github/workflows/ci.yml`), sur chaque PR et chaque push sur `main` : analyse, tests, build web. Le build de l'APK est désactivé pour l'instant (`if: false`).
- **Desktop** (`.github/workflows/desktop.yml`) : snap Linux et paquet MSIX Windows à chaque push sur `main`, publiés sur le Snap Store et le Microsoft Store quand les identifiants sont configurés (voir « Windows et Linux »).
- **Play Store** (`.github/workflows/play-store.yml`) : bundle Android signé, envoyé sur Google Play à chaque push sur `main` une fois activé (voir « Play Store »).
- **Deploy** (`.github/workflows/deploy.yml`) :
  - à chaque push sur `main` : appli web sur GitHub Pages. La release APK et le build iOS sont désactivés pour l'instant (`if: false`) ;
  - chaque jour ouvré après la publication de la BCE : redéploiement web avec un `rates.json` à jour.

### Réglages à faire une fois sur GitHub

- **Pages** : Settings → Pages → Source : « GitHub Actions ». Sur un dépôt privé, Pages demande une offre payante ; sinon il faut rendre le dépôt public.
- **Android** : l'APK de la release `latest` (désactivée) est signé avec une clé de debug. Les builds du Play Store sont signés avec la clé d'importation (voir ci-dessous).
- **iOS** : le build n'est pas signé. Une publication TestFlight ou App Store demande un compte Apple Developer et ses certificats en secrets.

## Play Store

Le workflow `Play Store` construit un Android App Bundle (`.aab`) signé avec la clé d'importation et l'envoie sur Google Play. Le `versionCode` est le numéro de run du workflow, donc il augmente à chaque envoi. L'identifiant de l'appli est `com.juadde.moneyconverter` ; il ne pourra plus changer une fois l'appli créée sur Google Play.

| Déclencheur | Ce qui se passe |
| --- | --- |
| Push sur `main` | Rien tant que la variable `PLAY_STORE_ENABLED` ne vaut pas `true` ; ensuite, envoi sur la piste `PLAY_TRACK` (par défaut `internal`) |
| Lancement manuel (onglet Actions) | Build et envoi sur la piste choisie ; sans compte de service, le bundle est seulement disponible en artefact du run |
| PR qui modifie le workflow ou le script | Build d'essai avec une clé jetable, rien n'est envoyé |

### Mise en place (une seule fois)

1. **Clé d'importation.** Sur ton ordinateur (Java installé) :

   ```sh
   keytool -genkeypair -v -keystore upload-keystore.jks -alias upload \
     -keyalg RSA -keysize 2048 -validity 10000
   base64 -w0 upload-keystore.jks   # macOS : base64 -i upload-keystore.jks
   ```

   Garde le fichier `.jks` et ses mots de passe en lieu sûr, hors du dépôt. Évite les antislashs dans les mots de passe.

2. **Secrets GitHub** (Settings → Secrets and variables → Actions → Secrets) :
   `ANDROID_KEYSTORE_BASE64` (sortie de `base64`), `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS` (`upload`), `ANDROID_KEY_PASSWORD` (facultatif s'il est identique au mot de passe du keystore).

3. **Appli dans la Play Console** : créer l'appli, remplir la fiche et les questionnaires (contenu, confidentialité…), puis activer la signature des applis par Google Play.

4. **Premier envoi à la main** (exigé par Google) : lancer le workflow `Play Store` depuis l'onglet Actions, télécharger l'artefact `moneyconverter-aab-…`, puis l'importer dans la Play Console sur la piste « Tests internes ».

5. **Compte de service** pour les envois automatiques : dans Google Cloud, créer un compte de service et une clé JSON, activer l'API Google Play Android Developer, puis inviter l'adresse du compte de service dans la Play Console (Utilisateurs et autorisations) avec le droit de publier sur les pistes de test. Ajouter le contenu du JSON dans le secret `PLAY_SERVICE_ACCOUNT_JSON`.

6. **Activer les envois automatiques** (Settings → Secrets and variables → Actions → Variables) :
   - `PLAY_STORE_ENABLED` = `true`
   - `PLAY_TRACK` (facultatif) : `internal`, `alpha` (test fermé), `beta` (test ouvert) ou `production`
   - `PLAY_RELEASE_STATUS` (facultatif) : `completed` par défaut ; mettre `draft` tant que l'appli n'a jamais été publiée, sinon Google refuse l'envoi.

### Bon à savoir

- Sur un compte développeur personnel créé après le 13 novembre 2023, Google exige un test fermé avec au moins 12 testeurs inscrits pendant 14 jours d'affilée avant d'ouvrir la production. Les tests internes ne comptent pas : utilise la piste `alpha` pour ce test fermé.
- Les builds Android de `ci.yml` et `deploy.yml` restent désactivés ; ce workflow est indépendant.

## Windows et Linux

Le workflow `Desktop` construit, à chaque push sur `main` (ou à la main depuis l'onglet Actions) :

- **Linux** : un snap (`money-converter-ecb`, base `core24`, extension GNOME) ;
- **Windows** : un paquet MSIX pour le Microsoft Store.

Les deux paquets sont toujours disponibles en artefacts du run. Chacun n'est publié que si les identifiants de sa boutique sont configurés ; une PR qui touche l'empaquetage déclenche seulement les builds.

### Snap Store (une seule fois)

1. Créer un compte sur [snapcraft.io](https://snapcraft.io) et réserver le nom : `snapcraft register money-converter-ecb`. Si le nom est pris, en choisir un autre et le changer dans `snap/snapcraft.yaml` (champ `name`, nom de l'appli et nom du fichier `.desktop` dans `snap/gui/`).
2. Générer des identifiants pour la CI :

   ```sh
   snapcraft export-login --snaps=money-converter-ecb --acls=package_access,package_push,package_update,package_release -
   ```

3. Mettre la sortie dans le secret `SNAPCRAFT_STORE_CREDENTIALS`.
4. Facultatif : la variable `SNAP_CHANNEL` choisit le canal (`edge` par défaut, puis `beta`, `candidate` ou `stable`).

### Microsoft Store (une seule fois)

1. Avoir un compte développeur dans [Partner Center](https://partner.microsoft.com/dashboard) et y réserver le nom de l'appli.
2. Dans la page de l'appli, « Identité du produit », recopier dans les **variables** GitHub :
   - `MSSTORE_IDENTITY_NAME` (Package/Identity/Name)
   - `MSSTORE_PUBLISHER` (Package/Identity/Publisher, de la forme `CN=…`)
   - `MSSTORE_PUBLISHER_DISPLAY_NAME` (Package/Properties/PublisherDisplayName)
   - `MSSTORE_PRODUCT_ID` (Store ID, 12 caractères)
3. Faire la **première soumission à la main** (exigé par Microsoft) : lancer le workflow `Desktop`, télécharger l'artefact `moneyconverter-msix-…` et l'importer dans une soumission Partner Center, avec la fiche, les captures et la classification d'âge.
4. Associer un annuaire Microsoft Entra ID (Azure AD) au compte Partner Center, y créer une application avec le rôle « Manager », puis mettre dans les **secrets** GitHub : `PARTNER_CENTER_TENANT_ID`, `PARTNER_CENTER_SELLER_ID`, `PARTNER_CENTER_CLIENT_ID`, `PARTNER_CENTER_CLIENT_SECRET`.

Ensuite, chaque push sur `main` crée et envoie une nouvelle soumission (version `2.0.<numéro de run>.0`).
