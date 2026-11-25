#!/usr/bin/env python3
"""Builds a Microsoft Store listing folder, ready for Partner Center's
"Import listing" (folder mode), for the 8 languages of the app.

The texts come from the Google Play listing (fastlane/metadata/android) plus
the Store-only fields below; the images from store/windows (logos) and the
screenshots rendered by screenshots/screenshots_test.dart.

Usage:
    python3 tool/msstore_listing.py --out build/msstore
Writes build/msstore/msstore-listing/listingData.csv and its images: import
the msstore-listing folder in Partner Center > Store listings.

The CSV keeps the exact layout of store/windows/listing_template.csv, the
file exported from Partner Center (Partner Center rejects any other layout).
"""

import argparse
import csv
import io
import pathlib
import shutil
import sys

ROOT_NAME = "msstore-listing"

# Partner Center language column -> Google Play listing folder.
LOCALES = {
    "en-us": "en-US",
    "fr-fr": "fr-FR",
    "de-de": "de-DE",
    "es-es": "es-ES",
    "it-it": "it-IT",
    "pl-pl": "pl-PL",
    "ro-ro": "ro",
    "lt-lt": "lt",
}

SCREENSHOTS = ["1_converter", "2_fixed_parity", "3_dark"]

DEV = "Julien Addé"
COPYRIGHT = "© 2026 Julien Addé"
LICENSE = "GNU GPL v3 or later: https://github.com/juadde/money_converter/blob/main/LICENSE"

CAPTIONS = {
    "en-us": ["Live conversion and 3-month history", "Currencies pegged to the euro, such as the Cape Verdean escudo", "Dark theme"],
    "fr-fr": ["Conversion en direct et évolution sur 3 mois", "Devises à parité fixe avec l'euro, comme l'escudo cap-verdien", "Thème sombre"],
    "de-de": ["Live-Umrechnung und Verlauf über 3 Monate", "Währungen mit festem Euro-Kurs, etwa der Kap-Verde-Escudo", "Dunkles Design"],
    "es-es": ["Conversión al instante y evolución en 3 meses", "Divisas con paridad fija con el euro, como el escudo caboverdiano", "Tema oscuro"],
    "it-it": ["Conversione istantanea e andamento su 3 mesi", "Valute a parità fissa con l'euro, come l'escudo capoverdiano", "Tema scuro"],
    "pl-pl": ["Przeliczanie na bieżąco i zmiany z 3 miesięcy", "Waluty o stałym kursie do euro, np. escudo Zielonego Przylądka", "Ciemny motyw"],
    "ro-ro": ["Conversie în timp real și evoluția pe 3 luni", "Valute cu paritate fixă față de euro, precum escudo capverdian", "Temă întunecată"],
    "lt-lt": ["Konvertavimas realiuoju laiku ir 3 mėnesių kitimas", "Valiutos su fiksuotu kursu euro atžvilgiu, pvz., Žaliojo Kyšulio eskudas", "Tamsi tema"],
}

