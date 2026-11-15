#!/usr/bin/env bash
#
# Upload the built iOS IPA to TestFlight automatically.
#
# One-time setup — grab these from App Store Connect →
# Users and Access → Integrations → App Store Connect API:
#
#   export ASC_KEY_ID=XXXXXXXXXX          # the "Key ID" of the API key
#   export ASC_ISSUER_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
#   export ASC_KEY_PATH=~/Downloads/AuthKey_XXXXXXXXXX.p8
#
# Then:
#   ./scripts/upload_testflight.sh                 # uses the default IPA path
#   ./scripts/upload_testflight.sh path/to/App.ipa
#
# The export-compliance question is answered by the app itself
# (ITSAppUsesNonExemptEncryption=false in ios/Runner/Info.plist), so App Store
# Connect will NOT ask it again.
set -euo pipefail

IPA="${1:-build/ios/ipa/He Clinic.ipa}"

: "${ASC_KEY_ID:?Set ASC_KEY_ID (App Store Connect API Key ID)}"
: "${ASC_ISSUER_ID:?Set ASC_ISSUER_ID (App Store Connect Issuer ID)}"
: "${ASC_KEY_PATH:?Set ASC_KEY_PATH (path to AuthKey_XXXX.p8)}"

if [ ! -f "$IPA" ]; then
  echo "IPA not found: $IPA" >&2
  exit 1
fi

# altool resolves the key by Key ID from ~/.appstoreconnect/private_keys.
KEY_DIR="$HOME/.appstoreconnect/private_keys"
KEY_DEST="$KEY_DIR/AuthKey_${ASC_KEY_ID}.p8"
mkdir -p "$KEY_DIR"
if [ ! -f "$KEY_DEST" ]; then
  cp "$ASC_KEY_PATH" "$KEY_DEST"
  chmod 600 "$KEY_DEST"
fi

echo "Uploading $IPA to TestFlight (key $ASC_KEY_ID)..."
xcrun altool --upload-app \
  --type ios \
  --file "$IPA" \
  --apiKey "$ASC_KEY_ID" \
  --apiIssuer "$ASC_ISSUER_ID"

echo "Upload complete. The build will appear in App Store Connect → TestFlight."
