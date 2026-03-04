#!/usr/bin/env bash
# check-env.sh — Verify Wolfram kernel and MCP server availability

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

ok()   { echo -e "  ${GREEN}✓${NC} $1"; }
fail() { echo -e "  ${RED}✗${NC} $1"; }
warn() { echo -e "  ${YELLOW}!${NC} $1"; }

echo ""
echo "=== Wolfram Research Environment Check ==="
echo ""

# ── 1. Wolfram kernel ──────────────────────────────────────────────────────

echo "Wolfram Kernel"

WOLFRAMSCRIPT=$(command -v wolframscript 2>/dev/null)
if [ -n "$WOLFRAMSCRIPT" ]; then
  ok "wolframscript found: $WOLFRAMSCRIPT"
  # Quick eval test
  RESULT=$(wolframscript -code "1+1" 2>/dev/null | tr -d '[:space:]')
  if [ "$RESULT" = "2" ]; then
    ok "Kernel evaluation works (1+1 = 2)"
  else
    warn "wolframscript found but evaluation returned: '$RESULT' (kernel may be starting)"
  fi
else
  fail "wolframscript not found in PATH"

  # Try alternative kernel paths
  MATH_PATHS=(
    "/usr/local/bin/math"
    "/Applications/Mathematica.app/Contents/MacOS/WolframKernel"
    "/Applications/Wolfram Engine.app/Contents/MacOS/WolframKernel"
    "$HOME/.local/bin/wolframscript"
  )
  FOUND_ALT=""
  for p in "${MATH_PATHS[@]}"; do
    if [ -x "$p" ]; then
      FOUND_ALT="$p"
      break
    fi
  done

  if [ -n "$FOUND_ALT" ]; then
    warn "Alternative kernel found at: $FOUND_ALT"
    warn "Add it to PATH or install wolframscript: https://www.wolfram.com/wolframscript/"
  else
    fail "No Wolfram kernel found. Install Wolfram Engine (free) or Mathematica."
    echo "       https://www.wolfram.com/engine/"
  fi
fi

echo ""

# ── 2. Wolfram MCP server ──────────────────────────────────────────────────

echo "Wolfram MCP Server"

MCP_FOUND=0

# Check for wolfram-mcp npm package (global)
if command -v npm &>/dev/null; then
  NPM_LIST=$(npm list -g --depth=0 2>/dev/null)
  if echo "$NPM_LIST" | grep -q "wolfram-mcp"; then
    ok "Wolfram MCP npm package installed (global)"
    MCP_FOUND=1
  fi
fi

# Check common MCP server binary locations
MCP_BINS=(
  "wolfram-mcp-server"
  "wolfram-mcp"
)
for bin in "${MCP_BINS[@]}"; do
  BIN_PATH=$(command -v "$bin" 2>/dev/null)
  if [ -n "$BIN_PATH" ]; then
    ok "MCP server binary found: $BIN_PATH"
    MCP_FOUND=1
  fi
done

# Check Claude MCP config files for wolfram entries
MCP_CONFIGS=(
  "$HOME/.claude/mcp_servers.json"
  "$HOME/.claude/settings.json"
  "./.mcp.json"
  ".claude/settings.json"
)
for cfg in "${MCP_CONFIGS[@]}"; do
  if [ -f "$cfg" ] && grep -qi "wolfram" "$cfg" 2>/dev/null; then
    ok "Wolfram MCP entry found in: $cfg"
    MCP_FOUND=1
  fi
done

if [ "$MCP_FOUND" -eq 0 ]; then
  fail "Wolfram MCP server not detected"
  warn "Install: https://github.com/WolframResearch/wolfram-mcp"
  warn "Or check /mcp inside Claude to see active MCP servers"
else
  ok "To confirm MCP is active in this session, run /mcp inside Claude"
fi

echo ""

# ── 3. Summary ─────────────────────────────────────────────────────────────

echo "=== Summary ==="
if [ -n "$WOLFRAMSCRIPT" ] && [ "$RESULT" = "2" ] && [ "$MCP_FOUND" -eq 1 ]; then
  echo -e "  ${GREEN}Environment ready for Wolfram research.${NC}"
elif [ -n "$WOLFRAMSCRIPT" ] && [ "$MCP_FOUND" -eq 0 ]; then
  echo -e "  ${YELLOW}Kernel available, but MCP server not detected.${NC}"
  echo "  Notebook creation via MCP will fall back to ExportString mode."
elif [ -z "$WOLFRAMSCRIPT" ] && [ "$MCP_FOUND" -eq 1 ]; then
  echo -e "  ${YELLOW}MCP server available, but wolframscript not in PATH.${NC}"
  echo "  Direct kernel evaluation commands will not work."
else
  echo -e "  ${RED}Environment incomplete. See details above.${NC}"
fi
echo ""
