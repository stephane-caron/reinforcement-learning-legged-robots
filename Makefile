BIBTEX=biber
INKSCAPE=inkscape
LATEX=xelatex -interaction nonstopmode -halt-on-error -file-line-error -shell-escape
READER=zathura
SHELL=/bin/zsh

SRC=$(wildcard *.tex)
PDF=$(SRC:.tex=.pdf)
TMP=$(wildcard *.aux *.bbl *.bcf *.blg *.dvi *.log *.nav *.out *.ps *.fls *.listing *.glo *.idx *.run.xml *.snm *.tns *.toc *.vrb)
SVG=$(wildcard figures/*.svg)
FIG_PDF=$(SVG:.svg=.pdf)
GENFIG=$(FIG_PDF:figures/%=genfig/%)

all: genfig $(GENFIG) $(SRC)
	$(LATEX) $(SRC)
	$(BIBTEX) $(SRC:.tex=)

clean:
	-@rm -f $(PDF) $(TMP)
	-@rm -rf genfig/

genfig:
	mkdir -p genfig

genfig/%.pdf: figures/%.svg
	$(INKSCAPE) -C -z --file=$< --export-pdf=$@

install-fonts:
	mkdir -p ~/.local/share/fonts/fira
	(cd ~/.local/share/fonts/fira && \
		wget https://github.com/mozilla/Fira/raw/master/otf/FiraMono-Bold.otf && \
		wget https://github.com/mozilla/Fira/raw/master/otf/FiraMono-Medium.otf && \
		wget https://github.com/mozilla/Fira/raw/master/otf/FiraMono-Regular.otf && \
		wget https://github.com/mozilla/Fira/raw/master/otf/FiraSans-Bold.otf && \
		wget https://github.com/mozilla/Fira/raw/master/otf/FiraSans-BoldItalic.otf && \
		wget https://github.com/mozilla/Fira/raw/master/otf/FiraSans-Italic.otf && \
		wget https://github.com/mozilla/Fira/raw/master/otf/FiraSans-Light.otf && \
		wget https://github.com/mozilla/Fira/raw/master/otf/FiraSans-LightItalic.otf && \
		wget https://github.com/mozilla/Fira/raw/master/otf/FiraSans-Regular.otf && \
		wget https://github.com/mozilla/Fira/raw/master/otf/FiraSans-SemiBold.otf && \
		wget https://github.com/mozilla/Fira/raw/master/otf/FiraSans-SemiBoldItalic.otf)
	fc-cache -fv

install-ubuntu: install-fonts
	sudo apt install texlive-xetex texlive-fonts-extra texlive-bibtex-extra biber
	sudo apt install texlive-latex-extra  # has metropolis beamer theme

open:
	$(READER) $(PDF) &

watch:
	while [ 1 ]; do; inotifywait $(SRC) $(SVG) && make; done
