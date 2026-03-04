Run `${CLAUDE_PLUGIN_ROOT}/scripts/check-env.sh` using the Bash tool and display the full output.

Then, **always** test MCP availability directly by calling `mcp__wolfram__ping`.
This is the authoritative test — in Cowork/remote environments the MCP is available
as a remote tool and will not be detected by the shell script.

After showing the output, summarize:
1. Whether the Wolfram kernel is available and working
2. Whether the Wolfram MCP server is detected (locally via script **and** remotely via ping)
3. Whether this appears to be a **Cowork environment** (MCP ping succeeds but script
   reports no local MCP; or working directory contains `/sessions/` or `/mnt/`)
4. What to do if anything is missing (include the exact install URL if relevant)

If both kernel and MCP are available, confirm the environment is ready for Wolfram
research. If Cowork mode is detected, note that notebook creation will use the
ExportString fallback (MCP cannot write to the mounted filesystem).
