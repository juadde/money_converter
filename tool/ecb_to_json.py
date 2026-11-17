#!/usr/bin/env python3
"""Convert the ECB euro reference rates (XML) to the JSON read by the app.

The app downloads the ECB feed directly. This JSON copy is its fallback, and
the only source for the web build (the ECB server sends no CORS header).

Usage:
    python3 tool/ecb_to_json.py --output build/web/rates.json
    python3 tool/ecb_to_json.py --input some.xml --output rates.json
"""

import argparse
import json
import sys
import urllib.request
import xml.etree.ElementTree as ET

ECB_URL = "https://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist-90d.xml"
NS = "{http://www.ecb.int/vocabulary/2002-08-01/eurofxref}"


def parse(xml_bytes):
    root = ET.fromstring(xml_bytes)
    days = []
    for cube in root.iter(NS + "Cube"):
        date = cube.get("time")
        if not date:
            continue
        rates = {}
        for child in cube.findall(NS + "Cube"):
            currency = child.get("currency")
            try:
                rate = float(child.get("rate", ""))
            except ValueError:
                continue
            if currency and rate > 0:
                rates[currency] = rate
        if rates:
            days.append({"date": date, "rates": rates})
    days.sort(key=lambda day: day["date"], reverse=True)
    return days


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--input", help="local XML file (default: download from the ECB)")
    parser.add_argument("--output", required=True, help="JSON file to write")
    args = parser.parse_args()

    if args.input:
        with open(args.input, "rb") as handle:
            xml_bytes = handle.read()
    else:
        request = urllib.request.Request(ECB_URL, headers={"User-Agent": "moneyconverter"})
        with urllib.request.urlopen(request, timeout=30) as response:
            xml_bytes = response.read()

    days = parse(xml_bytes)
    if not days:
        sys.exit("No rates found in the ECB document")

    with open(args.output, "w", encoding="utf-8") as handle:
        json.dump({"source": "ECB", "days": days}, handle, separators=(",", ":"))
    print(f"{len(days)} days written to {args.output} (latest: {days[0]['date']})")


if __name__ == "__main__":
    main()