FEATURES = {
    "en-us": ["Live conversion between 38 currencies", "Official ECB reference rates, updated every working day", "History chart over 1 week, 1 month or 3 months", "Currencies pegged to the euro: CFA francs, Cape Verdean escudo and more", "Works offline with the last saved rates", "No ads, no account, no tracking", "8 languages, light and dark theme"],
    "fr-fr": ["Conversion en direct entre 38 devises", "Taux de référence officiels de la BCE, mis à jour chaque jour ouvré", "Graphique de l'évolution sur 1 semaine, 1 mois ou 3 mois", "Devises à parité fixe avec l'euro : francs CFA, escudo cap-verdien…", "Fonctionne hors ligne avec les derniers taux enregistrés", "Sans publicité, sans compte, sans traceur", "8 langues, thème clair et sombre"],
    "de-de": ["Live-Umrechnung zwischen 38 Währungen", "Offizielle EZB-Referenzkurse, an jedem Arbeitstag aktualisiert", "Verlaufsdiagramm über 1 Woche, 1 Monat oder 3 Monate", "Währungen mit festem Euro-Kurs: CFA-Franc, Kap-Verde-Escudo und mehr", "Offline nutzbar mit den zuletzt gespeicherten Kursen", "Keine Werbung, kein Konto, kein Tracking", "8 Sprachen, helles und dunkles Design"],
    "es-es": ["Conversión al instante entre 38 divisas", "Tipos de referencia oficiales del BCE, actualizados cada día hábil", "Gráfico de evolución en 1 semana, 1 mes o 3 meses", "Divisas con paridad fija con el euro: francos CFA, escudo caboverdiano…", "Funciona sin conexión con los últimos tipos guardados", "Sin anuncios, sin cuenta, sin rastreadores", "8 idiomas, tema claro y oscuro"],
    "it-it": ["Conversione istantanea tra 38 valute", "Tassi di riferimento ufficiali della BCE, aggiornati ogni giorno lavorativo", "Grafico dell'andamento su 1 settimana, 1 mese o 3 mesi", "Valute a parità fissa con l'euro: franchi CFA, escudo capoverdiano…", "Funziona offline con gli ultimi tassi salvati", "Niente pubblicità, niente account, niente tracciamento", "8 lingue, tema chiaro e scuro"],
    "pl-pl": ["Przeliczanie na bieżąco między 38 walutami", "Oficjalne kursy referencyjne EBC, aktualizowane w każdy dzień roboczy", "Wykres zmian z 1 tygodnia, 1 miesiąca lub 3 miesięcy", "Waluty o stałym kursie do euro: franki CFA, escudo Zielonego Przylądka…", "Działa offline z ostatnio zapisanymi kursami", "Bez reklam, bez konta, bez śledzenia", "8 języków, jasny i ciemny motyw"],
    "ro-ro": ["Conversie în timp real între 38 de valute", "Cursurile oficiale de referință BCE, actualizate în fiecare zi lucrătoare", "Graficul evoluției pe 1 săptămână, 1 lună sau 3 luni", "Valute cu paritate fixă față de euro: francii CFA, escudo capverdian…", "Funcționează offline cu ultimele cursuri salvate", "Fără reclame, fără cont, fără urmărire", "8 limbi, temă deschisă și întunecată"],
    "lt-lt": ["Konvertavimas realiuoju laiku tarp 38 valiutų", "Oficialūs ECB orientaciniai kursai, atnaujinami kiekvieną darbo dieną", "Kitimo grafikas per 1 savaitę, 1 mėnesį ar 3 mėnesius", "Valiutos su fiksuotu kursu euro atžvilgiu: CFA frankai, Žaliojo Kyšulio eskudas…", "Veikia be ryšio su paskutiniais išsaugotais kursais", "Jokios reklamos, paskyros ar sekimo", "8 kalbos, šviesi ir tamsi tema"],
}

SEARCH_TERMS = {
    "en-us": ["currency converter", "exchange rates", "ECB", "euro", "forex", "money", "CFA franc"],
    "fr-fr": ["convertisseur de devises", "taux de change", "BCE", "euro", "devises", "change", "franc CFA"],
    "de-de": ["Währungsrechner", "Wechselkurse", "EZB", "Euro", "Devisen", "Währung", "Umrechner"],
    "es-es": ["conversor de divisas", "tipos de cambio", "BCE", "euro", "divisas", "moneda", "franco CFA"],
    "it-it": ["convertitore di valute", "tassi di cambio", "BCE", "euro", "valute", "cambio", "franco CFA"],
    "pl-pl": ["przelicznik walut", "kursy walut", "EBC", "euro", "waluty", "kantor", "wymiana walut"],
    "ro-ro": ["convertor valutar", "curs valutar", "BCE", "euro", "valute", "schimb valutar", "monedă"],
    "lt-lt": ["valiutų keitiklis", "valiutų kursai", "ECB", "euras", "valiuta", "keitimas", "kursai"],
}

