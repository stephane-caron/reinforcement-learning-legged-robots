#!/usr/bin/env bash
#
# Rebuild the slides whenever a source file changes (polling, no inotify
# needed). Run with: `pixi run watch`

set -uo pipefail

ROOT="${PIXI_PROJECT_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"

checksum() {
    cat "$ROOT/$SRC.tex" "$ROOT"/theme/*.sty "$ROOT"/figures/*.svg 2>/dev/null | md5sum | cut -d' ' -f1
}

SRC="reinforcement-learning-legged-robots"
last=""

echo "==> watching for changes (Ctrl-C to stop)"
while true; do
    cur="$(checksum)"
    if [ "$cur" != "$last" ]; then
        last="$cur"
        echo "==> change detected, rebuilding..."
        if bash "$ROOT/scripts/make-slides.sh"; then
            echo "==> rebuilt at $(date +%H:%M:%S)"
        else
            echo "==> build failed, waiting for the next change"
        fi
    fi
    sleep 2
done
