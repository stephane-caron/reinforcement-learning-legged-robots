#!/usr/bin/env bash
#
# Bootstrap a project-scoped TeX Live installation.
#
# conda-forge only ships TeX Live binaries (no LaTeX packages), so we install a
# real (minimal) TeX Live, kept outside the project tree (see
# scripts/texlive-dir.sh for the location and the reason). This is idempotent:
# it only downloads on the first run or when the package list below changes.
#
# The TeX Live version can be pinned by exporting TL_REPO, e.g. to a frozen
# historic repository such as
#   https://ftp.tug.org/historic/systems/texlive/2026/tlnet-final

set -euo pipefail

export LC_ALL=C LANG=C  # hermetic locale, silences perl warnings
ROOT="${PIXI_PROJECT_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
CONDA_PREFIX="${CONDA_PREFIX:-$ROOT/.pixi/envs/default}"

source "$(dirname "$0")/texlive-dir.sh"
TL_BINDIR="$TL_DIR/bin/x86_64-linux"
TL_REPO="${TL_REPO:-https://mirror.ctan.org/systems/texlive/tlnet}"

# LaTeX packages used by the slides (dependencies are resolved by tlmgr).
TL_PKGS=(
    xetex                # engine: provides the xelatex binary + format
    beamer
    beamertheme-metropolis
    minted
    biblatex
    biber
    fontspec
    fira
    adjustbox
    algorithm2e
    ifoddpage           # loaded by algorithm2e but not declared as a dep
    relsize             # likewise
    booktabs
    csquotes
    caption
)

if [ ! -f "$TL_DIR/.base-ok" ]; then
    echo "==> No TeX Live in $TL_DIR, downloading installer from $TL_REPO"
    tmp="$(mktemp -d)"
    trap 'rm -rf "$tmp"' EXIT
    curl -fsSL "$TL_REPO/install-tl-unx.tar.gz" -o "$tmp/install-tl.tar.gz"
    tar -xzf "$tmp/install-tl.tar.gz" -C "$tmp"
    installer="$(echo "$tmp"/install-tl-*/install-tl)"

    echo "==> Installing TeX Live (scheme-basic) into $TL_DIR"
    cat > "$tmp/profile.txt" <<EOF
selected_scheme scheme-basic
TEXDIR $TL_DIR
TEXMFLOCAL $TL_DIR/texmf-local
TEXMFCONFIG $TL_DIR/texmf-config
TEXMFVAR $TL_DIR/texmf-var
TEXMFSYSCONFIG $TL_DIR/texmf-config
TEXMFSYSVAR $TL_DIR/texmf-var
tlpdbopt_install_docfiles 0
tlpdbopt_install_srcfiles 0
tlpdbopt_autobackup 0
tlpdbopt_post_code 1
EOF
    perl "$installer" --profile="$tmp/profile.txt" --repository "$TL_REPO"
    touch "$TL_DIR/.base-ok"
fi

export PATH="$TL_BINDIR:$PATH"

# Install the required LaTeX packages (skipped when already done).
MARKER="$TL_DIR/.packages-ok"
WANT="$TL_REPO ${TL_PKGS[*]}"
if [ "$(cat "$MARKER" 2>/dev/null || true)" != "$WANT" ]; then
    echo "==> Installing LaTeX packages: ${TL_PKGS[*]}"
    tlmgr install "${TL_PKGS[@]}"
    echo "$WANT" > "$MARKER"
fi

# The metropolis beamer theme loads Fira fonts by *family name* through
# fontconfig. Make the OTFs from the TeX Live "fira" package visible to the
# fontconfig of the pixi environment (scripts/make-slides.sh points xelatex
# at this configuration via FONTCONFIG_FILE).
FONT_SRC="$TL_DIR/texmf-dist/fonts/opentype/public/fira"
FONT_DST="$CONDA_PREFIX/share/fonts"
shopt -s nullglob
src_fonts=("$FONT_SRC"/*.otf)
dst_fonts=("$FONT_DST"/Fira*.otf)
if [ "${#src_fonts[@]}" -gt 0 ] && [ "${#src_fonts[@]}" -ne "${#dst_fonts[@]}" ]; then
    echo "==> Publishing Fira fonts to fontconfig ($FONT_DST)"
    mkdir -p "$FONT_DST"
    cp "${src_fonts[@]}" "$FONT_DST/"
    fc-cache -f "$FONT_DST" > /dev/null
fi
shopt -u nullglob

# Sanity checks
command -v xelatex > /dev/null
command -v biber > /dev/null
command -v latexminted > /dev/null
echo "==> TeX Live ready: $(xelatex --version 2>/dev/null | head -n 1 || true)"
