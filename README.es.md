[English](README.md) | [Français](README.fr.md) | [Deutsch](README.de.md) | **Español** | [Italiano](README.it.md) | [Polski](README.pl.md) | [Română](README.ro.md) | [Lietuvių](README.lt.md)

# Money Converter

Conversor de divisas basado en los
[tipos de cambio de referencia del euro del Banco Central Europeo](https://www.ecb.europa.eu/stats/policy_and_exchange_rates/euro_reference_exchange_rates/html/index.es.html),
publicados como datos abiertos cada día hábil hacia las 16:00 (CET).

Aplicación Flutter: Android, iOS, web, Windows y Linux con una única base de código.

## Funciones

- Conversión al instante mientras se escribe, entre todas las divisas publicadas por el BCE (más el euro).
- Divisas con paridad fija con el euro, que el BCE no publica: escudo caboverdiano (CVE), francos CFA (XOF, XAF), franco comorense (KMF), franco CFP (XPF), marco convertible de Bosnia y Herzegovina (BAM) y dobra (STN). Sus tipos se obtienen de la paridad oficial y de los tipos del BCE del día (`lib/models/euro_pegs.dart`).
- Intercambio del par, búsqueda de divisas por código o por nombre.
- Tipos del día y gráfico de los valores pasados (1 semana, 1 mes, 3 meses); al tocar el gráfico se muestra el valor de un día.
- Funciona sin conexión con los últimos tipos guardados.
- Banderas en SVG (paquete `country_flags`), visibles en todas las plataformas, incluidas Windows y Linux.
- Inglés, francés, alemán, español, italiano, polaco, rumano y lituano: idioma del dispositivo por defecto (inglés si no está traducido), modificable en la app y guardado; tema claro y oscuro.

Política de privacidad (exigida por las tiendas): `site/privacy.html`, publicada en https://juadde.github.io/money_converter/privacy.html.

## De dónde vienen los tipos

1. **BCE, directamente**: `eurofxref-hist-90d.xml` (90 días, es decir, los tipos del día y el historial en una sola petición).
2. **Respaldo**: `rates.json`, una copia JSON del mismo archivo, regenerada por el workflow `Deploy` y servida por GitHub Pages junto a la app web.
3. **Caché local**: la última respuesta, reutilizada durante una hora y después como último recurso si no hay red.

El servidor del BCE no envía cabecera CORS, así que un navegador no puede leer su XML. Por eso la versión web lee directamente `rates.json` (mismo origen).

La URL de respaldo se puede cambiar al compilar:

```sh
flutter run --dart-define=RATES_FALLBACK_URL=https://example.org/rates.json
```

## Desarrollo

Las carpetas `android/`, `ios/`, `web/`, `windows/` y `linux/` no están versionadas: un script las genera con `flutter create` y aplica los ajustes que necesita la app (permiso de Internet, nombre de la app, iconos).

```sh
bash tool/bootstrap_platforms.sh
flutter pub get
flutter test
flutter run
```

Para ejecutar la versión web en local hace falta un `rates.json` junto a la app, o una URL de respaldo:

```sh
python3 tool/ecb_to_json.py --output web/rates.json
flutter run -d chrome
```

## Icono

El icono (un billete verde) está dibujado en SVG en `assets/icon/`. Tras un cambio, volver a generar los PNG y después los iconos de las plataformas:

```sh
rsvg-convert -w 1024 -h 1024 assets/icon/bill.svg -o assets/icon/icon.png
rsvg-convert -w 1024 -h 1024 assets/icon/bill_foreground.svg -o assets/icon/icon_foreground.png
dart run flutter_launcher_icons
```

## Organización del código

| Carpeta | Contenido |
| --- | --- |
| `lib/models` | Tipos de un día, instantánea, historial de un par, paridades con el euro |
| `lib/data` | Lectura del XML del BCE y del JSON, fuentes HTTP, caché, repositorio con respaldo |
| `lib/state` | Providers de Riverpod (tipos, par, importe e idioma guardados) |
| `lib/ui` | Pantalla principal, selector de divisas, gráfico, banderas |
| `lib/l10n` | Textos en los 8 idiomas |
| `screenshots` | Generación de las capturas para las tiendas |
| `fastlane/metadata/android` | Ficha de Google Play en los 8 idiomas |
| `site` | Página de la política de privacidad |
| `tool` | Generación de las plataformas, XML del BCE a JSON, gráficos y comprobaciones de las tiendas |
| `assets/icon` | Icono de la app (fuentes SVG y PNG de 1024 px) |

## Integración y despliegue continuos

- **CI** (`.github/workflows/ci.yml`), en cada PR y cada push a `main`: análisis, pruebas, comprobación de la ficha de la tienda, build web. El build del APK está desactivado por ahora (`if: false`).
- **Desktop** (`.github/workflows/desktop.yml`): snap de Linux y paquete MSIX de Windows en cada push a `main`, publicados en Snap Store y Microsoft Store una vez activados (ver «Windows y Linux»).
- **Play Store** (`.github/workflows/play-store.yml`): bundle de Android firmado y ficha de la tienda, enviados a Google Play en cada push a `main` una vez activado (ver «Play Store»).
- **Deploy** (`.github/workflows/deploy.yml`):
  - en cada push a `main`: app web y política de privacidad en GitHub Pages. El build de iOS está desactivado por ahora (`if: false`);
  - cada día hábil tras la publicación del BCE: nuevo despliegue web con un `rates.json` actualizado.
- **Release** (`.github/workflows/release.yml`), en cada push a `main`: una release de GitHub `v<versión>-<ejecución>` con el APK de Android firmado, un zip de Windows y el tar.gz y el snap de Linux.
- **Security** (`.github/workflows/security.yml`), en cada PR, cada push a `main` y cada lunes: análisis de vulnerabilidades de las dependencias (ver «Seguridad y SBOM»).

### Ajustes únicos en GitHub

- **Pages**: Settings → Pages → Source: «GitHub Actions». En un repositorio privado, Pages requiere un plan de pago; si no, el repositorio debe ser público.
- **Android**: el APK de las releases de GitHub está firmado con la clave de subida, así que no puede actualizar una versión instalada desde Google Play (desinstalarla antes). Los builds del Play Store se firman con la clave de subida (ver más abajo).
- **iOS**: el build no está firmado. Publicar en TestFlight o en el App Store requiere una cuenta de Apple Developer y sus certificados como secretos.

## Seguridad y SBOM

Para informar de una vulnerabilidad, ver [SECURITY.md](SECURITY.md) (informe privado en GitHub, sin issue público).

- **SBOM**: cada build tiene su lista de materiales de software en formato SPDX, generada con [Syft](https://github.com/anchore/syft) (paquetes Dart y Flutter de `pubspec.lock` y los componentes encontrados en el build). Las releases de GitHub tienen una por archivo (`<archivo>.spdx.json`); la aplicación web publica la suya en [sbom.spdx.json](https://juadde.github.io/money_converter/sbom.spdx.json); los builds de las tiendas la guardan como artefacto de la ejecución.
- **Atestaciones**: los archivos de las releases tienen una atestación de procedencia del build y una de SBOM, firmadas con Sigstore. Para comprobar un archivo: `gh attestation verify money-converter-android.apk -R juadde/money_converter`.
- **Análisis de vulnerabilidades**: el workflow Security analiza el SBOM con [Grype](https://github.com/anchore/grype). Una pull request falla si hay una vulnerabilidad alta o crítica con corrección disponible. En `main` y cada lunes, todos los resultados van a la pestaña Security (Code scanning) y las dependencias al gráfico de dependencias.
- **Dependabot** (`.github/dependabot.yml`): cada lunes, una pull request para los paquetes Dart y otra para las GitHub Actions; las actualizaciones de seguridad, de inmediato.

Ajuste único: Settings → Code security → activar «Private vulnerability reporting», «Dependabot alerts» y «Dependabot security updates».

## Play Store

El workflow `Play Store` genera un Android App Bundle (`.aab`) firmado con la clave de subida y lo publica en Google Play con [fastlane](https://docs.fastlane.tools/actions/upload_to_play_store/), junto con la ficha completa: textos, novedades, icono, gráfico de funciones y capturas. El `versionCode` es el número de ejecución del workflow, así que aumenta con cada subida. El ID de la app es `com.juadde.moneyconverter`; ya no se puede cambiar una vez creada la app en Google Play.

| Disparador | Qué ocurre |
| --- | --- |
| Push a `main` | Nada mientras la variable `PLAY_STORE_ENABLED` no sea `true`; después, subida al canal `PLAY_TRACK` (`internal` por defecto) |
| Ejecución manual (pestaña Actions) | Build y subida al canal elegido; sin cuenta de servicio, el bundle solo está disponible como artefacto de la ejecución |
| PR que modifica el workflow, el script o la ficha | Prueba con una clave desechable, no se sube nada |

### Ficha del Play Store

Toda la ficha está en el repositorio y se publica con cada versión, para los 8 idiomas (`fastlane/metadata/android/<idioma>/`):

| Archivo | Contenido | Límite |
| --- | --- | --- |
| `title.txt` | Nombre de la app | 30 caracteres |
| `short_description.txt` | Descripción breve | 80 caracteres |
| `full_description.txt` | Descripción completa | 4000 caracteres |
| `changelogs/default.txt` | Novedades de la versión («What's new») | 500 caracteres |
| `images/icon.png`, `images/featureGraphic.png` | Icono de 512 px y gráfico de funciones de 1024 × 500 (`tool/store_graphics.py`) | |
| `images/phoneScreenshots/` | 4 capturas de 1080 × 1920, **generadas** en cada publicación por `screenshots/screenshots_test.dart` con los tipos del BCE del día | |

`tool/check_store_metadata.py` comprueba los límites (lo ejecuta la CI). Para ver las capturas en local:

```sh
python3 tool/ecb_to_json.py --output screenshots/rates.json
flutter test --update-goldens screenshots/
```

### Configuración (una sola vez)

1. **Clave de subida.** En tu ordenador (con Java instalado):

   ```sh
   keytool -genkeypair -v -keystore upload-keystore.jks -alias upload \
     -keyalg RSA -keysize 2048 -validity 10000
   base64 -w0 upload-keystore.jks   # macOS: base64 -i upload-keystore.jks
   ```

   Guarda el archivo `.jks` y sus contraseñas en un lugar seguro, fuera del repositorio. Evita las barras invertidas en las contraseñas.

2. **Secretos de GitHub** (Settings → Secrets and variables → Actions → Secrets):
   `ANDROID_KEYSTORE_BASE64` (salida de `base64`), `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS` (`upload`), `ANDROID_KEY_PASSWORD` (opcional si coincide con la contraseña del keystore).

3. **App en Play Console**: crear la app, rellenar la ficha y los cuestionarios (contenido, privacidad…) y activar la firma de aplicaciones de Google Play.

4. **Primera subida a mano** (exigida por Google): ejecutar el workflow `Play Store` desde la pestaña Actions, descargar el artefacto `moneyconverter-aab-…` y subirlo en Play Console al canal «Prueba interna».

5. **Cuenta de servicio** para las subidas automáticas: en Google Cloud, crear una cuenta de servicio y una clave JSON, activar la API Google Play Android Developer e invitar la dirección de la cuenta de servicio en Play Console (Usuarios y permisos) con permiso para publicar en los canales de prueba. Guardar el contenido del JSON en el secreto `PLAY_SERVICE_ACCOUNT_JSON`.

6. **Activar las subidas automáticas** (Settings → Secrets and variables → Actions → Variables):
   - `PLAY_STORE_ENABLED` = `true`
   - `PLAY_TRACK` (opcional): `internal`, `alpha` (prueba cerrada), `beta` (prueba abierta) o `production`
   - `PLAY_RELEASE_STATUS` (opcional): `completed` por defecto; usar `draft` mientras la app no se haya publicado nunca, si no Google rechaza la subida.

### Conviene saber

- En una cuenta de desarrollador personal creada después del 13 de noviembre de 2023, Google exige una prueba cerrada con al menos 12 testers inscritos durante 14 días seguidos antes de abrir la producción. Las pruebas internas no cuentan: usa el canal `alpha` para esta prueba cerrada.
- **«Firmado con una clave incorrecta» en Play Console**: comparar las huellas de tu keystore, que muestra en tu ordenador `keytool -list -v -keystore upload-keystore.jks -alias upload` (los registros de las ejecuciones son públicos y nunca las muestran), con Play Console → Probar y publicar → Integridad de la aplicación → Certificado de la clave de subida. Subir solo los artefactos `moneyconverter-aab-…`: los `dry-run-do-not-upload-aab-…` vienen de pull requests y están firmados con una clave desechable. Si la clave registrada en Google no es la tuya, solicita allí el restablecimiento de la clave de subida con el certificado exportado por `keytool -export -rfc -keystore upload-keystore.jks -alias upload -file upload_certificate.pem`.
- Los builds de Android de `ci.yml` y `deploy.yml` siguen desactivados; este workflow es independiente.

## Windows y Linux

El workflow `Desktop` genera, en cada push a `main` (o a mano desde la pestaña Actions):

- **Linux**: un snap (`money-converter-ecb`, base `core24`, extensión GNOME);
- **Windows**: un paquete MSIX para Microsoft Store.

Ambos paquetes están siempre disponibles como artefactos de la ejecución. La publicación sigue la misma lógica que en el Play Store:

| Disparador | Snap Store | Microsoft Store |
| --- | --- | --- |
| Push a `main` | Si la variable `SNAP_STORE_ENABLED` es `true` | Si la variable `MSSTORE_ENABLED` es `true` |
| Ejecución manual (pestaña Actions) | Si las credenciales están configuradas | Si las credenciales están configuradas |
| PR que afecta al empaquetado | Nunca (solo build) | Nunca (solo build) |

### Snap Store (una sola vez)

1. Crear una cuenta en [snapcraft.io](https://snapcraft.io) y registrar el nombre: `snapcraft register money-converter-ecb`. Si el nombre está ocupado, elegir otro y cambiarlo en `snap/snapcraft.yaml` (campo `name`, nombre de la app y nombre del archivo `.desktop` en `snap/gui/`).
2. Generar credenciales para la CI:

   ```sh
   snapcraft export-login --snaps=money-converter-ecb --acls=package_access,package_push,package_update,package_release -
   ```

3. Guardar la salida en el secreto `SNAPCRAFT_STORE_CREDENTIALS`.
4. Activar la publicación automática: variable `SNAP_STORE_ENABLED` = `true`.
5. Opcional: la variable `SNAP_CHANNEL` elige el canal (`edge` por defecto, después `beta`, `candidate` o `stable`).

### Microsoft Store (una sola vez)

1. Tener una cuenta de desarrollador en [Partner Center](https://partner.microsoft.com/dashboard) y reservar allí el nombre de la app.
2. En la página de la app, «Identidad del producto», copiar en **variables** de GitHub:
   - `MSSTORE_IDENTITY_NAME` (Package/Identity/Name)
   - `MSSTORE_PUBLISHER` (Package/Identity/Publisher, con la forma `CN=…`)
   - `MSSTORE_PUBLISHER_DISPLAY_NAME` (Package/Properties/PublisherDisplayName)
   - `MSSTORE_PRODUCT_ID` (Store ID, 12 caracteres)
3. Hacer el **primer envío a mano** (exigido por Microsoft): ejecutar el workflow `Desktop`, descargar el artefacto `moneyconverter-msix-…` y subirlo en un envío de Partner Center, con la ficha, las capturas y la clasificación por edades. El artefacto `windows-store-listing-…` de la misma ejecución contiene toda la ficha para los 8 idiomas (textos, capturas de escritorio 1920 × 1080, logotipos): descomprimirlo e importar la carpeta `msstore-listing` en Fichas de Store → Importar ficha. Lo genera `tool/msstore_listing.py` a partir de los textos de Google Play y de `store/windows/listing_template.csv` (la plantilla exportada de Partner Center).
4. Asociar un directorio de Microsoft Entra ID (Azure AD) a la cuenta de Partner Center, crear en él una aplicación con el rol «Manager» y guardar en **secretos** de GitHub: `PARTNER_CENTER_TENANT_ID`, `PARTNER_CENTER_SELLER_ID`, `PARTNER_CENTER_CLIENT_ID`, `PARTNER_CENTER_CLIENT_SECRET`.
5. Activar la publicación automática: variable `MSSTORE_ENABLED` = `true`.

A partir de ahí, cada push a `main` crea y envía un nuevo envío (versión `2.0.<número de ejecución>.0`).

## Licencia

Copyright (C) 2026 Julien Addé

Este programa es software libre: puede redistribuirlo y/o modificarlo según los términos de la Licencia Pública General de GNU publicada por la Free Software Foundation, ya sea la versión 3 de la licencia o (a su elección) cualquier versión posterior (`GPL-3.0-or-later`).

Este programa se distribuye con la esperanza de que sea útil, pero SIN NINGUNA GARANTÍA, ni siquiera la garantía implícita de COMERCIABILIDAD o IDONEIDAD PARA UN FIN DETERMINADO. Consulte el archivo [LICENSE](LICENSE) para más detalles. Solo el texto en inglés de la licencia tiene validez legal.
