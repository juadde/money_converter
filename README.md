# Money Converter

Convertisseur de devises basé sur les
[taux de référence de la Banque centrale européenne](https://www.ecb.europa.eu/stats/policy_and_exchange_rates/euro_reference_exchange_rates/html/index.fr.html),
publiés en open data chaque jour ouvré vers 16 h (CET).

Application Flutter : Android, iOS et web avec une seule base de code.

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

Les dossiers `android/`, `ios/` et `web/` ne sont pas versionnés : un script les génère avec `flutter create` et y applique les réglages nécessaires (permission Internet, nom de l'appli).

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

- **CI** (`.github/workflows/ci.yml`), sur chaque PR et chaque push sur `main` : analyse, tests, build web, build de l'APK (téléchargeable dans les artefacts du run).
- **Deploy** (`.github/workflows/deploy.yml`) :
  - à chaque push sur `main` : appli web sur GitHub Pages, APK publié dans la release `latest`, build iOS de contrôle ;
  - chaque jour ouvré après la publication de la BCE : redéploiement web avec un `rates.json` à jour.

### Réglages à faire une fois sur GitHub

- **Pages** : Settings → Pages → Source : « GitHub Actions ». Sur un dépôt privé, Pages demande une offre payante ; sinon il faut rendre le dépôt public.
- **Android** : l'APK est signé avec une clé de debug régénérée à chaque build, donc il faut désinstaller l'appli avant d'installer une nouvelle version. Une publication sur le Play Store demande un keystore fourni en secret.
- **iOS** : le build n'est pas signé. Une publication TestFlight ou App Store demande un compte Apple Developer et ses certificats en secrets.
