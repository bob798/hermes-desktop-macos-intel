#!/bin/bash
# Build Hermes Desktop for Intel macOS and package it as a DMG.
# Run on an Intel Mac (x86_64). Produces dist/Hermes-<version>-mac-x64.dmg
set -euo pipefail

if [ "$(uname -m)" != "x86_64" ]; then
    echo "error: this script must run on an Intel Mac (uname -m = $(uname -m))" >&2
    echo "hint: on Apple Silicon, just use the official installer instead" >&2
    exit 1
fi

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DIST_DIR="$REPO_ROOT/dist"
HERMES_BIN="${HERMES_BIN:-$HOME/.local/bin/hermes}"

# 1. Install/refresh the Hermes CLI (official installer, skips interactive setup)
if ! command -v "$HERMES_BIN" >/dev/null 2>&1; then
    echo "==> Installing Hermes CLI..."
    curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash -s -- --skip-setup
fi

# 2. Build the desktop app for the current arch (x86_64)
echo "==> Building Hermes Desktop (x64)..."
"$HERMES_BIN" desktop --build-only --force-build

APP="$HOME/.hermes/hermes-agent/apps/desktop/release/mac/Hermes.app"
[ -d "$APP" ] || { echo "error: build did not produce $APP" >&2; exit 1; }

ARCH=$(file "$APP/Contents/MacOS/Hermes" | grep -o 'x86_64\|arm64')
[ "$ARCH" = "x86_64" ] || { echo "error: built binary is $ARCH, expected x86_64" >&2; exit 1; }

VERSION=$("$HERMES_BIN" --version 2>/dev/null | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | head -1 | tr -d v)
COMMIT=$(git -C "$HOME/.hermes/hermes-agent" rev-parse --short HEAD)

# 3. Safety scan: refuse to package if anything user-specific leaked into the bundle
echo "==> Scanning bundle for leaked secrets/paths..."
if grep -rl "$HOME" "$APP" 2>/dev/null | grep -q .; then
    echo "error: bundle contains references to $HOME — aborting" >&2
    exit 1
fi

# 4. Package DMG with an /Applications symlink
echo "==> Packaging DMG..."
mkdir -p "$DIST_DIR"
STAGE=$(mktemp -d)
cp -R "$APP" "$STAGE/"
ln -s /Applications "$STAGE/Applications"
DMG="$DIST_DIR/Hermes-$VERSION-mac-x64.dmg"
hdiutil create -volname "Hermes (Intel)" -srcfolder "$STAGE" -ov -format UDZO "$DMG"
rm -rf "$STAGE"

shasum -a 256 "$DMG" | tee "$DMG.sha256"
echo "==> Done: $DMG (upstream commit $COMMIT)"
