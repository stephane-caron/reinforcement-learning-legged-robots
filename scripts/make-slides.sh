#!/usr/bin/env bash
#
# Build the slides: SVG figures -> PDF, then xelatex -> biber -> xelatex.

set -euo pipefail

ROOT="${PIXI_PROJECT_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
CONDA_PREFIX="${CONDA_PREFIX:-$ROOT/.pixi/envs/default}"

source "$(dirname "$0")/texlive-dir.sh"
TL_BINDIR="$TL_DIR/bin/x86_64-linux"
SRC="reinforcement-learning-legged-robots"

if [ ! -x "$TL_BINDIR/xelatex" ]; then
    echo "error: no TeX Live in $TL_DIR, run: pixi run tex" >&2
    exit 1
fi

# Convert SVG figures to PDF
generate_figures() {
    mkdir -p "$ROOT/genfig"
    for svg in "$ROOT"/figures/*.svg; do
        out="$ROOT/genfig/$(basename "${svg%.svg}").pdf"
        rsvg-convert -f pdf -o "$out" "$svg"
    done
}

if [ "${1:-}" = "--genfig-only" ]; then
    generate_figures
    exit 0
fi

generate_figures

export PATH="$TL_BINDIR:$PATH"

# Use a UTF-8 locale that exists on any modern Linux; silences perl/biber
# locale warnings.
export LC_ALL="${LC_ALL:-C.UTF-8}" LANG="${LANG:-C.UTF-8}"

# xelatex links the *system* fontconfig, so point it at the pixi environment's
# fontconfig config, where the Fira fonts were published by install-texlive.sh.
# (metropolis loads Fira by family name, so this is required for the slides to
# use Fira rather than falling back to Latin Modern.)
export FONTCONFIG_FILE="${FONTCONFIG_FILE:-$CONDA_PREFIX/etc/fonts/fonts.conf}"
export OSFONTDIR="$TL_DIR/texmf-dist/fonts/opentype/public/fira:$CONDA_PREFIX/share/fonts"

flags=(-interaction=nonstopmode -halt-on-error -file-line-error -shell-escape)
cd "$ROOT"
xelatex "${flags[@]}" "$SRC.tex"
biber "$SRC"
xelatex "${flags[@]}" "$SRC.tex"
xelatex "${flags[@]}" "$SRC.tex"

if grep -q "Citation.*undefined" "$SRC.log"; then
    echo "warning: undefined citations remain, check $SRC.log" >&2
fi

echo "==> Built $SRC.pdf"
