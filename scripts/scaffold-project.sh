#!/usr/bin/env bash
# scaffold-project.sh — Create Wolfram research project directory structure
#
# Usage: scaffold-project.sh <ProjectName> ["Topic"] [output-dir] ["Author Name"] ["email"]
#
# Called by Claude during computational-exploration skill execution.
# Claude handles notebook creation and paper downloading via MCP separately.
#
# output-dir:   base directory where <ProjectName>/ will be created.
#               Defaults to current directory. In Cowork mode, pass the
#               mounted workspace path (e.g. /sessions/.../mnt/MyFolder/).
# Author Name:  for \author{} in LaTeX templates. Defaults to "Author".
# email:        for \email{} in LaTeX templates. Defaults to empty.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ASSETS_DIR="$SCRIPT_DIR/../skills/computational-exploration/assets"

if [ $# -lt 1 ]; then
  echo "Usage: scaffold-project.sh <ProjectName> [\"Topic description\"] [output-dir]" >&2
  exit 1
fi

PROJECT_NAME="$1"
TOPIC_DESCRIPTION="${2:-A Wolfram model research project.}"
OUTPUT_DIR="${3:-.}"
AUTHOR_NAME="${4:-Pavel H\'ajek}"
AUTHOR_EMAIL="${5:-p135246@gmail.com}"
TODAY=$(date +%Y-%m-%d)

mkdir -p "$OUTPUT_DIR"
cd "$OUTPUT_DIR"

# ── 1. Directories ─────────────────────────────────────────────────────────

mkdir -p "$PROJECT_NAME/Code"
mkdir -p "$PROJECT_NAME/Resources"
mkdir -p "$PROJECT_NAME/Article"
echo "Created directories: $PROJECT_NAME/{Code,Resources,Article}"

# ── 2. Tools.wl ───────────────────────────────────────────────────────────

cp "$ASSETS_DIR/tools_starter.wl" "$PROJECT_NAME/Code/Tools.wl"
echo "Created: $PROJECT_NAME/Code/Tools.wl"

# ── 3. CLAUDE.md ──────────────────────────────────────────────────────────
# Topic-specific code files (<Topic>.wl, <Topic>Visualization.wl) are created
# by the add-topic skill, not by this script.

sed \
  -e "s/{{PROJECT_NAME}}/$PROJECT_NAME/g" \
  -e "s|{{TOPIC_DESCRIPTION}}|$TOPIC_DESCRIPTION|g" \
  -e "s|{{GOALS}}|1. Understand the mathematical structure of $TOPIC_DESCRIPTION\n2. Develop computational tools using Wolfram Language\n3. Connect findings to Wolfram model / hypergraph settings|g" \
  "$ASSETS_DIR/claude_template.md" > "$PROJECT_NAME/CLAUDE.md"
echo "Created: $PROJECT_NAME/CLAUDE.md"

# ── 4. article1.tex ───────────────────────────────────────────────────────

WORKING_TITLE="${PROJECT_NAME}: A Computational Study"
ABSTRACT="We investigate $TOPIC_DESCRIPTION from a discrete and combinatorial perspective, connecting classical structures to the framework of Wolfram models and hypergraph rewriting systems. This work develops computational tools in Wolfram Language and explores how standard results survive, break down, or give rise to new phenomena in the discrete setting."

sed \
  -e "s|{{TITLE}}|$WORKING_TITLE|g" \
  -e "s|{{ABSTRACT}}|$ABSTRACT|g" \
  -e "s|{{AUTHOR}}|$AUTHOR_NAME|g" \
  -e "s|{{EMAIL}}|$AUTHOR_EMAIL|g" \
  "$ASSETS_DIR/article_template.tex" > "$PROJECT_NAME/Article/article1.tex"
echo "Created: $PROJECT_NAME/Article/article1.tex"

# ── 5. notes1.tex ─────────────────────────────────────────────────────────

sed \
  -e "s|{{TITLE}}|Working Notes: $PROJECT_NAME|g" \
  -e "s|{{FIRST_TOPIC}}|$PROJECT_NAME|g" \
  -e "s|{{AUTHOR}}|$AUTHOR_NAME|g" \
  -e "s|{{EMAIL}}|$AUTHOR_EMAIL|g" \
  "$ASSETS_DIR/notes_template.tex" > "$PROJECT_NAME/Article/notes1.tex"
echo "Created: $PROJECT_NAME/Article/notes1.tex"

# ── 6. references.bib ────────────────────────────────────────────────────

cat > "$PROJECT_NAME/Article/references.bib" << EOF
% References for: $PROJECT_NAME

@misc{wolfram2020technical,
  author       = {Stephen Wolfram},
  title        = {Technical Introduction to the {W}olfram Physics Project},
  year         = {2020},
  howpublished = {\url{https://wolframphysics.org/technical-introduction/}},
  note         = {Online resource}
}

@misc{wolframsummerschool,
  author       = {{Wolfram Research}},
  title        = {Wolfram Summer School --- Community Posts},
  howpublished = {\url{https://community.wolfram.com/content?curTag=wolfram\%20summer\%20school}},
  note         = {Online community resource}
}
EOF
echo "Created: $PROJECT_NAME/Article/references.bib"

# ── 7. Summary ────────────────────────────────────────────────────────────

echo ""
echo "=== Project scaffolded: $PROJECT_NAME/ ==="
echo ""
echo "  Code/"
echo "    Tools.wl           — shared general utilities"
echo "  Resources/            — reference PDFs and notebooks (Author_Year_Title.pdf/.nb)"
echo "  Article/"
echo "    article1.tex        — LaTeX article scaffold (your writing space)"
echo "    notes1.tex          — article-form working notes (Claude writes here when asked)"
echo "    references.bib      — BibTeX with Wolfram standard references"
echo "  CLAUDE.md             — project context for future Claude sessions"
echo ""
echo "Next: Claude will run add-topic for the initial scope, then create Resources1.nb."
