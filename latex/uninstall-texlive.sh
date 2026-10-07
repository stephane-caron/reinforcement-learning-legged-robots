#!/usr/bin/env bash
#
# Remove the project-scoped TeX Live installation.

set -euo pipefail

source "$(dirname "$0")/texlive-dir.sh"

echo "==> Removing $TL_DIR"
rm -rf "$TL_DIR"
