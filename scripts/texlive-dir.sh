# Location of the project-scoped TeX Live installation.
#
# NOTE: minted v3's latexrestricted security layer refuses to run when the TeX
# binaries are located under the directory the document is compiled in, so the
# installation must live OUTSIDE the project tree. Override with TL_DIR.

export TL_DIR="${TL_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/texlive-projects/reinforcement-learning-legged-robots}"
