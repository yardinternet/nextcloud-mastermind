#!/usr/bin/env bash
# Builds, packages, and signs a Nextcloud App Store release for this app.
# Run from the app root (the directory containing appinfo/info.xml).
#
# Override the key path with: NEXTCLOUD_APP_KEY=/path/to/key ./release.sh
set -euo pipefail

APP_ID=mastermind
KEY="${NEXTCLOUD_APP_KEY:-$HOME/.nextcloud/certificates/$APP_ID.key}"

if [[ ! -f appinfo/info.xml ]]; then
  echo "Error: run this from the app root (appinfo/info.xml not found)" >&2
  exit 1
fi

if [[ ! -f "$KEY" ]]; then
  echo "Error: private key not found at $KEY" >&2
  exit 1
fi

if ! git diff --quiet HEAD -- . ':!release.sh' 2>/dev/null; then
  echo "Warning: working tree has uncommitted changes; only committed files will be packaged." >&2
fi

VERSION=$(sed -n 's:.*<version>\(.*\)</version>.*:\1:p' appinfo/info.xml | head -1)
OUT_DIR="$PWD/dist"
ARCHIVE="$OUT_DIR/${APP_ID}-${VERSION}.tar.gz"
mkdir -p "$OUT_DIR"

BUILD_DIR=$(mktemp -d)
trap 'rm -rf "$BUILD_DIR"' EXIT

echo "==> Extracting clean copy from git (HEAD)"
git archive --prefix="$APP_ID/" HEAD | tar -x -C "$BUILD_DIR"

pushd "$BUILD_DIR/$APP_ID" >/dev/null

echo "==> Installing npm deps and building frontend"
npm ci
npm run build

echo "==> Installing production PHP deps"
composer install --no-dev --optimize-autoloader

popd >/dev/null

echo "==> Creating $ARCHIVE"
excludes=(
  --exclude="$APP_ID/dist"
  --exclude="$APP_ID/node_modules"
  --exclude="$APP_ID/src"
  --exclude="$APP_ID/tests"
  --exclude="$APP_ID/vendor-bin"
  --exclude="$APP_ID/.eslintrc.cjs"
  --exclude="$APP_ID/.github"
  --exclude="$APP_ID/.gitignore"
  --exclude="$APP_ID/.gitattributes"
  --exclude="$APP_ID/.nvmrc"
  --exclude="$APP_ID/.php-cs-fixer.dist.php"
  --exclude="$APP_ID/CLAUDE.md"
  --exclude="$APP_ID/composer.json"
  --exclude="$APP_ID/composer.lock"
  --exclude="$APP_ID/package.json"
  --exclude="$APP_ID/package-lock.json"
  --exclude="$APP_ID/psalm.xml"
  --exclude="$APP_ID/rector.php"
  --exclude="$APP_ID/release.sh"
  --exclude="$APP_ID/screenshot.png"
  --exclude="$APP_ID/tsconfig.json"
  --exclude="$APP_ID/stylelint.config.cjs"
  --exclude="$APP_ID/vite.config.ts"
)

tar -C "$BUILD_DIR" "${excludes[@]}" -czf "$ARCHIVE" "$APP_ID/"
ls -lh "$ARCHIVE"

echo "==> Verifying archive layout"
TOP_DIRS=$(tar -tzf "$ARCHIVE" | awk -F/ 'NF>1 {print $1}' | sort -u)
if [[ "$TOP_DIRS" != "$APP_ID" ]]; then
  echo "Error: archive must contain exactly one top-level folder named '$APP_ID', got: $TOP_DIRS" >&2
  exit 1
fi
if ! tar -tzf "$ARCHIVE" | grep -q "^$APP_ID/appinfo/info.xml$"; then
  echo "Error: $APP_ID/appinfo/info.xml missing from archive" >&2
  exit 1
fi

echo "==> Signing"
SIG_FILE="$ARCHIVE.sig.txt"
openssl dgst -sha512 -sign "$KEY" "$ARCHIVE" | openssl base64 > "$SIG_FILE"

echo
echo "Archive:   $ARCHIVE"
echo "Signature: $SIG_FILE"
echo
echo "--- Signature (paste into apps.nextcloud.com) ---"
cat "$SIG_FILE"
echo "--- end signature ---"
