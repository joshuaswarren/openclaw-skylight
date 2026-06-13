#!/usr/bin/env bash
# Install the Skylight OpenClaw skill + the `skylight` CLI it wraps.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
skills_dir="${OPENCLAW_SKILLS_DIR:-$HOME/.openclaw/skills}"
dest="$skills_dir/skylight"

# pyskylight is not on PyPI yet, so install from git by default. Override with
# PYSKYLIGHT_PACKAGE=pyskylight once it is published.
pkg="${PYSKYLIGHT_PACKAGE:-git+https://github.com/joshuaswarren/pyskylight}"
echo "==> Installing the 'skylight' CLI ($pkg)"
if command -v skylight >/dev/null 2>&1; then
  echo "    skylight already on PATH: $(command -v skylight)"
elif command -v pipx >/dev/null 2>&1; then
  pipx install "$pkg"
elif command -v pip3 >/dev/null 2>&1; then
  pip3 install --user "$pkg"
else
  echo "    WARNING: neither pipx nor pip3 found; install 'pyskylight' manually." >&2
fi

echo "==> Installing the skill into $dest"
mkdir -p "$dest"
cp "$here/SKILL.md" "$dest/SKILL.md"

echo "==> Done."
echo "    Set SKYLIGHT_EMAIL / SKYLIGHT_PASSWORD (op:// refs OK), and optionally"
echo "    SKYLIGHT_FRAME_ID / SKYLIGHT_TIMEZONE in your OpenClaw environment, then"
echo "    run 'skylight login' once to cache a session token."
