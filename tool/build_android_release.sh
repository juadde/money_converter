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

flutter build appbundle --release --build-number="$BUILD_NUMBER"

aab=build/app/outputs/bundle/release/app-release.aab
expected=$(keytool -list -v -keystore "$keystore" -storepass "$ANDROID_KEYSTORE_PASSWORD" \
  -alias "$ANDROID_KEY_ALIAS" | grep -m1 'SHA256:' | awk '{print $2}')
cert=$(keytool -printcert -jarfile "$aab")
actual=$(echo "$cert" | grep -m1 'SHA256:' | awk '{print $2}')
sha1=$(echo "$cert" | grep -m1 'SHA1:' | awk '{print $2}')
if [ -z "$expected" ] || [ "$expected" != "$actual" ]; then
  echo "The bundle is not signed with the upload key (expected $expected, got ${actual:-none})." >&2
  exit 1
fi
echo "Signed bundle: $aab (versionCode $BUILD_NUMBER)"
echo "Upload key SHA-1:   $sha1"
echo "Upload key SHA-256: $actual"
# Shown on the run page, to compare with Play Console > Test and release >
# App integrity > Upload key certificate.
if [ -n "${GITHUB_STEP_SUMMARY:-}" ]; then
  {
    echo "### Android bundle signature"
    echo ""
    echo "| | |"
    echo "| --- | --- |"
    echo "| versionCode | $BUILD_NUMBER |"
    echo "| Upload key SHA-1 | \`$sha1\` |"
    echo "| Upload key SHA-256 | \`$actual\` |"
    if [ "${DRY_RUN:-false}" = true ]; then
      echo ""
      echo "**Dry run: signed with a throwaway key, do not upload this bundle.**"
    fi
  } >> "$GITHUB_STEP_SUMMARY"
fi
