# Build reinforcement-learning-legged-robots.pdf from slides.tex
#
# Figure PDFs are generated from their SVG sources only when needed, and the
# slides are only recompiled when a source file changes. Defaults below
# follow the pixi layout, so plain `make` also works outside `pixi run`.

SHELL=/bin/zsh
SRC := slides
OUT := output
PDF := reinforcement-learning-legged-robots.pdf

# Project-scoped TeX Live (see latex/install-texlive.sh). It must live
# OUTSIDE the project tree: minted v3's latexrestricted security layer
# refuses to run when the TeX binaries are under the compilation directory.
TL_DIR ?= $(or $(XDG_DATA_HOME),$(HOME)/.local/share)/texlive-projects/reinforcement-learning-legged-robots
TL_BINDIR := $(TL_DIR)/bin/x86_64-linux
CONDA_PREFIX ?= $(CURDIR)/.pixi/envs/default

export PATH := $(TL_BINDIR):$(CONDA_PREFIX)/bin:$(PATH)

# UTF-8 locale, silences perl/biber locale warnings.
export LC_ALL ?= C.UTF-8
export LANG ?= C.UTF-8

# xelatex links the *system* fontconfig: point it at the pixi environment's
# fontconfig config, where install-texlive.sh published the Fira fonts
# (metropolis loads Fira by family name, so without this the slides fall back
# to Latin Modern).
export FONTCONFIG_FILE ?= $(CONDA_PREFIX)/etc/fonts/fonts.conf
export OSFONTDIR := $(TL_DIR)/texmf-dist/fonts/opentype/public/fira:$(CONDA_PREFIX)/share/fonts

XELATEX := xelatex -interaction=nonstopmode -halt-on-error -file-line-error -shell-escape -output-directory=$(OUT)

FIG_PDF := $(patsubst %.svg,%.pdf,$(wildcard figures/*.svg))
FIG_IMG := $(wildcard figures/*.png figures/*.jpg figures/*.jpeg)
THEME := $(wildcard latex/*.sty)

all: $(PDF)

# Don't keep a PDF from a failed run: its fresh timestamp would otherwise
# make the next `make` consider it up to date.
.DELETE_ON_ERROR:

genfig: $(FIG_PDF)

figures/%.pdf: figures/%.svg
	rsvg-convert -f pdf -o $@ $<

$(PDF): $(OUT)/$(SRC).pdf
	cp $< $@
	@echo "==> Built $@"

$(OUT)/$(SRC).pdf: $(SRC).tex refs.bib $(THEME) $(FIG_PDF) $(FIG_IMG) | $(OUT)
	$(XELATEX) $(SRC).tex
	biber $(OUT)/$(SRC)
	@if grep -q "Citation.*undefined" $(OUT)/$(SRC).log; then \
		echo "warning: undefined citations remain, check $(OUT)/$(SRC).log" >&2; \
	fi

$(OUT):
	mkdir -p $(OUT)

clean:
	rm -f $(PDF)
	rm -rf $(OUT)

watch:
	while [ 1 ]; do; inotifywait $(SRC).tex && make; done

.PHONY: all genfig clean watch
