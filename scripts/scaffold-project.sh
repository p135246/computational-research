#!/usr/bin/env bash
# scaffold-project.sh — Create Wolfram research project directory structure
#
# Usage: scaffold-project.sh <ProjectName> ["Topic description"]
#
# Called by Claude during computational-research skill execution.
# Claude handles notebook creation and paper downloading via MCP separately.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ASSETS_DIR="$SCRIPT_DIR/../skills/computational-research/assets"

if [ $# -lt 1 ]; then
  echo "Usage: scaffold-project.sh <ProjectName> [\"Topic description\"]" >&2
  exit 1
fi

PROJECT_NAME="$1"
TOPIC_DESCRIPTION="${2:-A Wolfram model research project.}"
TODAY=$(date +%Y-%m-%d)

# ── 1. Directories ─────────────────────────────────────────────────────────

mkdir -p "$PROJECT_NAME/Code"
mkdir -p "$PROJECT_NAME/Papers"
mkdir -p "$PROJECT_NAME/Notes"
echo "Created directories: $PROJECT_NAME/{Code,Papers,Notes}"

# ── 2. Tools.wl ───────────────────────────────────────────────────────────

cp "$ASSETS_DIR/tools_starter.wl" "$PROJECT_NAME/Code/Tools.wl"
echo "Created: $PROJECT_NAME/Code/Tools.wl"

# ── 3. ScopeName.wl + ScopeNameVisualization.wl stubs ────────────────────
# Initial scope name = project name. New scopes get their own Name.wl +
# NameVisualization.wl pair as the project grows.

cat > "$PROJECT_NAME/Code/$PROJECT_NAME.wl" << EOF
(* ::Package:: *)
(* $PROJECT_NAME.wl — Core functions for $TOPIC_DESCRIPTION *)
(* Load with: Get["Code/$PROJECT_NAME.wl"] *)
EOF
echo "Created: $PROJECT_NAME/Code/$PROJECT_NAME.wl"

cat > "$PROJECT_NAME/Code/${PROJECT_NAME}Visualization.wl" << EOF
(* ::Package:: *)
(* ${PROJECT_NAME}Visualization.wl — Visualization functions for $TOPIC_DESCRIPTION *)
(* Load with: Get["Code/${PROJECT_NAME}Visualization.wl"] *)
EOF
echo "Created: $PROJECT_NAME/Code/${PROJECT_NAME}Visualization.wl"

# ── 4. CLAUDE.md ──────────────────────────────────────────────────────────

sed \
  -e "s/{{PROJECT_NAME}}/$PROJECT_NAME/g" \
  -e "s|{{TOPIC_DESCRIPTION}}|$TOPIC_DESCRIPTION|g" \
  -e "s|{{GOALS}}|1. Understand the mathematical structure of $TOPIC_DESCRIPTION\n2. Develop computational tools using Wolfram Language\n3. Connect findings to Wolfram model / hypergraph settings|g" \
  "$ASSETS_DIR/claude_template.md" > "$PROJECT_NAME/CLAUDE.md"
echo "Created: $PROJECT_NAME/CLAUDE.md"

# ── 5. article1.tex ───────────────────────────────────────────────────────

WORKING_TITLE="${PROJECT_NAME}: A Computational Study"
ABSTRACT="We investigate $TOPIC_DESCRIPTION from a discrete and combinatorial perspective, connecting classical structures to the framework of Wolfram models and hypergraph rewriting systems. This work develops computational tools in Wolfram Language and explores how standard results survive, break down, or give rise to new phenomena in the discrete setting."

sed \
  -e "s|{{TITLE}}|$WORKING_TITLE|g" \
  -e "s|{{ABSTRACT}}|$ABSTRACT|g" \
  -e "s|{{CORE_SECTION_TITLE}}|${PROJECT_NAME} on graphs and hypergraphs|g" \
  "$ASSETS_DIR/article_template.tex" > "$PROJECT_NAME/Notes/article1.tex"
echo "Created: $PROJECT_NAME/Notes/article1.tex"

# ── 6. notes1.tex ─────────────────────────────────────────────────────────

sed \
  -e "s|{{TITLE}}|Working Notes: $PROJECT_NAME|g" \
  -e "s|{{ABSTRACT}}|Article-form working notes for the $PROJECT_NAME project ($TOPIC_DESCRIPTION). Written by Claude when asked; serves as source material for article1.tex.|g" \
  -e "s|{{CORE_SECTION_TITLE}}|Observations|g" \
  "$ASSETS_DIR/article_template.tex" > "$PROJECT_NAME/Notes/notes1.tex"
echo "Created: $PROJECT_NAME/Notes/notes1.tex"

# ── 7. references.bib ────────────────────────────────────────────────────

cat > "$PROJECT_NAME/Notes/references.bib" << 'EOF'
% References for: PROJECT_NAME

@book{wolfram2020,
  author    = {Stephen Wolfram},
  title     = {A Project to Find the Fundamental Theory of Physics},
  publisher = {Wolfram Media},
  year      = {2020}
}

@article{gorard2020,
  author  = {Jonathan Gorard},
  title   = {Some Quantum Mechanical Properties of the {W}olfram Model},
  journal = {Complex Systems},
  volume  = {29},
  pages   = {537--598},
  year    = {2020}
}
EOF
sed -i '' "s/PROJECT_NAME/$PROJECT_NAME/g" "$PROJECT_NAME/Notes/references.bib"
echo "Created: $PROJECT_NAME/Notes/references.bib"

# ── 8. Summary ────────────────────────────────────────────────────────────

echo ""
echo "=== Project scaffolded: $PROJECT_NAME/ ==="
echo ""
echo "  Code/"
echo "    Tools.wl                        — shared general utilities"
echo "    $PROJECT_NAME.wl               — core functions (initial scope, empty)"
echo "    ${PROJECT_NAME}Visualization.wl — visualization (initial scope, empty)"
echo "  Papers/             — reference PDFs (Author_Year_Title.pdf)"
echo "  Notes/"
echo "    article1.tex      — LaTeX article scaffold (your writing space)"
echo "    notes1.tex        — article-form working notes (Claude writes here when asked)"
echo "    references.bib    — BibTeX with Wolfram standard references"
echo "  CLAUDE.md           — project context for future Claude sessions"
echo ""
echo "Next: Claude will create $PROJECT_NAME/1.nb and Papers1.nb via Wolfram MCP."