LIMITS = {"Feature": 200, "SearchTerm": 30, "DesktopScreenshotCaption": 200, "ShortDescription": 1000, "Description": 10000, "ReleaseNotes": 1500}


def read(path):
    return path.read_text(encoding="utf-8").strip()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--out", default="build/msstore")
    args = parser.parse_args()

    repo = pathlib.Path(__file__).resolve().parent.parent
    windows = repo / "store/windows"
    play = repo / "fastlane/metadata/android"
    dest = pathlib.Path(args.out) / ROOT_NAME
    if dest.exists():
        shutil.rmtree(dest)
    dest.mkdir(parents=True)

    # Images, under the folder name Partner Center expects in the paths.
    for logo in ("logo_1080.png", "logo_300.png", "poster_art_1440x2160.png"):
        shutil.copy(windows / logo, dest / logo)
    missing = []
    for column, locale in LOCALES.items():
        target = dest / locale
        target.mkdir()
        for name in SCREENSHOTS:
            source = windows / locale / "screenshots" / f"{name}.png"
            if source.is_file():
                shutil.copy(source, target / f"{name}.png")
            else:
                missing.append(str(source))
    if missing:
        sys.exit("Missing screenshots (run the screenshot test first):\n" + "\n".join(missing))

    def values(field, column):
        locale = LOCALES[column]
        base = play / locale
        if field == "Description":
            return read(base / "full_description.txt")
        if field == "ShortDescription":
            return read(base / "short_description.txt")
        if field == "ReleaseNotes":
            return read(base / "changelogs/default.txt")
        if field == "DevStudio":
            return DEV
        if field == "CopyrightTrademarkInformation":
            return COPYRIGHT
        if field == "AdditionalLicenseTerms":
            return LICENSE
        if field.startswith("DesktopScreenshotCaption"):
            i = int(field.removeprefix("DesktopScreenshotCaption")) - 1
            return CAPTIONS[column][i] if i < len(SCREENSHOTS) else None
        if field.startswith("DesktopScreenshot"):
            i = int(field.removeprefix("DesktopScreenshot")) - 1
            return f"{ROOT_NAME}/{locale}/{SCREENSHOTS[i]}.png" if i < len(SCREENSHOTS) else None
        if field == "StoreLogo1080x1080":
            return f"{ROOT_NAME}/logo_1080.png"
        if field == "StoreLogo300x300":
            return f"{ROOT_NAME}/logo_300.png"
        if field == "StoreLogo720x1080":
            return f"{ROOT_NAME}/poster_art_1440x2160.png"
        if field.startswith("Feature"):
            i = int(field.removeprefix("Feature")) - 1
            return FEATURES[column][i] if i < len(FEATURES[column]) else None
        if field.startswith("SearchTerm"):
            i = int(field.removeprefix("SearchTerm")) - 1
            return SEARCH_TERMS[column][i] if i < len(SEARCH_TERMS[column]) else None
        return None

    template = (windows / "listing_template.csv").read_text(encoding="utf-8-sig")
    rows = list(csv.reader(io.StringIO(template)))
    header = rows[0]
    errors = []
    for row in rows[1:]:
        if not row or not row[0]:
            continue
        field = row[0]
        for c, column in enumerate(header):
            if column not in LOCALES:
                continue
            value = values(field, column)
            if value is None:
                continue
            for prefix, limit in LIMITS.items():
                if field.startswith(prefix) and len(value) > limit:
                    errors.append(f"{field} [{column}]: {len(value)} characters, limit {limit}")
            row[c] = value
    if errors:
        sys.exit("\n".join(errors))

    out = io.StringIO()
    csv.writer(out, lineterminator="\r\n").writerows(rows)
    (dest / "listingData.csv").write_text(out.getvalue(), encoding="utf-8-sig")
    print(f"Listing for {len(LOCALES)} languages written to {dest}")


if __name__ == "__main__":
    main()
