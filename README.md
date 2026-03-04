# computational-research

A Claude Code plugin for Wolfram computational research. Scaffolds research projects,
creates Mathematica notebooks, manages papers, and handles LaTeX notes — all with full
Wolfram MCP integration.

## Requirements

- [Claude Code](https://claude.ai/claude-code) v1.0.33+
- [Wolfram Engine](https://www.wolfram.com/engine/) or Mathematica (for notebook creation)
- [wolframscript](https://www.wolfram.com/wolframscript/) in PATH
- [Wolfram MCP server](https://github.com/WolframResearch/wolfram-mcp) (local)

## Installation

```bash
claude plugin install computational-research
```

Or load locally for development:

```bash
claude --plugin-dir /path/to/WolframComputationalResearch
```

## Slash commands

| Command | Description |
|---------|-------------|
| `/computational-research:check-env` | Check Wolfram kernel and MCP server availability |
| `/computational-research:new-project [name or topic]` | Scaffold a new research project |
| `/computational-research:add-paper [arXiv ID or query]` | Add a paper to the current project |
| `/computational-research:load-project [path]` | Summarize current project status and suggest next steps |

## Skills (Claude invokes automatically)

### `wolfram-research-project`

Scaffolds a complete research project:

```
ProjectName/
├── CLAUDE.md                  ← project memory
├── ProjectName1.nb            ← first Mathematica notebook
├── Papers1.nb                 ← paper summaries
├── Code/
│   ├── Tools.wl               ← graph utilities
│   └── ProjectName.wl         ← main code
├── Papers/                    ← PDFs (Author_Year_Title.pdf)
└── Notes/
    ├── article1.tex           ← your LaTeX article
    ├── notes1.tex             ← Claude's notes (written on request)
    └── references.bib
```

Trigger phrases: "new project on X", "start a project about Y", "scaffold Z".

### `wolfram-notebook`

Creates `.nb` files from structured Markdown via the Wolfram MCP's
`ExportString[ImportString[md, {"Markdown","Notebook"}], "NB"]` pipeline.
Handles backtick escaping, initialization cells, and all Wolfram cell styles.

Trigger phrases: "create a notebook", "make a .nb for X", "put this in a notebook".

## Scripts

| Script | Description |
|--------|-------------|
| `scripts/check-env.sh` | Checks kernel (wolframscript eval) and MCP server installation |
| `scripts/scaffold-project.sh <Name> "topic"` | Creates directory structure and all text files |

The scaffold script is called by Claude during project creation; the check-env
script is invoked by `/computational-research:check-env`.

## Conventions

- **Notes versioning**: `notes1.tex` → `notes2.tex` when it exceeds ~300 lines of content
- **Paper naming**: `Author_Year_Title.pdf` in `Papers/`
- **Paper summaries**: always in `Papers1.nb` (never as separate .md files)
- **Writing to notes**: only when explicitly asked ("note this", "write this down")
- **Article file**: `article1.tex` is your writing space — Claude doesn't touch it

## License

MIT
