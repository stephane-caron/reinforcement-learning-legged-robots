#!/usr/bin/env bash
# Build the slides: SVG figures -> output/genfig/*.pdf, then
# xelatex -> biber -> xelatex, all by-products in output/. The final PDF is
# copied to ./reinforcement-learning-legged-robots.pdf.
set -euo pipefail

ROOT="${PIXI_PROJECT_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
CONDA_PREFIX="${CONDA_PREFIX:-$ROOT/.pixi/envs/default}"
source "$(dirname "$0")/texlive-dir.sh"
TL_BINDIR="$TL_DIR/bin/x86_64-linux"
SRC="slides"
OUT="$ROOT/output"
PDF="$ROOT/reinforcement-learning-legged-robots.pdf"

if [ ! -x "$TL_BINDIR/xelatex" ]; then
    echo "error: no TeX Live in $TL_DIR, run: pixi run texlive-install" >&2
    exit 1
fi

genfig() {
    mkdir -p "$OUT/genfig"
    for svg in "$ROOT"/figures/*.svg; do
        out="$OUT/genfig/$(basename "${svg%.svg}").pdf"
        rsvg-convert -f pdf -o "$out" "$svg"
    done
}

if [ "${1:-}" = "--genfig-only" ]; then
    genfig
    exit 0
fi

genfig

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

mkdir -p "$OUT"
flags=(-interaction=nonstopmode -halt-on-error -file-line-error -shell-escape -output-directory="$OUT")
xelatex "${flags[@]}" "$SRC.tex"
biber "$OUT/$SRC"
xelatex "${flags[@]}" "$SRC.tex"
xelatex "${flags[@]}" "$SRC.tex"

if grep -q "Citation.*undefined" "$OUT/$SRC.log"; then
    echo "warning: undefined citations remain, check $OUT/$SRC.log" >&2
fi

cp "$OUT/$SRC.pdf" "$PDF"
echo "==> Built $PDF"
