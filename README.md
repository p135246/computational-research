# computational-research

A Claude Code plugin for Wolfram computational research. Scaffolds research projects,
creates Mathematica notebooks, manages papers, and handles LaTeX notes — all with full
Wolfram MCP integration.

## Requirements

- [Claude Code](https://claude.ai/claude-code) v1.0.33+ (or Claude Desktop with Cowork)
- [Wolfram Engine](https://www.wolfram.com/engine/) or Mathematica
- [wolframscript](https://www.wolfram.com/wolframscript/) in PATH

### MCP servers

This plugin relies on four MCP servers. They must be installed and configured
manually — Claude Code/Desktop does not auto-install MCP dependencies from plugins.

| Server | Purpose | Source |
|--------|---------|--------|
| **Wolfram** (official) | Wolfram Language evaluation | Wolfram paclet `Wolfram/MCPServer` (ships with Mathematica 14.2+) |
| **wolfram** (unofficial) | Notebook creation and editing | [sw1sh/WolframMCP](https://github.com/sw1sh/WolframMCP) |
| **arxiv** | Search and download arXiv papers | [blazickjp/arxiv-mcp-server](https://github.com/blazickjp/arxiv-mcp-server) |
| **arxiv-latex-mcp** | Read LaTeX source of arXiv papers | [takashiishida/arxiv-latex-mcp](https://github.com/takashiishida/arxiv-latex-mcp) |

You need **at least one** Wolfram MCP (official or unofficial). The unofficial one
is required for notebook creation/editing; the official one suffices for evaluation only.
Both arXiv servers are needed for the full paper management workflow.

<details>
<summary><strong>Installation instructions</strong></summary>

#### Wolfram MCP (official)

Runs directly from the Wolfram kernel as a paclet. No separate install needed if
you have Mathematica 14.2+. Add to your Claude config:

```json
"Wolfram": {
  "command": "/Applications/Wolfram.app/Contents/MacOS/wolfram",
  "args": ["-run", "PacletSymbol[\"Wolfram/MCPServer\",\"Wolfram`MCPServer`StartMCPServer\"][]", "-noinit", "-noprompt"],
  "env": {
    "MCP_SERVER_NAME": "Wolfram"
  }
}
```

#### Wolfram MCP (unofficial)

```bash
git clone https://github.com/sw1sh/WolframMCP.git
cd WolframMCP
python -m venv .venv && source .venv/bin/activate
pip install -e .
```

```json
"wolfram": {
  "command": "/path/to/.venv/bin/python",
  "args": ["-m", "wolfram_mcp.server", "--kernel-path", "/Applications/Wolfram.app/Contents/MacOS/WolframKernel", "--transport", "stdio"],
  "env": { "PYTHONUNBUFFERED": "1" }
}
```

#### arXiv MCP

```bash
pip install arxiv-mcp-server
```

```json
"arxiv": {
  "command": "arxiv-mcp-server",
  "args": ["--storage-path", "/path/to/ArxivPapers"],
  "env": { "PYTHONUNBUFFERED": "1" }
}
```

#### arXiv LaTeX MCP

```bash
git clone https://github.com/takashiishida/arxiv-latex-mcp.git
cd arxiv-latex-mcp
uv sync
```

```json
"arxiv-latex-mcp": {
  "command": "uv",
  "args": ["--directory", "/path/to/arxiv-latex-mcp", "run", "server/main.py"],
  "env": { "PYTHONUNBUFFERED": "1" }
}
```

</details>

Also works in **Cowork mode** (remote VM with mounted workspace) — the skill
automatically detects the environment and adapts notebook creation and file paths.

## Installation

**Claude Desktop (Cowork tab)**:
1. Download [`computational-research.zip`](computational-research.zip)
2. Open Claude Desktop → Cowork tab → Customize → upload the zip file

**Claude Code CLI — from the marketplace**:
```bash
claude plugin marketplace add p135246/claude-plugins
claude plugin install computational-research@p135246
```

**Claude Code CLI — direct load** (local development or offline):
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

### `computational-research`

Scaffolds a complete research project:

```
ProjectName/
├── CLAUDE.md                             ← project memory
├── ProjectName1.nb                       ← first Mathematica notebook
├── Papers1.nb                            ← paper summaries
├── Code/
│   ├── Tools.wl                          ← shared general utilities
│   ├── ProjectName.wl                    ← core functions (initial scope)
│   └── ProjectNameVisualization.wl       ← visualization (initial scope)
├── Papers/                               ← PDFs (Author_Year_Title.pdf)
└── Article/
    ├── article1.tex                      ← your LaTeX article (you write here)
    ├── notes1.tex                        ← working notes (Claude writes; source for article)
    └── references.bib
```

Trigger phrases: "new project on X", "start a project about Y", "scaffold Z".

### `create-notebook`

Creates `.nb` files from structured Markdown via the Wolfram MCP's
`ExportString[ImportString[md, {"Markdown","Notebook"}], "NB"]` pipeline.
Handles backtick escaping, initialization cells, and all Wolfram cell styles.

Trigger phrases: "create a notebook", "make a .nb for X", "put this in a notebook".

## Scripts

| Script | Description |
|--------|-------------|
| `scripts/check-env.sh` | Checks kernel (wolframscript eval) and MCP server installation |
| `scripts/scaffold-project.sh <Name> "topic" [output-dir] ["Author"] ["email"]` | Creates directory structure and all text files |

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
