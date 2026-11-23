#!/usr/bin/env bash
# Generates the android/, ios/, web/, windows/ and linux/ folders with `flutter create`, then
# applies the few changes the app needs. Safe to run several times.
set -euo pipefail
cd "$(dirname "$0")/.."

flutter create \
  --platforms=android,ios,web,windows,linux \
  --org com.juadde \
  --project-name moneyconverter \
  .

# Release builds need the INTERNET permission (the template only adds it to
# debug builds).
MANIFEST=android/app/src/main/AndroidManifest.xml
if [ -f "$MANIFEST" ] && ! grep -q 'android.permission.INTERNET' "$MANIFEST"; then
  perl -0pi -e 's|<application|<uses-permission android:name="android.permission.INTERNET"/>\n    <application|' "$MANIFEST"
fi

# Display name on the home screen.
if [ -f "$MANIFEST" ]; then
  perl -pi -e 's|android:label="moneyconverter"|android:label="Money Converter"|' "$MANIFEST"
fi

# Window title on the desktop builds.
if [ -f linux/runner/my_application.cc ]; then
  perl -pi -e 's|"moneyconverter"|"Money Converter"|g' linux/runner/my_application.cc
fi
if [ -f windows/runner/main.cpp ]; then
  perl -pi -e 's|L"moneyconverter"|L"Money Converter"|g' windows/runner/main.cpp
fi

# App icon for Android, iOS and web (config in pubspec.yaml).
flutter pub get
dart run flutter_launcher_icons
