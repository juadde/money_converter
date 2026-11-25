#!/usr/bin/env bash
# Builds the release Android App Bundle signed with the Play upload key, and
# checks the signature. Run tool/bootstrap_platforms.sh first.
#
# Environment:
#   ANDROID_KEYSTORE_PATH      upload keystore (.jks)
#   ANDROID_KEYSTORE_PASSWORD  keystore password
#   ANDROID_KEY_ALIAS          key alias in the keystore
#   ANDROID_KEY_PASSWORD       key password
#   BUILD_NUMBER               Android versionCode, must increase on each upload
#   ANDROID_ARTIFACT           appbundle (default, for Google Play) or apk
set -euo pipefail
cd "$(dirname "$0")/.."

: "${ANDROID_KEYSTORE_PATH:?missing}"
: "${ANDROID_KEYSTORE_PASSWORD:?missing}"
: "${ANDROID_KEY_ALIAS:?missing}"
: "${ANDROID_KEY_PASSWORD:?missing}"
: "${BUILD_NUMBER:?missing}"

keystore="$(realpath "$ANDROID_KEYSTORE_PATH")"

# The Android Gradle plugin signs with these "injected" properties instead of
# the debug key the Flutter template uses, without editing the generated
# build files. Backslashes in passwords would be read as escapes.
cat >> android/gradle.properties <<PROPS
android.injected.signing.store.file=$keystore
android.injected.signing.store.password=$ANDROID_KEYSTORE_PASSWORD
android.injected.signing.key.alias=$ANDROID_KEY_ALIAS
android.injected.signing.key.password=$ANDROID_KEY_PASSWORD
PROPS

artifact="${ANDROID_ARTIFACT:-appbundle}"
flutter build "$artifact" --release --build-number="$BUILD_NUMBER"

if [ "$artifact" = apk ]; then
  aab=build/app/outputs/flutter-apk/app-release.apk
else
  aab=build/app/outputs/bundle/release/app-release.aab
fi
# The repository is public, and so are the run logs: the fingerprints are
# compared here but never printed. Check them on your own computer with
#   keytool -list -v -keystore upload-keystore.jks -alias upload
expected=$(keytool -list -v -keystore "$keystore" -storepass "$ANDROID_KEYSTORE_PASSWORD" \
  -alias "$ANDROID_KEY_ALIAS" | grep -m1 'SHA256:' | awk '{print $2}')
if [ "$artifact" = apk ]; then
  # Recent APKs only carry the v2+ signature schemes, which keytool cannot
  # read: use apksigner from the Android SDK build tools.
  apksigner=$(ls "${ANDROID_HOME:-$ANDROID_SDK_ROOT}"/build-tools/*/apksigner 2>/dev/null | sort -V | tail -1)
  if [ -z "$apksigner" ]; then
    echo "apksigner not found in the Android SDK build tools." >&2
    exit 1
  fi
  actual=$("$apksigner" verify --print-certs "$aab" 2>/dev/null \
    | grep -m1 'certificate SHA-256 digest:' | awk '{print $NF}' || true)
  expected=$(echo "$expected" | tr -d ':' | tr 'A-F' 'a-f')
else
  actual=$(keytool -printcert -jarfile "$aab" 2>/dev/null | grep -m1 'SHA256:' | awk '{print $2}' || true)
fi
if [ -z "$expected" ] || [ "$expected" != "$actual" ]; then
  echo "The bundle is not signed with the upload key." >&2
  exit 1
fi
echo "Signed bundle: $aab (versionCode $BUILD_NUMBER), signature checked against the upload key"
if [ -n "${GITHUB_STEP_SUMMARY:-}" ]; then
  {
    echo "### Android bundle"
    echo ""
    echo "versionCode $BUILD_NUMBER, signed with the upload key (fingerprints not shown: public logs)."
    if [ "${DRY_RUN:-false}" = true ]; then
      echo ""
      echo "**Dry run: signed with a throwaway key, do not upload this bundle.**"
    fi
  } >> "$GITHUB_STEP_SUMMARY"
fi
